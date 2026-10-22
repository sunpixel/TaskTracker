/// Returns an error message if [dueAt] isn't valid relative to
/// [createdAt], or `null` if it's fine. A task may have no due date at
/// all — pass `null` to mean that.
///
/// Rule: when a due date is set, it must be at least a minute after the
/// creation time — mostly to rule out due-in-the-past or due-immediately
/// tasks that can't realistically be acted on.
String? validateDueDate({required DateTime createdAt, required DateTime? dueAt}) {
  if (dueAt == null) return null;
  final earliestAllowedDue = createdAt.add(const Duration(minutes: 1));
  if (dueAt.isBefore(earliestAllowedDue)) {
    return 'Due time must be at least a minute after the creation time.';
  }
  return null;
}

/// A task must always have a (non-blank) name.
String? validateTitle(String title) {
  if (title.trim().isEmpty) return 'Task name is required.';
  return null;
}
