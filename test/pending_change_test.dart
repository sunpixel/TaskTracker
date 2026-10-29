import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker/data/pending_change.dart';
import 'package:task_tracker/data/in_memory_pending_changes_repository.dart';

void main() {
  group('coalescePendingChange', () {
    test('a plain create with nothing queued yet stays a create', () {
      expect(coalescePendingChange(null, PendingChangeType.create), PendingChangeType.create);
    });

    test('editing a task that was created but never confirmed stays a create', () {
      expect(coalescePendingChange(PendingChangeType.create, PendingChangeType.update), PendingChangeType.create);
    });

    test('toggling a task that was created but never confirmed stays a create', () {
      expect(coalescePendingChange(PendingChangeType.create, PendingChangeType.statusChange), PendingChangeType.create);
    });

    test('deleting a task that was created but never confirmed drops it entirely', () {
      // The server never knew this task existed — there's nothing to
      // tell it, not even a delete.
      expect(coalescePendingChange(PendingChangeType.create, PendingChangeType.delete), null);
    });

    test('a status change with nothing queued yet becomes its own pending change', () {
      expect(coalescePendingChange(null, PendingChangeType.statusChange), PendingChangeType.statusChange);
    });

    test('a full edit after a queued status change supersedes it (carries status too)', () {
      expect(coalescePendingChange(PendingChangeType.statusChange, PendingChangeType.update), PendingChangeType.update);
    });

    test('a status change after a queued full edit is absorbed into the edit', () {
      expect(coalescePendingChange(PendingChangeType.update, PendingChangeType.statusChange), PendingChangeType.update);
    });

    test('deleting an already-synced (confirmed) task queues a real delete', () {
      expect(coalescePendingChange(PendingChangeType.update, PendingChangeType.delete), PendingChangeType.delete);
      expect(coalescePendingChange(null, PendingChangeType.delete), PendingChangeType.delete);
    });
  });

  group('InMemoryPendingChangesRepository', () {
    test('enqueueing create then delete for the same never-synced task leaves nothing queued', () async {
      final repo = InMemoryPendingChangesRepository();
      await repo.enqueue('task-1', PendingChangeType.create);
      await repo.enqueue('task-1', PendingChangeType.delete);
      expect(await repo.getAll(), isEmpty);
    });

    test('two edits in a row collapse into one queued update', () async {
      final repo = InMemoryPendingChangesRepository();
      await repo.enqueue('task-1', PendingChangeType.update);
      await repo.enqueue('task-1', PendingChangeType.update);
      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.single.type, PendingChangeType.update);
    });

    test('remove clears a queued change', () async {
      final repo = InMemoryPendingChangesRepository();
      await repo.enqueue('task-1', PendingChangeType.create);
      await repo.remove('task-1');
      expect(await repo.getAll(), isEmpty);
    });
  });
}
