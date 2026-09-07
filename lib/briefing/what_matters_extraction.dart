import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';

/// A persisted extraction with the exact prose it came from, so the
/// extractor can tell an unchanged document from a changed one without
/// hashing (ADR-0008).
@immutable
class StoredWhatMattersExtraction {
  const StoredWhatMattersExtraction({
    required this.extraction,
    required this.sourceProse,
    required this.extractedAt,
  });

  final WhatMattersExtraction extraction;
  final String sourceProse;
  final DateTime extractedAt;
}

/// The one prompt the model sees for extraction (ADR-0008). It reads *only*
/// the prose and returns structure -- this text, and the document, are the
/// entire input. The output contract is appended here in code, never stored
/// with an editable prompt, for the same reason the ranking contract is.
String buildWhatMattersExtractionPrompt(String prose) {
  return 'You are reading a personal "what matters" note. Extract two things '
      'and nothing else.\n\n'
      '1. Projects: long-horizon work with a deadline and a rough number of '
      'work sessions. Only include work the note frames this way.\n'
      '2. Keep: short phrases naming tasks or duties the person never wants '
      'to let slide, however old they get.\n\n'
      'Note:\n"""\n$prose\n"""\n\n'
      '$_contract';
}

/// ML Kit caps output at 256 tokens (see `rankingMaxOutputTokens`). A note
/// with a handful of Projects and keep-phrases fits; a longer answer is
/// truncated and fails to parse, which is treated as "no new extraction".
const whatMattersExtractionMaxOutputTokens = 256;

const _contract =
    'Respond with one JSON object and no other text:\n'
    '{"projects":[{"name":"...","deadline":"YYYY-MM-DD","sessions":N}],'
    '"keep":["...","..."]}\n'
    'Use [] for either list if the note names none. "sessions" is a whole '
    'number of at least 1. Do not invent a deadline the note does not give -- '
    'omit that Project instead.';

final _fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$');
final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Validates the model's [response] into a complete [WhatMattersExtraction],
/// or returns null if it is anything less.
///
/// Null covers every partial or malformed case -- unparseable JSON, the
/// wrong top-level shape, a missing list, a Project missing a field, a
/// deadline that is not `YYYY-MM-DD`, a non-positive session count, an empty
/// keep phrase. Per ADR-0008 a partial extraction is never returned: the
/// caller keeps the one it already has.
WhatMattersExtraction? parseWhatMattersExtraction(String response) {
  final trimmed = response.trim();
  final body = _fence.firstMatch(trimmed)?.group(1) ?? trimmed;

  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic>) {
    return null;
  }

  final rawProjects = decoded['projects'];
  final rawKeep = decoded['keep'];
  if (rawProjects is! List || rawKeep is! List) {
    return null;
  }

  final projects = <Project>[];
  for (final entry in rawProjects) {
    final project = _projectFrom(entry);
    if (project == null) {
      return null;
    }
    projects.add(project);
  }

  final neverDecays = <String>[];
  for (final entry in rawKeep) {
    if (entry is! String || entry.trim().isEmpty) {
      return null;
    }
    neverDecays.add(entry.trim());
  }

  return WhatMattersExtraction(projects: projects, neverDecays: neverDecays);
}

Project? _projectFrom(Object? entry) {
  if (entry is! Map<String, dynamic>) {
    return null;
  }
  final name = entry['name'];
  final deadline = entry['deadline'];
  final sessions = entry['sessions'];

  if (name is! String || name.trim().isEmpty) {
    return null;
  }
  if (deadline is! String || !_isoDate.hasMatch(deadline)) {
    return null;
  }
  final parsedDeadline = DateTime.tryParse(deadline);
  if (parsedDeadline == null) {
    return null;
  }
  final sessionCount = switch (sessions) {
    final int n => n,
    final double n when n == n.roundToDouble() => n.toInt(),
    _ => null,
  };
  if (sessionCount == null || sessionCount < 1) {
    return null;
  }

  return Project(
    name: name.trim(),
    deadline: DateTime(
      parsedDeadline.year,
      parsedDeadline.month,
      parsedDeadline.day,
    ),
    sessionsNeeded: sessionCount,
  );
}

/// Our own canonical JSON for a stored or snapshotted extraction. Round-trips
/// exactly with [whatMattersExtractionFromJson]; unlike the model parser it
/// trusts its input and throws on corruption.
String whatMattersExtractionToJson(WhatMattersExtraction extraction) {
  return jsonEncode({
    'projects': [
      for (final project in extraction.projects)
        {
          'name': project.name,
          'deadline': _dateOnly(project.deadline),
          'sessions': project.sessionsNeeded,
        },
    ],
    'keep': extraction.neverDecays,
  });
}

WhatMattersExtraction whatMattersExtractionFromJson(String json) {
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  return WhatMattersExtraction(
    projects: [
      for (final entry in decoded['projects'] as List<dynamic>)
        Project(
          name: (entry as Map<String, dynamic>)['name'] as String,
          deadline: DateTime.parse(entry['deadline'] as String),
          sessionsNeeded: entry['sessions'] as int,
        ),
    ],
    neverDecays: (decoded['keep'] as List<dynamic>).cast<String>(),
  );
}

String _dateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
