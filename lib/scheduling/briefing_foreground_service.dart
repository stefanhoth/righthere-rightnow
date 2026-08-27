import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/scheduling/focus_pull_notification.dart';

/// Separate from the Focus Pull notification channel (Task 2.4) -- this one
/// is only visible while a run is actually in flight.
const _serviceNotificationChannelId = 'briefing_service_v1';
const _serviceId = 256;

/// Call once in any isolate before starting the service from it: the
/// alarm callback's isolate is not the same one `main()` ran in, and
/// [FlutterForegroundTask]'s configuration is per-isolate Dart state.
void initializeBriefingService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: _serviceNotificationChannelId,
      channelName: 'Briefing Run',
      channelDescription:
          "Shown only while gathering and ranking today's agenda.",
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      // A single run, not a repeating task -- everything happens in
      // onStart, so there's nothing for onRepeatEvent to do.
      eventAction: ForegroundTaskEventAction.nothing(),
      allowWifiLock: true,
    ),
  );
}

/// Starts the foreground service that runs the actual Briefing Run.
///
/// Exact alarms are exempt from the Android 12+ foreground-service
/// background-start restriction (see docs/adr/0002), so this is only ever
/// called from the alarm callback, never from the UI.
Future<void> startBriefingService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return;
  }
  await FlutterForegroundTask.startService(
    serviceId: _serviceId,
    notificationTitle: 'Building your Daily Agenda',
    notificationText: 'This will only take a moment.',
    callback: briefingServiceCallback,
  );
}

@pragma('vm:entry-point')
void briefingServiceCallback() {
  FlutterForegroundTask.setTaskHandler(_BriefingTaskHandler());
}

class _BriefingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final orchestrator = BriefingRunOrchestrator(
      calendarReader: CalendarReader(),
      todoistClient: TodoistClient(),
      todoistTokenStorage: TodoistTokenStorage(),
      database: AppDatabase(),
      clock: DateTime.now,
    );

    try {
      final result = await orchestrator.run();
      await initializeFocusPullNotifications();
      await showFocusPullNotification(
        rankedItems: result.agenda.items,
        runId: result.runId,
      );
    } finally {
      await FlutterForegroundTask.stopService();
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
