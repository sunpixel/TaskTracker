import '../models/task.dart';
import '../models/task_status.dart';
import 'current_user.dart';

const _alex = 'alex'; // placeholder teammate id, for demo variety only.

/// Demo data so the app has something to show before real task creation
/// exists. Safe to delete once that's no longer needed.
///
/// Deliberately covers all three assignment shapes: self tasks, tasks you
/// delegated to someone else, and tasks someone else delegated to you —
/// see `task_permissions.dart` for how those affect the quick-toggle.
List<Task> buildSeedTasks() {
  final now = DateTime.now();
  return [
    Task(
      title: 'Review pull request',
      description: 'Check the new auth flow before merging.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.add(const Duration(minutes: 45)),
      assigner: _alex,
      assignee: currentUserId,
      status: TaskStatus.assigned,
      categories: const ['Work'],
    ),
    Task(
      title: 'Buy groceries',
      description: 'Milk, eggs, bread, and coffee.',
      createdAt: now.subtract(const Duration(hours: 3)),
      dueAt: now.add(const Duration(hours: 5)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Personal'],
    ),
    Task(
      title: 'Prepare sprint report',
      description: 'Summarize velocity and blockers for the team sync.',
      createdAt: now.subtract(const Duration(days: 2)),
      dueAt: now.add(const Duration(days: 2)),
      assigner: currentUserId,
      assignee: _alex,
      status: TaskStatus.working,
      categories: const ['Work', 'Reports'],
    ),
    Task(
      title: 'Book dentist appointment',
      description: 'Try to get a slot next week.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.add(const Duration(days: 6)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Health'],
    ),
    Task(
      title: 'Fix login bug',
      description: 'Users get logged out after 5 minutes of inactivity.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.subtract(const Duration(hours: 2)),
      assigner: _alex,
      assignee: currentUserId,
      status: TaskStatus.assigned,
      categories: const ['Work'],
    ),
    Task(
      title: 'Plan weekend trip',
      description: 'Decide on destination and book transport.',
      createdAt: now.subtract(const Duration(hours: 6)),
      dueAt: now.add(const Duration(days: 5)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Personal', 'Travel'],
    ),
    Task(
      title: 'Renew gym membership',
      description: '',
      createdAt: now.subtract(const Duration(days: 10)),
      dueAt: null,
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.completed,
      categories: const ['Health'],
    ),
  ];
}
