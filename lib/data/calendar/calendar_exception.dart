/// Base type for calendar-reading failures that callers should handle, as
/// distinct from a crash.
sealed class CalendarException implements Exception {
  const CalendarException(this.message);

  final String message;

  @override
  String toString() => 'CalendarException: $message';
}

/// `READ_CALENDAR` has not been granted (or has been denied).
class CalendarPermissionDeniedException extends CalendarException {
  const CalendarPermissionDeniedException()
    : super('Calendar permission has not been granted.');
}
