import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/calendar/calendar_exception.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/calendar/calendar_rsvp_channel.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

class _MockDeviceCalendar extends Mock implements DeviceCalendar {}

class _MockCalendarRsvpChannel extends Mock implements CalendarRsvpChannel {}

Calendar _calendar({
  required String id,
  required String name,
  bool hidden = false,
}) {
  return Calendar(id: id, name: name, readOnly: false, hidden: hidden);
}

Event _event({
  required String eventId,
  required DateTime start,
  required DateTime end,
  String? instanceId,
  String calendarId = 'work',
  String title = 'Untitled',
  bool isAllDay = false,
  bool isRecurring = false,
  List<Attendee>? attendees,
}) {
  return Event(
    eventId: eventId,
    instanceId: instanceId ?? '$eventId@${start.millisecondsSinceEpoch}',
    calendarId: calendarId,
    title: title,
    startDate: start,
    endDate: end,
    isAllDay: isAllDay,
    availability: EventAvailability.busy,
    status: EventStatus.confirmed,
    isRecurring: isRecurring,
    attendees: attendees,
  );
}

void main() {
  late _MockDeviceCalendar deviceCalendar;
  late _MockCalendarRsvpChannel rsvpChannel;
  late CalendarReader reader;

  final start = DateTime.utc(2026, 8, 26);
  final end = DateTime.utc(2026, 8, 27);

  setUpAll(() {
    registerFallbackValue(DateTime(0));
  });

  setUp(() {
    deviceCalendar = _MockDeviceCalendar();
    rsvpChannel = _MockCalendarRsvpChannel();
    reader = CalendarReader(
      deviceCalendar: deviceCalendar,
      rsvpChannel: rsvpChannel,
    );
    when(() => deviceCalendar.hasPermissions())
        .thenAnswer((_) async => CalendarPermissionStatus.granted);
    when(() => deviceCalendar.listCalendars())
        .thenAnswer((_) async => [_calendar(id: 'work', name: 'Work')]);
    when(
      () => rsvpChannel.fetch(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => {});
  });

  test('permission not granted throws a typed exception', () async {
    when(() => deviceCalendar.hasPermissions())
        .thenAnswer((_) async => CalendarPermissionStatus.denied);

    expect(
      () => reader.fetchCommitments(start: start, end: end),
      throwsA(isA<CalendarPermissionDeniedException>()),
    );
  });

  test('skips calendars the user has hidden', () async {
    when(() => deviceCalendar.listCalendars()).thenAnswer(
      (_) async => [
        _calendar(id: 'work', name: 'Work'),
        _calendar(id: 'archived', name: 'Archived', hidden: true),
      ],
    );
    when(
      () => deviceCalendar.listEvents(
        any(),
        any(),
        calendarIds: any(named: 'calendarIds'),
      ),
    ).thenAnswer((_) async => []);

    await reader.fetchCommitments(start: start, end: end);

    final calendarIds =
        verify(
              () => deviceCalendar.listEvents(
                any(),
                any(),
                calendarIds: captureAny(named: 'calendarIds'),
              ),
            ).captured.single
            as List<String>;
    expect(calendarIds, ['work']);
  });

  test(
    'a recurring event appears once per occurrence, not once per series',
    () async {
      when(
        () => deviceCalendar.listEvents(
          any(),
          any(),
          calendarIds: any(named: 'calendarIds'),
        ),
      ).thenAnswer(
        (_) async => [
          _event(
            eventId: 'standup',
            title: 'Standup',
            start: DateTime.utc(2026, 8, 26, 9),
            end: DateTime.utc(2026, 8, 26, 9, 15),
            isRecurring: true,
          ),
          _event(
            eventId: 'standup',
            title: 'Standup',
            start: DateTime.utc(2026, 8, 27, 9),
            end: DateTime.utc(2026, 8, 27, 9, 15),
            isRecurring: true,
          ),
        ],
      );

      final commitments = await reader.fetchCommitments(start: start, end: end);

      expect(commitments, hasLength(2));
      expect(commitments.map((c) => c.id).toSet(), hasLength(2));
      expect(commitments.every((c) => c.isRecurring), isTrue);
    },
  );

  test('an all-day event is flagged, not midnight-to-midnight', () async {
    final allDayStart = DateTime.utc(2026, 8, 26);
    final allDayEnd = DateTime.utc(2026, 8, 27);
    when(
      () => deviceCalendar.listEvents(
        any(),
        any(),
        calendarIds: any(named: 'calendarIds'),
      ),
    ).thenAnswer(
      (_) async => [
        _event(
          eventId: 'offsite',
          title: 'Company offsite',
          start: allDayStart,
          end: allDayEnd,
          isAllDay: true,
        ),
      ],
    );

    final commitments = await reader.fetchCommitments(start: start, end: end);

    expect(commitments.single.isAllDay, isTrue);
    expect(commitments.single.start, allDayStart);
    expect(commitments.single.end, allDayEnd);
  });

  test('maps calendar id to its name and counts attendees', () async {
    when(
      () => deviceCalendar.listEvents(
        any(),
        any(),
        calendarIds: any(named: 'calendarIds'),
      ),
    ).thenAnswer(
      (_) async => [
        _event(
          eventId: 'planning',
          start: DateTime.utc(2026, 8, 26, 10),
          end: DateTime.utc(2026, 8, 26, 11),
          attendees: [
            const Attendee(
              role: AttendeeRole.required,
              status: AttendeeStatus.accepted,
            ),
            const Attendee(
              role: AttendeeRole.optional,
              status: AttendeeStatus.none,
            ),
          ],
        ),
      ],
    );

    final commitments = await reader.fetchCommitments(start: start, end: end);

    expect(commitments.single.calendarName, 'Work');
    expect(commitments.single.attendeeCount, 2);
  });

  group('RSVP and organiser join', () {
    void stubEvent(String eventId, DateTime eventStart, DateTime eventEnd) {
      when(
        () => deviceCalendar.listEvents(
          any(),
          any(),
          calendarIds: any(named: 'calendarIds'),
        ),
      ).thenAnswer(
        (_) async => [
          _event(eventId: eventId, start: eventStart, end: eventEnd),
        ],
      );
    }

    test('a declined meeting reports myResponse == declined', () async {
      final eventStart = DateTime.utc(2026, 8, 26, 14);
      stubEvent(
        'declined-meeting',
        eventStart,
        eventStart.add(const Duration(hours: 1)),
      );
      when(
        () => rsvpChannel.fetch(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer(
        (_) async => {
          CalendarRsvpChannel.key(
            'declined-meeting',
            eventStart.millisecondsSinceEpoch,
          ): const CalendarRsvpEntry(
            myResponse: ResponseStatus.declined,
            isOrganiser: false,
          ),
        },
      );

      final commitments = await reader.fetchCommitments(start: start, end: end);

      expect(commitments.single.myResponse, ResponseStatus.declined);
    });

    test('a meeting you created reports isOrganiser == true', () async {
      final eventStart = DateTime.utc(2026, 8, 26, 15);
      stubEvent(
        'my-meeting',
        eventStart,
        eventStart.add(const Duration(hours: 1)),
      );
      when(
        () => rsvpChannel.fetch(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer(
        (_) async => {
          CalendarRsvpChannel.key(
            'my-meeting',
            eventStart.millisecondsSinceEpoch,
          ): const CalendarRsvpEntry(
            myResponse: ResponseStatus.accepted,
            isOrganiser: true,
          ),
        },
      );

      final commitments = await reader.fetchCommitments(start: start, end: end);

      expect(commitments.single.isOrganiser, isTrue);
    });

    test('an unjoinable row degrades to none/false, never throws', () async {
      final eventStart = DateTime.utc(2026, 8, 26, 16);
      stubEvent(
        'unjoined',
        eventStart,
        eventStart.add(const Duration(hours: 1)),
      );
      when(
        () => rsvpChannel.fetch(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => {});

      final commitments = await reader.fetchCommitments(start: start, end: end);

      expect(commitments.single.myResponse, ResponseStatus.none);
      expect(commitments.single.isOrganiser, isFalse);
    });

    test('the RSVP channel failing outright never fails the read', () async {
      final eventStart = DateTime.utc(2026, 8, 26, 17);
      stubEvent(
        'channel-down',
        eventStart,
        eventStart.add(const Duration(hours: 1)),
      );
      when(
        () => rsvpChannel.fetch(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenThrow(Exception('platform channel unavailable'));

      final commitments = await reader.fetchCommitments(start: start, end: end);

      expect(commitments.single.myResponse, ResponseStatus.none);
      expect(commitments.single.isOrganiser, isFalse);
    });
  });
}
