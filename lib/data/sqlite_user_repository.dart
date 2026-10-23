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
  Future<List<User>> getContacts() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('users', where: 'is_me = 0', orderBy: 'user_name ASC');
    return rows.map(User.fromMap).toList();
  }

  @override
  Future<User> upsertMe(User user) async {
    final db = await AppDatabase.instance();
    final existing = await getMe();
    final data = user.copyWith(isMe: true).toMap();
    if (existing == null) {
      final id = await db.insert('users', data);
      return user.withId(id).copyWith(isMe: true);
    }
    await db.update('users', data, where: 'id = ?', whereArgs: [existing.id]);
    return user.withId(existing.id!).copyWith(isMe: true);
  }

  @override
  Future<User> addContact(User contact) async {
    final db = await AppDatabase.instance();
    final id = await db.insert('users', contact.copyWith(isMe: false).toMap());
    return contact.withId(id).copyWith(isMe: false);
  }

  @override
  Future<void> deleteContact(int id) async {
    final db = await AppDatabase.instance();
    await db.delete('users', where: 'id = ? AND is_me = 0', whereArgs: [id]);
  }
}
