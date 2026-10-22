import '../models/task.dart';
import 'calendar_add_outcome.dart';
import 'calendar_service_unsupported.dart'
    if (dart.library.io) 'calendar_service_io.dart' as impl;

export 'calendar_add_outcome.dart';

/// Hands [task] off to the device's Calendar app, pre-filled, for the
/// user to save (not a silent write). The event spans 30 minutes starting
/// at the task's due date, with a 1-hour-before reminder requested — only
/// iOS's Calendar reliably honors a custom reminder offset this way;
/// Android's calendar app applies its own default instead.
///
/// Only implemented for Android/iOS (the `add_2_calendar` package's own
/// platform support); everywhere else — Web included — this is a no-op
/// that reports [CalendarAddOutcome.unsupportedPlatform].
Future<CalendarAddOutcome> addTaskToCalendar(Task task) => impl.addTaskToCalendar(task);
