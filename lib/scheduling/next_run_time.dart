/// The next occurrence of [hour]:[minute] at or after [now]: today if that
/// time hasn't passed yet, tomorrow otherwise.
DateTime nextRunTime(DateTime now, {required int hour, required int minute}) {
  final todayAtRunTime = DateTime(now.year, now.month, now.day, hour, minute);
  return todayAtRunTime.isAfter(now)
      ? todayAtRunTime
      : todayAtRunTime.add(const Duration(days: 1));
}
