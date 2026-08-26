import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

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
}
