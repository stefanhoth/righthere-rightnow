import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_repository.dart';

class MockWhatMattersRepository extends Mock implements WhatMattersRepository {}

/// A [WhatMattersRepository] that returns [result] and never touches the
/// network or the database. Defaults to "not configured" -- a no-op for
/// tests that only need the orchestrator to construct and run.
WhatMattersRepository stubWhatMattersRepository([
  WhatMattersReadResult result = const WhatMattersReadResult(),
]) {
  final mock = MockWhatMattersRepository();
  when(mock.read).thenAnswer((_) async => result);
  return mock;
}
