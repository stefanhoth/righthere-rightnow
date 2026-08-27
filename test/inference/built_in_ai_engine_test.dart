import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/inference/built_in_ai_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'isAvailable reports false, not an exception, with no native host',
    () async {
      final engine = BuiltInAiEngine();

      await expectLater(engine.isAvailable(), completion(isFalse));
    },
  );
}
