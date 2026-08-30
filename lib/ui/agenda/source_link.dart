import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';

/// Where an Agenda Item can be opened for editing, in the app it came from.
///
/// This app never writes to a source (see docs/VISION.md), so "edit" always
/// means handing off. The two sources need different machinery -- a
/// Commitment needs a `content://` Intent with instance extras, a Task needs
/// a URL -- so the destination is described here and acted on by the caller.
///
/// Derived from [AgendaItem.id] rather than from a new field, because the id
/// already carries everything a source needs to find the row again.
@immutable
sealed class SourceLink {
  const SourceLink();
}

/// One occurrence of a calendar Event, addressed the way the Calendar
/// Provider addresses it.
///
/// [beginMillis] is what distinguishes one occurrence of a recurring Event
/// from another: without it the calendar opens whichever instance it likes,
/// which for a daily standup is almost never the one that was tapped.
@immutable
final class CalendarEventLink extends SourceLink {
  const CalendarEventLink({required this.eventId, required this.beginMillis});

  final String eventId;
  final int beginMillis;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventLink &&
      other.eventId == eventId &&
      other.beginMillis == beginMillis;

  @override
  int get hashCode => Object.hash(eventId, beginMillis);
}

/// One Todoist Task, addressed by its numeric API id.
@immutable
final class TodoistTaskLink extends SourceLink {
  const TodoistTaskLink(this.taskId);

  final String taskId;

  /// The Todoist app's own scheme. Preferred, so the Task opens where it can
  /// actually be edited rather than in a browser.
  Uri get appUri => Uri.parse('todoist://task?id=$taskId');

  /// Where to go when the Todoist app is not installed to answer [appUri].
  Uri get webUri => Uri.parse('https://app.todoist.com/app/task/$taskId');

  @override
  bool operator ==(Object other) =>
      other is TodoistTaskLink && other.taskId == taskId;

  @override
  int get hashCode => taskId.hashCode;
}

/// The source destination for [item], or null when its id is not in the
/// shape the source that produced it writes.
///
/// A null result is a real possibility, not a defensive branch: ids come
/// back from the Briefing Run snapshot in the database, so a row written by
/// an older version of the app can outlive the format that wrote it. The
/// row simply loses its link rather than crashing the screen.
SourceLink? sourceLinkFor(AgendaItem item) {
  final parts = item.id.split(':');
  return switch (item) {
    // `cal:<eventId>:<startMillis>`, from CalendarReader.
    Commitment() when parts.length == 3 && parts.first == 'cal' =>
      switch (int.tryParse(parts[2])) {
        final int beginMillis when parts[1].isNotEmpty => CalendarEventLink(
          eventId: parts[1],
          beginMillis: beginMillis,
        ),
        _ => null,
      },
    // `td:<id>`, from TodoistClient.
    Task()
        when parts.length == 2 && parts.first == 'td' && parts[1].isNotEmpty =>
      TodoistTaskLink(parts[1]),
    _ => null,
  };
}
