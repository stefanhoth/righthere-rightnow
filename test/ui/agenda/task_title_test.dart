import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/ui/agenda/task_title.dart';

void main() {
  test('a plain title is left untouched and carries no link', () {
    final parsed = parseTaskTitle('Call the plumber');

    expect(parsed.text, 'Call the plumber');
    expect(parsed.link, isNull);
  });

  test('a title that is a single Markdown link unwraps to its text', () {
    final parsed = parseTaskTitle(
      '[FABER-CASTELL Spitzer Two Tone kaufen](https://www.thalia.de/p/A106?x=1)',
    );

    expect(parsed.text, 'FABER-CASTELL Spitzer Two Tone kaufen');
    expect(parsed.link?.host, 'www.thalia.de');
  });

  test('a link embedded in surrounding text keeps the prose', () {
    final parsed = parseTaskTitle(
      'Order [the sharpener](https://a.test/p) today',
    );

    expect(parsed.text, 'Order the sharpener today');
    expect(parsed.link, Uri.parse('https://a.test/p'));
  });

  test('the first absolute URL wins when there are several links', () {
    final parsed = parseTaskTitle(
      '[one](https://first.test) and [two](https://second.test)',
    );

    expect(parsed.text, 'one and two');
    expect(parsed.link, Uri.parse('https://first.test'));
  });

  test('a schemeless link target is unwrapped but not treated as a link', () {
    final parsed = parseTaskTitle('[see the notes](notes)');

    expect(parsed.text, 'see the notes');
    expect(parsed.link, isNull);
  });
}
