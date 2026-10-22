import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';

import '../models/task.dart';
import 'calendar_add_outcome.dart';

/// Native implementation of the conditional import in
/// `calendar_service.dart`. `add_2_calendar` itself only has Android/iOS
/// native code, so desktop (dart:io, but no plugin) reports unsupported
/// too, same as Web.
Future<CalendarAddOutcome> addTaskToCalendar(Task task) async {
  final due = task.dueAt;
  if (due == null) return CalendarAddOutcome.noDueDate;
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return CalendarAddOutcome.unsupportedPlatform;
  }

  final event = Event(
    title: task.title,
    description: task.description,
    startDate: due,
    endDate: due.add(const Duration(minutes: 30)),
    iosParams: const IOSParams(reminder: Duration(hours: 1)),
  );
  final success = await Add2Calendar.addEvent2Cal(event);
  return success ? CalendarAddOutcome.added : CalendarAddOutcome.failed;
}
