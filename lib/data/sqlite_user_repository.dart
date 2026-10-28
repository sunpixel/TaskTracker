import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'app_database.dart';
import 'user_repository.dart';

class SqliteUserRepository implements UserRepository {
  @override
  Future<User?> getMe() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('users', where: 'is_me = 1', limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  @override
  Future<void> upsertMe(User user) async {
    final db = await AppDatabase.instance();
    // There's only ever one "me" row — clear any previous one first in
    // case the id changed (e.g. a different account logged in on this
    // device than last time).
    await db.delete('users', where: 'is_me = 1');
    await db.insert('users', user.copyWith(isMe: true).toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> clearMe() async {
    final db = await AppDatabase.instance();
    await db.delete('users', where: 'is_me = 1');
  }

  @override
  Future<List<User>> getContacts() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('users', where: 'is_me = 0', orderBy: 'user_name ASC');
    return rows.map(User.fromMap).toList();
  }

  @override
  Future<void> upsertContact(User contact) async {
    final db = await AppDatabase.instance();
    await db.insert('users', contact.copyWith(isMe: false).toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteContact(String id) async {
    final db = await AppDatabase.instance();
    await db.delete('users', where: 'id = ? AND is_me = 0', whereArgs: [id]);
  }
}
