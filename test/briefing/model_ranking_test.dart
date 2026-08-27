import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/model_ranking.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';

Task _task(String id) {
  return Task(id: id, title: id, priority: Priority.p3, isRecurring: false);
}

void main() {
  final fallbackOrder = [_task('a'), _task('b'), _task('c'), _task('d')];

  group('validateModelRanking', () {
    test('a valid permutation is used verbatim', () {
      final result = validateModelRanking(
        response: '["d", "b", "a", "c"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'b', 'a', 'c']);
    });

    test('a hallucinated id is dropped, not inserted', () {
      final result = validateModelRanking(
        response: '["d", "zzz", "b", "a", "c"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'b', 'a', 'c']);
    });

    test('ids missing from the response are appended in fallback order', () {
      final result = validateModelRanking(
        response: '["c", "a"]',
        fallbackRankedItems: fallbackOrder,
      );

      // b and d were not returned; fallback order is a, b, c, d.
      expect(result?.map((i) => i.id), ['c', 'a', 'b', 'd']);
    });

    test('a duplicate id in the response counts once', () {
      final result = validateModelRanking(
        response: '["a", "a", "b", "c", "d"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['a', 'b', 'c', 'd']);
    });

    test('unparseable output is discarded entirely', () {
      final result = validateModelRanking(
        response: 'not json at all',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNull);
    });

    test('valid JSON that is not a list of strings is discarded', () {
      final result = validateModelRanking(
        response: '{"order": ["a", "b"]}',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNull);
    });

    test('fewer than half the candidate ids recognised discards it all', () {
      // Only 1 of 4 recognised -- below half.
      final result = validateModelRanking(
        response: '["a", "zzz", "yyy", "xxx"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNull);
    });

    test('exactly half recognised is enough to keep', () {
      final result = validateModelRanking(
        response: '["c", "a"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNotNull);
      expect(result, hasLength(4));
    });

    test('a fenced JSON block is unwrapped before parsing', () {
      final result = validateModelRanking(
        response: '```json\n["d", "c", "b", "a"]\n```',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'c', 'b', 'a']);
    });

    test('an empty candidate set never breaks validation', () {
      final result = validateModelRanking(
        response: '[]',
        fallbackRankedItems: const [],
      );

      expect(result, isEmpty);
    });

    test('the result is always the same length as the fallback order', () {
      final result = validateModelRanking(
        response: '["a", "b"]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, hasLength(fallbackOrder.length));
    });
  });

  group('buildRankingPrompt', () {
    test('appends the candidate set as JSON after the template', () {
      final prompt = buildRankingPrompt(
        promptTemplate: 'Rank these.',
        candidateItems: const [],
      );

      expect(prompt, startsWith('Rank these.'));
      expect(prompt, contains('[]'));
    });
  });
}
