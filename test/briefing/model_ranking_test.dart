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
        response: '[4, 2, 1, 3]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'b', 'a', 'c']);
    });

    test('a number that names no item is dropped, not inserted', () {
      final result = validateModelRanking(
        response: '[4, 99, 2, 1, 3]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'b', 'a', 'c']);
    });

    test('items missing from the response are appended in fallback order', () {
      final result = validateModelRanking(
        response: '[3, 1]',
        fallbackRankedItems: fallbackOrder,
      );

      // b and d were not returned; fallback order is a, b, c, d.
      expect(result?.map((i) => i.id), ['c', 'a', 'b', 'd']);
    });

    test('a duplicate number in the response counts once', () {
      final result = validateModelRanking(
        response: '[1, 1, 2, 3, 4]',
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

    test('valid JSON that is not a list of numbers is discarded', () {
      final result = validateModelRanking(
        response: '{"order": [1, 2]}',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNull);
    });

    test('fewer than half the candidates recognised discards it all', () {
      // Only 1 of 4 recognised -- below half.
      final result = validateModelRanking(
        response: '[1, 97, 98, 99]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNull);
    });

    test('exactly half recognised is enough to keep', () {
      final result = validateModelRanking(
        response: '[3, 1]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result, isNotNull);
      expect(result, hasLength(4));
    });

    test('a fenced JSON block is unwrapped before parsing', () {
      final result = validateModelRanking(
        response: '```json\n[4, 3, 2, 1]\n```',
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
        response: '[1, 2]',
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

  group('numbers outside the supplied range', () {
    test('zero and negatives name no item and are dropped', () {
      // 1-based numbering: a naive `n - 1` would make 0 index the last item
      // and negatives wrap. Both must simply not match.
      final result = validateModelRanking(
        response: '[0, -1, 4, 3, 2, 1]',
        fallbackRankedItems: fallbackOrder,
      );

      expect(result?.map((i) => i.id), ['d', 'c', 'b', 'a']);
    });
  });
}
