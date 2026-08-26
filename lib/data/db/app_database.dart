import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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

@DriftDatabase(tables: [BriefingRuns, SnapshotItems, RunRatings])
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}

// `driftDatabase(name:)` always opens the database via
// `NativeDatabase.createBackgroundConnection`, so all query execution already
// happens on a background isolate -- there is nothing extra to opt into here.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'righthere_rightnow');
}
