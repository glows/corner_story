const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');
const ts = require('typescript');
const { Hono } = require('hono');

// Load the project's TS routes; use real SQLite for their D1 SQL boundary.
require.extensions['.ts'] = (module, filename) => {
  module._compile(ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText, filename);
};
const { vibesRoutes } = require('../src/routes/vibes.ts');

function fixture() {
  const sqlite = new DatabaseSync(':memory:');
  for (const file of ['0001_schema.sql', '0002_seed.sql']) {
    sqlite.exec(fs.readFileSync(path.join(__dirname, '../migrations', file), 'utf8'));
  }
  const DB = { prepare(sql) {
    const statement = sqlite.prepare(sql);
    let values = [];
    return {
      bind(...args) { values = args; return this; },
      async all() { return { results: statement.all(...values) }; },
      async first() { return statement.get(...values) ?? null; },
      async run() { return statement.run(...values); },
    };
  } };
  const app = new Hono();
  app.use('*', async (c, next) => { c.set('userId', c.req.header('X-Corner-User-Id') || 'usr_clara'); await next(); });
  app.route('/vibes', vibesRoutes);
  return { sqlite, request: (url, options) => app.request(url, options, { DB }) };
}

test('a private note keeps its audience and is hidden from another reader', async (t) => {
  const { sqlite, request } = fixture();
  t.after(() => sqlite.close());
  const response = await request('/vibes/notes', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ spot_name: 'Eavesdrop', quote: 'A quiet evening.', scope: 'Private Book', sensory_tags: ['Vinyl Only'] }),
  });
  assert.equal(response.status, 201);
  const { id } = await response.json();
  assert.equal(sqlite.prepare('SELECT scope FROM field_notes WHERE id = ?').get(id).scope, 'Private Book');
  const owner = await (await request('/vibes/feed')).json();
  assert.ok(owner.notes.some(note => note.id === id));
  const other = await (await request('/vibes/feed', { headers: { 'X-Corner-User-Id': 'usr_jake' } })).json();
  assert.ok(!other.notes.some(note => note.id === id));
});

test('an unknown place cannot silently publish as Radio Bakery', async (t) => {
  const { sqlite, request } = fixture();
  t.after(() => sqlite.close());
  const response = await request('/vibes/notes', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ spot_name: 'Unknown place', quote: 'A note.' }),
  });
  assert.equal(response.status, 404);
});

test('notes longer than the editor limit are rejected by the API', async (t) => {
  const { sqlite, request } = fixture();
  t.after(() => sqlite.close());
  const response = await request('/vibes/notes', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ spot_name: 'Radio Bakery', quote: 'a'.repeat(281) }),
  });
  assert.equal(response.status, 400);
});
