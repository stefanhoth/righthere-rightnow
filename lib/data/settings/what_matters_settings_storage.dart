import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

/// The user's Nextcloud connection for the What Matters document
/// (see DECISIONS.md, 2026-08-28).
///
/// The [appPassword] is credential material, so the whole record lives in
/// `flutter_secure_storage` -- never Drift, never a log. The [baseUrl] and
/// [path] travel with it so a Briefing Run isolate can read all four from
/// one place, the way `RunTimeStorage` already does for its settings.
@immutable
class WhatMattersConnection {
  const WhatMattersConnection({
    required this.baseUrl,
    required this.path,
    required this.username,
    required this.appPassword,
  });

  /// The Nextcloud WebDAV root, e.g. `https://cloud.example.com/remote.php/dav/files/me`.
  final String baseUrl;

  /// The document's path under [baseUrl], e.g. `/Notes/What Matters.md`.
  final String path;

  final String username;
  final String appPassword;

  bool get isComplete =>
      baseUrl.isNotEmpty &&
      path.isNotEmpty &&
      username.isNotEmpty &&
      appPassword.isNotEmpty;
}

/// Persists the [WhatMattersConnection] in `flutter_secure_storage`, the same
/// pattern `TodoistTokenStorage` uses for its token.
class WhatMattersSettingsStorage {
  WhatMattersSettingsStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _baseUrlKey = 'what_matters_base_url';
  static const _pathKey = 'what_matters_path';
  static const _usernameKey = 'what_matters_username';
  static const _passwordKey = 'what_matters_app_password';

  final FlutterSecureStorage _storage;

  Future<WhatMattersConnection?> read() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final path = await _storage.read(key: _pathKey);
    final username = await _storage.read(key: _usernameKey);
    final appPassword = await _storage.read(key: _passwordKey);
    if (baseUrl == null ||
        path == null ||
        username == null ||
        appPassword == null) {
      return null;
    }
    return WhatMattersConnection(
      baseUrl: baseUrl,
      path: path,
      username: username,
      appPassword: appPassword,
    );
  }

  Future<void> write(WhatMattersConnection connection) async {
    await _storage.write(key: _baseUrlKey, value: connection.baseUrl);
    await _storage.write(key: _pathKey, value: connection.path);
    await _storage.write(key: _usernameKey, value: connection.username);
    await _storage.write(key: _passwordKey, value: connection.appPassword);
  }

  Future<void> clear() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _pathKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}
