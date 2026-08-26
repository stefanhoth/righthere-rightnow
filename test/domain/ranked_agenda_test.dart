import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';

void main() {
  const item = Task(
    id: 'td:1',
    title: 'File taxes',
    priority: Priority.p1,
    isRecurring: false,
  );

  test('a fallback-ranked agenda carries no prompt version', () {
    const agenda = RankedAgenda(items: [item], rankedBy: RankedBy.fallback);

    expect(agenda.rankedBy, RankedBy.fallback);
    expect(agenda.promptVersion, isNull);
  });

  test('a model-ranked agenda records the prompt version used', () {
    const agenda = RankedAgenda(
      items: [item],
      rankedBy: RankedBy.model,
      promptVersion: 'v3',
    );

    expect(agenda.promptVersion, 'v3');
  });
}
