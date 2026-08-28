import 'dart:convert';

import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';

/// Combines the active prompt with the full Candidate Set, features
/// included -- the model reasons over rich data, per ADR-0003.
String buildRankingPrompt({
  required String promptTemplate,
  required List<CandidateItem> candidateItems,
}) {
  // Each item carries a short number, and the model answers with those
  // numbers rather than ids. ML Kit's GenAI Prompt API rejects any
  // maxOutputTokens above 256 outright ("maxOutputTokens must be between 1
  // and 256"), and 25 ids like "cal:12345:1787900000000" do not fit in 256
  // tokens. Numbers do, with room to spare.
  final numbered = [
    for (final (index, candidate) in candidateItems.indexed)
      {'n': index + 1, ...candidateItemToJson(candidate)},
  ];
  return '$promptTemplate\n\n'
      'Agenda Items (JSON):\n${jsonEncode(numbered)}\n\n'
      '$_answerContract';
}

/// Parses and validates the model's [response] against [fallbackRankedItems]
/// -- the same items, already in fallback-rank order.
///
/// Returns the validated order (always the same length as
/// [fallbackRankedItems]) if the response is usable, or null if it should be
/// discarded entirely per ADR-0003: parsing failed, or fewer than half of
/// the candidate items were recognised. Never trust prompted output --
/// validation is what makes it safe to use.
List<AgendaItem>? validateModelRanking({
  required String response,
  required List<AgendaItem> fallbackRankedItems,
}) {
  final parsed = _tryParseNumbers(response);
  if (parsed == null) {
    return null;
  }

  // A number is only meaningful if it names one of the items we supplied.
  // The model still authors nothing -- this is the same permutation
  // contract as ADR-0003, counted rather than spelled out.
  final recognised = <int>[];
  for (final n in parsed) {
    final index = n - 1;
    if (index >= 0 &&
        index < fallbackRankedItems.length &&
        !recognised.contains(index)) {
      recognised.add(index);
    }
  }

  if (recognised.length * 2 < fallbackRankedItems.length) {
    return null;
  }

  final seen = recognised.toSet();
  final missing = [
    for (var i = 0; i < fallbackRankedItems.length; i++)
      if (!seen.contains(i)) i,
  ];

  return [
    ...recognised.map((index) => fallbackRankedItems[index]),
    ...missing.map((index) => fallbackRankedItems[index]),
  ];
}

/// Accepts a bare JSON array, or one wrapped in a markdown code fence --
/// models routinely add the latter even when told not to. Returns null for
/// anything else, including valid JSON that isn't a list of whole numbers.
List<int>? _tryParseNumbers(String response) {
  final trimmed = response.trim();
  final fenced = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$')
      .firstMatch(trimmed);
  final candidate = fenced?.group(1) ?? trimmed;

  final Object? decoded;
  try {
    decoded = jsonDecode(candidate);
  } on FormatException {
    return null;
  }

  if (decoded is! List) {
    return null;
  }
  if (decoded.any((element) => element is! int)) {
    return null;
  }
  return decoded.cast<int>();
}

/// The output contract, appended by code rather than stored with the
/// editable prompt. It has to match [validateModelRanking] exactly, and a
/// prompt seeded into the database months ago cannot know that.
const _answerContract =
    'Respond with a JSON array of the item numbers "n", in that order, and '
    'nothing else. Example: [3,1,2]. Use every number exactly once. Do not '
    'invent a number that was not given, and write no other text.';

/// How much room the model needs to answer with a permutation of
/// [itemCount] Agenda Item ids.
///
/// ML Kit applies its own default when no bound is given, and on the Pixel
/// that default is 256 tokens. A 25-item answer needs more than that, so the
/// array was being cut off mid-id and the JSON never parsed -- which the app
/// then reported, correctly but uselessly, as "the model's answer was
/// unusable".
///
/// Ids run to roughly sixteen tokens (`cal:12345:1787900000000`), plus quotes
/// and commas, plus a little slack for a model that likes a trailing newline.
/// ML Kit rejects anything above 256 outright, so this is a clamp, not just
/// a budget. Numbers cost roughly three tokens each with their comma.
int rankingMaxOutputTokens(int itemCount) {
  const mlKitCeiling = 256;
  final needed = itemCount * 4 + 16;
  return needed < mlKitCeiling ? needed : mlKitCeiling;
}
