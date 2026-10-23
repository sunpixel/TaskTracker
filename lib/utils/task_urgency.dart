import 'package:flutter/material.dart';

import '../models/task.dart';

enum TaskUrgency {
  /// Overdue, or due within the hour.
  critical,

  /// Due within 6 hours (but not within the hour).
  urgent,

  /// Due on tomorrow's calendar date. Colored yellow — a clearer "heads
  /// up" signal than the blue this used to be.
  dueTomorrow,

  /// Due within the next 7 calendar days (but not tomorrow).
  dueThisWeek,

  /// No due date, completed, or more than a week out.
  normal,
}

/// Buckets [task] by how pressing its deadline is.
///
/// The thresholds given ("under 6h", "within the hour", "tomorrow",
/// "within a week") overlap by construction, so this checks the most
/// specific/urgent bucket first: an overdue or <1h task is also <6h, and
/// "tomorrow" is also "within a week" — the narrower bucket wins each time.
TaskUrgency urgencyOf(Task task) {
  final due = task.dueAt;
  if (due == null || task.isCompleted) return TaskUrgency.normal;

  final now = DateTime.now();
  final remaining = due.difference(now);
  if (remaining.isNegative || remaining <= const Duration(hours: 1)) {
    return TaskUrgency.critical;
  }
  if (remaining <= const Duration(hours: 6)) {
    return TaskUrgency.urgent;
  }

  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final daysAhead = dueDay.difference(today).inDays;
  if (daysAhead == 1) return TaskUrgency.dueTomorrow;
  if (daysAhead >= 0 && daysAhead <= 7) return TaskUrgency.dueThisWeek;
  return TaskUrgency.normal;
}

class TaskUrgencyColors {
  final Color background;
  final Color onBackground;
  const TaskUrgencyColors(this.background, this.onBackground);
}

/// Background/foreground colors for [urgency], or `null` for
/// [TaskUrgency.normal] — callers should fall back to the theme's usual
/// card color in that case rather than override it.
TaskUrgencyColors? urgencyColors(TaskUrgency urgency, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  switch (urgency) {
    case TaskUrgency.critical: // strong red — most alarming
      return dark
          ? const TaskUrgencyColors(Color(0xFF601410), Color(0xFFFFDAD6))
          : const TaskUrgencyColors(Color(0xFFE57373), Color(0xFF3B0000));
    case TaskUrgency.urgent: // orange — distinct hue from critical's red
      return dark
          ? const TaskUrgencyColors(Color(0xFF4A2E00), Color(0xFFFFCC80))
          : const TaskUrgencyColors(Color(0xFFFFB74D), Color(0xFF4A2800));
    case TaskUrgency.dueTomorrow: // yellow
      return dark
          ? const TaskUrgencyColors(Color(0xFF4A3B00), Color(0xFFFFE082))
          : const TaskUrgencyColors(Color(0xFFFFCA28), Color(0xFF4A3800));
    case TaskUrgency.dueThisWeek: // green
      return dark
          ? const TaskUrgencyColors(Color(0xFF1E4620), Color(0xFFC2F2C3))
          : const TaskUrgencyColors(Color(0xFF81C784), Color(0xFF0B3D0F));
    case TaskUrgency.normal:
      return null;
  }
}
