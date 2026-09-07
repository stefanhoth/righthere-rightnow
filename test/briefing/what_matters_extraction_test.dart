import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/what_matters_extraction.dart';
import 'package:righthere_rightnow/domain/what_matters_extraction.dart';

/// A model response as a JSON string, built from parts so the test literals
/// stay readable and the linter stays happy.
String response({
  List<Object?> projects = const [],
  List<Object?> keep = const [],
}) => jsonEncode({'projects': projects, 'keep': keep});

Map<String, Object?> project({
  Object? name = 'P',
  Object? deadline = '2026-12-01',
  Object? sessions = 2,
}) => {'name': name, 'deadline': deadline, 'sessions': sessions};

void main() {
  group('buildWhatMattersExtractionPrompt', () {
    test('carries the prose and asks for the two lists', () {
      final prompt = buildWhatMattersExtractionPrompt(
        'Finish the deck by Friday.',
      );

      expect(prompt, contains('Finish the deck by Friday.'));
      expect(prompt, contains('projects'));
      expect(prompt, contains('keep'));
    });
  });

  group('parseWhatMattersExtraction', () {
    test('a clean object gives Projects and the keep list', () {
      final extraction = parseWhatMattersExtraction(
        response(
          projects: [
            project(name: 'Tax return', deadline: '2026-10-31', sessions: 4),
          ],
          keep: ['call mum', 'renew passport'],
        ),
      );

      expect(extraction, isNotNull);
      expect(extraction!.projects.single.name, 'Tax return');
      expect(extraction.projects.single.deadline, DateTime(2026, 10, 31));
      expect(extraction.projects.single.sessionsNeeded, 4);
      expect(extraction.neverDecays, ['call mum', 'renew passport']);
    });

    test('empty lists are a complete extraction, not a partial one', () {
      expect(
        parseWhatMattersExtraction(response()),
        WhatMattersExtraction.empty,
      );
    });

    test('a markdown code fence around the JSON is tolerated', () {
      final extraction = parseWhatMattersExtraction(
        '```json\n${response(keep: ['floss'])}\n```',
      );

      expect(extraction?.neverDecays, ['floss']);
    });

    test('a whole-number session count given as a double is accepted', () {
      final extraction = parseWhatMattersExtraction(
        response(projects: [project(sessions: 3.0)]),
      );

      expect(extraction?.projects.single.sessionsNeeded, 3);
    });

    test('unparseable text is rejected', () {
      expect(parseWhatMattersExtraction('not json at all'), isNull);
    });

    test('a missing list makes the whole extraction partial', () {
      expect(parseWhatMattersExtraction('{"projects":[]}'), isNull);
    });

    test('a Project missing a field rejects the whole extraction', () {
      expect(
        parseWhatMattersExtraction(
          jsonEncode({
            'projects': [
              {'name': 'P', 'sessions': 2},
            ],
            'keep': <String>[],
          }),
        ),
        isNull,
      );
    });

    test('a deadline that is not YYYY-MM-DD is rejected', () {
      expect(
        parseWhatMattersExtraction(
          response(projects: [project(deadline: 'Oct 31')]),
        ),
        isNull,
      );
    });

    test('a non-positive session count is rejected', () {
      expect(
        parseWhatMattersExtraction(response(projects: [project(sessions: 0)])),
        isNull,
      );
    });

    test('an empty or non-string keep phrase is rejected', () {
      expect(parseWhatMattersExtraction(response(keep: ['  '])), isNull);
      expect(parseWhatMattersExtraction(response(keep: [7])), isNull);
    });
  });

  group('canonical JSON round trip', () {
    test('to and from JSON reproduces the extraction', () {
      final extraction = WhatMattersExtraction(
        projects: [
          Project(
            name: 'Book',
            deadline: DateTime(2027, 3),
            sessionsNeeded: 20,
          ),
        ],
        neverDecays: const ['water the plants'],
      );

      final restored = whatMattersExtractionFromJson(
        whatMattersExtractionToJson(extraction),
      );

      expect(restored, extraction);
    });
  });
}
