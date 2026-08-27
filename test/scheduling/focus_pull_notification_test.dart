import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';
import 'package:righthere_rightnow/scheduling/focus_pull_notification.dart';

Commitment _commitment(String id, DateTime start) {
  return Commitment(
    id: id,
    title: id,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    isAllDay: false,
    attendeeCount: 2,
    isOrganiser: false,
    myResponse: ResponseStatus.accepted,
    isRecurring: false,
    calendarName: 'Work',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  AndroidFlutterLocalNotificationsPlugin.registerWith();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;

  setUp(() async {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'initialize' ? true : null;
    });
    await initializeFocusPullNotifications();
    calls.clear();
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('shows the verbatim titles of the top two ranked items', () async {
    await showFocusPullNotification(
      rankedItems: [
        _commitment('cal:standup', DateTime(2026, 8, 26, 9)),
        const Task(
          id: 'td:taxes',
          title: 'File taxes',
          priority: Priority.p1,
          isRecurring: false,
        ),
        const Task(
          id: 'td:other',
          title: 'Should not appear',
          priority: Priority.p4,
          isRecurring: false,
        ),
      ],
      runId: 42,
    );

    expect(calls, hasLength(1));
    expect(calls.single.method, 'show');
    final args = calls.single.arguments as Map<dynamic, dynamic>;
    expect(args['title'], contains('cal:standup'));
    expect(args['body'], 'File taxes');
    expect(args['payload'], '42');
  });

  test('a Commitment title includes its start time', () async {
    await showFocusPullNotification(
      rankedItems: [_commitment('Standup', DateTime(2026, 8, 26, 9))],
      runId: 1,
    );

    final args = calls.single.arguments as Map<dynamic, dynamic>;
    expect(args['title'], contains('Standup'));
    expect(args['title'], isNot('Standup'));
  });

  test('a Task with no due date has no time suffix', () async {
    await showFocusPullNotification(
      rankedItems: const [
        Task(
          id: 'td:x',
          title: 'Someday maybe',
          priority: Priority.p3,
          isRecurring: false,
        ),
      ],
      runId: 1,
    );

    final args = calls.single.arguments as Map<dynamic, dynamic>;
    expect(args['title'], 'Someday maybe');
  });

  test('a Task due today includes its due date', () async {
    await showFocusPullNotification(
      rankedItems: [
        Task(
          id: 'td:due',
          title: 'Renew passport',
          priority: Priority.p2,
          isRecurring: false,
          due: TaskDue(
            date: DateTime(2026, 8, 26),
            hasTime: false,
            isRecurring: false,
          ),
        ),
      ],
      runId: 1,
    );

    final args = calls.single.arguments as Map<dynamic, dynamic>;
    expect(args['title'], contains('Renew passport'));
    expect(args['title'], isNot('Renew passport'));
  });

  test('an empty agenda shows no notification', () async {
    await showFocusPullNotification(rankedItems: const [], runId: 1);

    expect(calls, isEmpty);
  });

  test(
    'the channel is silent, low importance, and public on the lock screen',
    () async {
      await showFocusPullNotification(
        rankedItems: [_commitment('Standup', DateTime(2026, 8, 26, 9))],
        runId: 1,
      );

      final args = calls.single.arguments as Map<dynamic, dynamic>;
      final platformSpecifics =
          args['platformSpecifics'] as Map<dynamic, dynamic>;
      expect(platformSpecifics['silent'], isTrue);
      expect(platformSpecifics['playSound'], isFalse);
      expect(platformSpecifics['enableVibration'], isFalse);
      expect(platformSpecifics['importance'], 2); // Importance.low
      expect(
        platformSpecifics['visibility'],
        1,
      ); // NotificationVisibility.public
    },
  );
}
