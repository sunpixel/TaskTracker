import '../data/user_store.dart';
import '../models/task.dart';
import 'api_client.dart';

/// One item's outcome from a `pushBatch` call. [isDefinitiveRejection]
/// distinguishes "the server told us flatly no, stop asking"
/// (not_found/forbidden/missing_fields/unknown_type) from "something
/// went wrong, worth trying again later" (the server's own generic
/// per-item `"error"` marker — see `TaskEndpoints.ApplyBatchItemAsync`'s
/// catch-all) — `TaskStore` uses this to decide whether to drop a
/// pending change or leave it queued for the next drain.
class BatchItemOutcome {
  final String taskId;
  final bool success;
  final String? error;

  const BatchItemOutcome({required this.taskId, required this.success, this.error});

  bool get isDefinitiveRejection => !success && error != 'error';
}

/// Raw result of a server pull: tasks to upsert locally, and ids the
/// server has soft-deleted (see TaskTrackerServer's `deletedAt`) that
/// should be removed from local storage entirely — there's no reason
/// for a single device to keep a local tombstone once it's acted on it.
class TaskSyncResult {
  final List<Task> upserted;
  final List<String> deletedIds;

  const TaskSyncResult({required this.upserted, required this.deletedIds});
}

/// The seam between the app and the backend for everything task-related.
/// Pure network I/O — deciding what a pull *means* for local state
/// (merging, conflict resolution, "was this newly assigned to me")
/// is `TaskStore`'s job; this only fetches/sends raw data.
///
/// Every method here is a no-op (or returns nothing) when not logged
/// in — that's what keeps the app fully self-sufficient offline, per
/// the original design: nothing in here is ever load-bearing for core
/// functionality, only for multi-device sync on top of it.
class ServerSyncService {
  ServerSyncService({required UserStore userStore, ApiClient? apiClient})
      : _userStore = userStore,
        _api = apiClient ?? ApiClient();

  final UserStore _userStore;
  final ApiClient _api;

  /// Pushes a newly-created task to the server. Best-effort: a failure
  /// here (offline, server down) is swallowed — the local save already
  /// happened and stays authoritative; this task will be picked up
  /// again next time a pull reconciles state, since there's no local
  /// "pending outbox" queue (yet) to retry it automatically.
  Future<void> pushNewTask(Task task) async {
    if (!_userStore.isLoggedIn) return;
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return;
    try {
      await _api.createTask(accessToken: token, body: {
        'id': task.id,
        ...task.toServerRequestBody(),
      });
    } catch (_) {
      // See class doc.
    }
  }

  Future<void> pushTaskEdit(Task task) async {
    if (!_userStore.isLoggedIn) return;
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return;
    try {
      await _api.updateTask(accessToken: token, id: task.id, body: task.toServerRequestBody());
    } catch (_) {
      // See class doc.
    }
  }

  Future<void> pushStatusChange(Task task) async {
    if (!_userStore.isLoggedIn) return;
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return;
    try {
      await _api.quickToggleTask(accessToken: token, id: task.id);
    } catch (_) {
      // See class doc.
    }
  }

  Future<void> pushDelete(String taskId) async {
    if (!_userStore.isLoggedIn) return;
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return;
    try {
      await _api.deleteTask(accessToken: token, id: taskId);
    } catch (_) {
      // See class doc.
    }
  }

  /// Replays a backlog of queued offline changes as a single request —
  /// see `TaskStore._drainPendingChanges`, which builds [items] (each
  /// already shaped the way `POST /tasks/batch` expects) from the local
  /// outbox.
  ///
  /// Returns `null` if the request failed *as a whole* (offline, not
  /// logged in, network error, rate-limited) — the caller should leave
  /// every pending change queued and just try again later, same as
  /// every other method here. A non-null result always has one entry
  /// per item in [items], in order, since the server applies each item
  /// independently rather than failing the batch over one bad entry.
  Future<List<BatchItemOutcome>?> pushBatch(List<Map<String, dynamic>> items) async {
    if (!_userStore.isLoggedIn) return null;
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return null;
    try {
      final raw = await _api.batchTasks(accessToken: token, items: items);
      return raw.cast<Map<String, dynamic>>().map((json) => BatchItemOutcome(
            taskId: json['id'] as String,
            success: json['success'] as bool,
            error: json['error'] as String?,
          )).toList();
    } catch (_) {
      return null;
    }
  }

  /// Fetches everything changed since [since] (or everything at all, if
  /// `null` — e.g. right after login on a device that's never synced).
  /// Returns an empty result (never throws) if not logged in or the
  /// request fails — callers should treat that as "nothing new", not
  /// as an error worth surfacing.
  Future<TaskSyncResult> fetchChanges({DateTime? since}) async {
    if (!_userStore.isLoggedIn) return const TaskSyncResult(upserted: [], deletedIds: []);
    final token = await _userStore.ensureFreshAccessToken();
    if (token == null) return const TaskSyncResult(upserted: [], deletedIds: []);

    try {
      final raw = await _api.getTasks(accessToken: token, since: since);
      final upserted = <Task>[];
      final deletedIds = <String>[];
      for (final json in raw.cast<Map<String, dynamic>>()) {
        if (Task.isDeletedInServerJson(json)) {
          deletedIds.add(json['id'] as String);
        } else {
          upserted.add(Task.fromServerJson(json));
        }
      }
      return TaskSyncResult(upserted: upserted, deletedIds: deletedIds);
    } catch (_) {
      return const TaskSyncResult(upserted: [], deletedIds: []);
    }
  }
}
