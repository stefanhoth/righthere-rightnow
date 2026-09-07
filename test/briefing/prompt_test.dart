import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/prompt.dart';

void main() {
  group('defaultPromptText', () {
    test(
      'says nothing about the answer format -- that is the code contract',
      () {
        final lower = defaultPromptText.toLowerCase();
        expect(lower, isNot(contains('json array')));
        expect(lower, isNot(contains('respond with')));
      },
    );

    test('tells the model a recurring overdue task is usually low-stakes', () {
      expect(defaultPromptText, contains('recurring'));
      expect(defaultPromptText, contains('regenerated'));
    });

    test('tells the model to sink low-priority background maintenance', () {
      expect(defaultPromptText, contains('no project'));
      expect(defaultPromptText, contains('maintenance'));
    });
  });
}
