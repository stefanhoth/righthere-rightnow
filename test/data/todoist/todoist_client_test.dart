import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/data/todoist/todoist_exception.dart';
import 'package:righthere_rightnow/domain/priority.dart';

class _MockHttpClient extends Mock implements http.Client {}

Map<String, dynamic> _taskJson({
  String id = '1',
  String content = 'Untitled',
  int priority = 1,
  Map<String, dynamic>? due,
  List<String> labels = const [],
  String? parentId,
}) {
  return {
    'id': id,
    'content': content,
    'priority': priority,
    'due': due,
    'labels': labels,
    'parent_id': parentId,
  };
}

http.Response _resultsResponse(
  List<Map<String, dynamic>> results, {
  String? nextCursor,
}) {
  return http.Response(
    jsonEncode({'results': results, 'next_cursor': nextCursor}),
    200,
  );
}

void main() {
  late _MockHttpClient httpClient;
  late TodoistClient client;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    httpClient = _MockHttpClient();
    client = TodoistClient(httpClient: httpClient);
  });

  test('a 200 response means the token is valid', () async {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('', 200));

    expect(await client.verifyToken('a-valid-token'), isTrue);
  });

  test('a 401 response means the token is invalid', () async {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('', 401));

    expect(await client.verifyToken('a-bad-token'), isFalse);
  });

  test(
    'verification hits the projects endpoint with a bearer header',
    () async {
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 200));

      await client.verifyToken('a-valid-token');

      final captured = verify(
        () =>
            httpClient.get(captureAny(), headers: captureAny(named: 'headers')),
      ).captured;
      final uri = captured[0] as Uri;
      final headers = captured[1] as Map<String, String>;

      expect(uri.path, '/api/v1/projects');
      expect(uri.queryParameters['limit'], '1');
      expect(headers['Authorization'], 'Bearer a-valid-token');
    },
  );

  group('fetchTasks due.date parsing', () {
    test('an all-day date has no time component', () async {
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
            (_) async => _resultsResponse([
              _taskJson(due: {'date': '2016-12-01', 'is_recurring': false}),
            ]),
          );

      final tasks = await client.fetchTasks('token');

      expect(tasks.single.due!.hasTime, isFalse);
      expect(tasks.single.due!.date, DateTime(2016, 12));
      expect(tasks.single.due!.timeZone, isNull);
    });

    test('a floating local time has no time zone', () async {
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => _resultsResponse([
          _taskJson(
            due: {'date': '2016-12-01T12:00:00.000000', 'is_recurring': false},
          ),
        ]),
      );

      final tasks = await client.fetchTasks('token');

      expect(tasks.single.due!.hasTime, isTrue);
      expect(tasks.single.due!.timeZone, isNull);
      expect(tasks.single.due!.date, DateTime(2016, 12, 1, 12));
      expect(tasks.single.due!.date.isUtc, isFalse);
    });

    test('a fixed zone carries its timezone name and a UTC instant', () async {
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
            (_) async => _resultsResponse([
              _taskJson(
                due: {
                  'date': '2016-12-06T13:00:00.000000Z',
                  'is_recurring': false,
                  'timezone': 'Europe/Berlin',
                },
              ),
            ]),
          );

      final tasks = await client.fetchTasks('token');

      expect(tasks.single.due!.hasTime, isTrue);
      expect(tasks.single.due!.timeZone, 'Europe/Berlin');
      expect(tasks.single.due!.date, DateTime.utc(2016, 12, 6, 13));
      expect(tasks.single.due!.date.isUtc, isTrue);
    });

    test('no due date at all is a valid, undated Task', () async {
      when(() => httpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _resultsResponse([_taskJson()]));

      final tasks = await client.fetchTasks('token');

      expect(tasks.single.due, isNull);
    });
  });

  group('fetchTasks priority inversion', () {
    for (final (apiPriority, expected) in [
      (4, Priority.p1),
      (3, Priority.p2),
      (2, Priority.p3),
      (1, Priority.p4),
    ]) {
      test('API priority $apiPriority maps to ${expected.name}', () async {
        when(() => httpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
              (_) async => _resultsResponse([_taskJson(priority: apiPriority)]),
            );

        final tasks = await client.fetchTasks('token');

        expect(tasks.single.priority, expected);
      });
    }
  });

  test('follows next_cursor across pages until it is null', () async {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((invocation) async {
          final uri = invocation.positionalArguments[0] as Uri;
          if (uri.queryParameters['cursor'] == null) {
            return _resultsResponse([
              _taskJson(content: 'First page'),
            ], nextCursor: 'page-2');
          }
          expect(uri.queryParameters['cursor'], 'page-2');
          expect(uri.queryParameters['query'], TodoistClient.defaultTaskQuery);
          expect(uri.queryParameters['limit'], '200');
          return _resultsResponse([_taskJson(id: '2', content: 'Second page')]);
        });

    final tasks = await client.fetchTasks('token');

    expect(tasks.map((t) => t.title), ['First page', 'Second page']);
    verify(() => httpClient.get(any(), headers: any(named: 'headers')))
        .called(2);
  });

  test('a 401 surfaces as a typed invalid-token error, not a crash', () async {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('', 401));

    expect(
      () => client.fetchTasks('a-bad-token'),
      throwsA(isA<TodoistInvalidTokenException>()),
    );
  });

  test('any other error status surfaces as a typed request error', () async {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('server exploded', 500));

    expect(
      () => client.fetchTasks('token'),
      throwsA(
        isA<TodoistRequestException>().having(
          (e) => e.statusCode,
          'statusCode',
          500,
        ),
      ),
    );
  });
}
