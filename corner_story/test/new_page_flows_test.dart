import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:corner_story/screens/profile_screen.dart';
import 'package:corner_story/screens/explore_screen.dart';
import 'package:corner_story/screens/collection_detail_screen.dart';
import 'package:corner_story/screens/taste_onboarding_screen.dart';
import 'package:corner_story/screens/drop_vibe_note_screen.dart';
import 'package:corner_story/screens/spot_detail_screen.dart';
import 'package:corner_story/theme/corner_theme.dart';
import 'package:corner_story/services/corner_api_client.dart';
import 'package:corner_story/widgets/place_image.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await rootBundle.loadString('assets/data/nyc_places.json');
    for (final family in ['Newsreader', 'PlusJakartaSans']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'))).load();
    }
  });

  testWidgets(
    'Explore shows sourced NYC places instead of fictional venue cards',
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: ExploreScreen())),
        );
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      expect(
        tester.widget<PlaceImage>(find.byType(PlaceImage).first).source,
        startsWith('https://corner-api.flymind.org/api/v1/media/'),
      );
      await tester.scrollUntilVisible(
        find.text('SEY'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('SEY'), findsOneWidget);
      expect(find.text('Céleste Gallery & Cafe'), findsNothing);
    },
  );
  testWidgets('a curated collection opens its itinerary instead of a venue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileScreen())),
    );
    await tester.scrollUntilVisible(
      find.text('Natural Wine &\nVinyl'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Natural Wine &\nVinyl'));
    await tester.pumpAndSettle();
    expect(find.byType(CollectionDetailScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  test(
    'publishing rejects API errors instead of returning a success result',
    () async {
      final client = CornerApiClient(
        httpClient: MockClient(
          (request) async =>
              http.Response('{"error":"Quote is required"}', 400),
        ),
      );
      await expectLater(
        client.publishFieldNote(spotName: 'Radio Bakery', quote: ''),
        throwsA(isA<Exception>()),
      );
    },
  );

  testWidgets('opening Lei passes its own bookmark identity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSpotDetailModal(
              context,
              name: 'Lei',
              neighborhoodAndPrice: 'CHINATOWN · \$\$',
              rating: '4.8',
              description: 'Natural wine and small plates.',
              imageAsset: 'assets/images/img_05.jpg',
              categoryBadge: 'Natural Wine',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SpotDetailScreen>(find.byType(SpotDetailScreen)).spotId,
      'spot_lei',
    );
  });

  testWidgets('palate selections survive closing and reopening', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final directory = Directory.systemTemp.createTempSync('corner-palate-');
    addTearDown(() => directory.deleteSync(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => directory.path,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TasteOnboardingScreen()),
            ),
            child: const Text('Preferences'),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Preferences'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hidden Courtyards'));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Continue to My City Map'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Preferences'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('4 selected'), findsOneWidget);
  });

  testWidgets('a failed publish keeps the note available for retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DropVibeNoteScreen()),
            ),
            child: const Text('Compose'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Compose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publish Note'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(DropVibeNoteScreen), findsOneWidget);
    expect(find.textContaining('Could not publish'), findsOneWidget);
  });

  testWidgets('a saved guide remains saved after reopening', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final directory = Directory.systemTemp.createTempSync('corner-guide-');
    addTearDown(() => directory.deleteSync(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => directory.path,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CollectionDetailScreen()),
            ),
            child: const Text('Guide'),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Guide'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Save Full Guide to My Map'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Guide'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Saved to Your Places'), findsOneWidget);
  });

  testWidgets('Add Frame uses the photo selected from the device', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final directory = Directory.systemTemp.createTempSync('corner-frame-');
    final bytes = await rootBundle.load('assets/images/img_33.jpg');
    final file = File('${directory.path}/chosen.jpg')
      ..writeAsBytesSync(bytes.buffer.asUint8List());
    addTearDown(() => directory.deleteSync(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/image_picker');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => file.path,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: DropVibeNoteScreen()));
    await tester.tap(find.text('ADD FRAME\n(35MM)'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is FileImage,
      ),
      findsOneWidget,
    );
  });
}
