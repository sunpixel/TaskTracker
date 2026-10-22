import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/task_validators.dart';
import 'app_database.dart';
import 'seed_tasks.dart';
import 'task_repository.dart';

/// Real, persistent repository backed by the on-device SQLite DB.
class SqliteTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance();
    // Sorting by deadline urgency (no-due-date last) is done in Dart —
    // see `sort_tasks.dart` — since that needs richer logic than a plain
    // SQL ORDER BY (NULLs would otherwise sort first).
    var rows = await db.query('tasks', orderBy: 'id ASC');
    if (rows.isEmpty) {
      await _seed(db);
      rows = await db.query('tasks', orderBy: 'id ASC');
    }
    return rows.map(Task.fromMap).toList();
  }

  @override
  Future<Task> insert(Task draft) async {
    final error = validateDueDate(createdAt: draft.createdAt, dueAt: draft.dueAt);
    if (error != null) throw ArgumentError(error);
    final db = await AppDatabase.instance();
    final id = await db.insert('tasks', draft.toMap());
    return draft.withId(id);
  }

  @override
  Future<void> update(Task task) async {
    final error = validateDueDate(createdAt: task.createdAt, dueAt: task.dueAt);
    if (error != null) throw ArgumentError(error);
    final db = await AppDatabase.instance();
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Future<void> updateStatus(int id, TaskStatus status) async {
    final db = await AppDatabase.instance();
    await db.update(
      'tasks',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _seed(Database db) async {
    for (final task in buildSeedTasks()) {
      await db.insert('tasks', task.toMap());
    }
  }
}
