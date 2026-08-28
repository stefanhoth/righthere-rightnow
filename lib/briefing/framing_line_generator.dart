import 'dart:async';

import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/framing_line.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

/// Writes the one generated sentence at the top of the Daily Agenda screen,
/// at app-open (ADR-0006) -- never during the morning Briefing Run itself,
/// and never shown on the lock screen.
class FramingLineGenerator {
  FramingLineGenerator({
    required this.engine,
    required this.database,
    this.timeout = const Duration(seconds: 30),
  });

  final InferenceEngine engine;
  final AppDatabase database;
  final Duration timeout;

  /// Returns the generated line, persisted to [result]'s run -- otherwise
  /// an outcome naming why there is none. The screen works either way: this
  /// only ever adds a line, and never blocks or replaces the deterministic
  /// agenda.
  ///
  /// A line that is absent because inference failed is not the same as one
  /// the model declined to write, and the caller can now tell.
  Future<InferenceOutcome<String>> generate(BriefingRunResult result) async {
    final available = await engine.availability();
    if (available != EngineAvailability.ready) {
      return InferenceSkipped(available);
    }

    final prompt = buildFramingLinePrompt(
      candidateItems: result.candidateItems,
    );

    final String response;
    try {
      response = await engine.complete(prompt, timeout: timeout);
    } on TimeoutException {
      return const InferenceFailed(InferenceFailure.timedOut);
    } on Exception {
      return const InferenceFailed(InferenceFailure.engineThrew);
    }

    final line = response.trim();
    if (line.isEmpty) {
      return const InferenceFailed(InferenceFailure.emptyOutput);
    }

    await database.saveFramingLine(runId: result.runId, framingLine: line);
    return InferenceSucceeded(line);
  }
}
