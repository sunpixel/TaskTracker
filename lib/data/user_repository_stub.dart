import 'in_memory_user_repository.dart';
import 'user_repository.dart';

/// Web implementation of the conditional import in `user_repository.dart`.
UserRepository createUserRepository() => InMemoryUserRepository();
