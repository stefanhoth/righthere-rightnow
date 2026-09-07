import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:righthere_rightnow/data/what_matters/what_matters_exception.dart';

/// Reads the What Matters markdown file over WebDAV from the user's Nextcloud
/// (see DECISIONS.md, 2026-08-28).
///
/// A plain authenticated GET: Nextcloud serves the file body directly at its
/// WebDAV URL, so no PROPFIND or XML is involved.
class WhatMattersClient {
  WhatMattersClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// The document body as text.
  ///
  /// Throws [WhatMattersUnauthorizedException] on 401,
  /// [WhatMattersRequestException] on any other non-200, and a
  /// [TimeoutException] if the server does not respond within [timeout] --
  /// without it, an unreachable host leaves the settings button spinning
  /// forever with no feedback.
  Future<String> fetch({
    required String baseUrl,
    required String path,
    required String username,
    required String appPassword,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final response = await _httpClient
        .get(
          _documentUri(baseUrl, path),
          headers: {'Authorization': _basicAuth(username, appPassword)},
        )
        .timeout(timeout);
    if (response.statusCode == 401) {
      throw const WhatMattersUnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw WhatMattersRequestException(response.statusCode);
    }
    return utf8.decode(response.bodyBytes);
  }

  /// Whether the file can be read with these credentials -- the settings
  /// screen's verify button.
  ///
  /// Returns false for a rejected credential (401), mirroring
  /// `TodoistClient.verifyToken`: an invalid password is an expected,
  /// user-facing outcome of verification, not a failure of the client. A
  /// wrong path (404) and network failures still propagate.
  Future<bool> verify({
    required String baseUrl,
    required String path,
    required String username,
    required String appPassword,
  }) async {
    try {
      await fetch(
        baseUrl: baseUrl,
        path: path,
        username: username,
        appPassword: appPassword,
      );
      return true;
    } on WhatMattersUnauthorizedException {
      return false;
    }
  }

  /// Joins [baseUrl] and [path] tolerant of a trailing slash on one and a
  /// leading slash on the other, and percent-encodes the path segments (a
  /// What Matters file is very likely to have a space in its name).
  static Uri _documentUri(String baseUrl, String path) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final segments = path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
    return Uri.parse('$root/$segments');
  }

  static String _basicAuth(String username, String appPassword) {
    final encoded = base64Encode(utf8.encode('$username:$appPassword'));
    return 'Basic $encoded';
  }
}
