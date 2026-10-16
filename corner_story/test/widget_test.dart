import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:corner_story/main.dart';
import 'package:corner_story/screens/sign_in_screen.dart';
import 'package:corner_story/screens/welcome_screen.dart';

void main() {
  testWidgets('Corner app renders all 4 editorial navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CornerMainShell()));

    expect(find.text('Corner'), findsOneWidget);
    expect(find.text('EXPLORE'), findsOneWidget);
    expect(find.text('MAP'), findsOneWidget);
    expect(find.text('VIBES'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);
    expect(
      find.text('New York: Coffee, Sound & Quiet Corners'),
      findsOneWidget,
    );

    await tester.tap(find.text('VIBES'));
    await tester.pump();
    expect(find.text('Zero sponsored'), findsOneWidget);

    await tester.tap(find.text('SAVED'));
    await tester.pump();
    expect(find.text('Clara Vance'), findsOneWidget);
  });

  testWidgets('welcome and email access screens render', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: WelcomeScreen(onSignIn: () {})));
    expect(find.text('Real palates.'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(onAuthenticated: () {})),
    );
    expect(find.text('Send Access Code  →'), findsOneWidget);
    expect(find.text('Mobile Number'), findsNothing);
    await tester.ensureVisible(find.text('Send Access Code  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send Access Code  →'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
