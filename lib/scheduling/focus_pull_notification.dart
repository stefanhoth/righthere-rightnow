import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';

/// Importance is immutable after a notification channel is created -- once
/// created, the user owns it and it can never be raised or lowered in code.
/// Versioned from day one so a future change to these settings can ship as a
/// new channel instead of silently failing to apply.
const _channelId = 'daily_briefing_v1';
const _notificationId = 1;

final _plugin = FlutterLocalNotificationsPlugin();

/// Call once in any isolate before showing a notification from it -- the
/// foreground service isolate is not the one `main()` ran in, and this
/// plugin's Dart-side state is per-isolate.
Future<void> initializeFocusPullNotifications({
  DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
}) async {
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );
}

/// Android 13+ hides notification content entirely without this. A no-op on
/// older versions and once already granted or permanently denied.
Future<void> requestFocusPullNotificationPermission() async {
  await _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
}

/// Shows the Focus Pull: the verbatim titles of the top two Agenda Items,
/// with their times. No generated text -- inference never runs in the
/// background (ADR-0006), so the lock screen can never show a hallucination.
///
/// Silent but visible: no sound or vibration, but present and legible on the
/// lock screen (`Importance.min` would hide it there entirely).
Future<void> showFocusPullNotification({
  required List<AgendaItem> rankedItems,
  required int runId,
}) async {
  if (rankedItems.isEmpty) {
    return;
  }
  final lines = rankedItems.take(2).map(_focusPullLine).toList();

  await _plugin.show(
    id: _notificationId,
    title: lines[0],
    body: lines.length > 1 ? lines[1] : null,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Daily Agenda',
        channelDescription: 'Your top two Agenda Items each morning.',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        silent: true,
        visibility: NotificationVisibility.public,
        onlyAlertOnce: true,
      ),
    ),
    payload: runId.toString(),
  );
}

String _focusPullLine(AgendaItem item) {
  final time = _timeLabel(item);
  return time == null ? item.title : '${item.title} -- $time';
}

String? _timeLabel(AgendaItem item) {
  return switch (item) {
    Commitment() => DateFormat.jm().format(item.start),
    Task(due: null) => null,
    Task(:final due?) when due.hasTime => DateFormat.yMMMd().add_jm().format(
      due.date,
    ),
    Task(:final due?) => DateFormat.yMMMd().format(due.date),
  };
}
