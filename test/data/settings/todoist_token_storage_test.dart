import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';

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
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

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
  }) async {
    return Map.of(_values);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

void main() {
  late _FakeSecureStoragePlatform fakePlatform;
  late TodoistTokenStorage storage;

  setUp(() {
    fakePlatform = _FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = fakePlatform;
    storage = TodoistTokenStorage();
  });

  test('a written token is read back', () async {
    await storage.write('a-token');

    expect(await storage.read(), 'a-token');
  });

  test('no token has been written yet', () async {
    expect(await storage.read(), isNull);
  });

  test('clear removes a previously written token', () async {
    await storage.write('a-token');

    await storage.clear();

    expect(await storage.read(), isNull);
  });
}
