import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/server_sync_service.dart';
import '../utils/task_permissions.dart';
import 'pending_change.dart';
import 'pending_changes_repository.dart';
import 'seed_tasks.dart';
import 'task_repository.dart';
import 'user_store.dart';

/// Single shared, reactive view of the task list, backed by a
/// [TaskRepository] (local SQLite — always the local source of truth,
/// read instantly, works fully offline) and synced with the backend
/// through [ServerSyncService] on top of that.
///
/// Every local write (create/update/status change/delete) records what
/// still needs to reach the server in [_pendingChanges] — a durable
/// outbox, not a fire-and-forget push — then makes an opportunistic
/// attempt to send it right away. That attempt (and the backlog it
/// leaves behind if it fails) is what [pullFromServer] drains first,
/// before pulling: see `_drainPendingChanges`. Pulls/drains happen on
/// login, right after any local write, on a pull-to-refresh gesture, and
/// on a 10-minute timer while logged in and the app is open.
class TaskStore extends ChangeNotifier {
  TaskStore({
    required UserStore userStore,
    TaskRepository? repository,
    PendingChangesRepository? pendingChangesRepository,
    ServerSyncService? syncService,
  })  : _userStore = userStore,
        _repository = repository ?? createTaskRepository(),
        _pendingChanges = pendingChangesRepository ?? createPendingChangesRepository(),
        _syncService = syncService ?? ServerSyncService(userStore: userStore) {
    _userStore.addListener(_handleUserStoreChanged);
  }

  /// A batch request this large would be unusual in practice (see the
  /// design notes — this exists for a backlog built up over a long
  /// offline stretch, not routine traffic), but the server caps a single
  /// `POST /tasks/batch` at the same number — chunking here means a
  /// bigger backlog still drains, just over a few requests instead of
  /// one oversized one the server would reject outright.
  static const _maxBatchSize = 500;

  final UserStore _userStore;
  final TaskRepository _repository;
  final PendingChangesRepository _pendingChanges;
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

  /// Flushes the offline outbox, then pulls whatever's changed since the
  /// last successful pull (or everything, the first time) and merges it
  /// into local storage. Draining first — rather than after — means
  /// whatever this device just pushed shows back up as already applied
  /// instead of racing its own pull.
  ///
  /// Last-write-wins by `updatedAt`, matching the server's own policy —
  /// an unpushed local edit newer than the incoming one is kept (it's
  /// already queued in the outbox, so it'll reach the server on a later
  /// drain) rather than being clobbered by a pull that raced it.
  ///
  /// Safe to call as often as needed (pull-to-refresh, the periodic
  /// timer, right after a local write) — every step here is a no-op when
  /// logged out.
  Future<void> pullFromServer() async {
    await _drainPendingChanges();

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

  /// Sends everything queued in the offline outbox as one (or, past
  /// [_maxBatchSize], a few) `POST /tasks/batch` request — this is the
  /// fix for the thing a plain fire-and-forget push couldn't do: a
  /// backlog built up while offline reaching the server as a handful of
  /// requests instead of one per task, which is both what actually makes
  /// it reach the server at all (nothing retried a failed push before)
  /// and what keeps a large backlog from needing as many requests as it
  /// has tasks against the per-IP rate limit.
  ///
  /// A whole-request failure (offline, 429, server down) leaves every
  /// pending change queued untouched for the next attempt. A per-item
  /// rejection the server considers final (not found, forbidden, ...)
  /// drops that one change — there's nothing more retrying would do —
  /// while anything else about it stays queued.
  Future<void> _drainPendingChanges() async {
    if (!_userStore.isLoggedIn) return;
    final pending = await _pendingChanges.getAll();
    if (pending.isEmpty) return;

    for (var offset = 0; offset < pending.length; offset += _maxBatchSize) {
      final chunk = pending.skip(offset).take(_maxBatchSize).toList();
      final items = <Map<String, dynamic>>[];
      final itemTaskIds = <String>[];

      for (final change in chunk) {
        if (change.type == PendingChangeType.delete) {
          items.add({'type': 'delete', 'id': change.taskId});
          itemTaskIds.add(change.taskId);
          continue;
        }

        final task = byId(change.taskId);
        if (task == null) {
          // Create/update/statusChange queued for a task that's since
          // vanished locally through some other path — nothing left to
          // replay.
          await _pendingChanges.remove(change.taskId);
          continue;
        }

        items.add(switch (change.type) {
          PendingChangeType.create => {'type': 'create', 'id': task.id, ...task.toServerRequestBody()},
          PendingChangeType.update => {'type': 'update', 'id': task.id, ...task.toServerRequestBody()},
          PendingChangeType.statusChange => {'type': 'statusChange', 'id': task.id, 'status': task.status.index},
          PendingChangeType.delete => throw StateError('handled above'),
        });
        itemTaskIds.add(task.id);
      }

      if (items.isEmpty) continue;

      final outcomes = await _syncService.pushBatch(items);
      if (outcomes == null) return; // Whole request failed — leave this and every later chunk queued.

      for (final outcome in outcomes) {
        if (outcome.success || outcome.isDefinitiveRejection) {
          await _pendingChanges.remove(outcome.taskId);
        }
        // Anything else (the server's generic per-item "error" marker —
        // see BatchItemOutcome's doc) stays queued for next time.
      }
    }
  }

  /// Creates [draft] — which already carries its final id, generated by
  /// the caller (see `task_detail_screen.dart`) — locally, then queues
  /// it for the server and makes an immediate opportunistic attempt to
  /// send it (which, offline, simply leaves it queued for later).
  Future<void> createTask(Task draft) async {
    await _repository.insert(draft);
    _tasks.add(draft);
    notifyListeners();
    await _syncNotificationsFor(draft);
    await _pendingChanges.enqueue(draft.id, PendingChangeType.create);
    unawaited(pullFromServer());
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
    await _pendingChanges.enqueue(updated.id, PendingChangeType.update);
    unawaited(pullFromServer());
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
    await _pendingChanges.enqueue(updated.id, PendingChangeType.statusChange);
    unawaited(pullFromServer());
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    try {
      await NotificationService.instance.cancelDueReminders(id);
    } catch (_) {}
    await _pendingChanges.enqueue(id, PendingChangeType.delete);
    unawaited(pullFromServer());
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
