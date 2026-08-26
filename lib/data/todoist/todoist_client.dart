import 'package:http/http.dart' as http;

/// Hand-rolled Todoist client -- there is no Dart SDK for the Todoist API.
///
/// Base URL is the current REST API. The older v2 and Sync v9 APIs return
/// HTTP 410 Gone: they are shut down, not merely deprecated.
class TodoistClient {
  TodoistClient({
    http.Client? httpClient,
    this.baseUrl = 'https://api.todoist.com/api/v1',
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;

  /// Verifies a personal API token with a minimal authenticated request.
  ///
  /// Returns false for a rejected token (401) rather than throwing: an
  /// invalid token is an expected, user-facing outcome of verification, not
  /// a failure of the client itself. Network failures still propagate as
  /// thrown exceptions.
  Future<bool> verifyToken(String token) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/projects?limit=1'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
