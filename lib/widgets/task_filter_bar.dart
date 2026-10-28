import 'package:flutter/material.dart';

import '../models/task.dart';

/// One entry in the horizontal filter bar.
///
/// `assignment == null` means "an 'All' chip" or a category chip —
/// anything that isn't filtering by [TaskAssignment].
class TaskFilter {
  final String label;
  final TaskAssignment? assignment;
  final String? category;

  const TaskFilter.all(this.label)
      : assignment = null,
        category = null;

  /// Tasks delegated to the current user by someone else.
  const TaskFilter.assignedToMe(this.label)
      : assignment = TaskAssignment.assignedToMe,
        category = null;

  /// Tasks the current user created/owns (self tasks and ones delegated
  /// to someone else).
  const TaskFilter.mine(this.label)
      : assignment = TaskAssignment.mine,
        category = null;

  const TaskFilter.category(this.category, this.label) : assignment = null;

  bool matches(Task task, String currentUserId) {
    if (assignment != null) return task.assignmentFor(currentUserId) == assignment;
    if (category != null) return task.categories.contains(category);
    return true; // "All"
  }

  // Deliberately excludes [label] — it's just display text, now
  // localized at construction time (see callers), so the same logical
  // filter built under two different languages must still compare equal
  // (e.g. a filter selection persisted across a language change).
  @override
  bool operator ==(Object other) =>
      other is TaskFilter && other.assignment == assignment && other.category == category;

  @override
  int get hashCode => Object.hash(assignment, category);
}

/// Horizontally scrollable row of filter chips sitting at the top of the
/// Tasks screen.
///
/// Today this mixes two kinds of filters — assignment (Assigned to me /
/// Mine) and category — in a single row, separated by a divider. This is
/// intentionally simple for now; as the idea gets expanded (e.g. separate
/// rows, multi-select categories, saved filter sets) this widget is the
/// place to grow.
class TaskFilterBar extends StatelessWidget {
  final List<TaskFilter> filters;
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  const TaskFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) {
          // Visually split the assignment group from the category group.
          final isGroupBoundary = filters[index].category == null &&
              index + 1 < filters.length &&
              filters[index + 1].category != null;
          if (isGroupBoundary) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: VerticalDivider(width: 1, indent: 8, endIndent: 8),
            );
          }
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}
