import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/settings/what_matters_settings_storage.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _values[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _values.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_values);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

void main() {
  late WhatMattersSettingsStorage storage;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    storage = WhatMattersSettingsStorage();
  });

  const connection = WhatMattersConnection(
    baseUrl: 'https://cloud.example.com/dav',
    path: '/Notes/What Matters.md',
    username: 'me',
    appPassword: 'app-pw',
  );

  test('a written connection reads back field for field', () async {
    await storage.write(connection);

    final read = await storage.read();
    expect(read, isNotNull);
    expect(read!.baseUrl, connection.baseUrl);
    expect(read.path, connection.path);
    expect(read.username, connection.username);
    expect(read.appPassword, connection.appPassword);
  });

  test('read is null until anything is stored', () async {
    expect(await storage.read(), isNull);
  });

  test(
    'a half-written record reads back as null, never a partial connection',
    () async {
      await storage.write(connection);
      FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
      final freshStorage = WhatMattersSettingsStorage();

      // Only the password is missing on the fresh platform.
      expect(await freshStorage.read(), isNull);
    },
  );

  test('clear removes every field', () async {
    await storage.write(connection);

    await storage.clear();

    expect(await storage.read(), isNull);
  });

  test('isComplete guards an empty field', () {
    expect(connection.isComplete, isTrue);
    expect(
      const WhatMattersConnection(
        baseUrl: '',
        path: '/x',
        username: 'me',
        appPassword: 'pw',
      ).isComplete,
      isFalse,
    );
  });
}
