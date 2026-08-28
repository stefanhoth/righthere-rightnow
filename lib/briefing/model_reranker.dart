import 'dart:async';

import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/model_ranking.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

/// Re-ranks an already-persisted Briefing Run's Daily Agenda using the
/// Inference Engine, at app-open (ADR-0006) -- never during the morning
/// Briefing Run itself.
class ModelReranker {
  ModelReranker({
    required this.engine,
    required this.database,
    this.timeout = const Duration(seconds: 30),
  });

  final InferenceEngine engine;
  final AppDatabase database;
  final Duration timeout;

  /// Returns an updated [BriefingRunResult] if the model produced a usable
  /// ranking, persisted to the same run -- otherwise an outcome naming why
  /// it did not. The caller keeps showing [result] as it already stands in
  /// every failing case. A late agenda is worse than a deterministic one,
  /// so this never retries or blocks.
  Future<InferenceOutcome<BriefingRunResult>> rerank(
    BriefingRunResult result,
  ) async {
    final available = await engine.availability();
    if (available != EngineAvailability.ready) {
      return InferenceSkipped(available);
    }

    final prompt = await database.activePrompt();
    final promptText = buildRankingPrompt(
      promptTemplate: prompt.text,
      candidateItems: result.candidateItems,
    );

    final String response;
    try {
      response = await engine.complete(promptText, timeout: timeout);
    } on TimeoutException {
      return const InferenceFailed(InferenceFailure.timedOut);
    } on Exception {
      return const InferenceFailed(InferenceFailure.engineThrew);
    }

    final reordered = validateModelRanking(
      response: response,
      fallbackRankedItems: result.agenda.items,
    );
    if (reordered == null) {
      return const InferenceFailed(InferenceFailure.unusableOutput);
    }

    final promptVersion = 'v${prompt.version}';
    await database.updateRunRanking(
      runId: result.runId,
      rankedBy: RankedBy.model,
      promptVersion: promptVersion,
      producedOrder: reordered.map((item) => item.id).toList(),
    );

    return InferenceSucceeded(
      BriefingRunResult(
        runId: result.runId,
        agenda: RankedAgenda(
          items: reordered,
          rankedBy: RankedBy.model,
          promptVersion: promptVersion,
        ),
        candidateItems: result.candidateItems,
        allDayCommitments: result.allDayCommitments,
        startedAt: result.startedAt,
        completedAt: result.completedAt,
        calendarPermissionDenied: result.calendarPermissionDenied,
        error: result.error,
      ),
    );
  }
}
