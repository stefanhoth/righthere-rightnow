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
import 'package:righthere_rightnow/main.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _MockTodoistTokenStorage extends Mock implements TodoistTokenStorage {}

class _FakeOrchestrator extends BriefingRunOrchestrator {
  _FakeOrchestrator()
    : super(
        calendarReader: _MockCalendarReader(),
        todoistClient: _MockTodoistClient(),
        todoistTokenStorage: _MockTodoistTokenStorage(),
        database: AppDatabase.forTesting(NativeDatabase.memory()),
        clock: DateTime.now,
      );

  @override
  Future<BriefingRunResult> run() async {
    return BriefingRunResult(
      runId: 1,
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
        ],
        child: const RightHereRightNowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily Agenda'), findsOneWidget);
  });
}
