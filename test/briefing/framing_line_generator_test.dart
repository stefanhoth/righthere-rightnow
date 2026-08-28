import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/framing_line.dart';
import 'package:righthere_rightnow/briefing/framing_line_generator.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _FakeInferenceEngine implements InferenceEngine {
  _FakeInferenceEngine({this.available = true, this.response, this.error});

  final bool available;
  final String? response;
  final Exception? error;

  int? lastMaxOutputTokens;

  @override
  Future<EngineAvailability> availability() async =>
      available ? EngineAvailability.ready : EngineAvailability.notReady;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) async {
    lastMaxOutputTokens = maxOutputTokens;
    if (error != null) {
      throw error!;
    }
    return response!;
  }
}

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map.of(_values);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

DateTime clock() => DateTime(2026, 8, 26, 9);

void main() {
  late AppDatabase database;
  late BriefingRunResult fallbackResult;

  setUp(() async {
    final calendarReader = _MockCalendarReader();
    final todoistClient = _MockTodoistClient();
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    final tokenStorage = TodoistTokenStorage();
    database = AppDatabase.forTesting(NativeDatabase.memory());

    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => []);
    when(() => todoistClient.fetchTasks(any())).thenAnswer((_) async => []);

    final orchestrator = BriefingRunOrchestrator(
      calendarReader: calendarReader,
      todoistClient: todoistClient,
      todoistTokenStorage: tokenStorage,
      database: database,
      clock: clock,
    );
    fallbackResult = await orchestrator.run();
  });

  tearDown(() => database.close());

  test('a usable response is trimmed, returned and persisted', () async {
    final generator = FramingLineGenerator(
      engine: _FakeInferenceEngine(
        response: '  A quiet day -- protect the morning.  \n',
      ),
      database: database,
    );

    final line = await generator.generate(fallbackResult);

    expect(line.valueOrNull, 'A quiet day -- protect the morning.');
    final storedRun = await (database.select(
      database.briefingRuns,
    )..where((r) => r.id.equals(fallbackResult.runId))).getSingle();
    expect(storedRun.framingLine, 'A quiet day -- protect the morning.');
  });

  test('an unavailable engine produces no line', () async {
    final generator = FramingLineGenerator(
      engine: _FakeInferenceEngine(available: false),
      database: database,
    );

    final line = await generator.generate(fallbackResult);

    expect(
      line,
      isA<InferenceSkipped<String>>().having(
        (outcome) => outcome.availability,
        'availability',
        EngineAvailability.notReady,
      ),
    );
  });

  test('a timing-out engine produces no line', () async {
    final generator = FramingLineGenerator(
      engine: _FakeInferenceEngine(
        error: TimeoutException('too slow', const Duration(seconds: 1)),
      ),
      database: database,
    );

    final line = await generator.generate(fallbackResult);

    expect(line, _failedWith(InferenceFailure.timedOut));
  });

  test(
    'an engine that throws is distinguishable from one that times out',
    () async {
      final generator = FramingLineGenerator(
        engine: _FakeInferenceEngine(error: Exception('AICore is not there')),
        database: database,
      );

      final line = await generator.generate(fallbackResult);

      expect(line, _failedWith(InferenceFailure.engineThrew));
    },
  );

  test('an empty response produces no line', () async {
    final generator = FramingLineGenerator(
      engine: _FakeInferenceEngine(response: '   '),
      database: database,
    );

    final line = await generator.generate(fallbackResult);

    expect(line, _failedWith(InferenceFailure.emptyOutput));
    final storedRun = await (database.select(
      database.briefingRuns,
    )..where((r) => r.id.equals(fallbackResult.runId))).getSingle();
    expect(storedRun.framingLine, isNull);
  });

  test('generation is bounded, so the line fits the screen', () async {
    // Unbounded, Nano ran to its own 256-token default and took 16.4s on the
    // Pixel for a sentence the screen then showed a third of. The cap
    // belongs on generation, not on the widget.
    final engine = _FakeInferenceEngine(response: 'A quiet day.');
    final generator = FramingLineGenerator(engine: engine, database: database);

    await generator.generate(fallbackResult);

    expect(engine.lastMaxOutputTokens, framingLineMaxOutputTokens);
  });
}

Matcher _failedWith(InferenceFailure failure) => isA<InferenceFailed<String>>()
    .having((outcome) => outcome.failure, 'failure', failure);
