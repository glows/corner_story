import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/explore_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vibes_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/corner_auth_service.dart';
import 'settings/app_settings.dart';
import 'l10n/app_localizations.dart';
import 'theme/corner_theme.dart';
import 'widgets/scroll_aware_header.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.load();
  void updateSystemBars() => SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: CornerColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  updateSystemBars();
  appSettings.addListener(updateSystemBars);
  runApp(const CornerApp());
}

class CornerApp extends StatelessWidget {
  const CornerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => MaterialApp(
        title: 'Corner — Curate & Share Places',
        debugShowCheckedModeBanner: false,
        locale: appSettings.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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
        home: const CornerEntry(),
      ),
    );
  }
}

class CornerEntry extends StatefulWidget {
  const CornerEntry({super.key});
  @override
  State<CornerEntry> createState() => _CornerEntryState();
}

class _CornerEntryState extends State<CornerEntry> {
  bool? _signedIn;
  bool _showSignIn = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    bool signedIn = false;
    try {
      signedIn = await CornerAuthService.instance.restoreSession();
    } catch (_) {}
    if (mounted) setState(() => _signedIn = signedIn);
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_signedIn!) {
      return CornerMainShell(
        onSignOut: () => setState(() {
          _signedIn = false;
          _showSignIn = false;
        }),
      );
    }
    return _showSignIn
        ? SignInScreen(
            onAuthenticated: () => setState(() => _signedIn = true),
            onBack: () => setState(() => _showSignIn = false),
          )
        : WelcomeScreen(onSignIn: () => setState(() => _showSignIn = true));
  }
}

class CornerMainShell extends StatefulWidget {
  const CornerMainShell({super.key, this.onSignOut});
  final VoidCallback? onSignOut;

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

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const ExploreScreen(),
      const MapScreen(),
      const VibesScreen(),
      ProfileScreen(onSignOut: widget.onSignOut),
    ];
    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: ScrollAwareHeader(
        section: _currentIndex,
        collapseEnabled: _currentIndex != 1,
        headerVisible: _currentIndex != 1,
        header: CornerTopBar(
          sectionLabel: _sectionLabels[_currentIndex],
          onProfileTap: () => setState(() => _currentIndex = 3),
          onPalateCompleted: () => setState(() => _currentIndex = 1),
        ),
        child: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: screens),
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
      ),
    );
  }
}
