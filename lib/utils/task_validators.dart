/// A problem with a task's due date, returned instead of an English
/// message so the UI layer (which has a `BuildContext`/`AppLocalizations`)
/// decides how to phrase it — mirrors `CalendarAddOutcome`'s pattern.
enum DueDateError { tooSoonAfterCreation }

/// Returns a [DueDateError] if [dueAt] isn't valid relative to
/// [createdAt], or `null` if it's fine. A task may have no due date at
/// all — pass `null` to mean that.
///
/// Rule: when a due date is set, it must be at least a minute after the
/// creation time — mostly to rule out due-in-the-past or due-immediately
/// tasks that can't realistically be acted on.
DueDateError? validateDueDate({required DateTime createdAt, required DateTime? dueAt}) {
  if (dueAt == null) return null;
  final earliestAllowedDue = createdAt.add(const Duration(minutes: 1));
  if (dueAt.isBefore(earliestAllowedDue)) return DueDateError.tooSoonAfterCreation;
  return null;
}

enum TitleError { empty }

/// A task must always have a (non-blank) name.
TitleError? validateTitle(String title) {
  if (title.trim().isEmpty) return TitleError.empty;
  return null;
}
