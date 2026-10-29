import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'pending_change.dart';
import 'pending_changes_repository.dart';

class SqlitePendingChangesRepository implements PendingChangesRepository {
  @override
  Future<void> enqueue(String taskId, PendingChangeType type) async {
    final db = await AppDatabase.instance();
    final existingRows = await db.query('pending_changes', columns: ['change_type'], where: 'task_id = ?', whereArgs: [taskId]);
    final existing = existingRows.isEmpty ? null : PendingChangeType.values.byName(existingRows.first['change_type'] as String);

    final resolved = coalescePendingChange(existing, type);
    if (resolved == null) {
      await db.delete('pending_changes', where: 'task_id = ?', whereArgs: [taskId]);
    } else {
      await db.insert(
        'pending_changes',
        {
          'task_id': taskId,
          'change_type': resolved.name,
          'enqueued_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> remove(String taskId) async {
    final db = await AppDatabase.instance();
    await db.delete('pending_changes', where: 'task_id = ?', whereArgs: [taskId]);
  }

  @override
  Future<List<PendingChange>> getAll() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('pending_changes');
    return rows
        .map((row) => PendingChange(
              taskId: row['task_id'] as String,
              type: PendingChangeType.values.byName(row['change_type'] as String),
              enqueuedAt: DateTime.fromMillisecondsSinceEpoch(row['enqueued_at'] as int),
            ))
        .toList();
  }
}
