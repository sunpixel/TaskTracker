import 'package:flutter/material.dart';

import '../models/task.dart';

/// A single row in the task list.
class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onToggleCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue =
        !task.completed && task.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.completed,
          onChanged: onToggleCompleted,
        ),
        title: Text(
          task.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
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
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(task.category),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: isOverdue
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                Text(
                  _formatDueDate(task.dueDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }
    if (difference.inHours < 24) {
      return 'Due in ${difference.inHours}h';
    }
    return 'Due in ${difference.inDays}d';
  }
}
