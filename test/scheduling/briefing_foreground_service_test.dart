import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/flutter_foreground_task_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/scheduling/briefing_foreground_service.dart';

class _RecordingForegroundTaskPlatform extends FlutterForegroundTaskPlatform {
  bool startCalled = false;
  List<ForegroundServiceTypes>? capturedServiceTypes;

  @override
  Future<bool> get isRunningService async => false;

  @override
  Future<void> startService({
    required AndroidNotificationOptions androidNotificationOptions,
    required IOSNotificationOptions iosNotificationOptions,
    required ForegroundTaskOptions foregroundTaskOptions,
    required String notificationTitle,
    required String notificationText,
    int? serviceId,
    List<ForegroundServiceTypes>? serviceTypes,
    NotificationIcon? notificationIcon,
    List<NotificationButton>? notificationButtons,
    String? notificationInitialRoute,
    Function? callback,
  }) async {
    startCalled = true;
    capturedServiceTypes = serviceTypes;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingForegroundTaskPlatform platform;

  setUp(() {
    platform = _RecordingForegroundTaskPlatform();
    FlutterForegroundTaskPlatform.instance = platform;
    // Skip the post-start round-trip to the (absent) native side.
    FlutterForegroundTask.skipServiceResponseCheck = true;
  });

  tearDown(() {
    FlutterForegroundTask.skipServiceResponseCheck = false;
  });

  test(
    'starts the Briefing Run service as a dataSync foreground service',
    () async {
      initializeBriefingService();
      await startBriefingService();

      expect(platform.startCalled, isTrue);
      expect(
        platform.capturedServiceTypes,
        contains(ForegroundServiceTypes.dataSync),
      );
    },
  );
}
