import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/what_matters_extractor.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

class _FakeEngine implements InferenceEngine {
  EngineAvailability available = EngineAvailability.ready;
  String? response;
  Exception? error;
  int completeCalls = 0;

  @override
  Future<EngineAvailability> availability() async => available;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) async {
    completeCalls++;
    if (error != null) {
      throw error!;
    }
    return response!;
  }
}

DateTime _clock() => DateTime.utc(2026, 8, 31, 6);

void main() {
  late _FakeEngine engine;
  late AppDatabase db;

  WhatMattersExtractor extractor() =>
      WhatMattersExtractor(engine: engine, database: db, clock: _clock);

  WhatMattersDocument doc(String prose) =>
      WhatMattersDocument(prose: prose, fetchedAt: DateTime.utc(2026, 8, 31));

  const cleanResponse =
      '{"projects":[{"name":"Book","deadline":"2027-03-01","sessions":12}],'
      '"keep":["call mum"]}';

  setUp(() {
    engine = _FakeEngine();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('no document means an empty extraction and no engine call', () async {
    final outcome = await extractor().extract(null);

    expect(outcome, isA<InferenceSucceeded<WhatMattersExtraction>>());
    expect(outcome.valueOrNull, WhatMattersExtraction.empty);
    expect(engine.completeCalls, 0);
  });

  test('a clean response is parsed, persisted, and returned', () async {
    engine.response = cleanResponse;

    final outcome = await extractor().extract(doc('Write the book.'));

    expect(outcome.valueOrNull!.projects.single.name, 'Book');
    final stored = await db.storedWhatMattersExtraction();
    expect(stored!.sourceProse, 'Write the book.');
    expect(stored.extraction.projects.single.sessionsNeeded, 12);
    expect(stored.extractedAt, DateTime.utc(2026, 8, 31, 6));
  });

  test('an unchanged document is not re-extracted', () async {
    engine.response = cleanResponse;
    await extractor().extract(doc('Write the book.'));
    expect(engine.completeCalls, 1);

    final again = await extractor().extract(doc('Write the book.'));

    expect(engine.completeCalls, 1, reason: 'no second engine call');
    expect(again.valueOrNull!.projects.single.name, 'Book');
  });

  test('a changed document triggers a fresh extraction', () async {
    engine.response = cleanResponse;
    await extractor().extract(doc('Write the book.'));

    engine.response = '{"projects":[],"keep":["water plants"]}';
    final outcome = await extractor().extract(doc('New priorities.'));

    expect(engine.completeCalls, 2);
    expect(outcome.valueOrNull!.neverDecays, ['water plants']);
    expect(
      (await db.storedWhatMattersExtraction())!.sourceProse,
      'New priorities.',
    );
  });

  group('every failure leaves the previous extraction intact', () {
    setUp(() async {
      engine.response = cleanResponse;
      await extractor().extract(doc('the good prose'));
      engine
        ..response = null
        ..completeCalls = 0;
    });

    Future<void> expectStoredUnchanged() async {
      final stored = await db.storedWhatMattersExtraction();
      expect(stored!.sourceProse, 'the good prose');
      expect(stored.extraction.projects.single.name, 'Book');
    }

    test('engine not ready -> skipped', () async {
      engine.available = EngineAvailability.notReady;

      final outcome = await extractor().extract(doc('changed prose'));

      expect(outcome, isA<InferenceSkipped<WhatMattersExtraction>>());
      await expectStoredUnchanged();
    });

    test('engine throws -> failed', () async {
      engine.error = Exception('boom');

      final outcome = await extractor().extract(doc('changed prose'));

      expect(
        (outcome as InferenceFailed).failure,
        InferenceFailure.engineThrew,
      );
      await expectStoredUnchanged();
    });

    test('timeout -> failed', () async {
      engine.error = TimeoutException('slow');

      final outcome = await extractor().extract(doc('changed prose'));

      expect((outcome as InferenceFailed).failure, InferenceFailure.timedOut);
      await expectStoredUnchanged();
    });

    test('an unparseable or partial response -> failed', () async {
      engine.response = '{"projects":[{"name":"P"}],"keep":[]}';

      final outcome = await extractor().extract(doc('changed prose'));

      expect(
        (outcome as InferenceFailed).failure,
        InferenceFailure.unusableOutput,
      );
      await expectStoredUnchanged();
    });
  });
}
