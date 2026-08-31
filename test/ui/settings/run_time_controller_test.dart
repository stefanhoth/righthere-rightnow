import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';
import 'package:righthere_rightnow/ui/settings/run_time_controller.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    // A real secure-storage write crosses a platform channel and yields to
    // the event loop. Model that here: an unwatched auto-dispose controller
    // is torn down across this gap, which is exactly the bug being guarded.
    await Future<void>.delayed(Duration.zero);
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map.of(_values);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const alarmChannel = MethodChannel(
    'dev.fluttercommunity.plus/android_alarm_manager',
    JSONMethodCodec(),
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late ProviderContainer container;
  late List<MethodCall> alarmCalls;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    container = ProviderContainer();
    alarmCalls = [];
    AndroidAlarmManager.setTestOverrides(
      getCallbackHandle: (callback) => CallbackHandle.fromRawHandle(1),
    );
    messenger.setMockMethodCallHandler(alarmChannel, (call) async {
      alarmCalls.add(call);
      return true;
    });
  });

  tearDown(() {
    container.dispose();
    messenger.setMockMethodCallHandler(alarmChannel, null);
  });

  test('updating the run time persists it and re-arms immediately', () async {
    await container
        .read(runTimeControllerProvider.notifier)
        .updateRunTime(const RunTime(hour: 7, minute: 15));

    final stored = await container.read(storedRunTimeProvider.future);
    expect(stored, const RunTime(hour: 7, minute: 15));
    expect(alarmCalls, hasLength(1));
    expect(alarmCalls.single.method, 'Alarm.oneShotAt');
  });
}
