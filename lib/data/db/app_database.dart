import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:righthere_rightnow/briefing/inference_health.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/briefing/prompt.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

part 'app_database.g.dart';

/// One Briefing Run: a complete cycle of gathering, ranking and producing a
/// Daily Agenda.
class BriefingRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get rankedBy => textEnum<RankedBy>()();
  TextColumn get promptVersion => text().nullable()();
  TextColumn get error => text().nullable()();

  /// The one generated sentence shown at the top of the Daily Agenda
  /// screen. Set only once, at app-open, alongside the model's re-ranking
  /// attempt -- null until then, and forever if inference never succeeds
  /// for this run.
  TextColumn get framingLine => text().nullable()();
}

/// One Agenda Item as a Briefing Run saw it: the replay input for later
/// prompt-change evaluation. If a feature isn't in [payloadJson], it can't be
/// replayed later.
class SnapshotItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId => integer().references(BriefingRuns, #id)();
  TextColumn get itemId => text()();

  /// The item as the ranker saw it, including its computed features.
  TextColumn get payloadJson => text()();
  IntColumn get fallbackRank => integer()();
  IntColumn get producedRank => integer()();

  /// Set only once a human has dragged this item to a different position.
  IntColumn get correctedRank => integer().nullable()();
}

/// A human's rating of one Briefing Run's output, captured as feedback.
class RunRatings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId => integer().references(BriefingRuns, #id)();
  IntColumn get rating => integer()();
  DateTimeColumn get notedAt => dateTime()();
}

/// One version of the ranking prompt -- see ADR-0003. The active prompt is
/// the row with the highest [version]; editing or resetting never overwrites
/// a row, it inserts a new one, so every version a Briefing Run could have
/// used stays queryable for replay.
class Prompts extends Table {
  IntColumn get version => integer().autoIncrement()();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// An Agenda Item the user has said needs nothing further.
///
/// Only past Commitments can be dismissed. They appear at all because a
/// finished meeting may have created work (a Follow-up Suggestion); saying
/// it did not is a real answer, and one the app must remember rather than
/// ask again tomorrow.
///
/// Keyed by the Agenda Item's id, which for a Commitment is per-occurrence
/// (`cal:eventId:begin`), so dismissing one instance never silences the
/// series.
class DismissedItems extends Table {
  TextColumn get itemId => text()();
  DateTimeColumn get dismissedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

/// One app-open attempt to run the model for a Briefing Run -- ranking or
/// framing (ADR-0006). Persisted so the dev screen can show the last N with
/// cause and timing, and so a *run* of failures can raise a banner on the
/// Daily Agenda without a single bad morning tripping it.
///
/// [detail] never holds the prompt: that carries calendar and Task content.
class InferenceAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId => integer().references(BriefingRuns, #id)();
  TextColumn get work => textEnum<InferenceWork>()();
  TextColumn get result => textEnum<InferenceResultKind>()();

  /// The [EngineAvailability] name when [result] is `skipped`, the
  /// [InferenceFailure] name when it `failed`, null when it `succeeded`.
  TextColumn get cause => text().nullable()();

  /// The engine's own error text, when it threw. Never the prompt.
  TextColumn get detail => text().nullable()();

  /// Wall-clock time the attempt took, or null when it was skipped before
  /// the engine was called.
  IntColumn get durationMs => integer().nullable()();

  DateTimeColumn get attemptedAt => dateTime()();
}

@DriftDatabase(
  tables: [
    BriefingRuns,
    SnapshotItems,
    RunRatings,
    Prompts,
    DismissedItems,
    InferenceAttempts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: pass an in-memory or otherwise pre-configured executor
  /// instead of opening the real on-disk database.
  AppDatabase.forTesting(super.e);

  // Default (unix-seconds) storage round-trips through local time, losing
  // whether a written DateTime was UTC. Briefing Run timestamps are always
  // written in UTC, so store them as ISO-8601 text to get that back exactly.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(prompts);
      }
      if (from < 3) {
        await m.addColumn(briefingRuns, briefingRuns.framingLine);
      }
      if (from < 4) {
        await m.createTable(dismissedItems);
      }
      if (from < 5) {
        await m.createTable(inferenceAttempts);
      }
    },
  );

  /// Records that [itemId] needs nothing further. Idempotent: dismissing
  /// something already dismissed just refreshes when it happened.
  Future<void> dismissItem(String itemId, {required DateTime at}) {
    return into(dismissedItems).insertOnConflictUpdate(
      DismissedItemsCompanion.insert(itemId: itemId, dismissedAt: at),
    );
  }

  /// Undoes [dismissItem], so the item can come back.
  Future<void> undismissItem(String itemId) {
    return (delete(dismissedItems)..where((r) => r.itemId.equals(itemId))).go();
  }

  /// Every dismissed Agenda Item id. Read once per Briefing Run and used to
  /// filter, so a dismissal survives restarts and future runs.
  Future<Set<String>> dismissedItemIds() async {
    final rows = await select(dismissedItems).get();
    return rows.map((row) => row.itemId).toSet();
  }

  /// When the most recent Briefing Run finished, or null if none ever has.
  /// Used to tell a silent alarm from a healthy one that just hasn't fired
  /// yet today.
  Future<DateTime?> latestBriefingRunCompletedAt() async {
    final query = select(briefingRuns)
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.completedAt;
  }

  /// The active prompt: the highest [Prompts.version] row, or
  /// [defaultPromptText] seeded as version 1 if the app has never stored
  /// one. A single query (and, at most, a single seed) for both the text
  /// and its version, so callers reading both never see them disagree.
  Future<ActivePrompt> activePrompt() async {
    final row = await _activePromptRow();
    if (row != null) {
      return ActivePrompt(text: row.body, version: row.version);
    }
    await _writePrompt(defaultPromptText);
    final seeded = (await _activePromptRow())!;
    return ActivePrompt(text: seeded.body, version: seeded.version);
  }

  /// The text of the active prompt (see [activePrompt]).
  Future<String> activePromptText() async => (await activePrompt()).text;

  /// The version number of the active prompt (see [activePrompt]).
  Future<int> activePromptVersion() async => (await activePrompt()).version;

  /// Inserts [text] as a new, higher-versioned active prompt.
  Future<void> updatePrompt(String text) => _writePrompt(text);

  /// Inserts [defaultPromptText] as a new, higher-versioned active prompt --
  /// a reset is a normal edit, not a deletion, so prior versions stay
  /// queryable for replay.
  Future<void> resetPromptToDefault() => _writePrompt(defaultPromptText);

  Future<Prompt?> _activePromptRow() {
    final query = select(prompts)
      ..orderBy([(t) => OrderingTerm.desc(t.version)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> _writePrompt(String text) {
    return into(prompts)
        .insert(PromptsCompanion.insert(body: text, updatedAt: DateTime.now()));
  }

  /// Records that a Briefing Run's Daily Agenda was re-ranked after it was
  /// first persisted -- the model re-ranks at app-open, after the run
  /// itself already wrote its fallback order (ADR-0006). [producedOrder] is
  /// every item id in [runId]'s Candidate Set, in its new order.
  Future<void> updateRunRanking({
    required int runId,
    required RankedBy rankedBy,
    required String? promptVersion,
    required List<String> producedOrder,
  }) {
    return transaction(() async {
      await (update(briefingRuns)..where((r) => r.id.equals(runId))).write(
        BriefingRunsCompanion(
          rankedBy: Value(rankedBy),
          promptVersion: Value(promptVersion),
        ),
      );

      for (final (rank, itemId) in producedOrder.indexed) {
        await (update(snapshotItems)
              ..where((s) => s.runId.equals(runId) & s.itemId.equals(itemId)))
            .write(SnapshotItemsCompanion(producedRank: Value(rank)));
      }
    });
  }

  /// Records the generated framing line for [runId], once inference
  /// produces one -- see Task 3.4.
  Future<void> saveFramingLine({
    required int runId,
    required String framingLine,
  }) {
    return (update(briefingRuns)..where((r) => r.id.equals(runId))).write(
      BriefingRunsCompanion(framingLine: Value(framingLine)),
    );
  }

  /// Records a human's drag-to-reorder of [runId]'s Daily Agenda.
  /// [correctedOrder] is every item id in the run's Candidate Set, in the
  /// order the human chose. Never touches [SnapshotItems.fallbackRank] or
  /// [SnapshotItems.producedRank] -- per ADR-0003, both the original and
  /// the corrected order must stay queryable, so improvement is
  /// measurable.
  Future<void> recordCorrectedOrder({
    required int runId,
    required List<String> correctedOrder,
  }) {
    return transaction(() async {
      for (final (rank, itemId) in correctedOrder.indexed) {
        await (update(snapshotItems)
              ..where((s) => s.runId.equals(runId) & s.itemId.equals(itemId)))
            .write(SnapshotItemsCompanion(correctedRank: Value(rank)));
      }
    });
  }

  /// Records a coarse thumbs up/down (positive/non-positive [rating]) for
  /// [runId] -- for days not worth reordering. One rating per run: rating
  /// it again replaces the previous one rather than adding a second row.
  Future<void> rateRun({required int runId, required int rating}) {
    return transaction(() async {
      final existing = await (select(
        runRatings,
      )..where((r) => r.runId.equals(runId))).getSingleOrNull();
      final notedAt = DateTime.now();

      if (existing != null) {
        await (update(
          runRatings,
        )..where((r) => r.id.equals(existing.id))).write(
          RunRatingsCompanion(rating: Value(rating), notedAt: Value(notedAt)),
        );
      } else {
        await into(runRatings).insert(
          RunRatingsCompanion.insert(
            runId: runId,
            rating: rating,
            notedAt: notedAt,
          ),
        );
      }
    });
  }

  /// Every Briefing Run ever persisted -- the replay harness's universe
  /// (Task 3.6).
  Future<List<int>> allBriefingRunIds() async {
    final rows = await (select(
      briefingRuns,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    return rows.map((r) => r.id).toList();
  }

  /// [runId]'s stored promptVersion, or null if it was never model-ranked.
  Future<String?> promptVersionForRun(int runId) async {
    final row = await (select(
      briefingRuns,
    )..where((r) => r.id.equals(runId))).getSingleOrNull();
    return row?.promptVersion;
  }

  /// Every Candidate Item [runId] considered, in no particular order --
  /// callers sort by whichever rank column they need.
  Future<List<SnapshotItem>> snapshotItemsForRun(int runId) {
    return (select(snapshotItems)..where((s) => s.runId.equals(runId))).get();
  }

  /// Records one app-open inference attempt for [runId] -- see Task 4.3.
  Future<void> recordInferenceAttempt({
    required int runId,
    required InferenceWork work,
    required InferenceResultKind result,
    required DateTime attemptedAt,
    String? cause,
    String? detail,
    Duration? duration,
  }) {
    return into(inferenceAttempts).insert(
      InferenceAttemptsCompanion.insert(
        runId: runId,
        work: work,
        result: result,
        attemptedAt: attemptedAt,
        cause: Value(cause),
        detail: Value(detail),
        durationMs: Value(duration?.inMilliseconds),
      ),
    );
  }

  /// The most recent [limit] inference attempts, newest first -- the dev
  /// screen's log, mapped to [InferenceAttemptRecord] so callers do not
  /// depend on the Drift row.
  Future<List<InferenceAttemptRecord>> recentInferenceAttempts({
    int limit = 20,
  }) async {
    final query = select(inferenceAttempts)
      ..orderBy([(a) => OrderingTerm.desc(a.attemptedAt)])
      ..limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        InferenceAttemptRecord(
          work: row.work,
          result: row.result,
          attemptedAt: row.attemptedAt,
          cause: row.cause,
          durationMs: row.durationMs,
        ),
    ];
  }

  /// The result of the ranking attempt for each of the most recent [limit]
  /// app-opens that made one, newest first -- the failure banner's input.
  /// Framing attempts are excluded: a missing framing line is not breakage.
  Future<List<InferenceResultKind>> recentRankingResults({
    int limit = 5,
  }) async {
    final query = select(inferenceAttempts)
      ..where((a) => a.work.equalsValue(InferenceWork.ranking))
      ..orderBy([(a) => OrderingTerm.desc(a.attemptedAt)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map((r) => r.result).toList();
  }
}

// `driftDatabase(name:)` always opens the database via
// `NativeDatabase.createBackgroundConnection`, so all query execution already
// happens on a background isolate -- there is nothing extra to opt into here.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'righthere_rightnow');
}
