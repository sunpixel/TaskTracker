import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/server_sync_service.dart';
import '../utils/task_permissions.dart';
import 'seed_tasks.dart';
import 'task_repository.dart';
import 'user_store.dart';

/// Single shared, reactive view of the task list, backed by a
/// [TaskRepository] (local SQLite — always the local source of truth,
/// read instantly, works fully offline) and synced with the backend
/// through [ServerSyncService] on top of that.
///
/// Every local write (create/update/status change) pushes to the server
/// in the background — never blocking on it, since the local save is
/// what the UI actually waits on. Pulls happen on login, right after any
/// local push, on a pull-to-refresh gesture, and on a 10-minute timer
/// while logged in and the app is open; see `pullFromServer`.
class TaskStore extends ChangeNotifier {
  TaskStore({
    required UserStore userStore,
    TaskRepository? repository,
    ServerSyncService? syncService,
  })  : _userStore = userStore,
        _repository = repository ?? createTaskRepository(),
        _syncService = syncService ?? ServerSyncService(userStore: userStore) {
    _userStore.addListener(_handleUserStoreChanged);
  }

  final UserStore _userStore;
  final TaskRepository _repository;
  final ServerSyncService _syncService;

  List<Task> _tasks = [];
  bool _isLoading = true;
  DateTime? _lastSyncedAt;
  Timer? _periodicSyncTimer;
  bool _wasLoggedIn = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  Task? byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> load() async {
    _tasks = await _repository.getAll();

    if (_tasks.isEmpty && !_userStore.isLoggedIn) {
      // Nothing synced yet and no account to sync from — seed demo data
      // so the app isn't empty on a fresh install. Once real data
      // exists (synced or logged in), this never runs again.
      for (final task in buildSeedTasks(_userStore.effectiveUserId)) {
        await _repository.insert(task);
      }
      _tasks = await _repository.getAll();
    }

    _isLoading = false;
    notifyListeners();

    _wasLoggedIn = _userStore.isLoggedIn;
    if (_wasLoggedIn) {
      pullFromServer();
      _startPeriodicSync();
    }
  }

  void _handleUserStoreChanged() {
    final isLoggedIn = _userStore.isLoggedIn;
    if (isLoggedIn && !_wasLoggedIn) {
      pullFromServer();
      _startPeriodicSync();
    } else if (!isLoggedIn && _wasLoggedIn) {
      _stopPeriodicSync();
    }
    _wasLoggedIn = isLoggedIn;
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 10), (_) => pullFromServer());
  }

  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  /// Pulls whatever's changed since the last successful pull (or
  /// everything, the first time) and merges it into local storage.
  /// Last-write-wins by `updatedAt`, matching the server's own policy —
  /// an unpushed local edit newer than the incoming one is kept (and
  /// implicitly re-pushed next time it's edited/toggled again) rather
  /// than being clobbered by a pull that raced it.
  ///
  /// Safe to call as often as needed (pull-to-refresh, the periodic
  /// timer, right after a push) — it's a no-op when logged out.
  Future<void> pullFromServer() async {
    final result = await _syncService.fetchChanges(since: _lastSyncedAt);
    if (result.upserted.isEmpty && result.deletedIds.isEmpty) {
      _lastSyncedAt = DateTime.now();
      return;
    }

    for (final incoming in result.upserted) {
      final local = byId(incoming.id);
      if (local != null && local.updatedAt.isAfter(incoming.updatedAt)) {
        continue; // Local has a newer unpushed edit — keep it.
      }

      final wasAlreadyAssignedToMe =
          local?.assignee == _userStore.effectiveUserId && local?.assigner != _userStore.effectiveUserId;
      final isNewlyAssignedToMe = incoming.assignee == _userStore.effectiveUserId &&
          incoming.assigner != _userStore.effectiveUserId &&
          !wasAlreadyAssignedToMe;

      await _repository.upsert(incoming);
      final index = _tasks.indexWhere((t) => t.id == incoming.id);
      if (index == -1) {
        _tasks.add(incoming);
      } else {
        _tasks[index] = incoming;
      }

      if (isNewlyAssignedToMe) {
        try {
          await NotificationService.instance.showAssignedNotification(incoming);
        } catch (_) {
          // Notifications are a nice-to-have, not critical path.
        }
      }
      try {
        await NotificationService.instance.scheduleDueReminders(incoming);
      } catch (_) {}
    }

    for (final id in result.deletedIds) {
      await _repository.delete(id);
      _tasks.removeWhere((t) => t.id == id);
      try {
        await NotificationService.instance.cancelDueReminders(id);
      } catch (_) {}
    }

    _lastSyncedAt = DateTime.now();
    notifyListeners();
  }

  /// Creates [draft] — which already carries its final id, generated by
  /// the caller (see `task_detail_screen.dart`) — locally, then pushes
  /// it to the server in the background.
  Future<void> createTask(Task draft) async {
    await _repository.insert(draft);
    _tasks.add(draft);
    notifyListeners();
    await _syncNotificationsFor(draft);
    unawaited(_syncService.pushNewTask(draft).then((_) => pullFromServer()));
  }

  /// Persists edits to an existing task (assigner only — enforced by the
  /// caller/UI via `canEdit`, not here).
  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _repository.update(updated);
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
    }
    await _syncNotificationsFor(updated);
    unawaited(_syncService.pushTaskEdit(updated).then((_) => pullFromServer()));
  }

  /// Applies the role-appropriate next status for [task] — see
  /// `task_permissions.dart` — and persists it.
  Future<void> quickToggle(Task task) async {
    final newStatus = nextStatusOnQuickToggle(task, _userStore.effectiveUserId);
    final now = DateTime.now();
    await _repository.updateStatus(task.id, newStatus, updatedAt: now);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    final updated = _tasks[index].copyWith(status: newStatus, updatedAt: now);
    _tasks[index] = updated;
    notifyListeners();
    await _syncNotificationsFor(updated);
    unawaited(_syncService.pushStatusChange(updated).then((_) => pullFromServer()));
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    try {
      await NotificationService.instance.cancelDueReminders(id);
    } catch (_) {}
    unawaited(_syncService.pushDelete(id));
  }

  /// Reschedules due-date reminders for a locally-changed task. Failures
  /// (e.g. no platform notification implementation — notably under
  /// `flutter test`, which has no plugin channel mocked) must never
  /// break saving a task, so they're swallowed rather than rethrown.
  Future<void> _syncNotificationsFor(Task task) async {
    try {
      await NotificationService.instance.scheduleDueReminders(task);
    } catch (_) {
      // See above.
    }
  }

  @override
  void dispose() {
    _stopPeriodicSync();
    _userStore.removeListener(_handleUserStoreChanged);
    super.dispose();
  }
}
