import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/main.dart';

import 'support/fake_what_matters_repository.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _MockTodoistTokenStorage extends Mock implements TodoistTokenStorage {}

/// Resolves synchronously, unlike the real engine's platform-channel probe --
/// that probe's own internal timeout leaves a pending Timer past the end of
/// a widget test that doesn't know to wait for the fire-and-forget re-rank.
class _FakeUnavailableEngine implements InferenceEngine {
  @override
  Future<EngineAvailability> availability() async =>
      EngineAvailability.unsupported;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) {
    throw UnimplementedError();
  }
}

class _FakeOrchestrator extends BriefingRunOrchestrator {
  _FakeOrchestrator()
    : super(
        calendarReader: _MockCalendarReader(),
        todoistClient: _MockTodoistClient(),
        todoistTokenStorage: _MockTodoistTokenStorage(),
        whatMattersRepository: stubWhatMattersRepository(),
        database: AppDatabase.forTesting(NativeDatabase.memory()),
        clock: DateTime.now,
      );

  @override
  Future<BriefingRunResult> run() async {
    return BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }
}

void main() {
  testWidgets('launches to an empty Daily Agenda scaffold', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          briefingRunOrchestratorProvider.overrideWithValue(
            _FakeOrchestrator(),
          ),
          inferenceEngineProvider.overrideWithValue(_FakeUnavailableEngine()),
        ],
        child: const RightHereRightNowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily Agenda'), findsOneWidget);
  });
}
