import 'dart:async';

import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/briefing/what_matters_extraction.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

/// Reads structure out of the What Matters prose once per Briefing Run, at
/// app-open (ADR-0006, ADR-0008). The deterministic ranker reads the
/// persisted extraction; it never sees the prose.
///
/// Runs the engine only when the document's content has actually changed
/// since the last stored extraction. A skipped engine, a timeout, an
/// engine error, or an incomplete parse all leave the previous extraction
/// untouched -- degrading to yesterday's understanding, never to none.
class WhatMattersExtractor {
  WhatMattersExtractor({
    required this.engine,
    required this.database,
    required this.clock,
    this.timeout = const Duration(seconds: 30),
  });

  final InferenceEngine engine;
  final AppDatabase database;
  final Clock clock;
  final Duration timeout;

  Future<InferenceOutcome<WhatMattersExtraction>> extract(
    WhatMattersDocument? document,
  ) async {
    if (document == null) {
      // No What Matters configured, and (since the cache falls back on a
      // failed fetch) nothing ever cached either -- so there is no prior
      // extraction to preserve. Not a failure; the ranker just gets no
      // extra input.
      return const InferenceSucceeded(WhatMattersExtraction.empty);
    }

    final stored = await database.storedWhatMattersExtraction();
    if (stored != null && stored.sourceProse == document.prose) {
      // The document has not changed. No second extraction (ADR-0008).
      return InferenceSucceeded(stored.extraction);
    }

    final availability = await engine.availability();
    if (availability != EngineAvailability.ready) {
      return InferenceSkipped(availability);
    }

    final String response;
    try {
      response = await engine.complete(
        buildWhatMattersExtractionPrompt(document.prose),
        timeout: timeout,
        maxOutputTokens: whatMattersExtractionMaxOutputTokens,
      );
    } on TimeoutException {
      return const InferenceFailed(InferenceFailure.timedOut);
    } on Exception catch (error) {
      return InferenceFailed(
        InferenceFailure.engineThrew,
        detail: error.toString(),
      );
    }

    final extraction = parseWhatMattersExtraction(response);
    if (extraction == null) {
      // Incomplete or malformed -- keep the previous extraction (ADR-0008).
      return InferenceFailed(InferenceFailure.unusableOutput, detail: response);
    }

    await database.saveWhatMattersExtraction(
      extraction: extraction,
      sourceProse: document.prose,
      extractedAt: clock(),
    );
    return InferenceSucceeded(extraction);
  }
}
