import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
TodoistTokenStorage todoistTokenStorage(Ref ref) => TodoistTokenStorage();

@riverpod
TodoistClient todoistClient(Ref ref) => TodoistClient();

@riverpod
Future<String?> storedTodoistToken(Ref ref) {
  return ref.watch(todoistTokenStorageProvider).read();
}

@riverpod
Future<CalendarPermissionStatus> calendarPermissionStatus(Ref ref) {
  return DeviceCalendar().hasPermissions();
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
