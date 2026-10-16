import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Interface copy only. Place names, member writing and editorial records stay
/// in their original language when they are not present in this catalogue.
class CornerL10n {
  CornerL10n._();

  static String translate(BuildContext context, String source) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode != 'zh') return source;
    final strings = AppLocalizations.of(context);
    if (strings == null) return source;
    final translated = switch (source) {
      'Explore' => strings.message000,
      'Map' => strings.message001,
      'Vibes' => strings.message002,
      'Profile' => strings.message003,
      'Appearance & Language' => strings.message004,
      'Appearance' => strings.message005,
      'Warm Editorial' => strings.message006,
      'Monochrome' => strings.message007,
      'Language' => strings.message008,
      'Follow Device' => strings.message009,
      'Back' => strings.message010,
      'Privacy' => strings.message011,
      'Continue' => strings.message012,
      'Cancel' => strings.message013,
      'Confirm' => strings.message014,
      'Remove' => strings.message015,
      'Retry' => strings.message016,
      'Save' => strings.message017,
      'Saved' => strings.message018,
      'Share' => strings.message019,
      'Share Map' => strings.message020,
      'Link Copied' => strings.message021,
      'Copy link' => strings.message022,
      'Copy website link' => strings.message023,
      'Official website' => strings.message024,
      'Official website link copied.' => strings.message025,
      'Place link copied.' => strings.message026,
      'Hours' => strings.message027,
      'Location & Hours' => strings.message028,
      'Plan visit' => strings.message029,
      'Walking & Transit Waypoints' => strings.message030,
      'Transit' => strings.message031,
      'Seating' => strings.message032,
      'What to Order' => strings.message033,
      'Field Note' => strings.message034,
      'Post vibe' => strings.message035,
      'Share your latest spot find...' => strings.message036,
      'Photographic notes & sensory fragments' => strings.message037,
      'Draft copied to clipboard.' => strings.message038,
      'Could not publish. Your note is still here; please try again.' =>
        strings.message039,
      'Could not open your photo library. Please try again.' =>
        strings.message040,
      'Could not save this place. Please try again.' => strings.message041,
      'Could not save your palate. Please try again.' => strings.message042,
      'Curated Collections' => strings.message043,
      'Curated Entries' => strings.message044,
      'Create new Curated Collection' => strings.message045,
      'Pin a Place' => strings.message046,
      'Pin a new place to your Corner map' => strings.message047,
      'Select Geo-Verified Sanctuary' => strings.message048,
      'Choose a known place, such as Radio Bakery or Eavesdrop.' =>
        strings.message049,
      'Ready to import saved lists' => strings.message050,
      'Import from Maps' => strings.message051,
      'List View' => strings.message052,
      'Atmosphere · Preview' => strings.message053,
      'No algorithmic noise.' => strings.message054,
      'Real palates.' => strings.message055,
      'Zero sponsored' => strings.message056,
      '100% Non-Sponsored IRL Experience' => strings.message057,
      'Handcrafted guides updated weekly' => strings.message058,
      'A place for your next chapter.' => strings.message059,
      'Start building your corner' => strings.message060,
      'Begin Taste Calibration  →' => strings.message061,
      'Calibrate your palate.' => strings.message062,
      'Skip for now, explore as guest' => strings.message063,
      'I already have a Corner · Sign In' => strings.message064,
      'CORNER ACCESS' => strings.message065,
      'PERSONAL EDITORIAL DISPATCH' => strings.message066,
      'Your private access.' => strings.message067,
      'Your access code is single-use. Your session stays private on this device.' =>
        strings.message068,
      'Use a different email' => strings.message069,
      'PASSKEYS' => strings.message070,
      'Passkeys & device verification' => strings.message071,
      'Authenticate with Passkey / Face ID' => strings.message072,
      'No passkeys added yet.' => strings.message073,
      'Name your passkey' => strings.message074,
      'Remove this passkey?' => strings.message075,
      'Add, rename or remove your passkeys' => strings.message076,
      'Create a passkey after signing in with email. Next time, your device can verify you with a fingerprint, face scan or PIN. Corner only stores the public key.' =>
        strings.message077,
      'Use a passkey you previously added to Corner. Your device may ask for a fingerprint, face scan or PIN.' =>
        strings.message078,
      'Privacy And Circles' => strings.message079,
      'Curate your circle.\nProtect your quiet spaces.' => strings.message080,
      'Choose who can see your real-world footprint and manage the people in your circle.' =>
        strings.message081,
      'No people in your circle yet.' => strings.message082,
      'Remove from your circle?' => strings.message083,
      'Find your friends in the real world' => strings.message084,
      'Address book matching is not available yet. No contacts have been accessed.' =>
        strings.message085,
      'See spots curated by friends in your contacts. No mutuals are notified without your permission.' =>
        strings.message086,
      'Delete account' => strings.message087,
      'Delete your Corner?' => strings.message088,
      'This permanently deletes your account, saved places, notes, and circle. Type DELETE MY CORNER to continue.' =>
        strings.message089,
      'Export' => strings.message090,
      'Source checked · 16 Oct 2026' => strings.message091,
      'Place Detail View' => strings.message092,
      'Save this place to revisit it, or share the map link with your circle.' =>
        strings.message093,
      'Write a note (1–280 characters) and confirm your non-sponsored visit.' =>
        strings.message094,
      'Your words guide real people to real tables.' => strings.message095,
      'Describe a mood, sound, or craving.' => strings.message096,
      'Looking for something specific? Ask Corner AI...' => strings.message097,
      '●  AUTHENTICATION PROTOCOL' => strings.message098,
      'Return to your quiet spaces.' => strings.message099,
      'Check your private dispatch.' => strings.message100,
      'Sign in password-free with a single-use code sent to your email.' =>
        strings.message101,
      'Send Access Code  →' => strings.message102,
      'Enter Corner  →' => strings.message103,
      'Enter a valid email address.' => strings.message104,
      'Enter the six-digit code from your email.' => strings.message105,
      'Six-digit access code' => strings.message106,
      'EST. 2024 · AN IRL ATLAS' => strings.message107,
      'More time in the real world.' => strings.message108,
      '—  ISSUE NO. 01 · THE MANIFESTO' => strings.message109,
      'An intimate sanctuary away from sponsored hype, TikTok queues, and tourist traps. Curate quiet wine bars, hidden listening lounges, and sunlit corners with the people whose taste you trust.' =>
        strings.message110,
      'CORNER CONCIERGE' => strings.message111,
      'Curate Matches' => strings.message112,
      'NEIGHBORHOOD HAUNTS' => strings.message113,
      'NEW YORK FIELD GUIDE' => strings.message114,
      'New York Field Guide' => strings.message115,
      'New York: Coffee, Sound & Quiet Corners' => strings.message116,
      'CURATED FIELD GUIDE' => strings.message117,
      'CHRONOLOGICAL SEQUENCE' => strings.message118,
      'SPATIAL MAPPING' => strings.message119,
      'The Ideal Acoustic Itinerary' => strings.message120,
      'ADD FRAME\n(35MM)' => strings.message121,
      'ANTI-HYPE CADENCE' => strings.message122,
      'AUDIENCE & REACH' => strings.message123,
      'DISPATCH NO. 04' => strings.message124,
      'DISPATCH NO. 04 • FIELD NOTES' => strings.message125,
      'FILM CAPTURES' => strings.message126,
      'GEO-VERIFIED SANCTUARY' => strings.message127,
      'Keep it truthful, concise & table-tested' => strings.message128,
      'SENSORY MARKERS' => strings.message129,
      'THE HONEST DISPATCH' => strings.message130,
      'Tap to imprint' => strings.message131,
      'DISPATCH SETTINGS · TRUST & PERMISSIONS' => strings.message132,
      'ACTIVE CHAPTERS' => strings.message133,
      'Candid Moments' => strings.message134,
      'QUIET CARTOGRAPHY' => strings.message135,
      'TASTE' => strings.message136,
      'ACOUSTIC PREFERENCE' => strings.message137,
      'ATMOSPHERE & ARCHETYPE' => strings.message138,
      'Decibel mood' => strings.message139,
      'STEP 2 OF 3 · TASTE RADAR CALIBRATION' => strings.message140,
      'FIELD ADVISORY' => strings.message141,
      'FIELD TESTED' => strings.message142,
      'From the Circle' => strings.message143,
      'SOUND DECIBELS' => strings.message144,
      'Acoustic Architecture' => strings.message145,
      'An audio recording is not available for this place yet.' =>
        strings.message146,
      'View All 18' => strings.message147,
      'It will no longer sign in to Corner. You can still use email. Remove its saved copy from your credential manager separately.' =>
        strings.message148,
      'Zero Paid Ads & Noise' => strings.message149,
      'Places cataloged and reviewed only by real friends—never sponsored, never boosted.' =>
        strings.message150,
      'Vibe & Acoustic First' => strings.message151,
      'Find spaces for conversations, warm light, and a pace that feels like yours.' =>
        strings.message152,
      'Privacy by Design' => strings.message153,
      'You choose who can see your places and your circle.' =>
        strings.message154,
      'Friends Only' => strings.message155,
      'Open Now' => strings.message156,
      'Coffee & Wine' => strings.message157,
      'CORNERS' => strings.message158,
      'FOLLOWERS' => strings.message159,
      'FOLLOWING' => strings.message160,
      'Quiet date spot with vinyl' => strings.message161,
      'Orange wine by the carafe' => strings.message162,
      'Sunlit cafe for reading' => strings.message163,
      'e.g. Rainy afternoon espresso bar with wooden booths...' =>
        strings.message164,
      'Spot name (e.g. Eavesdrop, Four Horsemen)' => strings.message165,
      'Write with restraint. What lingered after you left?' =>
        strings.message166,
      'My phone or laptop' => strings.message167,
      'Rename passkey' => strings.message168,
      'Remove passkey' => strings.message169,
      'Sign out' => strings.message170,
      'Remove from circle' => strings.message171,
      'Copy place link' => strings.message172,
      'Carto Editorial' => strings.message173,
      _ => null,
    };
    if (translated != null) return translated;
    final emailMatch = RegExp(
      r'^Check (.+) for a one-time code\. It expires in five minutes\.$',
    ).firstMatch(source);
    if (emailMatch != null) {
      final email = emailMatch.group(1)!;
      return locale.countryCode == 'TW'
          ? '請查收 $email 的一次性驗證碼，有效期限為五分鐘。'
          : '请查收 $email 的一次性验证码，有效期为五分钟。';
    }
    final placesMatch = RegExp(r'^(\d+) places$').firstMatch(source);
    if (placesMatch != null) return '${placesMatch.group(1)} 个地点';
    return source;
  }
}
