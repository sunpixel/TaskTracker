/// What kind of server push a task is still waiting on. Mirrors the
/// four push paths `ServerSyncService` already had
/// (create/edit/statusChange/delete) — this doesn't invent a new kind
/// of change, just makes "still needs to happen" a durable fact instead
/// of a fire-and-forget attempt that's lost if it fails while offline.
enum PendingChangeType { create, update, statusChange, delete }

/// One task's outstanding sync debt. There's at most one of these per
/// task at a time — see [coalescePendingChange] — not a log of every
/// edit made while offline, just "what does the server still need to
/// be told, net of everything that's happened since the last
/// successful sync".
class PendingChange {
  final String taskId;
  final PendingChangeType type;
  final DateTime enqueuedAt;

  const PendingChange({required this.taskId, required this.type, required this.enqueuedAt});
}

/// Folds a new local mutation ([incoming]) into whatever's already
/// queued for this task ([existing], `null` if nothing is), returning
/// the type that should end up queued — or `null` to mean "nothing
/// needs to be queued at all; drop the existing row if there is one".
///
/// The one case that produces `null`: a task created and then deleted
/// without ever successfully reaching the server has nothing worth
/// telling it — it never knew the task existed, so there's nothing to
/// delete *of*.
///
/// A later full edit or status change doesn't get queued alongside an
/// unconfirmed [PendingChangeType.create] as a separate step — it just
/// updates what the *eventual* create will contain, since the server
/// has no record of this task yet for an edit to apply on top of.
/// Symmetrically, once something is already queued as
/// [PendingChangeType.update] (the task is known to exist server-side),
/// a further status change is absorbed into that same pending update
/// rather than queued as its own [PendingChangeType.statusChange] —
/// the eventual push already carries the task's current full state,
/// status included.
PendingChangeType? coalescePendingChange(PendingChangeType? existing, PendingChangeType incoming) {
  switch (incoming) {
    case PendingChangeType.create:
      // Only ever happens once, right when a task is first drafted —
      // nothing could already be queued for an id that didn't exist
      // a moment ago.
      return PendingChangeType.create;

    case PendingChangeType.delete:
      return existing == PendingChangeType.create ? null : PendingChangeType.delete;

    case PendingChangeType.update:
    case PendingChangeType.statusChange:
      if (existing == PendingChangeType.create) return PendingChangeType.create;
      if (existing == PendingChangeType.update) return PendingChangeType.update;
      return incoming;
  }
}
