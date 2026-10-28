import '../l10n/generated/app_localizations.dart';

/// Lifecycle state of a [Task].
///
/// Stored *locally* in SQLite as its `.name` (e.g. 'onReview'), not an
/// int index, so that column stays readable and safe to reorder here
/// without corrupting existing rows.
///
/// The *server* (TaskTracker.Domain.Enums.TaskStatus) stores and
/// transmits this as a plain integer ordinal, and `Task.fromServerJson`/
/// `toServerRequestBody` rely on `.index` matching it position-for
/// -position. The two declarations must stay in the same order —
/// reordering only one side will silently reinterpret every task's
/// status as the wrong value.
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
  /// Display label, localized — takes [l10n] rather than being a plain
  /// getter since the text now depends on the app's current language.
  String label(AppLocalizations l10n) {
    switch (this) {
      case TaskStatus.assigned:
        return l10n.taskStatusAssigned;
      case TaskStatus.working:
        return l10n.taskStatusWorking;
      case TaskStatus.pending:
        return l10n.taskStatusPending;
      case TaskStatus.onReview:
        return l10n.taskStatusOnReview;
      case TaskStatus.completed:
        return l10n.taskStatusCompleted;
      case TaskStatus.toBeRedone:
        return l10n.taskStatusToBeRedone;
    }
  }
}
