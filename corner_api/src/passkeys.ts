import { passkey } from '@better-auth/passkey';
import { APIError } from 'better-auth/api';
import type { Env } from './types';

export function androidFingerprints(env: Env): string[] {
  return (env.ANDROID_SHA256_CERT_FINGERPRINTS ?? '').split(',').map(value => value.trim()).filter(value =>
    /^(?:[A-Fa-f0-9]{2}:){31}[A-Fa-f0-9]{2}$/.test(value));
}

export function androidOrigins(env: Env): string[] {
  return androidFingerprints(env).map(value => {
    const bytes = value.split(':').map(part => parseInt(part, 16));
    return 'android:apk-key-hash:' + btoa(String.fromCharCode(...bytes)).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  });
}

export function cornerPasskey(env: Env) {
  const origin = new URL(env.BETTER_AUTH_URL!).origin;
  return passkey({
    rpID: new URL(origin).hostname,
    rpName: 'Corner',
    origin: [origin, ...androidOrigins(env)],
    authenticatorSelection: { residentKey: 'required', userVerification: 'required' },
    registration: {
      requireSession: true,
      afterVerification: ({ verification }) => {
        if (!verification.registrationInfo?.userVerified) throw new APIError('UNAUTHORIZED', { message: 'Device verification is required.' });
      },
    },
    authentication: {
      afterVerification: ({ verification }) => {
        if (!verification.authenticationInfo.userVerified) throw new APIError('UNAUTHORIZED', { message: 'Device verification is required.' });
      },
    },
  });
}
