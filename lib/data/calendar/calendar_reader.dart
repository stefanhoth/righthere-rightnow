import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:righthere_rightnow/data/calendar/calendar_exception.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

/// Reads Commitments from the Android/iOS Calendar Provider.
///
/// The provider queries against `Instances`, so recurring events arrive
/// already expanded into one row per occurrence -- this class never expands
/// an RRULE itself.
class CalendarReader {
  CalendarReader({DeviceCalendar? deviceCalendar})
    : _deviceCalendar = deviceCalendar ?? DeviceCalendar();

  final DeviceCalendar _deviceCalendar;

  Future<CalendarPermissionStatus> requestPermission() {
    return _deviceCalendar.requestPermissions();
  }

  /// Fetches Commitments overlapping the half-open range `[start, end)`,
  /// skipping calendars the user has hidden.
  ///
  /// RSVP response and organiser status are not available through this
  /// plugin (see ADR-0001) and are left at their defaults here; a platform
  /// channel joins them in afterwards. Conference links are extracted from
  /// the description separately, without mutating it.
  Future<List<Commitment>> fetchCommitments({
    required DateTime start,
    required DateTime end,
  }) async {
    final permission = await _deviceCalendar.hasPermissions();
    if (permission != CalendarPermissionStatus.granted) {
      throw const CalendarPermissionDeniedException();
    }

    final visibleCalendars = (await _deviceCalendar.listCalendars())
        .where((calendar) => !calendar.hidden)
        .toList();
    final calendarNames = {
      for (final calendar in visibleCalendars) calendar.id: calendar.name,
    };

    final events = await _deviceCalendar.listEvents(
      start,
      end,
      calendarIds: visibleCalendars.map((calendar) => calendar.id).toList(),
    );

    return events.map((event) => _toCommitment(event, calendarNames)).toList();
  }

  Commitment _toCommitment(Event event, Map<String, String> calendarNames) {
    return Commitment(
      id: 'cal:${event.eventId}:${event.startDate.millisecondsSinceEpoch}',
      title: event.title,
      start: event.startDate,
      end: event.endDate,
      isAllDay: event.isAllDay,
      location: event.location,
      description: event.description,
      attendeeCount: event.attendees?.length ?? 0,
      isOrganiser: false,
      myResponse: ResponseStatus.none,
      isRecurring: event.isRecurring,
      calendarName: calendarNames[event.calendarId] ?? event.calendarId,
    );
  }
}
