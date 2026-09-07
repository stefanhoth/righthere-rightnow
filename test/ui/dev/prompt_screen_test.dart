import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/briefing/prompt.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';
import 'package:righthere_rightnow/ui/dev/prompt_screen.dart';

/// Resolves synchronously, unlike the real engine's platform-channel probe.
class _FakeInferenceEngine implements InferenceEngine {
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

Future<AppDatabase> _pumpPromptScreen(
  WidgetTester tester, {
  Future<void> Function(AppDatabase db)? seed,
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await seed?.call(db);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        inferenceEngineProvider.overrideWithValue(_FakeInferenceEngine()),
      ],
      child: const MaterialApp(home: PromptScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  testWidgets('shows the shipped default prompt and its version', (
    tester,
  ) async {
    await _pumpPromptScreen(tester);

    expect(find.widgetWithText(TextField, defaultPromptText), findsOneWidget);
    expect(find.text('Active version: v1'), findsOneWidget);
  });

  testWidgets('saving becomes the active prompt at a higher version', (
    tester,
  ) async {
    final db = await _pumpPromptScreen(tester);

    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Rank by urgency only.',
    );
    await tester.tap(find.byKey(const Key('savePromptButton')));
    await tester.pumpAndSettle();

    expect(find.text('Active version: v2'), findsOneWidget);
    expect(await db.activePromptText(), 'Rank by urgency only.');
  });

  testWidgets('reset restores the shipped default text in the field', (
    tester,
  ) async {
    await _pumpPromptScreen(tester);

    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Rank by urgency only.',
    );
    await tester.tap(find.byKey(const Key('savePromptButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('resetPromptButton')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, defaultPromptText), findsOneWidget);
    expect(find.text('Active version: v3'), findsOneWidget);
  });

  testWidgets('replaying with no stored runs reports nothing to measure', (
    tester,
  ) async {
    await _pumpPromptScreen(tester);

    await tester.tap(find.byKey(const Key('runReplayButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('replaySummary')), findsOneWidget);
    expect(find.text('Replayed 0 run(s).'), findsOneWidget);
    expect(
      find.text('No corrected runs to measure agreement against.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('nonDeterministicWarning')), findsNothing);
  });

  testWidgets('the inference log is empty until inference has run', (
    tester,
  ) async {
    await _pumpPromptScreen(tester);

    expect(find.byKey(const Key('inferenceLogEmpty')), findsOneWidget);
  });

  testWidgets('the inference log names a recorded attempt with its cause', (
    tester,
  ) async {
    await _pumpPromptScreen(
      tester,
      seed: (db) async {
        final runId = await db
            .into(db.briefingRuns)
            .insert(
              BriefingRunsCompanion.insert(
                startedAt: DateTime.utc(2026, 8, 28, 5, 30),
                completedAt: DateTime.utc(2026, 8, 28, 5, 30, 5),
                rankedBy: RankedBy.fallback,
              ),
            );
        await db.recordInferenceAttempt(
          runId: runId,
          work: InferenceWork.ranking,
          result: InferenceResultKind.failed,
          attemptedAt: DateTime.utc(2026, 8, 28, 5, 31),
          cause: 'timedOut',
          duration: const Duration(milliseconds: 30000),
        );
      },
    );

    expect(find.byKey(const Key('inferenceLogEmpty')), findsNothing);
    expect(find.textContaining('Ranking failed (timedOut)'), findsOneWidget);
  });
}
