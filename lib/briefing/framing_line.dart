import 'dart:convert';

import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';

/// Not versioned data like the ranking prompt (ADR-0003 is specifically
/// about ranking's permutation contract): the framing line has no
/// structured output to validate, and nothing yet calls for a dev screen to
/// tune it.
const framingLinePromptText = '''
Write one short sentence framing today for this person, based on their
Daily Agenda below -- what the day's shape is, and what deserves
attention or protecting. Use at most 20 words. No greeting, no markdown,
no explanation: respond with the sentence itself and nothing else.
''';

/// Combines the framing-line prompt with the full Candidate Set, the same
/// rich input the ranking prompt gets (ADR-0003).
String buildFramingLinePrompt({required List<CandidateItem> candidateItems}) {
  final json = jsonEncode(candidateItems.map(candidateItemToJson).toList());
  return '$framingLinePromptText\n\nAgenda Items (JSON):\n$json';
}

/// Enough for a 20-word sentence with room to finish it, and far below the
/// engine's own 256-token default -- which cost 16.4s on the Pixel for a
/// line the screen then showed a third of.
const framingLineMaxOutputTokens = 48;
