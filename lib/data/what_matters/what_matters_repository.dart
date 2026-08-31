import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/what_matters_settings_storage.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';

/// Fetches the What Matters prose and keeps the last good copy in Drift
/// (ADR-0008).
///
/// On a successful fetch: caches the body with its fetch time and returns it
/// fresh. On any failure: returns the cached copy (if any) flagged stale,
/// with a short error -- the same shape a Todoist outage takes in Task 1.10.
///
/// The Nextcloud credential is read here and never leaves: it is not in the
/// returned value, not in the cache, and not in the error string.
class WhatMattersRepository {
  WhatMattersRepository({
    required this.client,
    required this.settings,
    required this.database,
    required this.clock,
  });

  final WhatMattersClient client;
  final WhatMattersSettingsStorage settings;
  final AppDatabase database;
  final Clock clock;

  /// Reads the current prose. A null [WhatMattersReadResult.document] with no
  /// error means the connection has not been configured yet -- that is not a
  /// failure, just a feature the user has not turned on.
  Future<WhatMattersReadResult> read() async {
    final connection = await settings.read();
    if (connection == null || !connection.isComplete) {
      return const WhatMattersReadResult();
    }

    try {
      final prose = await client.fetch(
        baseUrl: connection.baseUrl,
        path: connection.path,
        username: connection.username,
        appPassword: connection.appPassword,
      );
      final fetchedAt = clock();
      await database.cacheWhatMatters(prose: prose, fetchedAt: fetchedAt);
      return WhatMattersReadResult(
        document: WhatMattersDocument(prose: prose, fetchedAt: fetchedAt),
      );
    } on Exception catch (error) {
      // `error` is a WhatMattersException (whose toString carries no
      // credential or URL) or a transport error from the HTTP client. The
      // cached copy carries the run.
      return WhatMattersReadResult(
        document: await database.cachedWhatMatters(),
        isStale: true,
        error: 'What Matters: $error',
      );
    }
  }
}
