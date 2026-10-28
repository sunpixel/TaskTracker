import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/task_validators.dart';
import 'task_repository.dart';

/// Pure-Dart fallback repository — no `dart:io`, no plugins — used on Web
/// (where sqflite doesn't run) and in tests, where hitting a real SQLite
/// file isn't desirable. Data lives only for the life of the app/test.
///
/// Seeding demo data for an empty store is TaskStore's job (it needs the
/// current user id, which this layer has no business knowing) — see
/// TaskStore.load.
class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async => List.of(_tasks);

  @override
  Future<void> insert(Task draft) async {
    final error = validateDueDate(createdAt: draft.createdAt, dueAt: draft.dueAt);
    if (error != null) throw ArgumentError(error);
    _tasks.add(draft);
  }

  @override
  Future<void> upsert(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> update(Task task) async {
    final error = validateDueDate(createdAt: task.createdAt, dueAt: task.dueAt);
    if (error != null) throw ArgumentError(error);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> updateStatus(String id, TaskStatus status, {DateTime? updatedAt}) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status, updatedAt: updatedAt ?? DateTime.now());
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}
