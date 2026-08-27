import 'package:meta/meta.dart';

/// The active prompt's text and version together, from a single query --
/// reading them separately risks two independent seed-if-missing writes
/// disagreeing on the version. Deliberately not Drift's generated row type:
/// callers outside `data/` should never see a Drift class.
@immutable
class ActivePrompt {
  const ActivePrompt({required this.text, required this.version});

  final String text;
  final int version;
}

/// Shipped starting point for the ranking prompt -- see ADR-0003. Stored as
/// versioned data from the first run, editable from the dev screen without a
/// rebuild; this constant only matters again if someone resets to it.
const defaultPromptText = '''
You are ranking a person's Daily Agenda: a list of Agenda Items competing
for their attention today. Each item includes an id and the features a
deterministic ranker would use -- due dates, overdue days, proximity,
priority, and similar.

Decide the order these items deserve attention today, most important first.

Respond with a JSON array containing every given item id, in that order, and
nothing else. Do not invent, omit, or rename any id.
''';
