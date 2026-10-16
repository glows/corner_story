-- ============================================================================
-- Corner v2.0 — Initial Editorial Seed Data for Cloudflare D1
-- ============================================================================

INSERT INTO users (id, handle, display_name, role_label, avatar_url, bio, is_verified, taste_badge, corners_count, followers_count, following_count) VALUES
  ('usr_clara', 'claravance', 'Clara Vance', 'Curator • NYC & Kyoto', 'assets/images/img_20.jpg', 'Architect & slow coffee enthusiast. Curating hidden courtyards, subterranean soundbars, and natural cellars in NYC, Milan & Kyoto.', 1, 'Top 5%', 38, 1240, 148),
  ('usr_jake', 'jake_t', 'Jake Turner', 'TASTE LEADER • NYC', 'assets/images/img_28.jpg', 'Vinyl collector, acoustic designer & morning bakery regular in Greenpoint.', 1, 'Top 1%', 54, 2100, 190),
  ('usr_eliza', 'eliza', 'Eliza Vance', 'FRIEND IRL • SOHO', 'assets/images/img_31.jpg', 'Art director & skin-contact wine devotee.', 1, 'Top 5%', 29, 860, 112),
  ('usr_annie', 'annie_m', 'Annie', 'FRIEND IRL • BK', 'assets/images/img_15.jpg', 'Print editor & listening bar regular.', 0, 'Top 10%', 19, 420, 95),
  ('usr_sophie', 'sophie_k', 'Sophie', 'FRIEND IRL • LES', 'assets/images/img_18.jpg', 'Ceramics & morning espresso.', 0, 'Top 10%', 22, 310, 88);

INSERT INTO user_relations (user_id, target_user_id, relation_type) VALUES
  ('usr_clara', 'usr_jake', 'friend_irl'),
  ('usr_clara', 'usr_eliza', 'friend_irl'),
  ('usr_clara', 'usr_annie', 'friend_irl'),
  ('usr_clara', 'usr_sophie', 'friend_irl');

INSERT INTO dispatches (id, issue_label, title, summary, author_byline, read_time, cover_url, city) VALUES
  ('disp_12', 'VOL. 03 · ISSUE 12', 'Lower Manhattan Underground: Acoustically Pure Sanctuaries', 'An intimate chronicle of seven cellar spaces where sound fidelity precedes social buzz, natural pours flow without fanfare, and lighting never exceeds candle-flicker.', 'By Clara Chen & Studio Corner', '6 MIN READ', 'assets/images/img_03.jpg', 'New York');

INSERT INTO spots (id, name, city, neighborhood, address, price_tier, category, badge, rating, description, acoustic_note, hours_text, walk_info, cover_url, marker_url, social_proof_text, lat, lng, has_live_vibe) VALUES
  ('spot_obvio', 'Obvio Cocktail Bar', 'New York', 'NoMad', '3E 28th St, New York', '$$$', 'Natural Wine', 'HI-FI AUDIO', 4.9, 'Dimly lit listening bar, vinyl only, bespoke seasonal vermouths, 0 tourist crowds.', '68 dB · Custom Klipschorn & Japanese Jazz Vinyl', 'Open tonight · 6:00 PM – 2:00 AM', '10 min walk · NoMad', 'assets/images/img_04.jpg', 'assets/images/img_04.jpg', 'Saved by 277 tastemakers', 40.7443, -73.9866, 0),
  ('spot_lei', 'Lei', 'New York', 'Chinatown', '18 Doyers St, New York', '$$', 'Natural Wine', 'LOW INTERVENTION', 4.8, 'Lowkey natural wine & Taiwanese small plates, unpretentious elegance, orange wines by the carafe.', '74 dB · Warm Bistro Murmur & Clinking Stems', 'Open today · 5:30 PM – 11:30 PM', '6 min walk · Chinatown', 'assets/images/img_05.jpg', 'assets/images/img_05.jpg', 'Friends visited recently', 40.7145, -73.9980, 0),
  ('spot_celeste', 'Céleste Gallery & Cafe', 'New York', 'SoHo', '112 Mercer St, New York', '$$', 'Specialty Coffee', 'ART & ROAST', 4.9, 'Daylight sanctuary, ceremonial oat hojicha & indie art publications in a calm gallery space.', '56 dB · Diffused Daylight & Ambient Brian Eno', 'Open now · 8:00 AM – 6:00 PM', '5 min walk · Mercer St', 'assets/images/img_06.jpg', 'assets/images/img_06.jpg', 'Quiet vibe right now', 40.7235, -73.9992, 1),
  ('spot_eavesdrop', 'Eavesdrop', 'New York', 'Nolita', '674 Manhattan Ave, Brooklyn', '$$$', 'Listening Lounge', 'LISTENING LOUNGE', 4.9, 'Intimate Japanese-inspired listening lounge with bespoke acoustics and seasonal cocktails.', '69 dB · Slatted Timber & Custom Tube Amp', 'Open tonight · 5:00 PM – 1:00 AM', '8 min walk · Greenpoint Ave', 'assets/images/img_14.jpg', 'assets/images/img_07.jpg', 'Saved by Annie & Jake', 40.7232, -73.9818, 1),
  ('spot_dimes', 'Dimes Deli', 'New York', 'Chinatown', '143 Division St, New York', '$$', 'Café & Provisions', 'CAFÉ & PROVISIONS', 4.8, 'Sunny neighborhood café & provisions on Division St. Sophie’s go-to morning spot.', '64 dB · Morning Espresso & Vinyl', 'Open now · 8:00 AM – 5:00 PM', '4 min walk · 143 Division St', 'assets/images/img_17.jpg', 'assets/images/img_10.jpg', 'Sophie''s go-to morning spot', 40.7149, -73.9915, 0),
  ('spot_abraco', 'Abraço Espresso', 'New York', 'East Village', '81 E 7th St, New York', '$', 'Standing Coffee', 'STANDING COFFEE', 4.8, 'Authentic standing espresso counter bar with olive oil cake and vinyl energy.', '71 dB · Upbeat Vinyl & Brass Espresso Pulls', 'Open now · 8:00 AM – 6:00 PM', '12 min walk · 81 E 7th St', 'assets/images/img_19.jpg', 'assets/images/img_12.jpg', 'Trending in East Village', 40.7272, -73.9861, 0),
  ('spot_romans', 'Roman''s Wine Cellar', 'New York', 'Nolita', '243 DeKalb Ave, New York', '$$$', 'Natural Cellar', 'WINE CELLAR', 4.9, 'Neighborhood Italian & low-intervention bottle shop with warm candlelit tables.', '72 dB · Candlelit Cellar Warmth', 'Open today · 5:00 PM – 11:00 PM', '6 min walk · Mulberry St', 'assets/images/img_13.jpg', 'assets/images/img_13.jpg', 'Curated by Clara Vance', 40.7185, -73.9862, 0),
  ('spot_radio', 'Radio Bakery', 'New York', 'Greenpoint, BK', '135 India St, Brooklyn', '$$', 'Morning Ritual', 'BAKED DAILY', 4.9, 'Artisanal sourdough focaccia & Earl Grey morning pastries with quiet brick courtyard seating.', '62 dB · Tranquil Courtyard Breeze', 'Open now · 7:30 AM – 4:00 PM', '7 min walk · India St', 'assets/images/img_29.jpg', 'assets/images/img_29.jpg', 'Saved by Jake & 42 others', 40.7318, -73.9548, 1),
  ('spot_altro', 'Café Altro Paradiso', 'New York', 'Spring St, NYC', '234 Spring St, New York', '$$$', 'Natural Wine', 'GOLDEN HOUR', 4.9, 'High-end Italian aperitivo setting with skin-contact Malvasia in delicate stems at golden hour.', '70 dB · Conversational Bistro Elegance', 'Open today · 12:00 PM – 11:00 PM', '5 min walk · Spring St', 'assets/images/img_32.jpg', 'assets/images/img_32.jpg', 'Saved by Eliza & 19 others', 40.7255, -74.0048, 1);

INSERT INTO saved_spots (user_id, spot_id, save_type, endorsement_note) VALUES
  ('usr_annie', 'spot_eavesdrop', 'curated', 'Saved by Annie & Jake'),
  ('usr_jake', 'spot_eavesdrop', 'curated', 'Saved by Annie & Jake'),
  ('usr_sophie', 'spot_dimes', 'curated', 'Sophie''s go-to morning spot'),
  ('usr_clara', 'spot_obvio', 'curated', 'Best vinyl listening acoustics'),
  ('usr_clara', 'spot_eavesdrop', 'curated', 'Weekend listening lounge');

INSERT INTO field_notes (id, author_id, spot_id, scope, quote, photos_json, sensory_tags_json, agreed_count, cozy_count, saved_count) VALUES
  (
    'note_01',
    'usr_jake',
    'spot_radio',
    'Friends IRL',
    'The smoked salmon focaccia & Earl Grey pastry are genuinely worth the 15-minute queue. Go on a Thursday morning if you want quiet courtyard seating.',
    '[{"url":"assets/images/img_29.jpg","label":"8:45 AM"},{"url":"assets/images/img_30.jpg","label":"Courtyard"}]',
    '["Morning Ritual","12-18 min wait","Baked Daily"]',
    14,
    9,
    42
  ),
  (
    'note_02',
    'usr_eliza',
    'spot_altro',
    'Friends IRL',
    'Skip the tourist hype on TikTok; this corner table at golden hour is the single best aperitivo in the city. Ask for the unfiltered skin-contact Malvasia.',
    '[{"url":"assets/images/img_32.jpg","label":"TABLE 14 • GOLDEN HOUR","meta":"24 Natural Bottles"}]',
    '["Golden Hour","Conversational","Corner Favorite"]',
    11,
    28,
    19
  );

INSERT INTO collections (id, curator_id, tag, title, cover_url, rating, spots_count, cities_label, city_filter) VALUES
  ('col_01', 'usr_clara', 'ATMOSPHERES', 'Natural Wine & Vinyl', 'assets/images/img_21.jpg', 4.9, 12, 'KYOTO • NYC', 'nyc'),
  ('col_02', 'usr_clara', 'FOCUS SPACES', 'Sun-drenched Work Cafes', 'assets/images/img_22.jpg', NULL, 8, 'SOHO • BUSHWICK', 'nyc'),
  ('col_03', 'usr_clara', 'SOLITUDE', 'Secret Green Sanctuaries', 'assets/images/img_23.jpg', NULL, 6, 'BRERA • NAVIGLI', 'milan'),
  ('col_04', 'usr_clara', 'MIDNIGHT', 'Late Night Ramen & Jazz', 'assets/images/img_24.jpg', NULL, 9, 'LOWER EAST SIDE', 'nyc');

INSERT INTO candid_moments (id, user_id, title, subtitle, city_badge, photo_url, is_featured) VALUES
  ('mom_01', 'usr_clara', 'FONDAZIONE PRADA', 'Shadow study, 10:45 AM', 'Milan', 'assets/images/img_25.jpg', 1),
  ('mom_02', 'usr_clara', 'KYOTO TEAHOUSE', 'Morning ceremonial matcha', 'Kyoto', 'assets/images/img_26.jpg', 0),
  ('mom_03', 'usr_clara', 'DIMES SQUARE', 'Sourdough & chilled pet-nat', 'Dimes Sq', 'assets/images/img_27.jpg', 0);
