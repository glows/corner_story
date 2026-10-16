import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corner_story/widgets/scroll_aware_header.dart';

void main() {
  testWidgets('header follows vertical scrolling and resets across sections', (
    tester,
  ) async {
    Future<void> show(int section) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrollAwareHeader(
            section: section,
            collapseEnabled: true,
            headerVisible: section != 1,
            header: const SizedBox(height: 60, child: Text('Header')),
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (_, index) =>
                  SizedBox(height: 80, child: Text('Row $index')),
            ),
          ),
        ),
      ),
    );
    Offset offset() =>
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset;
    await show(0);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(offset(), const Offset(0, -1));
    tester.state<ScrollableState>(find.byType(Scrollable)).position.jumpTo(0);
    await tester.pumpAndSettle();
    expect(offset(), Offset.zero);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(offset(), const Offset(0, -1));
    await tester.drag(find.byType(ListView), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(offset(), Offset.zero);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await show(3);
    expect(offset(), Offset.zero);
    await show(1);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Header'), findsNothing);
    await show(0);
    expect(offset(), Offset.zero);
  });
}
