import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// Explore
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get message000;

  /// Map
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get message001;

  /// Vibes
  ///
  /// In en, this message translates to:
  /// **'Vibes'**
  String get message002;

  /// Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get message003;

  /// Appearance & Language
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get message004;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get message005;

  /// Warm Editorial
  ///
  /// In en, this message translates to:
  /// **'Warm Editorial'**
  String get message006;

  /// Monochrome
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get message007;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get message008;

  /// Follow Device
  ///
  /// In en, this message translates to:
  /// **'Follow Device'**
  String get message009;

  /// Back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get message010;

  /// Privacy
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get message011;

  /// Continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get message012;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get message013;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get message014;

  /// Remove
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get message015;

  /// Retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get message016;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get message017;

  /// Saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get message018;

  /// Share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get message019;

  /// Share Map
  ///
  /// In en, this message translates to:
  /// **'Share Map'**
  String get message020;

  /// Link Copied
  ///
  /// In en, this message translates to:
  /// **'Link Copied'**
  String get message021;

  /// Copy link
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get message022;

  /// Copy website link
  ///
  /// In en, this message translates to:
  /// **'Copy website link'**
  String get message023;

  /// Official website
  ///
  /// In en, this message translates to:
  /// **'Official website'**
  String get message024;

  /// Official website link copied.
  ///
  /// In en, this message translates to:
  /// **'Official website link copied.'**
  String get message025;

  /// Place link copied.
  ///
  /// In en, this message translates to:
  /// **'Place link copied.'**
  String get message026;

  /// Hours
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get message027;

  /// Location & Hours
  ///
  /// In en, this message translates to:
  /// **'Location & Hours'**
  String get message028;

  /// Plan visit
  ///
  /// In en, this message translates to:
  /// **'Plan visit'**
  String get message029;

  /// Walking & Transit Waypoints
  ///
  /// In en, this message translates to:
  /// **'Walking & Transit Waypoints'**
  String get message030;

  /// Transit
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get message031;

  /// Seating
  ///
  /// In en, this message translates to:
  /// **'Seating'**
  String get message032;

  /// What to Order
  ///
  /// In en, this message translates to:
  /// **'What to Order'**
  String get message033;

  /// Field Note
  ///
  /// In en, this message translates to:
  /// **'Field Note'**
  String get message034;

  /// Post vibe
  ///
  /// In en, this message translates to:
  /// **'Post vibe'**
  String get message035;

  /// Share your latest spot find...
  ///
  /// In en, this message translates to:
  /// **'Share your latest spot find...'**
  String get message036;

  /// Photographic notes & sensory fragments
  ///
  /// In en, this message translates to:
  /// **'Photographic notes & sensory fragments'**
  String get message037;

  /// Draft copied to clipboard.
  ///
  /// In en, this message translates to:
  /// **'Draft copied to clipboard.'**
  String get message038;

  /// Could not publish. Your note is still here; please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not publish. Your note is still here; please try again.'**
  String get message039;

  /// Could not open your photo library. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not open your photo library. Please try again.'**
  String get message040;

  /// Could not save this place. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not save this place. Please try again.'**
  String get message041;

  /// Could not save your palate. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not save your palate. Please try again.'**
  String get message042;

  /// Curated Collections
  ///
  /// In en, this message translates to:
  /// **'Curated Collections'**
  String get message043;

  /// Curated Entries
  ///
  /// In en, this message translates to:
  /// **'Curated Entries'**
  String get message044;

  /// Create new Curated Collection
  ///
  /// In en, this message translates to:
  /// **'Create new Curated Collection'**
  String get message045;

  /// Pin a Place
  ///
  /// In en, this message translates to:
  /// **'Pin a Place'**
  String get message046;

  /// Pin a new place to your Corner map
  ///
  /// In en, this message translates to:
  /// **'Pin a new place to your Corner map'**
  String get message047;

  /// Select Geo-Verified Sanctuary
  ///
  /// In en, this message translates to:
  /// **'Select Geo-Verified Sanctuary'**
  String get message048;

  /// Choose a known place, such as Radio Bakery or Eavesdrop.
  ///
  /// In en, this message translates to:
  /// **'Choose a known place, such as Radio Bakery or Eavesdrop.'**
  String get message049;

  /// Ready to import saved lists
  ///
  /// In en, this message translates to:
  /// **'Ready to import saved lists'**
  String get message050;

  /// Import from Maps
  ///
  /// In en, this message translates to:
  /// **'Import from Maps'**
  String get message051;

  /// List View
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get message052;

  /// Atmosphere · Preview
  ///
  /// In en, this message translates to:
  /// **'Atmosphere · Preview'**
  String get message053;

  /// No algorithmic noise.
  ///
  /// In en, this message translates to:
  /// **'No algorithmic noise.'**
  String get message054;

  /// Real palates.
  ///
  /// In en, this message translates to:
  /// **'Real palates.'**
  String get message055;

  /// Zero sponsored
  ///
  /// In en, this message translates to:
  /// **'Zero sponsored'**
  String get message056;

  /// 100% Non-Sponsored IRL Experience
  ///
  /// In en, this message translates to:
  /// **'100% Non-Sponsored IRL Experience'**
  String get message057;

  /// Handcrafted guides updated weekly
  ///
  /// In en, this message translates to:
  /// **'Handcrafted guides updated weekly'**
  String get message058;

  /// A place for your next chapter.
  ///
  /// In en, this message translates to:
  /// **'A place for your next chapter.'**
  String get message059;

  /// Start building your corner
  ///
  /// In en, this message translates to:
  /// **'Start building your corner'**
  String get message060;

  /// Begin Taste Calibration  →
  ///
  /// In en, this message translates to:
  /// **'Begin Taste Calibration  →'**
  String get message061;

  /// Calibrate your palate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate your palate.'**
  String get message062;

  /// Skip for now, explore as guest
  ///
  /// In en, this message translates to:
  /// **'Skip for now, explore as guest'**
  String get message063;

  /// I already have a Corner · Sign In
  ///
  /// In en, this message translates to:
  /// **'I already have a Corner · Sign In'**
  String get message064;

  /// CORNER ACCESS
  ///
  /// In en, this message translates to:
  /// **'CORNER ACCESS'**
  String get message065;

  /// PERSONAL EDITORIAL DISPATCH
  ///
  /// In en, this message translates to:
  /// **'PERSONAL EDITORIAL DISPATCH'**
  String get message066;

  /// Your private access.
  ///
  /// In en, this message translates to:
  /// **'Your private access.'**
  String get message067;

  /// Your access code is single-use. Your session stays private on this device.
  ///
  /// In en, this message translates to:
  /// **'Your access code is single-use. Your session stays private on this device.'**
  String get message068;

  /// Use a different email
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get message069;

  /// PASSKEYS
  ///
  /// In en, this message translates to:
  /// **'PASSKEYS'**
  String get message070;

  /// Passkeys & device verification
  ///
  /// In en, this message translates to:
  /// **'Passkeys & device verification'**
  String get message071;

  /// Authenticate with Passkey / Face ID
  ///
  /// In en, this message translates to:
  /// **'Authenticate with Passkey / Face ID'**
  String get message072;

  /// No passkeys added yet.
  ///
  /// In en, this message translates to:
  /// **'No passkeys added yet.'**
  String get message073;

  /// Name your passkey
  ///
  /// In en, this message translates to:
  /// **'Name your passkey'**
  String get message074;

  /// Remove this passkey?
  ///
  /// In en, this message translates to:
  /// **'Remove this passkey?'**
  String get message075;

  /// Add, rename or remove your passkeys
  ///
  /// In en, this message translates to:
  /// **'Add, rename or remove your passkeys'**
  String get message076;

  /// Create a passkey after signing in with email. Next time, your device can verify you with a fingerprint, face scan or PIN. Corner only stores the public key.
  ///
  /// In en, this message translates to:
  /// **'Create a passkey after signing in with email. Next time, your device can verify you with a fingerprint, face scan or PIN. Corner only stores the public key.'**
  String get message077;

  /// Use a passkey you previously added to Corner. Your device may ask for a fingerprint, face scan or PIN.
  ///
  /// In en, this message translates to:
  /// **'Use a passkey you previously added to Corner. Your device may ask for a fingerprint, face scan or PIN.'**
  String get message078;

  /// Privacy And Circles
  ///
  /// In en, this message translates to:
  /// **'Privacy And Circles'**
  String get message079;

  /// Curate your circle.
  /// Protect your quiet spaces.
  ///
  /// In en, this message translates to:
  /// **'Curate your circle.\nProtect your quiet spaces.'**
  String get message080;

  /// Choose who can see your real-world footprint and manage the people in your circle.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see your real-world footprint and manage the people in your circle.'**
  String get message081;

  /// No people in your circle yet.
  ///
  /// In en, this message translates to:
  /// **'No people in your circle yet.'**
  String get message082;

  /// Remove from your circle?
  ///
  /// In en, this message translates to:
  /// **'Remove from your circle?'**
  String get message083;

  /// Find your friends in the real world
  ///
  /// In en, this message translates to:
  /// **'Find your friends in the real world'**
  String get message084;

  /// Address book matching is not available yet. No contacts have been accessed.
  ///
  /// In en, this message translates to:
  /// **'Address book matching is not available yet. No contacts have been accessed.'**
  String get message085;

  /// See spots curated by friends in your contacts. No mutuals are notified without your permission.
  ///
  /// In en, this message translates to:
  /// **'See spots curated by friends in your contacts. No mutuals are notified without your permission.'**
  String get message086;

  /// Delete account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get message087;

  /// Delete your Corner?
  ///
  /// In en, this message translates to:
  /// **'Delete your Corner?'**
  String get message088;

  /// This permanently deletes your account, saved places, notes, and circle. Type DELETE MY CORNER to continue.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, saved places, notes, and circle. Type DELETE MY CORNER to continue.'**
  String get message089;

  /// Export
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get message090;

  /// Source checked · 16 Oct 2026
  ///
  /// In en, this message translates to:
  /// **'Source checked · 16 Oct 2026'**
  String get message091;

  /// Place Detail View
  ///
  /// In en, this message translates to:
  /// **'Place Detail View'**
  String get message092;

  /// Save this place to revisit it, or share the map link with your circle.
  ///
  /// In en, this message translates to:
  /// **'Save this place to revisit it, or share the map link with your circle.'**
  String get message093;

  /// Write a note (1–280 characters) and confirm your non-sponsored visit.
  ///
  /// In en, this message translates to:
  /// **'Write a note (1–280 characters) and confirm your non-sponsored visit.'**
  String get message094;

  /// Your words guide real people to real tables.
  ///
  /// In en, this message translates to:
  /// **'Your words guide real people to real tables.'**
  String get message095;

  /// Describe a mood, sound, or craving.
  ///
  /// In en, this message translates to:
  /// **'Describe a mood, sound, or craving.'**
  String get message096;

  /// Looking for something specific? Ask Corner AI...
  ///
  /// In en, this message translates to:
  /// **'Looking for something specific? Ask Corner AI...'**
  String get message097;

  /// ●  AUTHENTICATION PROTOCOL
  ///
  /// In en, this message translates to:
  /// **'●  AUTHENTICATION PROTOCOL'**
  String get message098;

  /// Return to your quiet spaces.
  ///
  /// In en, this message translates to:
  /// **'Return to your quiet spaces.'**
  String get message099;

  /// Check your private dispatch.
  ///
  /// In en, this message translates to:
  /// **'Check your private dispatch.'**
  String get message100;

  /// Sign in password-free with a single-use code sent to your email.
  ///
  /// In en, this message translates to:
  /// **'Sign in password-free with a single-use code sent to your email.'**
  String get message101;

  /// Send Access Code  →
  ///
  /// In en, this message translates to:
  /// **'Send Access Code  →'**
  String get message102;

  /// Enter Corner  →
  ///
  /// In en, this message translates to:
  /// **'Enter Corner  →'**
  String get message103;

  /// Enter a valid email address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get message104;

  /// Enter the six-digit code from your email.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code from your email.'**
  String get message105;

  /// Six-digit access code
  ///
  /// In en, this message translates to:
  /// **'Six-digit access code'**
  String get message106;

  /// EST. 2024 · AN IRL ATLAS
  ///
  /// In en, this message translates to:
  /// **'EST. 2024 · AN IRL ATLAS'**
  String get message107;

  /// More time in the real world.
  ///
  /// In en, this message translates to:
  /// **'More time in the real world.'**
  String get message108;

  /// —  ISSUE NO. 01 · THE MANIFESTO
  ///
  /// In en, this message translates to:
  /// **'—  ISSUE NO. 01 · THE MANIFESTO'**
  String get message109;

  /// An intimate sanctuary away from sponsored hype, TikTok queues, and tourist traps. Curate quiet wine bars, hidden listening lounges, and sunlit corners with the people whose taste you trust.
  ///
  /// In en, this message translates to:
  /// **'An intimate sanctuary away from sponsored hype, TikTok queues, and tourist traps. Curate quiet wine bars, hidden listening lounges, and sunlit corners with the people whose taste you trust.'**
  String get message110;

  /// CORNER CONCIERGE
  ///
  /// In en, this message translates to:
  /// **'CORNER CONCIERGE'**
  String get message111;

  /// Curate Matches
  ///
  /// In en, this message translates to:
  /// **'Curate Matches'**
  String get message112;

  /// NEIGHBORHOOD HAUNTS
  ///
  /// In en, this message translates to:
  /// **'NEIGHBORHOOD HAUNTS'**
  String get message113;

  /// NEW YORK FIELD GUIDE
  ///
  /// In en, this message translates to:
  /// **'NEW YORK FIELD GUIDE'**
  String get message114;

  /// New York Field Guide
  ///
  /// In en, this message translates to:
  /// **'New York Field Guide'**
  String get message115;

  /// New York: Coffee, Sound & Quiet Corners
  ///
  /// In en, this message translates to:
  /// **'New York: Coffee, Sound & Quiet Corners'**
  String get message116;

  /// CURATED FIELD GUIDE
  ///
  /// In en, this message translates to:
  /// **'CURATED FIELD GUIDE'**
  String get message117;

  /// CHRONOLOGICAL SEQUENCE
  ///
  /// In en, this message translates to:
  /// **'CHRONOLOGICAL SEQUENCE'**
  String get message118;

  /// SPATIAL MAPPING
  ///
  /// In en, this message translates to:
  /// **'SPATIAL MAPPING'**
  String get message119;

  /// The Ideal Acoustic Itinerary
  ///
  /// In en, this message translates to:
  /// **'The Ideal Acoustic Itinerary'**
  String get message120;

  /// ADD FRAME
  /// (35MM)
  ///
  /// In en, this message translates to:
  /// **'ADD FRAME\n(35MM)'**
  String get message121;

  /// ANTI-HYPE CADENCE
  ///
  /// In en, this message translates to:
  /// **'ANTI-HYPE CADENCE'**
  String get message122;

  /// AUDIENCE & REACH
  ///
  /// In en, this message translates to:
  /// **'AUDIENCE & REACH'**
  String get message123;

  /// DISPATCH NO. 04
  ///
  /// In en, this message translates to:
  /// **'DISPATCH NO. 04'**
  String get message124;

  /// DISPATCH NO. 04 • FIELD NOTES
  ///
  /// In en, this message translates to:
  /// **'DISPATCH NO. 04 • FIELD NOTES'**
  String get message125;

  /// FILM CAPTURES
  ///
  /// In en, this message translates to:
  /// **'FILM CAPTURES'**
  String get message126;

  /// GEO-VERIFIED SANCTUARY
  ///
  /// In en, this message translates to:
  /// **'GEO-VERIFIED SANCTUARY'**
  String get message127;

  /// Keep it truthful, concise & table-tested
  ///
  /// In en, this message translates to:
  /// **'Keep it truthful, concise & table-tested'**
  String get message128;

  /// SENSORY MARKERS
  ///
  /// In en, this message translates to:
  /// **'SENSORY MARKERS'**
  String get message129;

  /// THE HONEST DISPATCH
  ///
  /// In en, this message translates to:
  /// **'THE HONEST DISPATCH'**
  String get message130;

  /// Tap to imprint
  ///
  /// In en, this message translates to:
  /// **'Tap to imprint'**
  String get message131;

  /// DISPATCH SETTINGS · TRUST & PERMISSIONS
  ///
  /// In en, this message translates to:
  /// **'DISPATCH SETTINGS · TRUST & PERMISSIONS'**
  String get message132;

  /// ACTIVE CHAPTERS
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CHAPTERS'**
  String get message133;

  /// Candid Moments
  ///
  /// In en, this message translates to:
  /// **'Candid Moments'**
  String get message134;

  /// QUIET CARTOGRAPHY
  ///
  /// In en, this message translates to:
  /// **'QUIET CARTOGRAPHY'**
  String get message135;

  /// TASTE
  ///
  /// In en, this message translates to:
  /// **'TASTE'**
  String get message136;

  /// ACOUSTIC PREFERENCE
  ///
  /// In en, this message translates to:
  /// **'ACOUSTIC PREFERENCE'**
  String get message137;

  /// ATMOSPHERE & ARCHETYPE
  ///
  /// In en, this message translates to:
  /// **'ATMOSPHERE & ARCHETYPE'**
  String get message138;

  /// Decibel mood
  ///
  /// In en, this message translates to:
  /// **'Decibel mood'**
  String get message139;

  /// STEP 2 OF 3 · TASTE RADAR CALIBRATION
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 3 · TASTE RADAR CALIBRATION'**
  String get message140;

  /// FIELD ADVISORY
  ///
  /// In en, this message translates to:
  /// **'FIELD ADVISORY'**
  String get message141;

  /// FIELD TESTED
  ///
  /// In en, this message translates to:
  /// **'FIELD TESTED'**
  String get message142;

  /// From the Circle
  ///
  /// In en, this message translates to:
  /// **'From the Circle'**
  String get message143;

  /// SOUND DECIBELS
  ///
  /// In en, this message translates to:
  /// **'SOUND DECIBELS'**
  String get message144;

  /// Acoustic Architecture
  ///
  /// In en, this message translates to:
  /// **'Acoustic Architecture'**
  String get message145;

  /// An audio recording is not available for this place yet.
  ///
  /// In en, this message translates to:
  /// **'An audio recording is not available for this place yet.'**
  String get message146;

  /// View All 18
  ///
  /// In en, this message translates to:
  /// **'View All 18'**
  String get message147;

  /// It will no longer sign in to Corner. You can still use email. Remove its saved copy from your credential manager separately.
  ///
  /// In en, this message translates to:
  /// **'It will no longer sign in to Corner. You can still use email. Remove its saved copy from your credential manager separately.'**
  String get message148;

  /// Zero Paid Ads & Noise
  ///
  /// In en, this message translates to:
  /// **'Zero Paid Ads & Noise'**
  String get message149;

  /// Places cataloged and reviewed only by real friends—never sponsored, never boosted.
  ///
  /// In en, this message translates to:
  /// **'Places cataloged and reviewed only by real friends—never sponsored, never boosted.'**
  String get message150;

  /// Vibe & Acoustic First
  ///
  /// In en, this message translates to:
  /// **'Vibe & Acoustic First'**
  String get message151;

  /// Find spaces for conversations, warm light, and a pace that feels like yours.
  ///
  /// In en, this message translates to:
  /// **'Find spaces for conversations, warm light, and a pace that feels like yours.'**
  String get message152;

  /// Privacy by Design
  ///
  /// In en, this message translates to:
  /// **'Privacy by Design'**
  String get message153;

  /// You choose who can see your places and your circle.
  ///
  /// In en, this message translates to:
  /// **'You choose who can see your places and your circle.'**
  String get message154;

  /// Friends Only
  ///
  /// In en, this message translates to:
  /// **'Friends Only'**
  String get message155;

  /// Open Now
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get message156;

  /// Coffee & Wine
  ///
  /// In en, this message translates to:
  /// **'Coffee & Wine'**
  String get message157;

  /// CORNERS
  ///
  /// In en, this message translates to:
  /// **'CORNERS'**
  String get message158;

  /// FOLLOWERS
  ///
  /// In en, this message translates to:
  /// **'FOLLOWERS'**
  String get message159;

  /// FOLLOWING
  ///
  /// In en, this message translates to:
  /// **'FOLLOWING'**
  String get message160;

  /// Quiet date spot with vinyl
  ///
  /// In en, this message translates to:
  /// **'Quiet date spot with vinyl'**
  String get message161;

  /// Orange wine by the carafe
  ///
  /// In en, this message translates to:
  /// **'Orange wine by the carafe'**
  String get message162;

  /// Sunlit cafe for reading
  ///
  /// In en, this message translates to:
  /// **'Sunlit cafe for reading'**
  String get message163;

  /// e.g. Rainy afternoon espresso bar with wooden booths...
  ///
  /// In en, this message translates to:
  /// **'e.g. Rainy afternoon espresso bar with wooden booths...'**
  String get message164;

  /// Spot name (e.g. Eavesdrop, Four Horsemen)
  ///
  /// In en, this message translates to:
  /// **'Spot name (e.g. Eavesdrop, Four Horsemen)'**
  String get message165;

  /// Write with restraint. What lingered after you left?
  ///
  /// In en, this message translates to:
  /// **'Write with restraint. What lingered after you left?'**
  String get message166;

  /// My phone or laptop
  ///
  /// In en, this message translates to:
  /// **'My phone or laptop'**
  String get message167;

  /// Rename passkey
  ///
  /// In en, this message translates to:
  /// **'Rename passkey'**
  String get message168;

  /// Remove passkey
  ///
  /// In en, this message translates to:
  /// **'Remove passkey'**
  String get message169;

  /// Sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get message170;

  /// Remove from circle
  ///
  /// In en, this message translates to:
  /// **'Remove from circle'**
  String get message171;

  /// Copy place link
  ///
  /// In en, this message translates to:
  /// **'Copy place link'**
  String get message172;

  /// Carto Editorial
  ///
  /// In en, this message translates to:
  /// **'Carto Editorial'**
  String get message173;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
