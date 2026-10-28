import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/task_status.dart';

const _alex = 'alex'; // placeholder teammate id, for demo variety only.
const _uuid = Uuid();

/// Demo data so the app has something to show before any real syncing
/// has happened (fresh install, logged out). Safe to delete once that's
/// no longer needed.
///
/// [currentUserId] is whatever `UserStore.effectiveUserId` resolves to
/// at the time this runs — the real logged-in user if there is one,
/// otherwise the stable local-device id (see `LocalIdentity`).
///
/// Deliberately covers all three assignment shapes: self tasks, tasks you
/// delegated to someone else, and tasks someone else delegated to you —
/// see `task_permissions.dart` for how those affect the quick-toggle.
List<Task> buildSeedTasks(String currentUserId) {
  final now = DateTime.now();
  Task task({
    required String title,
    required String description,
    required DateTime createdAt,
    DateTime? dueAt,
    required String? assigner,
    required String? assignee,
    required TaskStatus status,
    List<String> categories = const [],
  }) =>
      Task(
        id: _uuid.v4(),
        title: title,
        description: description,
        createdAt: createdAt,
        dueAt: dueAt,
        assigner: assigner,
        assignee: assignee,
        status: status,
        categories: categories,
        updatedAt: createdAt,
      );

  return [
    task(
      title: 'Review pull request',
      description: 'Check the new auth flow before merging.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.add(const Duration(minutes: 45)),
      assigner: _alex,
      assignee: currentUserId,
      status: TaskStatus.assigned,
      categories: const ['Work'],
    ),
    task(
      title: 'Buy groceries',
      description: 'Milk, eggs, bread, and coffee.',
      createdAt: now.subtract(const Duration(hours: 3)),
      dueAt: now.add(const Duration(hours: 5)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Personal'],
    ),
    task(
      title: 'Prepare sprint report',
      description: 'Summarize velocity and blockers for the team sync.',
      createdAt: now.subtract(const Duration(days: 2)),
      dueAt: now.add(const Duration(days: 2)),
      assigner: currentUserId,
      assignee: _alex,
      status: TaskStatus.working,
      categories: const ['Work', 'Reports'],
    ),
    task(
      title: 'Book dentist appointment',
      description: 'Try to get a slot next week.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.add(const Duration(days: 6)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Health'],
    ),
    task(
      title: 'Fix login bug',
      description: 'Users get logged out after 5 minutes of inactivity.',
      createdAt: now.subtract(const Duration(days: 1)),
      dueAt: now.subtract(const Duration(hours: 2)),
      assigner: _alex,
      assignee: currentUserId,
      status: TaskStatus.assigned,
      categories: const ['Work'],
    ),
    task(
      title: 'Plan weekend trip',
      description: 'Decide on destination and book transport.',
      createdAt: now.subtract(const Duration(hours: 6)),
      dueAt: now.add(const Duration(days: 5)),
      assigner: currentUserId,
      assignee: currentUserId,
      status: TaskStatus.pending,
      categories: const ['Personal', 'Travel'],
    ),
    task(
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
