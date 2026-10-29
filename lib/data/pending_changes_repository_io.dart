import 'pending_changes_repository.dart';
import 'sqlite_pending_changes_repository.dart';

/// Native implementation of the conditional import in
/// `pending_changes_repository.dart` — every platform with `dart:io`.
PendingChangesRepository createPendingChangesRepository() => SqlitePendingChangesRepository();
