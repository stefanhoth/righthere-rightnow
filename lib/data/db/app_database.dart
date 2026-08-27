import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:righthere_rightnow/briefing/prompt.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';

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

@DriftDatabase(tables: [BriefingRuns, SnapshotItems, RunRatings, Prompts])
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(prompts);
      }
    },
  );

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
}

// `driftDatabase(name:)` always opens the database via
// `NativeDatabase.createBackgroundConnection`, so all query execution already
// happens on a background isolate -- there is nothing extra to opt into here.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'righthere_rightnow');
}
