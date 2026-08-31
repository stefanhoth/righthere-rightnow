import 'package:meta/meta.dart';

/// The structure a Briefing Run needs from the What Matters prose, extracted
/// once by the model and then read from cache by the deterministic ranker
/// (ADR-0008). Pure data -- the model output is validated into this shape
/// elsewhere; by the time it is a [WhatMattersExtraction] it is complete and
/// trusted.
@immutable
class WhatMattersExtraction {
  const WhatMattersExtraction({
    required this.projects,
    required this.neverDecays,
  });

  /// Long-horizon work the user declared, each with a deadline and a session
  /// count -- the input to Pace (Task 4.7).
  final List<Project> projects;

  /// Match strings for Tasks that must escalate with age rather than decay
  /// (ADR-0007, applied in Task 4.6). Compared against Task titles.
  final List<String> neverDecays;

  /// A document that declares nothing. Distinct from "not extracted yet"
  /// (which is null): this is a real, complete extraction of an empty
  /// intent, and reproduces today's ranking behaviour exactly.
  static const empty = WhatMattersExtraction(projects: [], neverDecays: []);

  @override
  bool operator ==(Object other) =>
      other is WhatMattersExtraction &&
      _listEquals(other.projects, projects) &&
      _listEquals(other.neverDecays, neverDecays);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(projects), Object.hashAll(neverDecays));
}

/// Work that needs several Sessions before a deadline, declared in What
/// Matters -- see CONTEXT.md. Not a Todoist project (`todoistProject`).
@immutable
class Project {
  const Project({
    required this.name,
    required this.deadline,
    required this.sessionsNeeded,
  });

  final String name;

  /// Date only -- the time component is always midnight local.
  final DateTime deadline;

  /// How many Sessions the user estimates the Project needs in total.
  /// Always at least 1.
  final int sessionsNeeded;

  @override
  bool operator ==(Object other) =>
      other is Project &&
      other.name == name &&
      other.deadline == deadline &&
      other.sessionsNeeded == sessionsNeeded;

  @override
  int get hashCode => Object.hash(name, deadline, sessionsNeeded);
}

bool _listEquals<T>(List<T> a, List<T> b) {
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
