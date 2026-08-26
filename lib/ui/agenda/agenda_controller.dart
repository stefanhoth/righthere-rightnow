import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
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
