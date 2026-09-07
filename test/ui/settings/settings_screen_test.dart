import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/data/settings/what_matters_settings_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';
import 'package:righthere_rightnow/ui/settings/settings_controller.dart';
import 'package:righthere_rightnow/ui/settings/settings_screen.dart';

Calendar _calendar(String id, String name) =>
    Calendar(id: id, name: name, readOnly: false);

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

class _FakeWhatMattersClient extends WhatMattersClient {
  _FakeWhatMattersClient({required this.readable});

  final bool readable;

  @override
  Future<bool> verify({
    required String baseUrl,
    required String path,
    required String username,
    required String appPassword,
  }) async => readable;
}

Future<void> _pumpSettingsScreen(
  WidgetTester tester, {
  required bool tokenIsValid,
  PermissionStatus batteryOptimizationStatus = PermissionStatus.granted,
  List<Calendar> calendars = const [],
  String? existingToken,
  bool whatMattersReadable = true,
  WhatMattersConnection? existingWhatMatters,
  WhatMattersDocument? cachedWhatMatters,
}) async {
  // The settings list is long; a tall surface keeps every section on screen
  // so tests can tap buttons without fighting the scroll view.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoistClientProvider.overrideWithValue(
          _FakeTodoistClient(isValid: tokenIsValid),
        ),
        if (existingToken != null)
          storedTodoistTokenProvider.overrideWith((ref) async => existingToken),
        if (existingWhatMatters != null)
          storedWhatMattersConnectionProvider.overrideWith(
            (ref) async => existingWhatMatters,
          ),
        whatMattersClientProvider.overrideWithValue(
          _FakeWhatMattersClient(readable: whatMattersReadable),
        ),
        cachedWhatMattersProvider.overrideWith(
          (ref) async => cachedWhatMatters,
        ),
        calendarPermissionStatusProvider.overrideWith(
          (ref) async => CalendarPermissionStatus.granted,
        ),
        availableCalendarsProvider.overrideWith((ref) async => calendars),
        batteryOptimizationStatusProvider.overrideWith(
          (ref) async => batteryOptimizationStatus,
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

  testWidgets('lists a checkbox per calendar, all included by default', (
    tester,
  ) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      calendars: [_calendar('work', 'Work'), _calendar('personal', 'Personal')],
    );

    final work = tester.widget<CheckboxListTile>(
      find.byKey(const Key('calendarCheckbox:work')),
    );
    final personal = tester.widget<CheckboxListTile>(
      find.byKey(const Key('calendarCheckbox:personal')),
    );
    expect(work.value, isTrue);
    expect(personal.value, isTrue);
  });

  testWidgets('unchecking a calendar persists a selection without it', (
    tester,
  ) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      calendars: [_calendar('work', 'Work'), _calendar('personal', 'Personal')],
    );

    await tester.tap(find.byKey(const Key('calendarCheckbox:personal')));
    await tester.pumpAndSettle();

    final work = tester.widget<CheckboxListTile>(
      find.byKey(const Key('calendarCheckbox:work')),
    );
    final personal = tester.widget<CheckboxListTile>(
      find.byKey(const Key('calendarCheckbox:personal')),
    );
    expect(work.value, isTrue);
    expect(personal.value, isFalse);
  });

  testWidgets('a valid token is saved and reported', (tester) async {
    await _pumpSettingsScreen(tester, tokenIsValid: true);

    await tester.enterText(find.byKey(const Key('tokenField')), 'good-token');
    await tester.tap(find.byKey(const Key('verifyAndSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
    expect(find.text('A token is saved.'), findsOneWidget);
  });

  testWidgets('a saved token collapses to a one-line summary', (tester) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      existingToken: 'saved-token',
    );

    expect(find.text('A token is saved.'), findsOneWidget);
    expect(find.byKey(const Key('editTokenButton')), findsOneWidget);
    expect(find.byKey(const Key('tokenField')), findsNothing);
  });

  testWidgets('Replace reveals an in-place editor that Cancel collapses', (
    tester,
  ) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      existingToken: 'saved-token',
    );

    await tester.tap(find.byKey(const Key('editTokenButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tokenField')), findsOneWidget);
    expect(find.byKey(const Key('verifyAndSaveButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancelTokenEditButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tokenField')), findsNothing);
    expect(find.text('A token is saved.'), findsOneWidget);
  });

  testWidgets('replacing a saved token collapses back on success', (
    tester,
  ) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      existingToken: 'old-token',
    );

    await tester.tap(find.byKey(const Key('editTokenButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tokenField')), 'new-token');
    await tester.tap(find.byKey(const Key('verifyAndSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
    expect(find.byKey(const Key('tokenField')), findsNothing);
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

  testWidgets('a granted battery exemption is reported with no action needed', (
    tester,
  ) async {
    await _pumpSettingsScreen(tester, tokenIsValid: true);

    expect(find.byKey(const Key('batteryOptimizationStatus')), findsOneWidget);
    expect(
      find.byKey(const Key('requestBatteryExemptionButton')),
      findsNothing,
    );
  });

  testWidgets('a denied battery exemption offers a button to request it', (
    tester,
  ) async {
    await _pumpSettingsScreen(
      tester,
      tokenIsValid: true,
      batteryOptimizationStatus: PermissionStatus.denied,
    );

    expect(
      find.byKey(const Key('requestBatteryExemptionButton')),
      findsOneWidget,
    );
  });

  group('What Matters', () {
    const connection = WhatMattersConnection(
      baseUrl: 'https://cloud.example.com/dav',
      path: '/Notes/What Matters.md',
      username: 'me',
      appPassword: 'app-pw',
    );

    Future<void> fillEditor(
      WidgetTester tester, {
      String appPassword = 'pw',
    }) async {
      await tester.enterText(
        find.byKey(const Key('whatMattersBaseUrlField')),
        connection.baseUrl,
      );
      await tester.enterText(
        find.byKey(const Key('whatMattersPathField')),
        connection.path,
      );
      await tester.enterText(
        find.byKey(const Key('whatMattersUsernameField')),
        connection.username,
      );
      await tester.enterText(
        find.byKey(const Key('whatMattersPasswordField')),
        appPassword,
      );
    }

    testWidgets('a fresh setup shows the editor inline', (tester) async {
      await _pumpSettingsScreen(tester, tokenIsValid: true);

      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsOneWidget);
      expect(find.byKey(const Key('editWhatMattersButton')), findsNothing);
    });

    testWidgets('a saved connection collapses to a one-line summary', (
      tester,
    ) async {
      await _pumpSettingsScreen(
        tester,
        tokenIsValid: true,
        existingWhatMatters: connection,
        cachedWhatMatters: WhatMattersDocument(
          prose: '# What matters',
          fetchedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      );

      expect(find.text('Reading /Notes/What Matters.md'), findsOneWidget);
      expect(find.text('Last fetched 3 h ago.'), findsOneWidget);
      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsNothing);
    });

    testWidgets('Replace reveals an editor that Cancel collapses', (
      tester,
    ) async {
      await _pumpSettingsScreen(
        tester,
        tokenIsValid: true,
        existingWhatMatters: connection,
      );

      await tester.tap(find.byKey(const Key('editWhatMattersButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancelWhatMattersEditButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsNothing);
      expect(find.text('Reading /Notes/What Matters.md'), findsOneWidget);
    });

    testWidgets('a readable connection verifies, is saved, and collapses', (
      tester,
    ) async {
      await _pumpSettingsScreen(tester, tokenIsValid: true);

      await fillEditor(tester);
      await tester.tap(find.byKey(const Key('whatMattersVerifyButton')));
      await tester.pumpAndSettle();

      expect(find.text('Saved.'), findsOneWidget);
      expect(find.text('Reading /Notes/What Matters.md'), findsOneWidget);
      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsNothing);
    });

    testWidgets('a rejected credential is reported and the editor stays open', (
      tester,
    ) async {
      await _pumpSettingsScreen(
        tester,
        tokenIsValid: true,
        whatMattersReadable: false,
      );

      await fillEditor(tester, appPassword: 'wrong');
      await tester.tap(find.byKey(const Key('whatMattersVerifyButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Nextcloud rejected that username or app password.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('whatMattersBaseUrlField')), findsOneWidget);
    });
  });
}
