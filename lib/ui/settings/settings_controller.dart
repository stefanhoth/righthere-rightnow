import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:righthere_rightnow/data/battery_optimization.dart'
    as battery_optimization;
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/data/settings/selected_calendars_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
Future<String?> storedTodoistToken(Ref ref) {
  return ref.watch(todoistTokenStorageProvider).read();
}

@riverpod
Future<CalendarPermissionStatus> calendarPermissionStatus(Ref ref) {
  return DeviceCalendar().hasPermissions();
}

/// The calendars the user could include in the Daily Agenda -- every
/// calendar the OS reports that is not hidden.
@riverpod
Future<List<Calendar>> availableCalendars(Ref ref) async {
  final calendars = await DeviceCalendar().listCalendars();
  return calendars.where((calendar) => !calendar.hidden).toList();
}

/// The calendars the user has chosen. An empty set means "every calendar in
/// [availableCalendars]" -- see [SelectedCalendarsStorage].
@riverpod
Future<Set<String>> selectedCalendarIds(Ref ref) {
  return ref.watch(selectedCalendarsStorageProvider).read();
}

// Holds no state, but kept alive so an in-flight [setSelected] -- which
// awaits secure storage between reading and invalidating -- is not disposed
// mid-write when the checklist stops listening.
@Riverpod(keepAlive: true)
class SelectedCalendarsController extends _$SelectedCalendarsController {
  @override
  void build() {}

  /// Includes or excludes one calendar, then persists. [allCalendarIds] is
  /// every calendar currently offered, so the "empty means everything"
  /// default can be expanded and re-collapsed correctly. The next Briefing
  /// Run picks up the change; it does not re-run the current one.
  Future<void> setSelected(
    String calendarId, {
    required bool selected,
    required Set<String> allCalendarIds,
  }) async {
    final storage = ref.read(selectedCalendarsStorageProvider);
    final stored = await storage.read();

    // An empty stored set means "every calendar". Expand it before toggling
    // so unchecking one box removes exactly that calendar, not all of them.
    final next = stored.isEmpty ? {...allCalendarIds} : {...stored};
    if (selected) {
      next.add(calendarId);
    } else {
      next.remove(calendarId);
    }

    // Collapse back to the "every calendar" default when nothing is
    // excluded, so calendars added later stay included too.
    await storage.write(next.containsAll(allCalendarIds) ? <String>{} : next);
    ref.invalidate(selectedCalendarIdsProvider);
  }
}

@riverpod
Future<PermissionStatus> batteryOptimizationStatus(Ref ref) {
  return battery_optimization.batteryOptimizationStatus();
}

enum TokenEntryStatus { idle, verifying, saved, invalid, error }

@riverpod
class TokenEntryController extends _$TokenEntryController {
  @override
  TokenEntryStatus build() => TokenEntryStatus.idle;

  Future<void> verifyAndSave(String token) async {
    state = TokenEntryStatus.verifying;

    final bool isValid;
    try {
      isValid = await ref.read(todoistClientProvider).verifyToken(token);
    } on Exception {
      state = TokenEntryStatus.error;
      return;
    }

    if (!isValid) {
      state = TokenEntryStatus.invalid;
      return;
    }

    await ref.read(todoistTokenStorageProvider).write(token);
    ref.invalidate(storedTodoistTokenProvider);
    state = TokenEntryStatus.saved;
  }
}
