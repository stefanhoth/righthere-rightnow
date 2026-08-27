import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/settings/selected_calendars_storage.dart';

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
  late SelectedCalendarsStorage storage;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    storage = SelectedCalendarsStorage();
  });

  test('reads an empty set when nothing has been chosen', () async {
    expect(await storage.read(), isEmpty);
  });

  test('a written selection is read back', () async {
    await storage.write({'work', 'personal'});

    expect(await storage.read(), {'work', 'personal'});
  });

  test(
    'writing an empty set clears the selection back to the default',
    () async {
      await storage.write({'work'});
      await storage.write({});

      expect(await storage.read(), isEmpty);
    },
  );

  test('a calendar id containing no separator round-trips intact', () async {
    await storage.write({'12', '3', 'caldav:abc'});

    expect(await storage.read(), {'12', '3', 'caldav:abc'});
  });
}
