import '../models/user.dart';
import 'user_repository.dart';

/// Pure-Dart fallback — no `dart:io` — used on Web and in tests. Seeded
/// with one demo contact ("alex") matching the placeholder id already
/// used in `seed_tasks.dart`, so the Contacts list isn't empty out of
/// the box.
class InMemoryUserRepository implements UserRepository {
  User? _me;
  final List<User> _contacts = [
    const User(id: 1, userName: 'alex', fullName: 'Alex', email: 'alex@example.com'),
  ];
  int _nextId = 2;

  @override
  Future<User?> getMe() async => _me;

  @override
  Future<List<User>> getContacts() async => List.of(_contacts);

  @override
  Future<User> upsertMe(User user) async {
    final me = user.withId(_me?.id ?? _nextId++).copyWith(isMe: true);
    _me = me;
    return me;
  }

  @override
  Future<User> addContact(User contact) async {
    final withId = contact.withId(_nextId++).copyWith(isMe: false);
    _contacts.add(withId);
    return withId;
  }

  @override
  Future<void> deleteContact(int id) async {
    _contacts.removeWhere((c) => c.id == id);
  }
}
