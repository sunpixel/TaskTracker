import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/task_validators.dart';
import 'seed_tasks.dart';
import 'task_repository.dart';

/// Pure-Dart fallback repository — no `dart:io`, no plugins — used on Web
/// (where sqflite doesn't run) and in tests, where hitting a real SQLite
/// file isn't desirable. Data lives only for the life of the app/test.
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository() {
    var nextId = 1;
    _tasks = buildSeedTasks().map((t) => t.withId(nextId++)).toList();
    _nextId = nextId;
  }

  late List<Task> _tasks;
  late int _nextId;

  @override
  Future<List<Task>> getAll() async => List.of(_tasks);

  @override
  Future<Task> insert(Task draft) async {
    final error = validateDueDate(createdAt: draft.createdAt, dueAt: draft.dueAt);
    if (error != null) throw ArgumentError(error);
    final withId = draft.withId(_nextId++);
    _tasks.add(withId);
    return withId;
  }

  @override
  Future<void> update(Task task) async {
    final error = validateDueDate(createdAt: task.createdAt, dueAt: task.dueAt);
    if (error != null) throw ArgumentError(error);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> updateStatus(int id, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status);
    }
  }
}
