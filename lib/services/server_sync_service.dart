import '../data/current_user.dart';
import '../models/task.dart';
import 'notification_service.dart';

/// Single seam for everything that will eventually be a real call to the
/// backend (the RabbitMQ-based server mentioned early on, not built yet).
///
/// Right now there's nothing to actually call — every method here is a
/// local stand-in for the network behavior it'll have once a server
/// exists. The point of keeping it in one file is that swapping the
/// insides for real HTTP/queue calls later should only ever touch this
/// file, not every place in the app that currently calls it.
class ServerSyncService {
  ServerSyncService._();
  static final ServerSyncService instance = ServerSyncService._();

  /// Called whenever a task is saved (created or edited) that assigns it
  /// to someone.
  ///
  /// TODO(server): once a backend exists, this should push the task to
  /// the assignee's account, and it's the **server** that pushes a real
  /// notification to their device from there — this method would then
  /// just be the outgoing half (upload the task), with the notification
  /// arriving separately via FCM/APNs.
  ///
  /// Until then, there's no one else's device to notify — so as a local
  /// stand-in, if the save makes *you* the assignee of a task someone
  /// else is the assigner of, this fires the "assigned to you"
  /// notification directly, right here. It's the one scenario this can
  /// genuinely demonstrate without a server: tasks already in your local
  /// contacts' data (e.g. seeded demo tasks from "alex"). A task you
  /// create yourself can never trigger this, since the assigner is
  /// always fixed to you at creation — see `task_detail_screen.dart`.
  Future<void> notifyTaskAssigned(Task task) async {
    final isAssignedToMeByOther =
        task.assignee == currentUserId && task.assigner != currentUserId;
    if (!isAssignedToMeByOther) return;
    await NotificationService.instance.showAssignedNotification(task);
  }

  // Natural next additions once a backend exists, kept here as a map of
  // what this file is for — not implemented, just named:
  // Future<void> pushTask(Task task) => ...;
  // Future<void> pullTasksForCurrentUser() => ...;
  // Future<List<User>> searchUsersByUsername(String query) => ...;
}
