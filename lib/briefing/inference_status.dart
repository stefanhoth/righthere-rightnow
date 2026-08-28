import 'package:meta/meta.dart';

/// What the Inference Engine is doing for the current Briefing Run, so the
/// Daily Agenda can say so.
///
/// Inference is fire-and-forget behind the deterministic agenda (ADR-0006),
/// which means that without this the screen is identical whether the model
/// is thinking, finished, or was never reachable. On the device that made a
/// total inference failure indistinguishable from a success for weeks.
@immutable
class InferenceStatus {
  const InferenceStatus({this.running = const {}, this.notes = const {}});

  /// The work currently in flight. Completions are queued in the engine, so
  /// more than one can be waiting at once.
  final Set<InferenceWork> running;

  /// What became of each piece of work that has finished, phrased for a
  /// human.
  final Map<InferenceWork, String> notes;

  bool get isRunning => running.isNotEmpty;

  /// The single line the screen shows: what is being waited on, or what
  /// happened. Null when there is nothing to say.
  String? get summary {
    if (running.isNotEmpty) {
      final labels = running.map((work) => work.label).toList()..sort();
      return '${labels.join(' and ')}…';
    }
    if (notes.isEmpty) {
      return null;
    }
    final ordered = InferenceWork.values
        .where(notes.containsKey)
        .map((work) => notes[work]!);
    return ordered.join(' · ');
  }

  InferenceStatus starting(InferenceWork work) => InferenceStatus(
    running: {...running, work},
    notes: {...notes}..remove(work),
  );

  /// Marks [work] done. A null [note] means there is nothing worth saying --
  /// a framing line that arrived is its own evidence.
  InferenceStatus finished(InferenceWork work, String? note) => InferenceStatus(
    running: {...running}..remove(work),
    notes: note == null ? ({...notes}..remove(work)) : {...notes, work: note},
  );
}

/// The two things the model is asked to do at app-open.
enum InferenceWork {
  ranking('Ranking your agenda'),
  framing("Writing today's framing");

  const InferenceWork(this.label);

  final String label;
}
