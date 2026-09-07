import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/what_matters_settings_storage.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_exception.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_repository.dart';

class _MockClient extends Mock implements WhatMattersClient {}

class _MockSettings extends Mock implements WhatMattersSettingsStorage {}

DateTime _clock() => DateTime.utc(2026, 8, 31, 6);

void main() {
  late _MockClient client;
  late _MockSettings settings;
  late AppDatabase database;

  const connection = WhatMattersConnection(
    baseUrl: 'https://cloud.example.com/dav',
    path: '/wm.md',
    username: 'me',
    appPassword: 'secret-app-password',
  );

  WhatMattersRepository repository() => WhatMattersRepository(
    client: client,
    settings: settings,
    database: database,
    clock: _clock,
  );

  void stubFetch(String Function() answer) {
    when(
      () => client.fetch(
        baseUrl: any(named: 'baseUrl'),
        path: any(named: 'path'),
        username: any(named: 'username'),
        appPassword: any(named: 'appPassword'),
      ),
    ).thenAnswer((_) async => answer());
  }

  setUp(() {
    client = _MockClient();
    settings = _MockSettings();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    when(() => settings.read()).thenAnswer((_) async => connection);
  });

  tearDown(() => database.close());

  test('an unconfigured connection is a no-op, not an error', () async {
    when(() => settings.read()).thenAnswer((_) async => null);

    final result = await repository().read();

    expect(result.document, isNull);
    expect(result.error, isNull);
    expect(result.isStale, isFalse);
    verifyNever(
      () => client.fetch(
        baseUrl: any(named: 'baseUrl'),
        path: any(named: 'path'),
        username: any(named: 'username'),
        appPassword: any(named: 'appPassword'),
      ),
    );
  });

  test(
    'a successful fetch is returned fresh and cached with its fetch time',
    () async {
      stubFetch(() => '# What matters\n\nShip the thing.');

      final result = await repository().read();

      expect(result.isStale, isFalse);
      expect(result.error, isNull);
      expect(result.document!.prose, '# What matters\n\nShip the thing.');
      expect(result.document!.fetchedAt, DateTime.utc(2026, 8, 31, 6));

      final cached = await database.cachedWhatMatters();
      expect(cached!.prose, '# What matters\n\nShip the thing.');
      expect(cached.fetchedAt, DateTime.utc(2026, 8, 31, 6));
    },
  );

  test('a failed fetch falls back to the cached copy, flagged stale', () async {
    await database.cacheWhatMatters(
      prose: 'the last good copy',
      fetchedAt: DateTime.utc(2026, 8, 30, 6),
    );
    when(
      () => client.fetch(
        baseUrl: any(named: 'baseUrl'),
        path: any(named: 'path'),
        username: any(named: 'username'),
        appPassword: any(named: 'appPassword'),
      ),
    ).thenThrow(const WhatMattersRequestException(503));

    final result = await repository().read();

    expect(result.isStale, isTrue);
    expect(result.document!.prose, 'the last good copy');
    expect(result.document!.fetchedAt, DateTime.utc(2026, 8, 30, 6));
    expect(result.error, isNotNull);
  });

  test(
    'a failed fetch with nothing cached yields a null document, still no throw',
    () async {
      when(
        () => client.fetch(
          baseUrl: any(named: 'baseUrl'),
          path: any(named: 'path'),
          username: any(named: 'username'),
          appPassword: any(named: 'appPassword'),
        ),
      ).thenThrow(const WhatMattersUnauthorizedException());

      final result = await repository().read();

      expect(result.document, isNull);
      expect(result.isStale, isTrue);
      expect(result.error, isNotNull);
    },
  );

  test('the error string carries the cause but never the credential', () async {
    when(
      () => client.fetch(
        baseUrl: any(named: 'baseUrl'),
        path: any(named: 'path'),
        username: any(named: 'username'),
        appPassword: any(named: 'appPassword'),
      ),
    ).thenThrow(const WhatMattersUnauthorizedException());

    final result = await repository().read();

    expect(result.error, contains('What Matters'));
    expect(result.error, isNot(contains('secret-app-password')));
    expect(result.error, isNot(contains('cloud.example.com')));
    expect(await database.cachedWhatMatters(), isNull);
  });

  test('a stale fetch does not overwrite the cached copy', () async {
    await database.cacheWhatMatters(
      prose: 'good copy',
      fetchedAt: DateTime.utc(2026, 8, 29),
    );
    when(
      () => client.fetch(
        baseUrl: any(named: 'baseUrl'),
        path: any(named: 'path'),
        username: any(named: 'username'),
        appPassword: any(named: 'appPassword'),
      ),
    ).thenThrow(const WhatMattersRequestException(500));

    await repository().read();

    final cached = await database.cachedWhatMatters();
    expect(cached!.prose, 'good copy');
    expect(cached.fetchedAt, DateTime.utc(2026, 8, 29));
  });
}
