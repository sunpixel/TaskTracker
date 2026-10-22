import '../models/task.dart';
import '../models/task_status.dart';
import 'task_repository_stub.dart'
    if (dart.library.io) 'task_repository_io.dart' as impl;

/// Local on-device cache of tasks, so the app isn't round-tripping to the
/// backend for every read. This is the local source of truth until a sync
/// layer with the backend is built; `insert`/`updateStatus` write straight
/// through to storage (no network involved here at all).
abstract class TaskRepository {
  Future<List<Task>> getAll();

  /// Validates `draft`'s due date, stores it, and returns it with its new
  /// id filled in.
  Future<Task> insert(Task draft);

  /// Replaces the stored task with the same id as [task] with [task]'s
  /// current field values. Used by the task editor (assigner only).
  Future<void> update(Task task);

  Future<void> updateStatus(int id, TaskStatus status);
}

/// Picks the best repository for the current platform: SQLite (via
/// sqflite / sqflite_common_ffi) wherever `dart:io` is available — Android,
/// iOS, macOS, Windows, Linux — or an in-memory fallback on Web, where
/// sqflite isn't supported at all.
TaskRepository createTaskRepository() => impl.createTaskRepository();
