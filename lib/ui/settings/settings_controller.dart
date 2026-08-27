import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:righthere_rightnow/data/battery_optimization.dart'
    as battery_optimization;
import 'package:righthere_rightnow/data/providers.dart';
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
