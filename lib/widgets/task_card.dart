import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/date_format.dart';
import '../utils/task_permissions.dart';
import '../utils/task_urgency.dart';

/// A single row in a task list.
///
/// Background color signals how pressing the deadline is — see
/// `task_urgency.dart` — so it's set directly on the [Card], overriding
/// the theme's usual surface color except for [TaskUrgency.normal], which
/// falls back to it.
class TaskCard extends StatelessWidget {
  final Task task;

  /// Called when the quick-toggle checkbox is tapped. What it actually
  /// does depends on the current user's role on the task — see
  /// `task_permissions.dart` — so this is a plain trigger, not a value
  /// callback; the caller (via `TaskStore.quickToggle`) decides the result.
  final VoidCallback? onToggle;

  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgency = urgencyOf(task);
    final colors = urgencyColors(urgency, theme.brightness);
    final showStatusChip = task.status != TaskStatus.pending && task.status != TaskStatus.completed;

    return Card(
      color: colors?.background,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          tristate: true,
          value: quickToggleValue(task),
          onChanged: onToggle == null ? null : (_) => onToggle!(),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: colors?.onBackground ??
                (task.isCompleted
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors?.onBackground),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final category in task.categories) _Tag(category, colors),
                if (showStatusChip) _Tag(task.status.label, colors),
                Icon(Icons.schedule, size: 14, color: colors?.onBackground ?? theme.colorScheme.onSurfaceVariant),
                Text(
                  task.dueAt == null ? 'No due date' : formatDateTime(task.dueAt!),
                  style: theme.textTheme.bodySmall?.copyWith(color: colors?.onBackground),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final TaskUrgencyColors? colors;

  const _Tag(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: colors?.onBackground.withValues(alpha: 0.15),
      labelStyle: colors == null ? null : TextStyle(color: colors!.onBackground),
    );
  }
}
