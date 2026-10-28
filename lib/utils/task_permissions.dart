/// Rules for the quick-toggle checkbox/button shown on the Home and Tasks
/// lists and mirrored on the task detail screen. This is the fast, role
/// -restricted action; the status dropdown in the task editor (assigner
/// only) is a separate, unrestricted override across all six statuses.
///
/// - No delegation (I'm both assigner and assignee, or neither — shouldn't
///   normally happen): plain pending <-> completed toggle.
/// - I delegated this task to someone else (I'm the assigner, assignee is
///   someone else): I have final say on completion, so my toggle flips
///   completed <-> pending directly.
/// - Someone else delegated this task to me (I'm the assignee, assigner is
///   someone else): I can only flag my part done or undo that — toggling
///   moves between pending and [TaskStatus.onReview]. Only the assigner
///   can mark it [TaskStatus.completed].
///
/// Every function here takes [currentUserId] explicitly — whoever is
/// effectively "you" right now (your real account if logged in,
/// otherwise the stable local-device id; see `UserStore.effectiveUserId`)
/// — rather than reading a global, since that's no longer a fixed
/// constant now that real accounts exist. The server
/// (TaskAuthorization.cs) independently re-derives the same rules from
/// the authenticated caller — this copy is a UX nicety, not enforcement.
library;

import '../models/task.dart';
import '../models/task_status.dart';

bool _isDelegatedToMe(Task task, String currentUserId) =>
    task.assignee == currentUserId && task.assigner != currentUserId;

/// Whether [currentUserId] is allowed to edit [task]'s fields at all —
/// only its assigner can.
bool canEdit(Task task, String currentUserId) =>
    task.assigner == null || task.assigner == currentUserId;

/// The status [task] should move to if its quick-toggle is tapped right
/// now, given [currentUserId]'s role on it.
TaskStatus nextStatusOnQuickToggle(Task task, String currentUserId) {
  if (_isDelegatedToMe(task, currentUserId)) {
    return task.status == TaskStatus.onReview ? TaskStatus.pending : TaskStatus.onReview;
  }
  // Self task, or I'm the assigner (delegated to someone else, or both).
  return task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
}

/// What the quick-toggle checkbox should show for [task]: `true` checked,
/// `false` unchecked, `null` indeterminate (used for "on review").
bool? quickToggleValue(Task task, String currentUserId) {
  if (task.status == TaskStatus.completed) return true;
  if (_isDelegatedToMe(task, currentUserId) && task.status == TaskStatus.onReview) return null;
  return false;
}

/// What the quick-toggle action button on the task detail screen is
/// about to do, mirroring [nextStatusOnQuickToggle] — returned as an
/// enum rather than an English label so the UI layer localizes it (see
/// `DueDateError`'s doc in task_validators.dart for why).
enum QuickToggleAction { backToPending, markMyPartDone, markAsPending, markAsComplete }

QuickToggleAction quickToggleActionFor(Task task, String currentUserId) {
  if (_isDelegatedToMe(task, currentUserId)) {
    return task.status == TaskStatus.onReview ? QuickToggleAction.backToPending : QuickToggleAction.markMyPartDone;
  }
  return task.isCompleted ? QuickToggleAction.markAsPending : QuickToggleAction.markAsComplete;
}
