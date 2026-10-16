const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');
const ts = require('typescript');
const { Hono } = require('hono');

require.extensions['.ts'] = (module, filename) => module._compile(ts.transpileModule(
  fs.readFileSync(filename, 'utf8'), { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 } },
).outputText, filename);
const { exploreRoutes } = require('../src/routes/explore.ts');
const { mapRoutes } = require('../src/routes/map.ts');

function fixture() {
  const sqlite = new DatabaseSync(':memory:');
  const migration = name => sqlite.exec(fs.readFileSync(path.join(__dirname, '../migrations', name), 'utf8'));
  for (const name of ['0001_schema.sql', '0002_seed.sql', '0004_privacy.sql']) migration(name);
  const savedBefore = sqlite.prepare('SELECT COUNT(*) AS count FROM saved_spots').get().count;
  const notesBefore = sqlite.prepare('SELECT COUNT(*) AS count FROM field_notes').get().count;
  migration('0005_verified_nyc_places.sql');
  migration('0005_verified_nyc_places.sql');
  migration('0006_nyc_place_photos.sql');
  migration('0006_nyc_place_photos.sql');
  migration('0007_r2_place_photos.sql');
  migration('0007_r2_place_photos.sql');
  migration('0009_photo_custom_domain.sql');
  migration('0009_photo_custom_domain.sql');
  const DB = { prepare(sql) {
    const statement = sqlite.prepare(sql); let values = [];
    return {
      bind(...args) { values = args; return this; },
      async all() { return { results: statement.all(...values) }; },
      async first() { return statement.get(...values) ?? null; },
      async run() { return statement.run(...values); },
    };
  } };
  const app = new Hono();
  app.use('*', async (c, next) => { c.set('userId', 'usr_clara'); await next(); });
  app.route('/explore', exploreRoutes); app.route('/map', mapRoutes);
  return { sqlite, savedBefore, notesBefore, request: url => app.request(url, undefined, { DB }) };
}

test('the NYC update can run twice without deleting existing saves or notes', t => {
  const { sqlite, savedBefore, notesBefore } = fixture(); t.after(() => sqlite.close());
  assert.equal(sqlite.prepare('SELECT COUNT(*) AS count FROM spot_sources').get().count, 12);
  assert.equal(sqlite.prepare('SELECT COUNT(*) AS count FROM saved_spots').get().count, savedBefore);
  assert.equal(sqlite.prepare('SELECT COUNT(*) AS count FROM field_notes').get().count, notesBefore);
  const place = sqlite.prepare('SELECT neighborhood, lat, lng, rating FROM spots WHERE id = ?').get('spot_eavesdrop');
  assert.equal(place.neighborhood, 'Greenpoint, Brooklyn');
  assert.equal(place.lat, 40.724901); assert.equal(place.lng, -73.951187);
  assert.equal(place.rating, null);
});

test('Explore returns the sourced catalogue and can find a newly added cafe', async t => {
  const { sqlite, request } = fixture(); t.after(() => sqlite.close());
  const feed = await (await request('/explore/feed')).json();
  assert.equal(feed.spots.length, 12);
  assert.ok(feed.spots.every(place => place.website_url && place.verified_at && place.rating === null));
  assert.ok(feed.spots.every(place => place.cover_url.startsWith('https://') && place.marker_url === place.cover_url));
  assert.ok(feed.spots.every(place => place.cover_url.startsWith('https://corner-api.flymind.org/api/v1/media/nyc_')));
  assert.ok(!feed.spots.some(place => place.id === 'spot_celeste'));
  const search = await (await request('/explore/feed?category=Specialty%20Coffee&q=SEY')).json();
  assert.deepEqual(search.spots.map(place => place.id), ['spot_sey']);
});

test('Map returns the same sourced places with real coordinates and no invented live activity', async t => {
  const { sqlite, request } = fixture(); t.after(() => sqlite.close());
  const feed = await (await request('/map/spots?city=New%20York&friendsOnly=false')).json();
  assert.equal(feed.spots.length, 12);
  assert.ok(feed.spots.every(place => place.has_live_vibe === 0));
  const romans = feed.spots.find(place => place.id === 'spot_romans');
  assert.equal(romans.neighborhood, 'Fort Greene, Brooklyn');
  assert.equal(romans.lat, 40.68967);
});
