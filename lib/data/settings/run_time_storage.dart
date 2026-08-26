import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';

/// Persists the configured Briefing Run time. Not a secret, but reuses
/// flutter_secure_storage rather than adding another storage dependency for
/// one small setting -- and it needs to be readable from the same isolates
/// TodoistTokenStorage already works from (the alarm callback, the headless
/// re-arm dispatcher).
class RunTimeStorage {
  RunTimeStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _hourKey = 'briefing_run_hour';
  static const _minuteKey = 'briefing_run_minute';

  final FlutterSecureStorage _storage;

  Future<RunTime> read() async {
    final hour = int.tryParse(await _storage.read(key: _hourKey) ?? '');
    final minute = int.tryParse(await _storage.read(key: _minuteKey) ?? '');
    if (hour == null || minute == null) {
      return RunTime.defaultValue;
    }
    return RunTime(hour: hour, minute: minute);
  }

  Future<void> write(RunTime runTime) async {
    await _storage.write(key: _hourKey, value: runTime.hour.toString());
    await _storage.write(key: _minuteKey, value: runTime.minute.toString());
  }
}
