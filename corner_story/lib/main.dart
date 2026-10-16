import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/explore_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vibes_screen.dart';
import 'theme/corner_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: CornerColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CornerApp());
}

class CornerApp extends StatelessWidget {
  const CornerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corner — Curate & Share Places',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: CornerColors.surface,
        fontFamily: CornerTypography.sansFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CornerColors.primary,
          surface: CornerColors.surface,
          primary: CornerColors.primary,
          secondary: CornerColors.secondary,
        ),
      ),
      home: const CornerMainShell(),
    );
  }
}

class CornerMainShell extends StatefulWidget {
  const CornerMainShell({super.key});

  @override
  State<CornerMainShell> createState() => _CornerMainShellState();
}

class _CornerMainShellState extends State<CornerMainShell> {
  int _currentIndex = 0;

  static const List<String> _sectionLabels = [
    'Explore',
    'Map',
    'Vibes',
    'Profile',
  ];

  final List<Widget> _screens = const [
    ExploreScreen(),
    MapScreen(),
    VibesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CornerTopBar(
              sectionLabel: _sectionLabels[_currentIndex],
              onProfileTap: () => setState(() => _currentIndex = 3),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CornerBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
        ],
      ),
    );
  }
}
