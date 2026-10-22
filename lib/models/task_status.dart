/// Lifecycle state of a [Task].
///
/// Stored in SQLite as its `.name` (e.g. 'onReview'), not an int index, so
/// the column stays readable in the DB and safe to reorder in code without
/// corrupting existing rows.
///
/// Two different controls can change this:
/// - The quick-toggle checkbox/button (list screens, task detail) — a
///   fast one-tap action restricted by role; see `task_permissions.dart`.
///   It only ever lands on [pending], [onReview], or [completed].
/// - The status dropdown in the task editor (assigner only) — a full
///   manual override across all six values.
enum TaskStatus {
  assigned,
  working,
  pending,
  onReview,
  completed,
  toBeRedone,
}

extension TaskStatusLabel on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.working:
        return 'Working';
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.onReview:
        return 'On Review';
      case TaskStatus.completed:
        return 'Complete';
      case TaskStatus.toBeRedone:
        return 'To be redone';
    }
  }
}
