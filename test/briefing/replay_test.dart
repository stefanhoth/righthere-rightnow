import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/replay.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

class _FakeInferenceEngine implements InferenceEngine {
  _FakeInferenceEngine({this.available = true, this.responses = const []});

  final bool available;

  /// Consumed one per call to [complete], in order -- lets a test return a
  /// different response on each replay to simulate non-determinism.
  final List<String> responses;
  var _calls = 0;

  @override
  Future<EngineAvailability> availability() async =>
      available ? EngineAvailability.ready : EngineAvailability.notReady;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) async {
    return responses[_calls++];
  }
}

Task _task(String id) {
  return Task(id: id, title: id, priority: Priority.p3, isRecurring: false);
}

CandidateItem _candidate(String id) {
  return CandidateItem(
    item: _task(id),
    features: const AgendaItemFeatures(
      attendeeCount: 0,
      isOrganiser: false,
      isRecurring: false,
      isFollowUpCandidate: false,
    ),
  );
}

Future<int> _insertRun(
  AppDatabase db, {
  String? promptVersion,
  RankedBy rankedBy = RankedBy.fallback,
}) {
  return db
      .into(db.briefingRuns)
      .insert(
        BriefingRunsCompanion.insert(
          startedAt: DateTime.utc(2026, 8, 26),
          completedAt: DateTime.utc(2026, 8, 26, 0, 0, 5),
          rankedBy: rankedBy,
          promptVersion: Value(promptVersion),
        ),
      );
}

Future<void> _insertSnapshotItem(
  AppDatabase db, {
  required int runId,
  required CandidateItem candidate,
  required int fallbackRank,
  required int producedRank,
  int? correctedRank,
}) {
  return db
      .into(db.snapshotItems)
      .insert(
        SnapshotItemsCompanion.insert(
          runId: runId,
          itemId: candidate.item.id,
          payloadJson: jsonEncode(candidateItemToJson(candidate)),
          fallbackRank: fallbackRank,
          producedRank: producedRank,
          correctedRank: Value(correctedRank),
        ),
      );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('a matching prompt version that reproduces the original order is flagged deterministic', () async {
    await database.activePromptText(); // seeds v1
    final runId = await _insertRun(
      database,
      promptVersion: 'v1',
      rankedBy: RankedBy.model,
    );
    final a = _candidate('a');
    final b = _candidate('b');
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: a,
      fallbackRank: 0,
      producedRank: 0,
    );
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: b,
      fallbackRank: 1,
      producedRank: 1,
    );
    final harness = ReplayHarness(
      engine: _FakeInferenceEngine(responses: ['[1, 2]']),
      database: database,
    );

    final result = await harness.replayRun(runId);

    expect(result.promptVersionMatches, isTrue);
    expect(result.replayedOrder, ['a', 'b']);
    expect(result.originalOrder, ['a', 'b']);
    expect(result.isDeterministic, isTrue);
  });

  test('a matching prompt version producing a different order is flagged non-deterministic, not an error', () async {
    await database.activePromptText(); // seeds v1
    final runId = await _insertRun(
      database,
      promptVersion: 'v1',
      rankedBy: RankedBy.model,
    );
    final a = _candidate('a');
    final b = _candidate('b');
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: a,
      fallbackRank: 0,
      producedRank: 0,
    );
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: b,
      fallbackRank: 1,
      producedRank: 1,
    );
    final harness = ReplayHarness(
      engine: _FakeInferenceEngine(responses: ['[2, 1]']),
      database: database,
    );

    final result = await harness.replayRun(runId);

    expect(result.promptVersionMatches, isTrue);
    expect(result.replayedOrder, ['b', 'a']);
    expect(result.isDeterministic, isFalse);
  });

  test('a run stored under a different prompt version is never called deterministic', () async {
    await database.activePromptText(); // seeds v1
    await database.updatePrompt('a newer prompt'); // now v2 is active
    final runId = await _insertRun(
      database,
      promptVersion: 'v1',
      rankedBy: RankedBy.model,
    );
    final a = _candidate('a');
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: a,
      fallbackRank: 0,
      producedRank: 0,
    );
    final harness = ReplayHarness(
      engine: _FakeInferenceEngine(responses: ['[1]']),
      database: database,
    );

    final result = await harness.replayRun(runId);

    expect(result.promptVersionMatches, isFalse);
    expect(result.isDeterministic, isFalse);
  });

  test('an unavailable engine replays no order, without throwing', () async {
    final runId = await _insertRun(database);
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: _candidate('a'),
      fallbackRank: 0,
      producedRank: 0,
    );
    final harness = ReplayHarness(
      engine: _FakeInferenceEngine(available: false),
      database: database,
    );

    final result = await harness.replayRun(runId);

    expect(result.replayedOrder, isNull);
    expect(result.isDeterministic, isFalse);
  });

  test('replayAll never writes a new Briefing Run', () async {
    final runId = await _insertRun(database);
    await _insertSnapshotItem(
      database,
      runId: runId,
      candidate: _candidate('a'),
      fallbackRank: 0,
      producedRank: 0,
    );
    final harness = ReplayHarness(
      engine: _FakeInferenceEngine(responses: ['[1]']),
      database: database,
    );

    await harness.replayAll();

    final allRuns = await database.allBriefingRunIds();
    expect(allRuns, [runId]);
  });

  group('agreementMetric', () {
    test(
      'runs with no corrected order are excluded, not scored as zero',
      () async {
        final runId = await _insertRun(database);
        await _insertSnapshotItem(
          database,
          runId: runId,
          candidate: _candidate('a'),
          fallbackRank: 0,
          producedRank: 0,
          // No correctedRank.
        );
        final harness = ReplayHarness(
          engine: _FakeInferenceEngine(responses: ['[1]']),
          database: database,
        );

        final results = await harness.replayAll();

        expect(agreementMetric(results), isNull);
      },
    );

    test('averages agreement only across runs with a correction', () async {
      final fullyAgreeingRun = await _insertRun(database);
      await _insertSnapshotItem(
        database,
        runId: fullyAgreeingRun,
        candidate: _candidate('a'),
        fallbackRank: 0,
        producedRank: 0,
        correctedRank: 0,
      );
      await _insertSnapshotItem(
        database,
        runId: fullyAgreeingRun,
        candidate: _candidate('b'),
        fallbackRank: 1,
        producedRank: 1,
        correctedRank: 1,
      );
      final uncorrectedRun = await _insertRun(database);
      await _insertSnapshotItem(
        database,
        runId: uncorrectedRun,
        candidate: _candidate('c'),
        fallbackRank: 0,
        producedRank: 0,
      );
      final harness = ReplayHarness(
        engine: _FakeInferenceEngine(responses: ['[1, 2]', '[3]']),
        database: database,
      );

      final results = await harness.replayAll();

      expect(agreementMetric(results), 1.0);
    });
  });
}
