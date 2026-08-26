import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/ui/settings/settings_controller.dart';
import 'package:righthere_rightnow/ui/settings/settings_screen.dart';

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

class _FakeTodoistClient extends TodoistClient {
  _FakeTodoistClient({required this.isValid});

  final bool isValid;

  @override
  Future<bool> verifyToken(String token) async => isValid;
}

Future<void> _pumpSettingsScreen(
  WidgetTester tester, {
  required bool tokenIsValid,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoistClientProvider.overrideWithValue(
          _FakeTodoistClient(isValid: tokenIsValid),
        ),
        calendarPermissionStatusProvider.overrideWith(
          (ref) async => CalendarPermissionStatus.granted,
        ),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
  });

  testWidgets('shows the calendar permission state', (tester) async {
    await _pumpSettingsScreen(tester, tokenIsValid: true);

    expect(find.text('Calendar access granted.'), findsOneWidget);
  });

  testWidgets('a valid token is saved and reported', (tester) async {
    await _pumpSettingsScreen(tester, tokenIsValid: true);

    await tester.enterText(find.byKey(const Key('tokenField')), 'good-token');
    await tester.tap(find.byKey(const Key('verifyAndSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
    expect(find.text('A token is saved.'), findsOneWidget);
  });

  testWidgets('an invalid token shows an error and is not saved', (
    tester,
  ) async {
    await _pumpSettingsScreen(tester, tokenIsValid: false);

    await tester.enterText(find.byKey(const Key('tokenField')), 'bad-token');
    await tester.tap(find.byKey(const Key('verifyAndSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('That token was rejected by Todoist.'), findsOneWidget);
    expect(find.text('No token saved yet.'), findsOneWidget);
  });

  testWidgets('shows the configured briefing time and its next run', (
    tester,
  ) async {
    await _pumpSettingsScreen(tester, tokenIsValid: true);

    expect(find.byKey(const Key('storedRunTime')), findsOneWidget);
    expect(find.byKey(const Key('nextScheduledRun')), findsOneWidget);
  });
}
