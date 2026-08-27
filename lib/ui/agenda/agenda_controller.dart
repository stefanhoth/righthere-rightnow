import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/scheduling/notification_navigation.dart'
    as notification_navigation;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agenda_controller.g.dart';

@riverpod
class DailyAgendaController extends _$DailyAgendaController {
  @override
  Future<BriefingRunResult> build() {
    return ref.read(briefingRunOrchestratorProvider).run();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<BriefingRunResult>();
    state = await AsyncValue.guard(
      () => ref.read(briefingRunOrchestratorProvider).run(),
    );
  }
}

/// The runId of the Focus Pull notification that cold-started the app, if
/// any. `getNotificationAppLaunchDetails()` reports the same launch for the
/// life of the process, so this is safe to read more than once.
@riverpod
Future<int?> notificationLaunchRunId(Ref ref) {
  return notification_navigation.notificationLaunchRunId();
}
