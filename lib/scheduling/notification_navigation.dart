import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shared with `MaterialApp.navigatorKey`, so a notification tap can get
/// back to the Daily Agenda no matter which screen is on top of it.
final navigatorKey = GlobalKey<NavigatorState>();

/// Handles a tap while the app is already running -- foreground or
/// backgrounded. Never wired to `onDidReceiveBackgroundNotificationResponse`:
/// that callback runs in a separate isolate with no UI, so it cannot
/// navigate. It exists only for notification-action side effects, and this
/// app has none.
void onNotificationTap(NotificationResponse response) {
  navigatorKey.currentState?.popUntil((route) => route.isFirst);
}

/// The runId from the notification that cold-started the app, or null if
/// the app was opened any other way. Read once at startup, before the
/// widget tree is built.
Future<int?> notificationLaunchRunId() async {
  final details = await FlutterLocalNotificationsPlugin()
      .getNotificationAppLaunchDetails();
  if (details?.didNotificationLaunchApp != true) {
    return null;
  }
  return int.tryParse(details!.notificationResponse?.payload ?? '');
}
