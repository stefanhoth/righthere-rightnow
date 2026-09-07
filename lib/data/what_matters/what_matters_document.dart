import 'package:meta/meta.dart';

/// The What Matters prose as the app last held it, with when that copy was
/// fetched (ADR-0008). This is the raw markdown only -- the structure the
/// ranker uses is a separate extraction (Task 4.5), not part of this value.
@immutable
class WhatMattersDocument {
  const WhatMattersDocument({required this.prose, required this.fetchedAt});

  final String prose;
  final DateTime fetchedAt;

  @override
  bool operator ==(Object other) =>
      other is WhatMattersDocument &&
      other.prose == prose &&
      other.fetchedAt == fetchedAt;

  @override
  int get hashCode => Object.hash(prose, fetchedAt);
}

/// The outcome of asking for the current What Matters prose.
///
/// [document] is the freshly fetched copy when [isStale] is false, the last
/// cached copy when it is true, and null only when the server is unreachable
/// and nothing was ever cached. [error] is set exactly when the fetch failed
/// -- it never contains the credential or the full URL.
@immutable
class WhatMattersReadResult {
  const WhatMattersReadResult({
    this.document,
    this.isStale = false,
    this.error,
  });

  final WhatMattersDocument? document;
  final bool isStale;
  final String? error;
}
