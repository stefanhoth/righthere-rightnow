/// Base type for Todoist API failures that callers should handle, as
/// distinct from a crash.
sealed class TodoistException implements Exception {
  const TodoistException(this.message);

  final String message;

  @override
  String toString() => 'TodoistException: $message';
}

/// The token was rejected by the API (HTTP 401).
class TodoistInvalidTokenException extends TodoistException {
  const TodoistInvalidTokenException()
    : super('The Todoist API token is invalid.');
}

/// Any other non-2xx response.
class TodoistRequestException extends TodoistException {
  const TodoistRequestException(this.statusCode, super.message);

  final int statusCode;
}
