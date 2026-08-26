import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/priority.dart';

void main() {
  test('holds the items a Briefing Run considered plus when it ran', () {
    const item = Task(
      id: 'td:1',
      title: 'File taxes',
      priority: Priority.p1,
      isRecurring: false,
    );
    final generatedAt = DateTime.utc(2026, 8, 26, 6);

    final candidateSet = CandidateSet(
      items: const [item],
      generatedAt: generatedAt,
    );

    expect(candidateSet.items, [item]);
    expect(candidateSet.generatedAt, generatedAt);
  });

  test('can be empty', () {
    final candidateSet = CandidateSet(
      items: const [],
      generatedAt: DateTime.utc(2026, 8, 26),
    );

    expect(candidateSet.items, isEmpty);
  });
}
