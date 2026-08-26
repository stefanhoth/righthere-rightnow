import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/scheduling/briefing_alarm.dart';
import 'package:righthere_rightnow/scheduling/next_run_time.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_time_controller.g.dart';

@riverpod
Future<RunTime> storedRunTime(Ref ref) {
  return ref.watch(runTimeStorageProvider).read();
}

/// The next occurrence of the stored run time, purely computed from it and
/// the current clock -- so it's visible in Settings without waiting for the
/// alarm to actually fire, and without needing to query the native side for
/// what it last scheduled.
@riverpod
Future<DateTime> nextScheduledRun(Ref ref) async {
  final runTime = await ref.watch(storedRunTimeProvider.future);
  return nextRunTime(
    DateTime.now(),
    hour: runTime.hour,
    minute: runTime.minute,
  );
}

@riverpod
class RunTimeController extends _$RunTimeController {
  @override
  void build() {}

  /// Persists [runTime] and re-arms the alarm immediately -- no app restart
  /// needed for the change to take effect.
  Future<void> updateRunTime(RunTime runTime) async {
    await ref.read(runTimeStorageProvider).write(runTime);
    ref.invalidate(storedRunTimeProvider);
    await scheduleNextBriefingAlarm(runTime: runTime);
  }
}
