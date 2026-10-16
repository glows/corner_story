import 'package:flutter_test/flutter_test.dart';
import 'package:corner_story/main.dart';

void main() {
  testWidgets('Corner app renders all 4 editorial navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CornerApp());

    expect(find.text('Corner'), findsOneWidget);
    expect(find.text('EXPLORE'), findsOneWidget);
    expect(find.text('MAP'), findsOneWidget);
    expect(find.text('VIBES'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);
    expect(
      find.text(
        'Lower Manhattan Underground: Acoustically Pure Sanctuaries',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('VIBES'));
    await tester.pump();
    expect(find.text('Zero sponsored'), findsOneWidget);

    await tester.tap(find.text('SAVED'));
    await tester.pump();
    expect(find.text('Clara Vance'), findsOneWidget);
  });
}
