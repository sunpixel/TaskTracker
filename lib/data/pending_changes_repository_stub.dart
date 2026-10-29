import 'in_memory_pending_changes_repository.dart';
import 'pending_changes_repository.dart';

/// Web implementation of the conditional import in
/// `pending_changes_repository.dart` — see `task_repository_stub.dart`
/// for why (no sqflite support on Web).
PendingChangesRepository createPendingChangesRepository() => InMemoryPendingChangesRepository();
