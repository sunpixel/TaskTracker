import '../models/user.dart';
import 'user_repository.dart';

/// Pure-Dart fallback — no `dart:io` — used on Web and in tests.
class InMemoryUserRepository implements UserRepository {
  User? _me;
  final List<User> _contacts = [];

  @override
  Future<User?> getMe() async => _me;

  @override
  Future<void> upsertMe(User user) async {
    _me = user.copyWith(isMe: true);
  }

  @override
  Future<void> clearMe() async {
    _me = null;
  }

  @override
  Future<List<User>> getContacts() async => List.of(_contacts);

  @override
  Future<void> upsertContact(User contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    final withFlag = contact.copyWith(isMe: false);
    if (index == -1) {
      _contacts.add(withFlag);
    } else {
      _contacts[index] = withFlag;
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
  }
}
