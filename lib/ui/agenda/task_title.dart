import 'package:meta/meta.dart';

/// A Task title after inline Markdown links have been unwrapped for display.
///
/// Todoist task content is Markdown, so a title can arrive as
/// `[FABER-CASTELL Spitzer kaufen](https://thalia.de/...)`. Rendered raw the
/// URL swamps the row; [parseTaskTitle] keeps the link text for the title and
/// the first absolute URL so the row can open it.
@immutable
class ParsedTaskTitle {
  const ParsedTaskTitle({required this.text, this.link});

  /// The title with every `[text](url)` replaced by its `text`.
  final String text;

  /// The first absolute URL found in the raw title, or null when there is
  /// none. A link without a scheme (`[x](foo)`) is ignored.
  final Uri? link;
}

final _markdownLink = RegExp(r'\[([^\]]+)\]\((\S+?)\)');

ParsedTaskTitle parseTaskTitle(String rawTitle) {
  Uri? firstLink;
  final text = rawTitle.replaceAllMapped(_markdownLink, (match) {
    final candidate = Uri.tryParse(match.group(2)!);
    if (firstLink == null && candidate != null && candidate.hasScheme) {
      firstLink = candidate;
    }
    return match.group(1)!;
  }).trim();
  return ParsedTaskTitle(text: text, link: firstLink);
}
