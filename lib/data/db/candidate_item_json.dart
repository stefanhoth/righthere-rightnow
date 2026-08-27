import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';
import 'package:righthere_rightnow/domain/agenda_source.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

/// The item as the ranker saw it, including its computed features -- the
/// replay input stored in `snapshot_items.payloadJson`. If a feature isn't
/// in here, it can't be replayed later.
Map<String, dynamic> candidateItemToJson(CandidateItem candidateItem) {
  final item = candidateItem.item;
  final features = candidateItem.features;

  return {
    'id': item.id,
    'title': item.title,
    'source': item.source.name,
    ...switch (item) {
      Commitment() => {
        'start': item.start.toIso8601String(),
        'end': item.end.toIso8601String(),
        'isAllDay': item.isAllDay,
        'location': item.location,
        'description': item.description,
        'attendeeCount': item.attendeeCount,
        'isOrganiser': item.isOrganiser,
        'myResponse': item.myResponse.name,
        'isRecurring': item.isRecurring,
        'conferenceUrl': item.conferenceUrl,
        'calendarName': item.calendarName,
      },
      Task() => {
        'due': switch (item.due) {
          null => null,
          final due => {
            'date': due.date.toIso8601String(),
            'hasTime': due.hasTime,
            'timeZone': due.timeZone,
            'isRecurring': due.isRecurring,
          },
        },
        'priority': item.priority.name,
        'projectName': item.projectName,
        'labels': item.labels,
        'isRecurring': item.isRecurring,
        'parentId': item.parentId,
      },
    },
    'features': {
      'minutesUntilStart': features.minutesUntilStart,
      'durationMinutes': features.durationMinutes,
      'attendeeCount': features.attendeeCount,
      'isOrganiser': features.isOrganiser,
      'isRecurring': features.isRecurring,
      'overdueDays': features.overdueDays,
      'daysUntilDue': features.daysUntilDue,
      'priority': features.priority?.name,
      'isFollowUpCandidate': features.isFollowUpCandidate,
    },
  };
}

/// The inverse of [candidateItemToJson] -- reconstructs the Agenda Item and
/// its computed features exactly as a Briefing Run persisted them, for the
/// Task 3.6 replay harness. Never used at Briefing Run time: a live run
/// always computes features fresh, it never reads its own snapshot back.
CandidateItem candidateItemFromJson(Map<String, dynamic> json) {
  final id = json['id'] as String;
  final title = json['title'] as String;
  final source = AgendaSource.values.byName(json['source'] as String);

  final item = switch (source) {
    AgendaSource.calendar => Commitment(
      id: id,
      title: title,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isAllDay: json['isAllDay'] as bool,
      location: json['location'] as String?,
      description: json['description'] as String?,
      attendeeCount: json['attendeeCount'] as int,
      isOrganiser: json['isOrganiser'] as bool,
      myResponse: ResponseStatus.values.byName(json['myResponse'] as String),
      isRecurring: json['isRecurring'] as bool,
      conferenceUrl: json['conferenceUrl'] as String?,
      calendarName: json['calendarName'] as String,
    ),
    AgendaSource.todoist => Task(
      id: id,
      title: title,
      priority: Priority.values.byName(json['priority'] as String),
      isRecurring: json['isRecurring'] as bool,
      due: switch (json['due']) {
        null => null,
        final due => TaskDue(
          date: DateTime.parse((due as Map<String, dynamic>)['date'] as String),
          hasTime: due['hasTime'] as bool,
          timeZone: due['timeZone'] as String?,
          isRecurring: due['isRecurring'] as bool,
        ),
      },
      projectName: json['projectName'] as String?,
      labels: (json['labels'] as List<dynamic>).cast<String>(),
      parentId: json['parentId'] as String?,
    ),
  };

  final featuresJson = json['features'] as Map<String, dynamic>;
  final features = AgendaItemFeatures(
    minutesUntilStart: featuresJson['minutesUntilStart'] as int?,
    durationMinutes: featuresJson['durationMinutes'] as int?,
    attendeeCount: featuresJson['attendeeCount'] as int,
    isOrganiser: featuresJson['isOrganiser'] as bool,
    isRecurring: featuresJson['isRecurring'] as bool,
    overdueDays: featuresJson['overdueDays'] as int?,
    daysUntilDue: featuresJson['daysUntilDue'] as int?,
    priority: switch (featuresJson['priority']) {
      null => null,
      final p => Priority.values.byName(p as String),
    },
    isFollowUpCandidate: featuresJson['isFollowUpCandidate'] as bool,
  );

  return CandidateItem(item: item, features: features);
}
