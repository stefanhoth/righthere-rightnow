import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/scheduling/notification_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AndroidFlutterLocalNotificationsPlugin.registerWith();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('notificationLaunchRunId', () {
    // Scoped to this group only: `debugDefaultTargetPlatformOverride` must
    // be back to its default before a `testWidgets` test runs, or the
    // binding's invariant check fails.
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    });

    test('is null when the app was not launched from a notification', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return {'notificationLaunchedApp': false};
      });

      expect(await notificationLaunchRunId(), isNull);
    });

    test('is the payload runId when a notification launched the app', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return {
          'notificationLaunchedApp': true,
          'notificationResponse': {
            'notificationId': 1,
            'notificationResponseType': 0,
            'payload': '42',
          },
        };
      });

      expect(await notificationLaunchRunId(), 42);
    });
  });

  group('onNotificationTap', () {
    testWidgets('pops back to the first route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('Settings')),
                ),
              ),
              child: const Text('Open Settings'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      onNotificationTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}
