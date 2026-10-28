import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/task_status.dart';
import '../utils/task_validators.dart';
import 'app_database.dart';
import 'task_repository.dart';

/// Real, persistent repository backed by the on-device SQLite DB.
///
/// Seeding demo data for a fresh install is TaskStore's job (it needs
/// the current user id, which this layer has no business knowing) —
/// see TaskStore.load.
class SqliteTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance();
    // Sorting by deadline urgency (no-due-date last) is done in Dart —
    // see `sort_tasks.dart` — since that needs richer logic than a plain
    // SQL ORDER BY (NULLs would otherwise sort first).
    final rows = await db.query('tasks');
    return rows.map(Task.fromMap).toList();
  }

  @override
  Future<void> insert(Task draft) async {
    final error = validateDueDate(createdAt: draft.createdAt, dueAt: draft.dueAt);
    if (error != null) throw ArgumentError(error);
    final db = await AppDatabase.instance();
    await db.insert('tasks', draft.toMap());
  }

  @override
  Future<void> upsert(Task task) async {
    final db = await AppDatabase.instance();
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Task task) async {
    final error = validateDueDate(createdAt: task.createdAt, dueAt: task.dueAt);
    if (error != null) throw ArgumentError(error);
    final db = await AppDatabase.instance();
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Future<void> updateStatus(String id, TaskStatus status, {DateTime? updatedAt}) async {
    final db = await AppDatabase.instance();
    await db.update(
      'tasks',
      {
        'status': status.name,
        'updated_at': (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await AppDatabase.instance();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
