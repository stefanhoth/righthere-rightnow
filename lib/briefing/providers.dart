import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
BriefingRunOrchestrator briefingRunOrchestrator(Ref ref) {
  return BriefingRunOrchestrator(
    calendarReader: ref.watch(calendarReaderProvider),
    todoistClient: ref.watch(todoistClientProvider),
    todoistTokenStorage: ref.watch(todoistTokenStorageProvider),
    database: ref.watch(appDatabaseProvider),
    clock: DateTime.now,
  );
}
