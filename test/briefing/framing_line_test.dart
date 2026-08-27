import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/framing_line.dart';

void main() {
  test('appends the candidate set as JSON after the prompt', () {
    final prompt = buildFramingLinePrompt(candidateItems: const []);

    expect(prompt, startsWith(framingLinePromptText));
    expect(prompt, contains('[]'));
  });
}
