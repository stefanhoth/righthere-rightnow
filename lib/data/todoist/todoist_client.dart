import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:righthere_rightnow/data/todoist/todoist_exception.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

/// Hand-rolled Todoist client -- there is no Dart SDK for the Todoist API.
///
/// Base URL is the current REST API. The older v2 and Sync v9 APIs return
/// HTTP 410 Gone: they are shut down, not merely deprecated.
class TodoistClient {
  TodoistClient({
    http.Client? httpClient,
    this.baseUrl = 'https://api.todoist.com/api/v1',
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;

  /// Due through today + 10 days, plus all overdue -- per the Todoist filter
  /// docs, "due before" already includes overdue tasks. That needs
  /// confirming against a real account on first use; if it doesn't hold,
  /// switch to `overdue | due before: +10 days`.
  ///
  /// If a query ever needs to filter by label, Todoist filters use `%label`,
  /// not `@label` -- `@` is being retired. The comma operator (`,`) only
  /// works in the Todoist UI, not on this endpoint.
  static const defaultTaskQuery = 'due before: +10 days';

  /// Verifies a personal API token with a minimal authenticated request.
  ///
  /// Returns false for a rejected token (401) rather than throwing: an
  /// invalid token is an expected, user-facing outcome of verification, not
  /// a failure of the client itself. Network failures still propagate as
  /// thrown exceptions.
  Future<bool> verifyToken(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/projects?limit=1'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  /// Fetches every Task matching [query], following `next_cursor` until the
  /// API reports none left. The cursor is opaque and only ever passed back
  /// unchanged; it is never persisted across calls.
  Future<List<Task>> fetchTasks(
    String token, {
    String query = defaultTaskQuery,
  }) async {
    final tasks = <Task>[];
    String? cursor;

    do {
      final uri = Uri.parse('$baseUrl/tasks/filter').replace(
        queryParameters: {'query': query, 'limit': '200', 'cursor': ?cursor},
      );
      final response = await _httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        throw const TodoistInvalidTokenException();
      }
      if (response.statusCode != 200) {
        throw TodoistRequestException(response.statusCode, response.body);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (body['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      tasks.addAll(results.map(_taskFromJson));
      cursor = body['next_cursor'] as String?;
    } while (cursor != null);

    return tasks;
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    final due = json['due'] as Map<String, dynamic>?;

    return Task(
      id: 'td:${json['id']}',
      title: json['content'] as String,
      priority: _priorityFromApi(json['priority'] as int),
      isRecurring: due?['is_recurring'] as bool? ?? false,
      due: due == null ? null : _dueFromJson(due),
      labels: (json['labels'] as List<dynamic>).cast<String>(),
      parentId: json['parent_id'] as String?,
    );
  }

  /// The API's raw integer is inverted from the UI's naming: 4 is urgent
  /// ("p1"), 1 is normal ("p4"). Mapped by meaning, not by number.
  Priority _priorityFromApi(int apiPriority) {
    return switch (apiPriority) {
      4 => Priority.p1,
      3 => Priority.p2,
      2 => Priority.p3,
      1 => Priority.p4,
      _ => throw FormatException('Unexpected Todoist priority: $apiPriority'),
    };
  }

  /// `due.date` takes three shapes, distinguished only by the string itself
  /// -- there is no separate `datetime` field in this API version:
  ///   - `"2016-12-01"` -- all-day
  ///   - `"2016-12-01T12:00:00.000000"` -- floating local time, not RFC 3339
  ///   - `"2016-12-06T13:00:00.000000Z"` with a `timezone` field -- fixed zone
  TaskDue _dueFromJson(Map<String, dynamic> due) {
    final rawDate = due['date'] as String;
    final isRecurring = due['is_recurring'] as bool? ?? false;

    if (!rawDate.contains('T')) {
      final parts = rawDate.split('-').map(int.parse).toList();
      return TaskDue(
        date: DateTime(parts[0], parts[1], parts[2]),
        hasTime: false,
        isRecurring: isRecurring,
      );
    }

    if (rawDate.endsWith('Z')) {
      return TaskDue(
        date: DateTime.parse(rawDate),
        hasTime: true,
        isRecurring: isRecurring,
        timeZone: due['timezone'] as String?,
      );
    }

    return TaskDue(
      date: DateTime.parse(rawDate),
      hasTime: true,
      isRecurring: isRecurring,
    );
  }
}
