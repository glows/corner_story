const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');
const ts = require('typescript');
const crypto = require('node:crypto');
const { encodeCBOR } = require('@levischuck/tiny-cbor');
require.extensions['.ts'] = (module, filename) => module._compile(ts.transpileModule(
  fs.readFileSync(filename, 'utf8'), { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 } },
).outputText, filename);
const { createAuth } = require('../src/auth.ts');
function fixture(t) {
  const db = new DatabaseSync(':memory:');
  t.after(() => db.close());
  db.exec(fs.readFileSync(path.join(__dirname, '../migrations/0003_better_auth.sql'), 'utf8'));
  const migration = path.join(__dirname, '../migrations/0008_passkeys.sql');
  if (fs.existsSync(migration)) { db.exec(fs.readFileSync(migration, 'utf8')); db.exec(fs.readFileSync(migration, 'utf8')); }
  const auth = createAuth({ DB: db, BETTER_AUTH_SECRET: 'qa-only-secret-at-least-thirty-two-characters-long',
    BETTER_AUTH_URL: 'https://corner-api.flymind.org',
    ANDROID_SHA256_CERT_FINGERPRINTS: '46:A5:2F:9C:24:91:3E:FA:3C:96:03:D9:5C:E3:AE:FE:6F:AC:D9:29:EA:B3:AE:F9:0A:F7:03:43:4F:F2:E6:3B' });
  return { db, auth, request: (endpoint, body, cookie, token) => auth.handler(new Request(
    'https://corner-api.flymind.org/api/auth/passkey/' + endpoint,
    { method: body ? 'POST' : 'GET', headers: { Origin: 'https://corner-api.flymind.org',
      ...(body ? { 'Content-Type': 'application/json' } : {}), ...(cookie ? { Cookie: cookie } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      ...(body ? { body: JSON.stringify(body) } : {}) })) };
}
test('an unauthenticated visitor cannot register a passkey', async t => {
  const f = fixture(t);
  assert.equal((await f.request('generate-register-options')).status, 401);
});

test('signed WebAuthn ceremonies register and log in, enforce device verification and reject replay', async t => {
  const f = fixture(t);
  const now = new Date().toISOString();
  // Isolated in-memory fixture only. No account or credential is inserted into a running app.
  f.db.prepare('INSERT INTO user(id,name,email,emailVerified,createdAt,updatedAt) VALUES(?,?,?,?,?,?)')
    .run('qa-user', 'QA passkeys', 'qa@example.invalid', 1, now, now);
  f.db.prepare('INSERT INTO session(id,token,userId,expiresAt,createdAt,updatedAt) VALUES(?,?,?,?,?,?)')
    .run('qa-session', 'qa-session-token', 'qa-user', new Date(Date.now() + 3600000).toISOString(), now, now);
  const cookieOf = response => response.headers.getSetCookie().map(value => value.split(';')[0]).join('; ');
  const options = await f.request('generate-register-options', null, null, 'qa-session-token');
  assert.equal(options.status, 200, await options.clone().text());
  const registration = await options.json();
  assert.equal(registration.authenticatorSelection.userVerification, 'required');
  const { privateKey, publicKey } = crypto.generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
  const jwk = publicKey.export({ format: 'jwk' });
  const credentialId = crypto.randomBytes(32);
  const id = credentialId.toString('base64url');
  const rpHash = crypto.createHash('sha256').update('corner-api.flymind.org').digest();
  const cose = encodeCBOR(new Map([[1, 2], [3, -7], [-1, 1], [-2, Buffer.from(jwk.x, 'base64url')], [-3, Buffer.from(jwk.y, 'base64url')]]));
  const length = Buffer.alloc(2); length.writeUInt16BE(credentialId.length);
  const clientData = (type, challenge, origin = 'https://corner-api.flymind.org') => Buffer.from(JSON.stringify({ type, challenge, origin }));
  const attestation = encodeCBOR(new Map([['fmt', 'none'], ['attStmt', new Map()], ['authData', Buffer.concat([
    rpHash, Buffer.from([0x45]), Buffer.alloc(4), Buffer.alloc(16), length, credentialId, cose,
  ])]]));
  const registered = await f.request('verify-registration', { name: 'QA device', response: {
    id, rawId: id, type: 'public-key', clientExtensionResults: {}, response: {
      clientDataJSON: clientData('webauthn.create', registration.challenge).toString('base64url'),
      attestationObject: Buffer.from(attestation).toString('base64url'), transports: ['internal'],
    },
  } }, cookieOf(options), 'qa-session-token');
  assert.equal(registered.status, 200, await registered.clone().text());
  const androidOrigin = 'android:apk-key-hash:' + Buffer.from('46a52f9c24913efa3c9603d95ce3aefe6facd929eab3aef90af703434ff2e63b', 'hex').toString('base64url');
  for (const [verified, expectedStatus, origin, counter] of [
    [true, 200, 'https://corner-api.flymind.org', 1],
    [false, 401, 'https://corner-api.flymind.org', 2],
    [true, 200, androidOrigin, 3],
    [true, 400, 'https://untrusted.example.invalid', 4],
  ]) {
    const start = await f.request('generate-authenticate-options');
    const challenge = (await start.json()).challenge;
    const data = clientData('webauthn.get', challenge, origin);
    const count = Buffer.alloc(4); count.writeUInt32BE(counter);
    const authData = Buffer.concat([rpHash, Buffer.from([verified ? 5 : 1]), count]);
    const signature = crypto.sign('sha256', Buffer.concat([authData, crypto.createHash('sha256').update(data).digest()]), privateKey);
    const assertion = { response: { id, rawId: id, type: 'public-key', clientExtensionResults: {}, response: {
      clientDataJSON: data.toString('base64url'), authenticatorData: authData.toString('base64url'), signature: signature.toString('base64url'),
    } } };
    const result = await f.request('verify-authentication', assertion, cookieOf(start));
    assert.equal(result.status, expectedStatus, await result.clone().text());
    if (expectedStatus === 200) {
      assert.ok(result.headers.get('set-auth-token'));
      const session = await f.auth.handler(new Request('https://corner-api.flymind.org/api/auth/get-session',
        { headers: { Authorization: `Bearer ${result.headers.get('set-auth-token')}` } }));
      assert.equal((await session.json()).user.id, 'qa-user');
    } else assert.equal(result.headers.get('set-auth-token'), null);
    assert.equal((await f.request('verify-authentication', assertion, cookieOf(start))).status, 400);
  }
});
test('passkey login issues a signed challenge and rejects an unknown credential without a session', async t => {
  const f = fixture(t);
  const options = await f.request('generate-authenticate-options');
  assert.equal(options.status, 200);
  const data = await options.json();
  assert.equal(data.rpId, 'corner-api.flymind.org');
  assert.ok(data.challenge.length >= 32);
  const cookie = options.headers.getSetCookie().map(value => value.split(';')[0]).join('; ');
  assert.ok(cookie.includes('passkey'));
  const invalid = await f.request('verify-authentication', { response: { id: 'unregistered-credential' } }, cookie);
  assert.equal(invalid.status, 401);
  assert.equal(f.db.prepare('SELECT COUNT(*) AS n FROM session').get().n, 0);
  const replay = await f.request('verify-authentication', { response: { id: 'unregistered-credential' } }, cookie);
  assert.equal(replay.status, 400);
});
