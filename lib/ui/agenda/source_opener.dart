import 'package:flutter/services.dart';
import 'package:righthere_rightnow/data/calendar/calendar_view_channel.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/ui/agenda/source_link.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

/// The one thing [SourceOpener] needs from `url_launcher`.
typedef LaunchUrl = Future<bool> Function(Uri url);

/// Hands an Agenda Item back to the app that owns it, so it can be edited
/// where editing is allowed. This app only ever reads its sources.
///
/// A class rather than two free functions so a widget test can substitute
/// one: both real paths leave the app, which no widget test can follow.
class SourceOpener {
  SourceOpener({CalendarViewChannel? calendarView, LaunchUrl? launchUrl})
    : _calendarView = calendarView ?? CalendarViewChannel(),
      _launchUrl = launchUrl ?? launcher.launchUrl;

  final CalendarViewChannel _calendarView;
  final LaunchUrl _launchUrl;

  /// False when nothing on the device would take it -- no calendar app, or
  /// neither Todoist nor a browser. The caller says so; this only reports.
  Future<bool> open(AgendaItem item) async {
    return switch (sourceLinkFor(item)) {
      final CalendarEventLink link => _openCalendar(link),
      final TodoistTaskLink link => _openTodoist(link),
      null => false,
    };
  }

  /// Opens any other URL an Agenda Item carries: a conference link, or the
  /// target of a Markdown link in a Task's title.
  Future<bool> openUrl(Uri url) => _tryLaunch(url);

  Future<bool> _openCalendar(CalendarEventLink link) async {
    try {
      return await _calendarView.openEvent(
        eventId: link.eventId,
        beginMillis: link.beginMillis,
      );
    } on PlatformException {
      return false;
    }
  }

  /// Tries the Todoist app first and the web app second. The fallback is the
  /// point: the app's own scheme is the only one that opens the Task ready
  /// to edit, but it fails outright when Todoist is not installed.
  Future<bool> _openTodoist(TodoistTaskLink link) async {
    return await _tryLaunch(link.appUri) || await _tryLaunch(link.webUri);
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await _launchUrl(uri);
    } on PlatformException {
      return false;
    }
  }
}
