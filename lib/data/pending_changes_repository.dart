import 'pending_change.dart';
import 'pending_changes_repository_stub.dart'
    if (dart.library.io) 'pending_changes_repository_io.dart' as impl;

/// The offline outbox: durably tracks which tasks still need to be
/// pushed to the server, surviving app restarts and offline stretches
/// that a plain fire-and-forget push (the old design) would silently
/// lose. See `pending_change.dart` for why this is "at most one pending
/// change per task", not a log of every edit.
abstract class PendingChangesRepository {
  /// Folds [type] into whatever's already queued for [taskId] — see
  /// `coalescePendingChange`'s doc — removing the row entirely if that
  /// resolves to "nothing worth telling the server".
  Future<void> enqueue(String taskId, PendingChangeType type);

  /// Called once a queued change has been confirmed applied (or
  /// definitively rejected — see `TaskStore._drainPendingChanges`) —
  /// either way, there's nothing left to retry for this task.
  Future<void> remove(String taskId);

  Future<List<PendingChange>> getAll();
}

/// Picks the best repository for the current platform — same split as
/// `task_repository.dart`: SQLite wherever `dart:io` exists, an
/// in-memory fallback on Web and in tests.
PendingChangesRepository createPendingChangesRepository() => impl.createPendingChangesRepository();
