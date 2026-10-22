import 'package:flutter/material.dart';

import '../data/current_user.dart';
import '../data/task_store.dart';
import '../data/task_store_scope.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/calendar_service.dart';
import '../utils/date_format.dart';
import '../utils/task_permissions.dart';
import '../utils/task_validators.dart';
import '../widgets/category_chips_editor.dart';

/// Single screen for viewing, creating, and editing a task.
///
/// - `taskId == null`: creating a new task — always editable.
/// - An existing task: editable only by its assigner (`canEdit`); anyone
///   else gets a read-only view plus the quick-toggle action.
///
/// Pushed within the current tab's own [Navigator] (see `MainScaffold`),
/// so the bottom nav bar stays visible and the back arrow returns to
/// wherever this was opened from.
class TaskDetailScreen extends StatefulWidget {
  final int? taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _initialized = false;
  bool _saving = false;

  Task? _original;
  late DateTime _createdAt;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;
  late TextEditingController _assignerController;
  DateTime? _dueAt;
  TaskStatus _status = TaskStatus.assigned;
  List<String> _categories = [];

  bool get _isNew => widget.taskId == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final task = _isNew ? null : TaskStoreScope.of(context).byId(widget.taskId!);
    _original = task;
    _createdAt = task?.createdAt ?? DateTime.now();
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _assigneeController =
        TextEditingController(text: task?.assignee ?? (_isNew ? currentUserId : ''));
    _assignerController =
        TextEditingController(text: task?.assigner ?? (_isNew ? currentUserId : ''));
    _dueAt = task?.dueAt;
    _status = task?.status ?? TaskStatus.assigned;
    _categories = List.of(task?.categories ?? const []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    _assignerController.dispose();
    super.dispose();
  }

  bool get _editable => _isNew || (_original != null && canEdit(_original!));

  /// The task as currently drafted on screen — used both to save and to
  /// feed role-based logic (quick-toggle, Add to Calendar) that needs a
  /// [Task], even before anything is persisted.
  Task _draftTask() => Task(
        id: _original?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: _createdAt,
        dueAt: _dueAt,
        assignee: _assigneeController.text.trim().isEmpty ? null : _assigneeController.text.trim(),
        assigner: _assignerController.text.trim().isEmpty ? null : _assignerController.text.trim(),
        status: _status,
        categories: _categories,
      );

  Future<void> _save(TaskStore store) async {
    final draft = _draftTask();
    final titleError = validateTitle(draft.title);
    if (titleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(titleError)));
      return;
    }
    final dueError = validateDueDate(createdAt: draft.createdAt, dueAt: draft.dueAt);
    if (dueError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dueError)));
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isNew) {
        await store.createTask(draft);
      } else {
        await store.updateTask(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Quick-toggle in edit mode only adjusts the local draft — it's folded
  /// into the same explicit Save as everything else. In read-only/view
  /// mode (not editing) it persists immediately via the store, since
  /// that's the only action available there.
  void _handleQuickToggleEditable() {
    setState(() => _status = nextStatusOnQuickToggle(_draftTask()));
  }

  Future<void> _handleAddToCalendar() async {
    final outcome = await addTaskToCalendar(_draftTask());
    if (!mounted) return;
    final message = switch (outcome) {
      CalendarAddOutcome.added => 'Opened in your calendar app.',
      CalendarAddOutcome.noDueDate => 'Set a due date first.',
      CalendarAddOutcome.unsupportedPlatform =>
        'Adding to calendar isn\'t supported on this platform yet.',
      CalendarAddOutcome.failed => 'Could not add this to your calendar.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? now),
    );
    if (time == null) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = TaskStoreScope.of(context);
    final theme = Theme.of(context);

    if (!_isNew && _original == null) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Task')),
        body: const Center(child: Text('This task no longer exists.')),
      );
    }

    final editable = _editable;
    final draft = _draftTask();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isNew ? 'New task' : _titleController.text,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (editable) ...[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task name'),
              onChanged: (_) => setState(() {}), // keeps the AppBar title live
            ),
            const SizedBox(height: 16),
          ],
          CategoryChipsEditor(
            categories: _categories,
            editable: editable,
            onChanged: (value) => setState(() => _categories = value),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('Description', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          editable
              ? TextField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  _descriptionController.text.isEmpty
                      ? 'No description.'
                      : _descriptionController.text,
                ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 12),
          _InfoColumns(
            columns: [
              ('Created', Text(formatDateTime(_createdAt))),
              (
                'Due',
                editable
                    ? _DueDateField(value: _dueAt, onTap: _pickDueDate, onClear: () => setState(() => _dueAt = null))
                    : Text(
                        _dueAt == null ? 'No due date' : formatDateTime(_dueAt!),
                        style: TextStyle(color: draft.isOverdue ? theme.colorScheme.error : null),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoColumns(
            columns: [
              ('Assigner', _PersonCell(controller: editable ? _assignerController : null, fallback: _assignerController.text)),
              ('Assignee', _PersonCell(controller: editable ? _assigneeController : null, fallback: _assigneeController.text)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _dueAt == null ? null : _handleAddToCalendar,
              icon: const Icon(Icons.event_available),
              label: const Text('Add to calendar'),
            ),
          ),
          const SizedBox(height: 20),
          if (editable) ...[
            Text('Status', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<TaskStatus>(
              initialValue: _status,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: [
                for (final s in TaskStatus.values) DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: editable
                ? _handleQuickToggleEditable
                : () => store.quickToggle(_original!),
            icon: const Icon(Icons.check),
            label: Text(quickToggleActionLabel(draft)),
          ),
          if (editable) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : () => _save(store),
                child: Text(_isNew ? 'Create task' : 'Save changes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoColumns extends StatelessWidget {
  final List<(String, Widget)> columns;

  const _InfoColumns({required this.columns});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, child) in columns)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  child,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DueDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DueDateField({required this.value, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(value == null ? 'Tap to set' : formatDateTime(value!)),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

/// Shows a circular avatar (initials, as a placeholder) above the
/// person's id — or a text field to edit it, when editable.
class _PersonCell extends StatelessWidget {
  final TextEditingController? controller;
  final String fallback;

  const _PersonCell({required this.controller, required this.fallback});

  static String _initialsFor(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller ?? ValueNotifier(TextEditingValue(text: fallback)),
      builder: (context, value, _) => CircleAvatar(
        radius: 14,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          _initialsFor(value.text),
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(height: 4),
        if (controller != null)
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          Text(fallback.isEmpty ? '—' : fallback),
      ],
    );
  }
}
