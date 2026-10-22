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
library;

import '../data/current_user.dart';
import '../models/task.dart';
import '../models/task_status.dart';

bool _isDelegatedToMe(Task task) =>
    task.assignee == currentUserId && task.assigner != currentUserId;

/// Whether the current user is allowed to edit [task]'s fields at all —
/// only its assigner can.
bool canEdit(Task task) => task.assigner == null || task.assigner == currentUserId;

/// The status [task] should move to if its quick-toggle is tapped right
/// now, given the current user's role on it.
TaskStatus nextStatusOnQuickToggle(Task task) {
  if (_isDelegatedToMe(task)) {
    return task.status == TaskStatus.onReview ? TaskStatus.pending : TaskStatus.onReview;
  }
  // Self task, or I'm the assigner (delegated to someone else, or both).
  return task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
}

/// What the quick-toggle checkbox should show for [task]: `true` checked,
/// `false` unchecked, `null` indeterminate (used for "on review").
bool? quickToggleValue(Task task) {
  if (task.status == TaskStatus.completed) return true;
  if (_isDelegatedToMe(task) && task.status == TaskStatus.onReview) return null;
  return false;
}

/// Label for the quick-toggle action button on the task detail screen,
/// matching what [nextStatusOnQuickToggle] is about to do.
String quickToggleActionLabel(Task task) {
  if (_isDelegatedToMe(task)) {
    return task.status == TaskStatus.onReview ? 'Back to pending' : 'Mark my part done';
  }
  return task.isCompleted ? 'Mark as pending' : 'Mark as complete';
}
