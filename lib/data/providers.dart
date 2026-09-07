import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/run_time_storage.dart';
import 'package:righthere_rightnow/data/settings/selected_calendars_storage.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/settings/what_matters_settings_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Shared, cross-cutting data-layer providers. Kept separate from any one
/// screen's controller so settings and the Daily Agenda don't have to
/// import each other just to share a token store or a database handle.
@riverpod
TodoistTokenStorage todoistTokenStorage(Ref ref) => TodoistTokenStorage();

@riverpod
TodoistClient todoistClient(Ref ref) => TodoistClient();

@riverpod
CalendarReader calendarReader(Ref ref) => CalendarReader();

@riverpod
RunTimeStorage runTimeStorage(Ref ref) => RunTimeStorage();

@riverpod
SelectedCalendarsStorage selectedCalendarsStorage(Ref ref) =>
    SelectedCalendarsStorage();

@riverpod
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

@riverpod
WhatMattersSettingsStorage whatMattersSettingsStorage(Ref ref) =>
    WhatMattersSettingsStorage();

@riverpod
WhatMattersClient whatMattersClient(Ref ref) => WhatMattersClient();

@riverpod
WhatMattersRepository whatMattersRepository(Ref ref) {
  return WhatMattersRepository(
    client: ref.watch(whatMattersClientProvider),
    settings: ref.watch(whatMattersSettingsStorageProvider),
    database: ref.watch(appDatabaseProvider),
    clock: DateTime.now,
  );
}
