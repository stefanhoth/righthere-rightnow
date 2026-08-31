import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_exception.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient httpClient;
  late WhatMattersClient client;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    httpClient = _MockHttpClient();
    client = WhatMattersClient(httpClient: httpClient);
  });

  void stubGet(http.Response response) {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => response);
  }

  Future<String> fetch() => client.fetch(
    baseUrl: 'https://cloud.example.com/remote.php/dav/files/me',
    path: '/Notes/What Matters.md',
    username: 'me',
    appPassword: 'app-pw',
  );

  test('a 200 returns the file body decoded as UTF-8', () async {
    stubGet(
      http.Response.bytes(utf8.encode('# What matters\n\nShip it — café'), 200),
    );

    expect(await fetch(), '# What matters\n\nShip it — café');
  });

  test(
    'the request carries HTTP Basic auth and a joined, encoded URL',
    () async {
      stubGet(http.Response('body', 200));

      await fetch();

      final captured = verify(
        () =>
            httpClient.get(captureAny(), headers: captureAny(named: 'headers')),
      ).captured;
      final uri = captured[0] as Uri;
      final headers = captured[1] as Map<String, String>;

      expect(
        uri.toString(),
        'https://cloud.example.com/remote.php/dav/files/me/Notes/What%20Matters.md',
      );
      expect(
        headers['Authorization'],
        'Basic ${base64Encode(utf8.encode('me:app-pw'))}',
      );
    },
  );

  test('a trailing slash on the base URL does not double up', () async {
    stubGet(http.Response('body', 200));

    await client.fetch(
      baseUrl: 'https://cloud.example.com/dav/',
      path: 'notes/wm.md',
      username: 'me',
      appPassword: 'pw',
    );

    final uri =
        verify(
              () =>
                  httpClient.get(captureAny(), headers: any(named: 'headers')),
            ).captured.single
            as Uri;
    expect(uri.toString(), 'https://cloud.example.com/dav/notes/wm.md');
  });

  test('a 401 is a typed unauthorized error', () async {
    stubGet(http.Response('', 401));

    await expectLater(
      fetch(),
      throwsA(isA<WhatMattersUnauthorizedException>()),
    );
  });

  test(
    'any other non-200 is a typed request error carrying the status',
    () async {
      stubGet(http.Response('not found', 404));

      await expectLater(
        fetch(),
        throwsA(
          isA<WhatMattersRequestException>().having(
            (e) => e.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    },
  );

  test('no exception toString leaks the credential', () {
    expect(
      const WhatMattersUnauthorizedException().toString(),
      isNot(contains('app-pw')),
    );
    expect(
      const WhatMattersRequestException(404).toString(),
      isNot(contains('app-pw')),
    );
  });

  group('verify', () {
    test('true when the file reads', () async {
      stubGet(http.Response('body', 200));

      expect(
        await client.verify(
          baseUrl: 'https://c/dav',
          path: '/wm.md',
          username: 'me',
          appPassword: 'pw',
        ),
        isTrue,
      );
    });

    test('false for a rejected credential', () async {
      stubGet(http.Response('', 401));

      expect(
        await client.verify(
          baseUrl: 'https://c/dav',
          path: '/wm.md',
          username: 'me',
          appPassword: 'bad',
        ),
        isFalse,
      );
    });

    test(
      'a wrong path still throws -- it is not a credential problem',
      () async {
        stubGet(http.Response('', 404));

        await expectLater(
          client.verify(
            baseUrl: 'https://c/dav',
            path: '/nope.md',
            username: 'me',
            appPassword: 'pw',
          ),
          throwsA(isA<WhatMattersRequestException>()),
        );
      },
    );
  });
}
