import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/server_sync_service.dart';
import '../utils/task_permissions.dart';
import 'task_repository.dart';

/// Single shared, reactive view of the task list, backed by a
/// [TaskRepository]. Home, Tasks, and the task detail/editor screen all
/// read and mutate through this instance so a change made from any of
/// them shows up everywhere immediately.
class TaskStore extends ChangeNotifier {
  TaskStore({TaskRepository? repository}) : _repository = repository ?? createTaskRepository();

  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  Task? byId(int id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> load() async {
    _tasks = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  /// Creates [draft] and returns the stored task (with its id filled in).
  Future<Task> createTask(Task draft) async {
    final created = await _repository.insert(draft);
    _tasks.add(created);
    notifyListeners();
    await _syncNotificationsFor(created);
    return created;
  }

  /// Persists edits to an existing task (assigner only — enforced by the
  /// caller/UI via `canEdit`, not here).
  Future<void> updateTask(Task task) async {
    await _repository.update(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
    await _syncNotificationsFor(task);
  }

  /// Applies the role-appropriate next status for [task] — see
  /// `task_permissions.dart` — and persists it.
  Future<void> quickToggle(Task task) async {
    final newStatus = nextStatusOnQuickToggle(task);
    await _repository.updateStatus(task.id!, newStatus);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    final updated = _tasks[index].copyWith(status: newStatus);
    _tasks[index] = updated;
    notifyListeners();
    await _syncNotificationsFor(updated);
  }

  /// Reschedules due-date reminders and fires the "assigned to you"
  /// notification where applicable. Failures here (e.g. no platform
  /// notification implementation — notably under `flutter test`, which
  /// has no plugin channel mocked) must never break saving a task, so
  /// they're swallowed rather than rethrown.
  Future<void> _syncNotificationsFor(Task task) async {
    try {
      await NotificationService.instance.scheduleDueReminders(task);
      await ServerSyncService.instance.notifyTaskAssigned(task);
    } catch (_) {
      // Notifications are a nice-to-have, not critical path.
    }
  }
}
