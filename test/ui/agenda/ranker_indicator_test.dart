import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/ui/agenda/ranker_indicator.dart';

void main() {
  test('the label names each ranker plainly', () {
    expect(rankerLabel(RankedBy.fallback), 'Ranked by rules');
    expect(rankerLabel(RankedBy.model), 'Ranked by the model');
  });

  testWidgets('renders the label for whichever ranker produced the order', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RankerIndicator(rankedBy: RankedBy.model)),
      ),
    );

    expect(find.byKey(const Key('rankerIndicator')), findsOneWidget);
    expect(find.text('Ranked by the model'), findsOneWidget);
  });
}
