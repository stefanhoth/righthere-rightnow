import 'package:meta/meta.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/briefing/replay.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'replay_controller.g.dart';

/// One run of the replay harness against every stored Briefing Run.
@immutable
class ReplaySummary {
  const ReplaySummary({required this.results, required this.agreement});

  final List<ReplayResult> results;

  /// See [agreementMetric] -- null if no replayed run had a corrected
  /// order to compare against.
  final double? agreement;

  int get nonDeterministicCount =>
      results.where((r) => r.promptVersionMatches && !r.isDeterministic).length;
}

/// Idle (data: null) until [run] is called -- this harness reasons over
/// stored history and the current prompt only; it never runs on its own.
@Riverpod(keepAlive: true)
class ReplayController extends _$ReplayController {
  @override
  AsyncValue<ReplaySummary?> build() => const AsyncData(null);

  Future<void> run() async {
    state = const AsyncLoading<ReplaySummary?>();
    state = await AsyncValue.guard(() async {
      final harness = ReplayHarness(
        engine: ref.read(inferenceEngineProvider),
        database: ref.read(appDatabaseProvider),
      );
      final results = await harness.replayAll();
      return ReplaySummary(
        results: results,
        agreement: agreementMetric(results),
      );
    });
  }
}
