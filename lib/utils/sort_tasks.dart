import '../models/task.dart';

/// Sorts [tasks] by urgency: the closer the deadline, the higher up the
/// list. Tasks with no due date carry no deadline pressure, so they sort
/// last, in the order they were created.
List<Task> sortByDeadline(List<Task> tasks) {
  final sorted = List<Task>.of(tasks);
  sorted.sort((a, b) {
    final aDue = a.dueAt;
    final bDue = b.dueAt;
    if (aDue == null && bDue == null) return a.createdAt.compareTo(b.createdAt);
    if (aDue == null) return 1;
    if (bDue == null) return -1;
    return aDue.compareTo(bDue);
  });
  return sorted;
}
