import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/calendar/calendar_rsvp_channel.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'com.stefanhoth.righthere_rightnow/calendar_rsvp';
  const methodChannel = MethodChannel(channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late CalendarRsvpChannel rsvpChannel;

  setUp(() {
    rsvpChannel = CalendarRsvpChannel(channel: methodChannel);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  test('keys entries by eventId and begin', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      return [
        {
          'eventId': '123',
          'begin': 456,
          'selfAttendeeStatus': 2,
          'isOrganizer': false,
        },
      ];
    });

    final entries = await rsvpChannel.fetch(
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
    );

    expect(entries.keys, [CalendarRsvpChannel.key('123', 456)]);
  });

  test('a declined meeting reports myResponse == declined', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      return [
        {
          'eventId': '1',
          'begin': 1000,
          'selfAttendeeStatus': 2,
          'isOrganizer': false,
        },
      ];
    });

    final entries = await rsvpChannel.fetch(
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
    );

    expect(
      entries[CalendarRsvpChannel.key('1', 1000)]!.myResponse,
      ResponseStatus.declined,
    );
  });

  test('a meeting you created reports isOrganiser == true', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      return [
        {
          'eventId': '2',
          'begin': 2000,
          'selfAttendeeStatus': 1,
          'isOrganizer': true,
        },
      ];
    });

    final entries = await rsvpChannel.fetch(
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
    );

    expect(entries[CalendarRsvpChannel.key('2', 2000)]!.isOrganiser, isTrue);
  });

  test('a row missing eventId or begin is skipped, not crashed on', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      return [
        {'begin': 1000, 'selfAttendeeStatus': 1, 'isOrganizer': false},
        {
          'eventId': '3',
          'begin': 3000,
          'selfAttendeeStatus': 1,
          'isOrganizer': false,
        },
      ];
    });

    final entries = await rsvpChannel.fetch(
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
    );

    expect(entries, hasLength(1));
    expect(entries.keys, [CalendarRsvpChannel.key('3', 3000)]);
  });

  test('a null result (nothing in range) is an empty map', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async => null);

    final entries = await rsvpChannel.fetch(
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
    );

    expect(entries, isEmpty);
  });
}
