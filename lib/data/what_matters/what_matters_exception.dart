/// Base type for What Matters fetch failures that callers should handle, as
/// distinct from a crash.
///
/// No subtype's [toString] ever carries the app password or the full URL --
/// these are logged and folded into the Briefing Run error string.
sealed class WhatMattersException implements Exception {
  const WhatMattersException();
}

/// The Nextcloud app password (or username) was rejected -- HTTP 401.
class WhatMattersUnauthorizedException extends WhatMattersException {
  const WhatMattersUnauthorizedException();

  @override
  String toString() => 'WhatMattersException: credentials rejected';
}

/// Any other non-200 response -- a wrong path is the usual cause (404).
class WhatMattersRequestException extends WhatMattersException {
  const WhatMattersRequestException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'WhatMattersException: HTTP $statusCode';
}
