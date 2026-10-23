import 'sqlite_user_repository.dart';
import 'user_repository.dart';

/// Native implementation of the conditional import in
/// `user_repository.dart`.
UserRepository createUserRepository() => SqliteUserRepository();
