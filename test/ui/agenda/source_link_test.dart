import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/ui/agenda/source_link.dart';

Commitment _commitment(String id) => Commitment(
  id: id,
  title: 'Standup',
  start: DateTime(2026, 8, 30, 10),
  end: DateTime(2026, 8, 30, 10, 30),
  isAllDay: false,
  attendeeCount: 2,
  isOrganiser: false,
  myResponse: ResponseStatus.accepted,
  isRecurring: false,
  calendarName: 'Work',
);

Task _task(String id) => Task(
  id: id,
  title: 'File taxes',
  priority: Priority.p2,
  isRecurring: false,
);

void main() {
  group('a Commitment', () {
    test('addresses the occurrence that was tapped, not the series', () {
      final begin = DateTime(2026, 8, 30, 10).millisecondsSinceEpoch;

      final link = sourceLinkFor(_commitment('cal:4711:$begin'));

      expect(link, CalendarEventLink(eventId: '4711', beginMillis: begin));
    });

    test('two occurrences of one Event are different links', () {
      final monday = sourceLinkFor(_commitment('cal:4711:1000'));
      final tuesday = sourceLinkFor(_commitment('cal:4711:2000'));

      expect(monday, isNot(tuesday));
    });

    test('has no link when the id predates the current format', () {
      expect(sourceLinkFor(_commitment('cal:4711')), isNull);
      expect(sourceLinkFor(_commitment('cal::1000')), isNull);
      expect(sourceLinkFor(_commitment('cal:4711:not-a-time')), isNull);
      expect(sourceLinkFor(_commitment('4711')), isNull);
    });
  });

  group('a Task', () {
    test('points at the Todoist app first and the web app second', () {
      final link = sourceLinkFor(_task('td:6X4Vw2')) as TodoistTaskLink?;

      expect(link, isNotNull);
      expect(link!.appUri, Uri.parse('todoist://task?id=6X4Vw2'));
      expect(link.webUri, Uri.parse('https://app.todoist.com/app/task/6X4Vw2'));
    });

    test('has no link when the id predates the current format', () {
      expect(sourceLinkFor(_task('td:')), isNull);
      expect(sourceLinkFor(_task('6X4Vw2')), isNull);
      expect(sourceLinkFor(_task('td:1:2')), isNull);
    });
  });
}
