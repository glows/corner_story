CREATE TABLE IF NOT EXISTS privacy_settings (
  user_id TEXT PRIMARY KEY,
  map_scope TEXT NOT NULL DEFAULT 'inner' CHECK(map_scope IN ('inner', 'radar', 'ghost')),
  ghost_saves INTEGER NOT NULL DEFAULT 1,
  hide_visits INTEGER NOT NULL DEFAULT 1,
  fuzzy_geo INTEGER NOT NULL DEFAULT 0,
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);
