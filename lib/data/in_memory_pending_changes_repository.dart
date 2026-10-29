import 'pending_change.dart';
import 'pending_changes_repository.dart';

/// Pure-Dart fallback — same role as `InMemoryTaskRepository`: Web (no
/// sqflite) and tests. Data lives only for the life of the app/test.
class InMemoryPendingChangesRepository implements PendingChangesRepository {
  final Map<String, PendingChange> _byTaskId = {};

  @override
  Future<void> enqueue(String taskId, PendingChangeType type) async {
    final resolved = coalescePendingChange(_byTaskId[taskId]?.type, type);
    if (resolved == null) {
      _byTaskId.remove(taskId);
    } else {
      _byTaskId[taskId] = PendingChange(taskId: taskId, type: resolved, enqueuedAt: DateTime.now());
    }
  }

  @override
  Future<void> remove(String taskId) async => _byTaskId.remove(taskId);

  @override
  Future<List<PendingChange>> getAll() async => _byTaskId.values.toList();
}
