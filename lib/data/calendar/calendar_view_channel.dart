import 'package:flutter/services.dart';

/// Opens one occurrence of a calendar Event in whichever app handles the
/// device's calendar.
///
/// Not `url_launcher`: landing on the right occurrence of a recurring Event
/// needs `EXTRA_EVENT_BEGIN_TIME` on the Intent, and `url_launcher` can only
/// carry a URI. A `content://` URI alone opens the series, so a daily
/// standup tapped on Thursday would open Monday's.
///
/// Android only, matching the rest of this app.
class CalendarViewChannel {
  CalendarViewChannel({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel(
            'com.stefanhoth.righthere_rightnow/calendar_view',
          );

  final MethodChannel _channel;

  /// Returns false when no installed app can show the Event. Throws only if
  /// the platform side fails outright.
  Future<bool> openEvent({
    required String eventId,
    required int beginMillis,
  }) async {
    final opened = await _channel.invokeMethod<bool>('viewEvent', {
      'eventId': eventId,
      'beginMillis': beginMillis,
    });
    return opened ?? false;
  }
}
