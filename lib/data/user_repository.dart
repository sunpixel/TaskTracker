import '../models/user.dart';
import 'user_repository_stub.dart'
    if (dart.library.io) 'user_repository_io.dart' as impl;

/// Local on-device store of "me" and contacts. Same platform-split
/// rationale as `task_repository.dart`: SQLite everywhere `dart:io` is
/// available, an in-memory fallback on Web and in tests.
abstract class UserRepository {
  /// The single local "me" row, or `null` if no local account has been
  /// created yet on this device.
  Future<User?> getMe();

  Future<List<User>> getContacts();

  /// Creates or replaces the local "me" row (there's only ever one).
  Future<User> upsertMe(User user);

  Future<User> addContact(User contact);

  Future<void> deleteContact(int id);
}

UserRepository createUserRepository() => impl.createUserRepository();
