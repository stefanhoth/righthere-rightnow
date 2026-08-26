import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:righthere_rightnow/data/calendar/calendar_exception.dart';
import 'package:righthere_rightnow/data/calendar/calendar_rsvp_channel.dart';
import 'package:righthere_rightnow/data/calendar/conference_link_extractor.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

/// Reads Commitments from the Android/iOS Calendar Provider.
///
/// The provider queries against `Instances`, so recurring events arrive
/// already expanded into one row per occurrence -- this class never expands
/// an RRULE itself.
class CalendarReader {
  CalendarReader({
    DeviceCalendar? deviceCalendar,
    CalendarRsvpChannel? rsvpChannel,
  }) : _deviceCalendar = deviceCalendar ?? DeviceCalendar(),
       _rsvpChannel = rsvpChannel ?? CalendarRsvpChannel();

  final DeviceCalendar _deviceCalendar;
  final CalendarRsvpChannel _rsvpChannel;

  Future<CalendarPermissionStatus> requestPermission() {
    return _deviceCalendar.requestPermissions();
  }

  /// Fetches Commitments overlapping the half-open range `[start, end)`,
  /// skipping calendars the user has hidden.
  ///
  /// Conference links are extracted from the description separately,
  /// without mutating it.
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
    final rsvpByKey = await _fetchRsvpWithoutThrowing(start, end);

    return events
        .map((event) => _toCommitment(event, calendarNames, rsvpByKey))
        .toList();
  }

  /// A missing or unjoinable row -- including the channel failing outright,
  /// e.g. on a platform that doesn't implement it -- degrades every
  /// Commitment to [ResponseStatus.none] and `isOrganiser: false`. It never
  /// fails the whole read.
  Future<Map<String, CalendarRsvpEntry>> _fetchRsvpWithoutThrowing(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _rsvpChannel.fetch(start: start, end: end);
    } on Exception {
      return const {};
    }
  }

  Commitment _toCommitment(
    Event event,
    Map<String, String> calendarNames,
    Map<String, CalendarRsvpEntry> rsvpByKey,
  ) {
    final rsvp =
        rsvpByKey[CalendarRsvpChannel.key(
          event.eventId,
          event.startDate.millisecondsSinceEpoch,
        )];

    return Commitment(
      id: 'cal:${event.eventId}:${event.startDate.millisecondsSinceEpoch}',
      title: event.title,
      start: event.startDate,
      end: event.endDate,
      isAllDay: event.isAllDay,
      location: event.location,
      description: event.description,
      attendeeCount: event.attendees?.length ?? 0,
      isOrganiser: rsvp?.isOrganiser ?? false,
      myResponse: rsvp?.myResponse ?? ResponseStatus.none,
      isRecurring: event.isRecurring,
      conferenceUrl: extractConferenceUrl(event.description),
      calendarName: calendarNames[event.calendarId] ?? event.calendarId,
    );
  }
}
