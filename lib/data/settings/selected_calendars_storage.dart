import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists which calendars feed the Daily Agenda.
///
/// An **empty** set is the default and means "every visible calendar",
/// including any added later. A non-empty set is an explicit allow-list.
/// Storing an empty set clears the key, so the two representations of
/// "everything" collapse to one.
///
/// Reuses `flutter_secure_storage` for the same reason `RunTimeStorage`
/// does: it is not a secret, but it must be readable from the isolates the
/// alarm callback and the foreground service run in, without adding another
/// storage dependency for one small setting.
class SelectedCalendarsStorage {
  SelectedCalendarsStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'selected_calendar_ids';
  static const _separator = '\n';

  final FlutterSecureStorage _storage;

  /// The chosen calendar ids, or an empty set when the user has never
  /// chosen -- an empty set means "every visible calendar".
  Future<Set<String>> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    return raw.split(_separator).where((id) => id.isNotEmpty).toSet();
  }

  Future<void> write(Set<String> calendarIds) {
    if (calendarIds.isEmpty) {
      return _storage.delete(key: _key);
    }
    return _storage.write(key: _key, value: calendarIds.join(_separator));
  }
}
