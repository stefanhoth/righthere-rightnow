import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

void main() {
  group('round-trips through JSON', () {
    test('a Commitment with every optional field set', () {
      final candidate = CandidateItem(
        item: Commitment(
          id: 'cal:1:100',
          title: 'Standup',
          start: DateTime(2026, 8, 26, 9),
          end: DateTime(2026, 8, 26, 9, 30),
          isAllDay: false,
          location: 'Room 4',
          description: 'Daily sync',
          attendeeCount: 3,
          isOrganiser: true,
          myResponse: ResponseStatus.accepted,
          isRecurring: true,
          conferenceUrl: 'https://meet.example.com/abc',
          calendarName: 'Work',
        ),
        features: const AgendaItemFeatures(
          minutesUntilStart: 15,
          durationMinutes: 30,
          attendeeCount: 3,
          isOrganiser: true,
          isRecurring: true,
          isFollowUpCandidate: false,
        ),
      );

      final roundTripped = candidateItemFromJson(
        jsonDecode(jsonEncode(candidateItemToJson(candidate)))
            as Map<String, dynamic>,
      );

      final item = roundTripped.item as Commitment;
      expect(item.id, 'cal:1:100');
      expect(item.start, DateTime(2026, 8, 26, 9));
      expect(item.end, DateTime(2026, 8, 26, 9, 30));
      expect(item.location, 'Room 4');
      expect(item.description, 'Daily sync');
      expect(item.attendeeCount, 3);
      expect(item.isOrganiser, isTrue);
      expect(item.myResponse, ResponseStatus.accepted);
      expect(item.conferenceUrl, 'https://meet.example.com/abc');
      expect(item.calendarName, 'Work');
      expect(roundTripped.features.minutesUntilStart, 15);
      expect(roundTripped.features.durationMinutes, 30);
    });

    test('a Commitment with every optional field null', () {
      final candidate = CandidateItem(
        item: Commitment(
          id: 'cal:1:200',
          title: 'Focus block',
          start: DateTime(2026, 8, 26, 10),
          end: DateTime(2026, 8, 26, 11),
          isAllDay: false,
          attendeeCount: 0,
          isOrganiser: false,
          myResponse: ResponseStatus.none,
          isRecurring: false,
          calendarName: 'Personal',
        ),
        features: const AgendaItemFeatures(
          attendeeCount: 0,
          isOrganiser: false,
          isRecurring: false,
          isFollowUpCandidate: false,
        ),
      );

      final roundTripped = candidateItemFromJson(
        jsonDecode(jsonEncode(candidateItemToJson(candidate)))
            as Map<String, dynamic>,
      );

      final item = roundTripped.item as Commitment;
      expect(item.location, isNull);
      expect(item.description, isNull);
      expect(item.conferenceUrl, isNull);
    });

    test('a Task with a due date', () {
      final candidate = CandidateItem(
        item: Task(
          id: 'td:1',
          title: 'File taxes',
          priority: Priority.p1,
          isRecurring: false,
          due: TaskDue(
            date: DateTime(2026, 8, 26),
            hasTime: false,
            isRecurring: false,
          ),
          projectName: 'Admin',
          labels: const ['urgent', 'money'],
          parentId: 'td:0',
        ),
        features: const AgendaItemFeatures(
          attendeeCount: 0,
          isOrganiser: false,
          isRecurring: false,
          daysUntilDue: 0,
          priority: Priority.p1,
          isFollowUpCandidate: false,
        ),
      );

      final roundTripped = candidateItemFromJson(
        jsonDecode(jsonEncode(candidateItemToJson(candidate)))
            as Map<String, dynamic>,
      );

      final item = roundTripped.item as Task;
      expect(item.priority, Priority.p1);
      expect(item.due?.date, DateTime(2026, 8, 26));
      expect(item.due?.hasTime, isFalse);
      expect(item.projectName, 'Admin');
      expect(item.labels, ['urgent', 'money']);
      expect(item.parentId, 'td:0');
      expect(roundTripped.features.daysUntilDue, 0);
      expect(roundTripped.features.priority, Priority.p1);
    });

    test('a Task with no due date', () {
      const candidate = CandidateItem(
        item: Task(
          id: 'td:2',
          title: 'Someday maybe',
          priority: Priority.p4,
          isRecurring: false,
        ),
        features: AgendaItemFeatures(
          attendeeCount: 0,
          isOrganiser: false,
          isRecurring: false,
          isFollowUpCandidate: false,
        ),
      );

      final roundTripped = candidateItemFromJson(
        jsonDecode(jsonEncode(candidateItemToJson(candidate)))
            as Map<String, dynamic>,
      );

      final item = roundTripped.item as Task;
      expect(item.due, isNull);
    });
  });
}
