import 'package:intl/intl.dart';

/// A short label for the day a Commitment falls on, so Agenda Items drawn
/// from different days of the Candidate Set window do not all read as today.
///
/// The window runs from the start of the previous working day to the first
/// Commitment tomorrow, so the cases that matter are "Yesterday", "Today",
/// "Tomorrow", and -- on a Monday run -- the names of the intervening
/// weekend days. Anything further out falls back to a short date.
String dayLabel(DateTime day, DateTime now) {
  final dayDate = DateTime(day.year, day.month, day.day);
  final nowDate = DateTime(now.year, now.month, now.day);
  final deltaDays = dayDate.difference(nowDate).inDays;

  return switch (deltaDays) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    _ when deltaDays.abs() < 7 => DateFormat.E().format(day),
    _ => DateFormat.MMMd().format(day),
  };
}
