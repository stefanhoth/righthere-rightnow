import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Todoist personal API token outside Drift and
/// SharedPreferences, per ADR context: this is single-user credential
/// material and must never sit in the app's on-disk database or backup.
class TodoistTokenStorage {
  TodoistTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'todoist_api_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
