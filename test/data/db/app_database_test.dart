import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('a Briefing Run with items reads back identically', () async {
    final startedAt = DateTime.utc(2026, 8, 26, 5, 30);
    final completedAt = DateTime.utc(2026, 8, 26, 5, 30, 4);

    final runId = await db
        .into(db.briefingRuns)
        .insert(
          BriefingRunsCompanion.insert(
            startedAt: startedAt,
            completedAt: completedAt,
            rankedBy: RankedBy.fallback,
          ),
        );

    await db
        .into(db.snapshotItems)
        .insert(
          SnapshotItemsCompanion.insert(
            runId: runId,
            itemId: 'cal:1:100',
            payloadJson: '{"id":"cal:1:100","title":"Standup"}',
            fallbackRank: 0,
            producedRank: 0,
          ),
        );
    await db
        .into(db.snapshotItems)
        .insert(
          SnapshotItemsCompanion.insert(
            runId: runId,
            itemId: 'td:9',
            payloadJson: '{"id":"td:9","title":"File taxes"}',
            fallbackRank: 1,
            producedRank: 2,
          ),
        );

    final storedRun = await (db.select(
      db.briefingRuns,
    )..where((r) => r.id.equals(runId))).getSingle();
    final storedItems =
        await (db.select(db.snapshotItems)
              ..where((i) => i.runId.equals(runId))
              ..orderBy([(i) => OrderingTerm.asc(i.fallbackRank)]))
            .get();

    expect(storedRun.startedAt, startedAt);
    expect(storedRun.completedAt, completedAt);
    expect(storedRun.rankedBy, RankedBy.fallback);
    expect(storedRun.promptVersion, isNull);
    expect(storedRun.error, isNull);

    expect(storedItems, hasLength(2));
    expect(storedItems[0].itemId, 'cal:1:100');
    expect(storedItems[0].payloadJson, '{"id":"cal:1:100","title":"Standup"}');
    expect(storedItems[0].producedRank, 0);
    expect(storedItems[0].correctedRank, isNull);
    expect(storedItems[1].itemId, 'td:9');
    expect(storedItems[1].producedRank, 2);
  });

  test('a rating references its Briefing Run', () async {
    final runId = await db
        .into(db.briefingRuns)
        .insert(
          BriefingRunsCompanion.insert(
            startedAt: DateTime.utc(2026, 8, 26),
            completedAt: DateTime.utc(2026, 8, 26, 0, 0, 3),
            rankedBy: RankedBy.fallback,
          ),
        );
    final notedAt = DateTime.utc(2026, 8, 26, 8);

    await db
        .into(db.runRatings)
        .insert(
          RunRatingsCompanion.insert(runId: runId, rating: 5, notedAt: notedAt),
        );

    final rating = await db.select(db.runRatings).getSingle();

    expect(rating.runId, runId);
    expect(rating.rating, 5);
    expect(rating.notedAt, notedAt);
  });

  test('an error is recorded alongside a fallback result', () async {
    final runId = await db
        .into(db.briefingRuns)
        .insert(
          BriefingRunsCompanion.insert(
            startedAt: DateTime.utc(2026, 8, 26),
            completedAt: DateTime.utc(2026, 8, 26, 0, 0, 1),
            rankedBy: RankedBy.fallback,
            error: const Value('Todoist: 401 invalid token'),
          ),
        );

    final storedRun = await (db.select(
      db.briefingRuns,
    )..where((r) => r.id.equals(runId))).getSingle();

    expect(storedRun.error, 'Todoist: 401 invalid token');
  });

  test(
    'latestBriefingRunCompletedAt is null when no run has ever happened',
    () async {
      expect(await db.latestBriefingRunCompletedAt(), isNull);
    },
  );

  test(
    'latestBriefingRunCompletedAt is the newest run, not the last inserted',
    () async {
      final older = DateTime.utc(2026, 8, 24);
      final newer = DateTime.utc(2026, 8, 26);

      await db
          .into(db.briefingRuns)
          .insert(
            BriefingRunsCompanion.insert(
              startedAt: newer,
              completedAt: newer,
              rankedBy: RankedBy.fallback,
            ),
          );
      await db
          .into(db.briefingRuns)
          .insert(
            BriefingRunsCompanion.insert(
              startedAt: older,
              completedAt: older,
              rankedBy: RankedBy.fallback,
            ),
          );

      expect(await db.latestBriefingRunCompletedAt(), newer);
    },
  );
}
