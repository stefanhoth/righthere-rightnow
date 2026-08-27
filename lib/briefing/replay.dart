import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:righthere_rightnow/briefing/model_ranking.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// One stored Briefing Run replayed against the current prompt (Task 3.6):
/// its originally-persisted order, its human-corrected order if any, and
/// the order this replay produced.
@immutable
class ReplayResult {
  const ReplayResult({
    required this.runId,
    required this.originalOrder,
    required this.correctedOrder,
    required this.replayedOrder,
    required this.promptVersionMatches,
  });

  final int runId;

  /// The order the run actually persisted (its `producedRank`) -- whatever
  /// ranked it, fallback or model.
  final List<String> originalOrder;

  /// The human's drag-corrected order, or null if this run was never
  /// corrected.
  final List<String>? correctedOrder;

  /// The order this replay produced, or null if inference was unavailable,
  /// failed, timed out, or its output failed validation.
  final List<String>? replayedOrder;

  /// Whether [runId]'s stored `promptVersion` equals the prompt version
  /// used for this replay -- only meaningful for a determinism check: with
  /// the same prompt and the same input, [replayedOrder] should reproduce
  /// [originalOrder] exactly. On-device inference is not guaranteed
  /// deterministic, so a mismatch here is a fact to flag, not an error to
  /// throw.
  final bool promptVersionMatches;

  /// True if replaying under a matching prompt version reproduced the
  /// original order exactly. False (never a crash) if the versions differ,
  /// replay failed, or the model was not, in fact, deterministic.
  bool get isDeterministic {
    final replayed = replayedOrder;
    return promptVersionMatches &&
        replayed != null &&
        _sameOrder(replayed, originalOrder);
  }

  /// Fraction of items at the same position in [replayedOrder] and
  /// [correctedOrder] -- null if there is nothing to compare: no
  /// correction was ever recorded, or this replay didn't produce an order.
  /// Never scored as zero agreement; simply excluded.
  double? get agreementWithCorrection {
    final corrected = correctedOrder;
    final replayed = replayedOrder;
    if (corrected == null || replayed == null || corrected.isEmpty) {
      return null;
    }
    var matches = 0;
    for (var i = 0; i < corrected.length; i++) {
      if (i < replayed.length && replayed[i] == corrected[i]) {
        matches++;
      }
    }
    return matches / corrected.length;
  }
}

bool _sameOrder(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// The average [ReplayResult.agreementWithCorrection] across [results] --
/// null if none of them have a corrected order to compare against. Runs
/// with no correction are excluded entirely, never scored as disagreement.
double? agreementMetric(List<ReplayResult> results) {
  final scores = results
      .map((result) => result.agreementWithCorrection)
      .whereType<double>()
      .toList();
  if (scores.isEmpty) {
    return null;
  }
  return scores.reduce((a, b) => a + b) / scores.length;
}

/// Replays stored Briefing Runs against the current prompt: "edit prompt →
/// replay stored days → diff orderings" (Task 3.6). Never touches the
/// network and never writes a new Briefing Run -- it only reads persisted
/// snapshots and calls the (on-device) Inference Engine.
class ReplayHarness {
  ReplayHarness({
    required this.engine,
    required this.database,
    this.timeout = const Duration(seconds: 10),
  });

  final InferenceEngine engine;
  final AppDatabase database;
  final Duration timeout;

  /// Replays every stored Briefing Run. Works offline: nothing here reaches
  /// the calendar or Todoist, or even the network -- only the local
  /// database and the on-device engine.
  Future<List<ReplayResult>> replayAll() async {
    final runIds = await database.allBriefingRunIds();
    final results = <ReplayResult>[];
    for (final runId in runIds) {
      results.add(await replayRun(runId));
    }
    return results;
  }

  /// Replays a single stored run.
  Future<ReplayResult> replayRun(int runId) async {
    final rows = await database.snapshotItemsForRun(runId);
    final storedPromptVersion = await database.promptVersionForRun(runId);
    final activePrompt = await database.activePrompt();

    final byFallbackRank = [...rows]
      ..sort((a, b) => a.fallbackRank.compareTo(b.fallbackRank));
    final byProducedRank = [...rows]
      ..sort((a, b) => a.producedRank.compareTo(b.producedRank));
    final hasFullCorrection =
        rows.isNotEmpty && rows.every((row) => row.correctedRank != null);
    final correctedOrder = hasFullCorrection
        ? ([...rows]
                ..sort((a, b) => a.correctedRank!.compareTo(b.correctedRank!)))
              .map((row) => row.itemId)
              .toList()
        : null;

    final candidateItems = byFallbackRank
        .map(
          (row) => candidateItemFromJson(
            jsonDecode(row.payloadJson) as Map<String, dynamic>,
          ),
        )
        .toList();
    final fallbackOrderItems = candidateItems
        .map((candidate) => candidate.item)
        .toList();

    final replayedOrder = await _replayOrder(
      promptTemplate: activePrompt.text,
      candidateItems: candidateItems,
      fallbackOrderItems: fallbackOrderItems,
    );

    return ReplayResult(
      runId: runId,
      originalOrder: byProducedRank.map((row) => row.itemId).toList(),
      correctedOrder: correctedOrder,
      replayedOrder: replayedOrder,
      promptVersionMatches:
          storedPromptVersion != null &&
          storedPromptVersion == 'v${activePrompt.version}',
    );
  }

  Future<List<String>?> _replayOrder({
    required String promptTemplate,
    required List<CandidateItem> candidateItems,
    required List<AgendaItem> fallbackOrderItems,
  }) async {
    if (!await engine.isAvailable()) {
      return null;
    }

    final prompt = buildRankingPrompt(
      promptTemplate: promptTemplate,
      candidateItems: candidateItems,
    );

    final String response;
    try {
      response = await engine.complete(prompt, timeout: timeout);
    } on Exception {
      return null;
    }

    final validated = validateModelRanking(
      response: response,
      fallbackRankedItems: fallbackOrderItems,
    );
    return validated?.map((item) => item.id).toList();
  }
}
