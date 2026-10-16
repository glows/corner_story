# Corner passkeys — Web and Android

## Access

- Secure Web app: https://corner-api.flymind.org/app/
- RP ID: `corner-api.flymind.org`. A credential is bound to this domain; do not silently change it.
- Local Web previews can use email login. Use the secure Web URL for production passkeys.
- Sign in with email first, then open **SAVED → Privacy → Passkeys & device verification** to add a passkey.
- The login screen accepts an existing passkey. The management screen lists, renames and removes keys belonging to the authenticated account.
- Removing a server record does not remove the device/password-manager copy.

## Protocol and security

Uses Better Auth 1.7.10 and its official `@better-auth/passkey` plugin, with the Flutter `passkeys` platform client. Registration requires a fresh authenticated session. Private keys and biometrics remain with the device/credential provider.

Signed, expiring, single-use challenge cookies must return with verification. Web uses browser-owned HttpOnly cookies on the same HTTPS origin. Native requests preserve only the challenge cookie for that ceremony and send the trusted API Origin header required by Better Auth's CSRF checks. The signed Android client-data origin is independently checked against configured signing certificates.

Both registration and authentication require the signed user-verification flag. The plugin's verification hooks enforce this in addition to requesting verification from the device. A local biometric success alone cannot create a login session. Sessions use the existing bearer token and secure storage.

## Android deployment

`/.well-known/assetlinks.json` grants credential association to `com.example.corner_story` and the SHA-256 certificates in `ANDROID_SHA256_CERT_FINGERPRINTS` (comma-separated). The configured fingerprint was checked against the installed debug APK. Add the actual release/Play signing certificate when release signing changes.

The connected Android 12 phone currently has Google Play services **22.02.21 / 220221045**. On 2026-10-16, a real registration attempt failed before the system verification prompt with:

```
Google Play services out of date ... Requires 230815045 but found 220221045
TYPE_CREATE_CREDENTIAL_PROVIDER_CONFIGURATION_EXCEPTION
```

The APK contains the Credential Manager Play Services dependency and provider metadata. The phone must update Google Play services, have a Google account and screen lock before real registration can be retested. Do not treat protocol tests as successful device biometric verification.

## Build and deploy

1. `flutter build web --base-href /app/`
2. Execute `migrations/0008_passkeys.sql` with Wrangler D1 (local or remote). It adds a table and index without resetting existing data.
3. `npm run deploy` in `corner_api`. Wrangler packages the built Flutter Web assets; the Worker serves them under `/app/`.
4. Build/install the Android APK with the certificate configured above.

WebAuthn bridge `corner_story/web/passkeys.js` is vendored from the plugin's documented release: https://github.com/corbado/flutter-passkeys/releases/download/2.4.0/bundle.js

## Verification

- `node --test test/passkey.test.cjs test/verified_places.test.cjs test/vibes.test.cjs`
- `npm run typecheck`
- `flutter test test/passkeys_test.dart test/new_page_flows_test.dart --concurrency=1`
- `dart analyze lib test`

Backend tests use an isolated in-memory database and real cryptographic WebAuthn signatures. They cover Web/Android origins, session restoration, signed device verification and replay rejection. They never seed credentials or sessions into the running application.
