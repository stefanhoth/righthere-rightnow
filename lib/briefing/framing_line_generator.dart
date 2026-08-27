import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/framing_line.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// Writes the one generated sentence at the top of the Daily Agenda screen,
/// at app-open (ADR-0006) -- never during the morning Briefing Run itself,
/// and never shown on the lock screen.
class FramingLineGenerator {
  FramingLineGenerator({
    required this.engine,
    required this.database,
    this.timeout = const Duration(seconds: 10),
  });

  final InferenceEngine engine;
  final AppDatabase database;
  final Duration timeout;

  /// Returns the generated line, persisted to [result]'s run, or null if
  /// inference is unavailable, fails, times out, or returns nothing usable.
  /// The screen works either way -- this only ever adds a line, never
  /// blocks or replaces the deterministic agenda.
  Future<String?> generate(BriefingRunResult result) async {
    if (!await engine.isAvailable()) {
      return null;
    }

    final prompt = buildFramingLinePrompt(
      candidateItems: result.candidateItems,
    );

    final String response;
    try {
      response = await engine.complete(prompt, timeout: timeout);
    } on Exception {
      return null;
    }

    final line = response.trim();
    if (line.isEmpty) {
      return null;
    }

    await database.saveFramingLine(runId: result.runId, framingLine: line);
    return line;
  }
}
