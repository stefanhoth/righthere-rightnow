import 'dart:convert';

import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';

/// Combines the active prompt with the full Candidate Set, features
/// included, and -- when there is one -- the What Matters extraction, so the
/// model ranks against what the person is actually working toward and not
/// only calendar/Todoist mechanics (ADR-0003, and DECISIONS.md 2026-08-31).
///
/// [whatMatters] is the *extraction* (Projects and the never-decays list),
/// never the raw prose -- ADR-0008 keeps the prose out of the ranking
/// prompt. Null, or empty, and the block is omitted entirely.
String buildRankingPrompt({
  required String promptTemplate,
  required List<CandidateItem> candidateItems,
  WhatMattersExtraction? whatMatters,
}) {
  // Each item carries a short number "n" and the model answers with those,
  // not the ids: a 2B model reproducing 25 opaque id strings verbatim
  // either mangles one (unusable) or spends its whole turn on them
  // (timeout). Numbers are trivially reproducible. This is *not* the old
  // 256-token workaround -- LiteRT-LM has no such ceiling -- it is a
  // reliability choice.
  final numbered = [
    for (final (index, candidate) in candidateItems.indexed)
      {'n': index + 1, ...candidateItemToJson(candidate)},
  ];

  final priorities = _prioritiesBlock(whatMatters);

  return '$promptTemplate\n\n'
      '$priorities'
      'Agenda Items (JSON):\n${jsonEncode(numbered)}\n\n'
      '$_answerContract';
}

String _prioritiesBlock(WhatMattersExtraction? whatMatters) {
  if (whatMatters == null ||
      (whatMatters.projects.isEmpty && whatMatters.neverDecays.isEmpty)) {
    return '';
  }
  final json = jsonEncode({
    'projects': [
      for (final project in whatMatters.projects)
        {
          'name': project.name,
          'deadline': project.deadline.toIso8601String().split('T').first,
          'sessionsNeeded': project.sessionsNeeded,
        },
    ],
    'neverLetSlide': whatMatters.neverDecays,
  });
  return 'What this person is working toward (weigh this heavily -- an item '
      'that serves a project deadline or is on the never-let-slide list '
      'matters more than its due date alone suggests):\n$json\n\n';
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

  // A number is only meaningful if it names one of the items we supplied,
  // and only counts once. The model authors nothing -- this is the ADR-0003
  // permutation contract, counted rather than spelled out.
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
    'Respond with a JSON array of the item numbers "n", most important '
    'first, and nothing else. Example: [3,1,2]. Use every number exactly '
    'once. Do not invent a number that was not given, and write no other '
    'text.';

/// How much room the model needs to answer with a permutation of
/// [itemCount] item numbers.
///
/// A number costs roughly three tokens with its comma. LiteRT-LM has no hard
/// output ceiling (unlike ML Kit GenAI's 256), so this is a real budget, not
/// a clamp; it is bounded only so a runaway generation cannot eat the
/// context window.
int rankingMaxOutputTokens(int itemCount) {
  final needed = itemCount * 6 + 32;
  return needed < 1024 ? needed : 1024;
}
