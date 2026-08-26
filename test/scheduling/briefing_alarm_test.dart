import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/scheduling/briefing_alarm.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const alarmChannel = MethodChannel(
    'dev.fluttercommunity.plus/android_alarm_manager',
    JSONMethodCodec(),
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    AndroidAlarmManager.setTestOverrides(
      getCallbackHandle: (callback) => CallbackHandle.fromRawHandle(1),
    );
    messenger.setMockMethodCallHandler(alarmChannel, (call) async {
      calls.add(call);
      return true;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(alarmChannel, null);
  });

  test('schedules an exact, wake, reboot-persistent alarm', () async {
    await scheduleNextBriefingAlarm(
      now: DateTime(2026, 8, 26, 4),
      runTime: RunTime.defaultValue,
    );

    expect(calls, hasLength(1));
    expect(calls.single.method, 'Alarm.oneShotAt');
    final args = calls.single.arguments as List<dynamic>;
    final [
      id,
      alarmClock,
      allowWhileIdle,
      exact,
      wakeup,
      startMillis,
      rescheduleOnReboot,
      ...,
    ] = args;

    expect(id, briefingAlarmId);
    expect(alarmClock, isFalse);
    expect(allowWhileIdle, isTrue);
    expect(exact, isTrue);
    expect(wakeup, isTrue);
    expect(rescheduleOnReboot, isTrue);
    expect(
      DateTime.fromMillisecondsSinceEpoch(startMillis as int),
      DateTime(2026, 8, 26, 5, 30),
    );
  });

  test("re-arms for tomorrow when today's run time has passed", () async {
    await scheduleNextBriefingAlarm(
      now: DateTime(2026, 8, 26, 6),
      runTime: RunTime.defaultValue,
    );

    final args = calls.single.arguments as List<dynamic>;
    expect(
      DateTime.fromMillisecondsSinceEpoch(args[5] as int),
      DateTime(2026, 8, 27, 5, 30),
    );
  });
}
