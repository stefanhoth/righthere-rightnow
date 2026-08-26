import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

/// RSVP response and organiser status for one calendar event occurrence, as
/// supplied by the native side.
@immutable
class CalendarRsvpEntry {
  const CalendarRsvpEntry({
    required this.myResponse,
    required this.isOrganiser,
  });

  final ResponseStatus myResponse;
  final bool isOrganiser;
}

/// Joins in the RSVP response and organiser status that
/// `device_calendar_plus` doesn't expose (see docs/adr/0001), via a small
/// platform channel querying `CalendarContract.Instances`.
///
/// Android only, matching the rest of this app.
class CalendarRsvpChannel {
  CalendarRsvpChannel({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel(
            'com.stefanhoth.righthere_rightnow/calendar_rsvp',
          );

  final MethodChannel _channel;

  /// Keyed by [key] on (eventId, begin) -- the same pair the plugin's
  /// `instanceId` is built from.
  Future<Map<String, CalendarRsvpEntry>> fetch({
    required DateTime start,
    required DateTime end,
  }) async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'queryRsvpAndOrganiser',
      {
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
      },
    );

    final entries = <String, CalendarRsvpEntry>{};
    for (final rawRow in raw ?? const []) {
      final row = (rawRow as Map).cast<String, Object?>();
      final eventId = row['eventId'] as String?;
      final begin = row['begin'] as int?;
      if (eventId == null || begin == null) {
        continue;
      }
      entries[key(eventId, begin)] = CalendarRsvpEntry(
        myResponse: _responseFromRaw(row['selfAttendeeStatus'] as int?),
        isOrganiser: row['isOrganizer'] as bool? ?? false,
      );
    }
    return entries;
  }

  static String key(String eventId, int beginMillis) => '$eventId:$beginMillis';

  /// Matches `Events.SELF_ATTENDEE_STATUS`: 0 none, 1 accepted, 2 declined,
  /// 3 invited, 4 tentative.
  ResponseStatus _responseFromRaw(int? raw) {
    return switch (raw) {
      0 => ResponseStatus.none,
      1 => ResponseStatus.accepted,
      2 => ResponseStatus.declined,
      3 => ResponseStatus.invited,
      4 => ResponseStatus.tentative,
      _ => ResponseStatus.none,
    };
  }
}
