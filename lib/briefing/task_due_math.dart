import 'package:righthere_rightnow/domain/task_due.dart';

/// Days a Task is overdue by, or null when it isn't overdue. Compared by
/// calendar date, ignoring time of day -- a due date is a constraint on a
/// day, not a schedule.
int? overdueDays(TaskDue? due, DateTime now) {
  if (due == null) {
    return null;
  }
  final daysPastDue = _dateOnly(now).difference(_dateOnly(due.date)).inDays;
  return daysPastDue > 0 ? daysPastDue : null;
}

/// Days until a Task is due (0 means due today), or null when it's overdue
/// or has no due date.
int? daysUntilDue(TaskDue? due, DateTime now) {
  if (due == null) {
    return null;
  }
  final daysPastDue = _dateOnly(now).difference(_dateOnly(due.date)).inDays;
  return daysPastDue > 0 ? null : -daysPastDue;
}

DateTime _dateOnly(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);
