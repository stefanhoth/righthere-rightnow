/// Extracts a conference join link from a Commitment's description.
///
/// Android's Calendar Provider has no structured conference-link column --
/// Meet, Zoom and Teams URLs arrive as plain text inside the description.
/// This never mutates [description]; only reads it. Mutating it is the bug
/// that disqualified `eventide`.
///
/// When a description contains more than one link, the one appearing
/// earliest in the text wins, regardless of which service it's for.
String? extractConferenceUrl(String? description) {
  if (description == null) {
    return null;
  }

  RegExpMatch? earliest;
  for (final pattern in _patterns) {
    final match = pattern.firstMatch(description);
    if (match != null && (earliest == null || match.start < earliest.start)) {
      earliest = match;
    }
  }
  return earliest?.group(0);
}

final _patterns = [
  RegExp(r'https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}'),
  RegExp(r'https://[\w-]*\.?zoom\.us/j/\d+'),
  RegExp(r'https://teams\.microsoft\.com/l/meetup-join/\S+'),
];
