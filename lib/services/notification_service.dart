import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/generated/app_localizations.dart';
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

  /// This service has no `BuildContext` (it's triggered from `TaskStore`/
  /// `ServerSyncService`, not a widget), so it can't read the in-app
  /// language override the Profile screen sets — it always renders
  /// notification text in the device's own system language instead,
  /// falling back to English if that language isn't one of the three
  /// supported. This is a deliberate scope simplification: the OS tray
  /// itself (timestamps, action buttons) already renders in the system
  /// language regardless of any in-app override, so keeping notification
  /// body text consistent with that is more coherent than threading the
  /// in-app locale through here just for two strings.
  AppLocalizations _l10n() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales
        .any((l) => l.languageCode == deviceLocale.languageCode);
    return lookupAppLocalizations(supported ? deviceLocale : const Locale('en'));
  }

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

  /// flutter_local_notifications needs a plain int id, but a task's id
  /// is a GUID string — this derives a stable one from it (FNV-1a, not
  /// Dart's `String.hashCode`, which isn't guaranteed stable across runs)
  /// so the *same* task always maps to the *same* notification id,
  /// letting it be rescheduled/cancelled correctly later. Masked to 28
  /// bits so `* 4 + 0..3` below still fits a 32-bit signed int.
  int _baseNotificationId(String taskId) {
    const prime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(taskId)) {
      hash ^= byte;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash & 0x0FFFFFFF;
  }

  int _sixHourReminderId(String taskId) => _baseNotificationId(taskId) * 4 + 1;
  int _oneHourReminderId(String taskId) => _baseNotificationId(taskId) * 4 + 2;
  int _assignedNotificationId(String taskId) => _baseNotificationId(taskId) * 4 + 3;

  /// (Re)schedules the 6h-before and 1h-before reminders for [task],
  /// replacing any previously scheduled ones for it first. Clears them
  /// (and schedules nothing new) if the task has no due date, is already
  /// completed, or a given reminder time has already passed.
  Future<void> scheduleDueReminders(Task task) async {
    await cancelDueReminders(task.id);

    final due = task.dueAt;
    if (due == null || task.isCompleted) return;

    final now = DateTime.now();
    final sixHoursBefore = due.subtract(const Duration(hours: 6));
    final oneHourBefore = due.subtract(const Duration(hours: 1));
    final l10n = _l10n();

    if (sixHoursBefore.isAfter(now)) {
      await _scheduleAt(
        id: _sixHourReminderId(task.id),
        when: sixHoursBefore,
        title: l10n.notificationDueIn(task.title, 6),
        channel: _dueChannel,
        priority: Priority.defaultPriority,
        interruptionLevel: InterruptionLevel.active,
      );
    }
    if (oneHourBefore.isAfter(now)) {
      await _scheduleAt(
        id: _oneHourReminderId(task.id),
        when: oneHourBefore,
        title: l10n.notificationDueIn(task.title, 1),
        channel: _urgentChannel,
        priority: Priority.high,
        // Needs the 'Time Sensitive Notifications' capability enabled in
        // the Xcode project to actually break through on iOS — falls
        // back to a normal active alert without it.
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
    }
  }

  Future<void> cancelDueReminders(String taskId) async {
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
      id: _assignedNotificationId(task.id),
      title: _l10n().notificationAssignedTitle,
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
