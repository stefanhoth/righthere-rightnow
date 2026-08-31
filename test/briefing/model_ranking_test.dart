import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/model_ranking.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';

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

    test('zero and negatives name no item and are dropped', () {
      final result = validateModelRanking(
        response: '[0, -1, 4, 3, 2, 1]',
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
    test('numbers the candidate set and asks for a number array', () {
      final prompt = buildRankingPrompt(
        promptTemplate: 'Rank these.',
        candidateItems: const [],
      );

      expect(prompt, startsWith('Rank these.'));
      expect(prompt, contains('[]'));
      // The answer contract comes from code, never the stored prompt.
      expect(prompt, contains('JSON array of the item numbers'));
    });

    test('omits the priorities block when there is no extraction', () {
      final prompt = buildRankingPrompt(
        promptTemplate: 'Rank.',
        candidateItems: const [],
      );

      expect(prompt, isNot(contains('working toward')));
    });

    test('omits the priorities block when the extraction is empty', () {
      final prompt = buildRankingPrompt(
        promptTemplate: 'Rank.',
        candidateItems: const [],
        whatMatters: WhatMattersExtraction.empty,
      );

      expect(prompt, isNot(contains('working toward')));
    });

    test('carries the extracted structure -- never the prose -- when set', () {
      final prompt = buildRankingPrompt(
        promptTemplate: 'Rank.',
        candidateItems: const [],
        whatMatters: WhatMattersExtraction(
          projects: [
            Project(
              name: 'Tax return',
              deadline: DateTime(2026, 10, 31),
              sessionsNeeded: 4,
            ),
          ],
          neverDecays: const ['renew passport'],
        ),
      );

      expect(prompt, contains('working toward'));
      expect(prompt, contains('Tax return'));
      expect(prompt, contains('2026-10-31'));
      expect(prompt, contains('renew passport'));
    });
  });

  group('rankingMaxOutputTokens', () {
    test('scales with item count', () {
      expect(
        rankingMaxOutputTokens(25),
        greaterThan(rankingMaxOutputTokens(5)),
      );
    });

    test('is bounded so a runaway answer cannot eat the context', () {
      expect(rankingMaxOutputTokens(1000), lessThanOrEqualTo(1024));
    });
  });
}
