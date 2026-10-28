import '../models/user.dart';
import 'user_repository_stub.dart'
    if (dart.library.io) 'user_repository_io.dart' as impl;

/// Local on-device cache of "me" (your own profile, once logged in) and
/// contacts. Same platform-split rationale as `task_repository.dart`:
/// SQLite everywhere `dart:io` is available, an in-memory fallback on
/// Web and in tests.
///
/// Unlike before, this is purely a cache — authentication itself happens
/// against the real backend (see `UserStore`/`ApiClient`), so there's no
/// local "create an account" write path here anymore; `upsertMe` just
/// mirrors whatever the server returned, keyed by the server's own id.
abstract class UserRepository {
  /// The cached "me" row, or `null` if nobody's ever logged in on this
  /// device (or `clearMe` ran on logout).
  Future<User?> getMe();

  Future<void> upsertMe(User user);

  Future<void> clearMe();

  Future<List<User>> getContacts();

  Future<void> upsertContact(User contact);

  Future<void> deleteContact(String id);
}

UserRepository createUserRepository() => impl.createUserRepository();
