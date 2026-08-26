import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/agenda_source.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

/// A single thing competing for attention today. The atomic unit of the
/// Daily Agenda: every Agenda Item is either a [Commitment] or a [Task].
@immutable
sealed class AgendaItem {
  const AgendaItem({required this.id, required this.title});

  /// Stable and source-prefixed, e.g. `cal:123:456` or `td:789`.
  final String id;

  final String title;

  AgendaSource get source;
}

/// An Agenda Item fixed in time and involving other people, derived from a
/// calendar Event. Its start and end cannot be moved unilaterally.
@immutable
class Commitment extends AgendaItem {
  Commitment({
    required super.id,
    required super.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    required this.attendeeCount,
    required this.isOrganiser,
    required this.myResponse,
    required this.isRecurring,
    required this.calendarName,
    this.location,
    this.description,
    this.conferenceUrl,
  }) : assert(
         !end.isBefore(start),
         "a Commitment's end must not be before its start",
       );

  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final String? location;
  final String? description;
  final int attendeeCount;
  final bool isOrganiser;
  final ResponseStatus myResponse;
  final bool isRecurring;
  final String? conferenceUrl;
  final String calendarName;

  @override
  AgendaSource get source => AgendaSource.calendar;
}

/// An Agenda Item that needs doing but is not fixed to a point in time,
/// derived from a task manager. Its [due] date is a constraint, not a
/// schedule.
@immutable
class Task extends AgendaItem {
  const Task({
    required super.id,
    required super.title,
    required this.priority,
    required this.isRecurring,
    this.due,
    this.projectName,
    this.labels = const [],
    this.parentId,
  });

  final TaskDue? due;
  final Priority priority;
  final String? projectName;
  final List<String> labels;
  final bool isRecurring;

  /// The parent Task's id, for a subtask. Null for a top-level Task.
  final String? parentId;

  @override
  AgendaSource get source => AgendaSource.todoist;
}
