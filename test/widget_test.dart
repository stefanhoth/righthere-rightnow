import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/main.dart';

void main() {
  testWidgets('launches to an empty Daily Agenda scaffold', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RightHereRightNowApp()));

    expect(find.text('Daily Agenda'), findsOneWidget);
  });
}
