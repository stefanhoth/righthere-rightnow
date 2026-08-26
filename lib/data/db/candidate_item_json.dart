import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';

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
