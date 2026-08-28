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
  final json = jsonEncode(candidateItems.map(candidateItemToJson).toList());
  return '$promptTemplate\n\nAgenda Items (JSON):\n$json';
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
  final parsedIds = _tryParseIds(response);
  if (parsedIds == null) {
    return null;
  }

  final byId = {for (final item in fallbackRankedItems) item.id: item};
  final recognisedIds = <String>[];
  for (final id in parsedIds) {
    if (byId.containsKey(id) && !recognisedIds.contains(id)) {
      recognisedIds.add(id);
    }
  }

  if (recognisedIds.length * 2 < fallbackRankedItems.length) {
    return null;
  }

  final recognisedSet = recognisedIds.toSet();
  final missingIds = fallbackRankedItems
      .map((item) => item.id)
      .where((id) => !recognisedSet.contains(id));

  return [
    ...recognisedIds.map((id) => byId[id]!),
    ...missingIds.map((id) => byId[id]!),
  ];
}

/// Accepts a bare JSON array, or one wrapped in a markdown code fence --
/// models routinely add the latter even when told not to. Returns null for
/// anything else, including valid JSON that isn't a list of strings.
List<String>? _tryParseIds(String response) {
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
  if (decoded.any((element) => element is! String)) {
    return null;
  }
  return decoded.cast<String>();
}

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
int rankingMaxOutputTokens(int itemCount) => itemCount * 20 + 32;
