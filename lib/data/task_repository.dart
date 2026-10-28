import '../models/task.dart';
import '../models/task_status.dart';
import 'task_repository_stub.dart'
    if (dart.library.io) 'task_repository_io.dart' as impl;

/// Local on-device cache of tasks, so the app isn't round-tripping to the
/// backend for every read. This is the local source of truth — reads
/// here never touch the network; sync with the server happens separately
/// (see `server_sync_service.dart`), pulling into and pushing from this
/// same storage.
abstract class TaskRepository {
  Future<List<Task>> getAll();

  /// [draft] already carries its final id (a GUID assigned by the
  /// caller at creation time) — there's no server round-trip needed to
  /// learn "the real id" the way an auto-increment column would require.
  Future<void> insert(Task draft);

  /// Inserts [task] if its id isn't already present, or replaces the
  /// existing row if it is — used when merging tasks pulled from the
  /// server, where either can happen depending on whether this device
  /// has seen that task before.
  Future<void> upsert(Task task);

  /// Replaces the stored task with the same id as [task] with [task]'s
  /// current field values. Used by the task editor (assigner only).
  Future<void> update(Task task);

  Future<void> updateStatus(String id, TaskStatus status, {DateTime? updatedAt});

  /// Removes a task from local storage entirely — used when the server
  /// reports a task as deleted during sync. There's no local tombstone;
  /// once a device has this, the server's own `deletedAt` is the only
  /// record that it ever existed.
  Future<void> delete(String id);
}

/// Picks the best repository for the current platform: SQLite (via
/// sqflite / sqflite_common_ffi) wherever `dart:io` is available — Android,
/// iOS, macOS, Windows, Linux — or an in-memory fallback on Web, where
/// sqflite isn't supported at all.
TaskRepository createTaskRepository() => impl.createTaskRepository();
