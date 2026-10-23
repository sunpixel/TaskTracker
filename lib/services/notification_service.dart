import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

/// Local notifications for tasks: two tied to a due date (6h and 1h
/// before), plus an immediate one for "assigned to you". See
/// `server_sync_service.dart` — that's the one place the "assigned"
/// notification should actually be triggered from, not here directly.
///
/// `flutter_local_notifications` ships real implementations for every
/// platform this project targets (Android, iOS, Web, Windows, Linux) —
/// unlike sqflite/add_2_calendar, it doesn't need the conditional-import
/// trick to stay off the Web build; it already handles that itself.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _dueChannel = AndroidNotificationChannel(
    'task_due_reminders',
    'Task reminders',
    description: "Reminders as a task's due time approaches.",
    importance: Importance.defaultImportance,
  );

  static const _urgentChannel = AndroidNotificationChannel(
    'task_due_urgent',
    'Urgent task reminders',
    description: 'A task is due within the hour.',
    importance: Importance.max,
  );

  static const _assignedChannel = AndroidNotificationChannel(
    'task_assigned',
    'New assignments',
    description: 'A task has been assigned to you.',
    importance: Importance.defaultImportance,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // The device's timezone abbreviation isn't in the tz database on
      // some platforms/locales — scheduled times are still computed from
      // the device's local DateTime regardless, so this is cosmetic.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // requestXPermission flags left false here: permission is asked
        // for explicitly via requestPermissions() instead, once, at a
        // point in the UI that makes sense (not at app launch).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_dueChannel);
      await androidPlugin.createNotificationChannel(_urgentChannel);
      await androidPlugin.createNotificationChannel(_assignedChannel);
    }
  }

  /// Asks the user for notification permission. Call this from a real UI
  /// moment (e.g. a Profile toggle), not automatically at launch.
  Future<void> requestPermissions() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      return;
    }
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  int _sixHourReminderId(int taskId) => taskId * 10 + 1;
  int _oneHourReminderId(int taskId) => taskId * 10 + 2;

  /// (Re)schedules the 6h-before and 1h-before reminders for [task],
  /// replacing any previously scheduled ones for it first. Clears them
  /// (and schedules nothing new) if the task has no due date, is already
  /// completed, or a given reminder time has already passed.
  Future<void> scheduleDueReminders(Task task) async {
    final id = task.id;
    if (id == null) return;
    await cancelDueReminders(id);

    final due = task.dueAt;
    if (due == null || task.isCompleted) return;

    final now = DateTime.now();
    final sixHoursBefore = due.subtract(const Duration(hours: 6));
    final oneHourBefore = due.subtract(const Duration(hours: 1));

    if (sixHoursBefore.isAfter(now)) {
      await _scheduleAt(
        id: _sixHourReminderId(id),
        when: sixHoursBefore,
        title: '"${task.title}" is due in 6 hours',
        channel: _dueChannel,
        priority: Priority.defaultPriority,
        interruptionLevel: InterruptionLevel.active,
      );
    }
    if (oneHourBefore.isAfter(now)) {
      await _scheduleAt(
        id: _oneHourReminderId(id),
        when: oneHourBefore,
        title: '"${task.title}" is due in 1 hour',
        channel: _urgentChannel,
        priority: Priority.high,
        // Needs the 'Time Sensitive Notifications' capability enabled in
        // the Xcode project to actually break through on iOS — falls
        // back to a normal active alert without it.
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
    }
  }

  Future<void> cancelDueReminders(int taskId) async {
    await _plugin.cancel(id: _sixHourReminderId(taskId));
    await _plugin.cancel(id: _oneHourReminderId(taskId));
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required AndroidNotificationChannel channel,
    required Priority priority,
    required InterruptionLevel interruptionLevel,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: null,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: priority,
        ),
        iOS: DarwinNotificationDetails(interruptionLevel: interruptionLevel),
      ),
      // Avoids needing Android 12+'s SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM
      // permission — a reminder landing within a few minutes of the exact
      // target time is fine for this use case.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Immediate notification for a task just assigned to you by someone
  /// else. Intentionally not called anywhere outside
  /// `server_sync_service.dart` — see that file.
  Future<void> showAssignedNotification(Task task) async {
    await _plugin.show(
      id: task.id ?? 0,
      title: 'New task assigned to you',
      body: task.title,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _assignedChannel.id,
          _assignedChannel.name,
          channelDescription: _assignedChannel.description,
          importance: _assignedChannel.importance,
        ),
        iOS: const DarwinNotificationDetails(interruptionLevel: InterruptionLevel.active),
      ),
    );
  }
}
