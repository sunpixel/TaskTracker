import '../models/task.dart';
import 'calendar_add_outcome.dart';

/// Web implementation of the conditional import in `calendar_service.dart`.
Future<CalendarAddOutcome> addTaskToCalendar(Task task) async =>
    task.dueAt == null ? CalendarAddOutcome.noDueDate : CalendarAddOutcome.unsupportedPlatform;
