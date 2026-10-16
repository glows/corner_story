-- ============================================================================
-- Corner v2.0 (Warm Editorial Sanctuary) — Cloudflare D1 Database Schema
-- ============================================================================

DROP TABLE IF EXISTS candid_moments;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS field_notes;
DROP TABLE IF EXISTS saved_spots;
DROP TABLE IF EXISTS spots;
DROP TABLE IF EXISTS dispatches;
DROP TABLE IF EXISTS user_relations;
DROP TABLE IF EXISTS users;

-- 1. Users & Tastemakers
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  handle TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  role_label TEXT NOT NULL DEFAULT 'Friend IRL • NYC',
  avatar_url TEXT NOT NULL,
  bio TEXT,
  is_verified INTEGER DEFAULT 0,
  taste_badge TEXT DEFAULT 'Top 5%',
  corners_count INTEGER DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  created_at INTEGER DEFAULT (unixepoch())
);

-- 2. IRL Social Graph (Friends IRL vs Following)
CREATE TABLE user_relations (
  user_id TEXT NOT NULL,
  target_user_id TEXT NOT NULL,
  relation_type TEXT NOT NULL, -- 'friend_irl' | 'following' | 'taste_radar'
  PRIMARY KEY (user_id, target_user_id)
);

-- 3. Editorial Dispatches (Magazine Issues)
CREATE TABLE dispatches (
  id TEXT PRIMARY KEY,
  issue_label TEXT NOT NULL,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  author_byline TEXT NOT NULL,
  read_time TEXT NOT NULL,
  cover_url TEXT NOT NULL,
  city TEXT NOT NULL,
  created_at INTEGER DEFAULT (unixepoch())
);

-- 4. Curated Spots (Explore & Map Pins)
CREATE TABLE spots (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  address TEXT NOT NULL,
  price_tier TEXT NOT NULL,
  category TEXT NOT NULL,
  badge TEXT NOT NULL,
  rating REAL DEFAULT 4.9,
  description TEXT NOT NULL,
  acoustic_note TEXT NOT NULL,
  hours_text TEXT NOT NULL,
  walk_info TEXT NOT NULL,
  cover_url TEXT NOT NULL,
  marker_url TEXT NOT NULL,
  social_proof_text TEXT NOT NULL,
  lat REAL NOT NULL,
  lng REAL NOT NULL,
  has_live_vibe INTEGER DEFAULT 0
);
CREATE INDEX idx_spots_city_geo ON spots(city, lat, lng);
CREATE INDEX idx_spots_category ON spots(category);

-- 5. Saved Spots & Friend Endorsements
CREATE TABLE saved_spots (
  user_id TEXT NOT NULL,
  spot_id TEXT NOT NULL,
  collection_id TEXT,
  save_type TEXT DEFAULT 'curated', -- 'curated' | 'want_to_try'
  endorsement_note TEXT,
  created_at INTEGER DEFAULT (unixepoch()),
  PRIMARY KEY (user_id, spot_id)
);
CREATE INDEX idx_saved_spots_spot ON saved_spots(spot_id);

-- 6. Vibes / Field Notes (Zero-Sponsored Community Reviews)
CREATE TABLE field_notes (
  id TEXT PRIMARY KEY,
  author_id TEXT NOT NULL,
  spot_id TEXT NOT NULL,
  scope TEXT DEFAULT 'Friends IRL',
  quote TEXT NOT NULL,
  photos_json TEXT NOT NULL,
  sensory_tags_json TEXT NOT NULL,
  agreed_count INTEGER DEFAULT 0,
  cozy_count INTEGER DEFAULT 0,
  saved_count INTEGER DEFAULT 0,
  created_at INTEGER DEFAULT (unixepoch())
);
CREATE INDEX idx_field_notes_created ON field_notes(created_at DESC);

-- 7. Curated Collections (Profile 2x2 Bento Grid)
CREATE TABLE collections (
  id TEXT PRIMARY KEY,
  curator_id TEXT NOT NULL,
  tag TEXT NOT NULL,
  title TEXT NOT NULL,
  cover_url TEXT NOT NULL,
  rating REAL,
  spots_count INTEGER DEFAULT 0,
  cities_label TEXT NOT NULL,
  city_filter TEXT DEFAULT 'all'
);

-- 8. Candid Moments (Profile Photographic Fragments)
CREATE TABLE candid_moments (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  city_badge TEXT NOT NULL,
  photo_url TEXT NOT NULL,
  is_featured INTEGER DEFAULT 0
);
