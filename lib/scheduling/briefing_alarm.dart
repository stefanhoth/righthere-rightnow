import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:righthere_rightnow/data/settings/run_time_storage.dart';
import 'package:righthere_rightnow/scheduling/next_run_time.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';

/// `android_alarm_manager_plus` has no exact repeating alarm -- each run
/// re-arms the next one, and this id is reused so a re-arm always replaces
/// rather than duplicates the pending alarm.
const briefingAlarmId = 0;

const _rearmChannel = MethodChannel(
  'com.stefanhoth.righthere_rightnow/alarm_rearm',
);

/// Signals `RearmBroadcastReceiver` that it can release the broadcast and
/// tear down the headless engine it started for [rearmDispatcher].
const _rearmCompleteChannel = MethodChannel(
  'com.stefanhoth.righthere_rightnow/alarm_rearm_complete',
);

/// Call once at app startup, before scheduling anything.
Future<void> initializeBriefingAlarm() async {
  await AndroidAlarmManager.initialize();
  // Persisted natively so RearmBroadcastReceiver can start a headless
  // isolate from a plain BroadcastReceiver, with no Flutter engine already
  // running -- see android/.../RearmBroadcastReceiver.kt.
  final handle = PluginUtilities.getCallbackHandle(rearmDispatcher);
  if (handle != null) {
    await _rearmChannel.invokeMethod<void>(
      'storeRearmCallbackHandle',
      handle.toRawHandle(),
    );
  }
  await scheduleNextBriefingAlarm();
}

/// Re-arms from the current setting -- pass [runTime] to skip the storage
/// read when the caller just wrote a new one (e.g. from Settings).
Future<void> scheduleNextBriefingAlarm({
  DateTime? now,
  RunTime? runTime,
}) async {
  final effectiveRunTime = runTime ?? await RunTimeStorage().read();
  final next = nextRunTime(
    now ?? DateTime.now(),
    hour: effectiveRunTime.hour,
    minute: effectiveRunTime.minute,
  );
  await AndroidAlarmManager.oneShotAt(
    next,
    briefingAlarmId,
    briefingAlarmCallback,
    exact: true,
    allowWhileIdle: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
}

/// Fires at the scheduled time, in a fresh isolate with no access to
/// main-isolate memory, globals, singletons or providers.
///
/// Task 2.3 replaces the body with the real Briefing Run, run inside a
/// foreground service. For now this only proves the alarm mechanism itself:
/// that it fires and re-arms for the following day.
@pragma('vm:entry-point')
Future<void> briefingAlarmCallback() async {
  await scheduleNextBriefingAlarm();
}

/// Invoked by `RearmBroadcastReceiver` on boot, app update, or a system
/// clock/timezone change -- any of which can leave the previously scheduled
/// alarm stale or gone. Recomputes and re-arms from the current time rather
/// than trusting whatever was scheduled before.
///
/// Started directly by a headless Flutter engine (not through
/// android_alarm_manager_plus's own dispatcher), so bindings are not yet
/// initialised here.
@pragma('vm:entry-point')
Future<void> rearmDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  await scheduleNextBriefingAlarm();
  await _rearmCompleteChannel.invokeMethod<void>('rearmComplete');
}
