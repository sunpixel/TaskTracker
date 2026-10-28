import 'package:flutter/material.dart';

import '../data/task_store.dart';
import '../data/task_store_scope.dart';
import '../data/user_store_scope.dart';
import '../models/task.dart';
import '../navigation/app_nav_controller.dart';
import '../navigation/app_nav_scope.dart';
import '../utils/sort_tasks.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import 'task_detail_screen.dart';

/// Full task list with the horizontal filter bar on top.
///
/// Filtering is intentionally simple right now: one active filter at a
/// time, mixing assignment ("Assigned to me" / "Mine") and category into a
/// single row. This is the first iteration — multi-select, search, and
/// sorting are natural next steps once the design settles.
///
/// Split into two collapsible sections rather than one flat list: a
/// single by-deadline sort across *all* tasks put newly-created,
/// no-due-date tasks below every completed task that happened to have
/// one, which read as broken. Current and completed tasks now have their
/// own sort entirely, so that can't happen.
///
/// Pull-to-refresh here is one of the three sync triggers (alongside
/// right-after-any-push and the 10-minute timer) — see `TaskStore`.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _selected = const TaskFilter.all();
  AppNavController? _navController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pick up a filter requested from Home's summary cards (see
    // AppNavController.goToTasksTab). This screen stays alive in the
    // IndexedStack, so the listener added here persists across tab
    // switches without being re-added.
    final controller = AppNavScope.of(context);
    if (_navController != controller) {
      _navController?.removeListener(_handleNavChange);
      _navController = controller;
      _navController!.addListener(_handleNavChange);
      _applyPendingFilter();
    }
  }

  @override
  void dispose() {
    _navController?.removeListener(_handleNavChange);
    super.dispose();
  }

  void _handleNavChange() {
    _applyPendingFilter();
    setState(() {}); // also covers the back-button visibility changing
  }

  void _applyPendingFilter() {
    final filter = _navController?.consumePendingTasksFilter();
    if (filter != null) {
      setState(() => _selected = filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = TaskStoreScope.of(context);
    final nav = AppNavScope.of(context);
    final currentUserId = UserStoreScope.of(context).effectiveUserId;

    if (store.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allTasks = store.tasks;
    final categories = allTasks.expand((t) => t.categories).toSet().toList()..sort();
    final filters = [
      const TaskFilter.all(),
      const TaskFilter.assignedToMe(),
      const TaskFilter.mine(),
      for (final category in categories) TaskFilter.category(category, category),
    ];

    final filtered = allTasks.where((t) => _selected.matches(t, currentUserId)).toList();

    // Same sort as Home for current tasks (soonest deadline first).
    final current = sortByDeadline(filtered.where((t) => !t.isCompleted).toList());

    // Completed tasks aren't ranked by deadline at all — most recently
    // completed first. There's no dedicated "completed at" timestamp;
    // `updatedAt` is a reliable stand-in here since completing a task is
    // itself the edit that bumps it.
    final completed = filtered.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: nav.tasksTabHasBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => nav.setTabIndex(0),
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: TaskFilterBar(
              filters: filters,
              selected: _selected,
              onSelected: (filter) => setState(() => _selected = filter),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: store.pullFromServer,
              child: filtered.isEmpty
                  ? ListView(
                      // A plain Center() can't be pulled-to-refresh —
                      // RefreshIndicator needs a scrollable child even
                      // for the empty state.
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No tasks match this filter.')),
                      ],
                    )
                  : ListView(
                      children: [
                        _TaskSection(
                          title: 'Current Tasks',
                          tasks: current,
                          currentUserId: currentUserId,
                          store: store,
                          initiallyExpanded: true,
                          emptyLabel: 'Nothing current.',
                        ),
                        _TaskSection(
                          title: 'Completed Tasks',
                          tasks: completed,
                          currentUserId: currentUserId,
                          store: store,
                          initiallyExpanded: false,
                          emptyLabel: 'Nothing completed yet.',
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TaskDetailScreen(taskId: null)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final String currentUserId;
  final TaskStore store;
  final bool initiallyExpanded;
  final String emptyLabel;

  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.currentUserId,
    required this.store,
    required this.initiallyExpanded,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Row(
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('${tasks.length}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
      children: tasks.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emptyLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ]
          : [
              for (final task in tasks)
                TaskCard(
                  task: task,
                  currentUserId: currentUserId,
                  onToggle: () => store.quickToggle(task),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
                  ),
                ),
              const SizedBox(height: 4),
            ],
    );
  }
}
