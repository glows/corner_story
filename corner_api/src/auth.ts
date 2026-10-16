import { betterAuth } from 'better-auth';
import { bearer, emailOTP } from 'better-auth/plugins';
import type { Env } from './types';
import { cornerPasskey, androidOrigins } from './passkeys';

export type EmailDelivery = { error?: string };

async function sendEmail(env: Env, email: string, code: string) {
  if (!env.RESEND_API_KEY || !env.AUTH_EMAIL_FROM) {
    throw new Error('Email delivery is not configured');
  }
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: env.AUTH_EMAIL_FROM,
      to: [email],
      subject: 'Your Corner access code',
      text: `Your Corner access code is ${code}. It expires in five minutes.`,
    }),
  });
  if (!response.ok) throw new Error('Email delivery failed');
}

export function createAuth(env: Env, delivery?: EmailDelivery) {
  if (!env.BETTER_AUTH_SECRET || !env.BETTER_AUTH_URL) {
    throw new Error('BETTER_AUTH_SECRET and BETTER_AUTH_URL are required');
  }
  const localOrigins = /^http:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/.test(env.BETTER_AUTH_URL)
    ? ['http://127.0.0.1:*', 'http://localhost:*']
    : [];
  return betterAuth({
    database: env.DB,
    secret: env.BETTER_AUTH_SECRET,
    baseURL: env.BETTER_AUTH_URL,
    trustedOrigins: [
      ...androidOrigins(env),
      ...localOrigins,
      ...(env.AUTH_TRUSTED_ORIGINS?.split(',').map((value) => value.trim()).filter(Boolean) ?? []),
    ],
    socialProviders: env.GOOGLE_WEB_CLIENT_ID && env.GOOGLE_CLIENT_SECRET ? {
      google: {
        clientId: [env.GOOGLE_WEB_CLIENT_ID, env.GOOGLE_IOS_CLIENT_ID,
          env.GOOGLE_ANDROID_CLIENT_ID].filter((value): value is string => Boolean(value)),
        clientSecret: env.GOOGLE_CLIENT_SECRET,
      },
    } : {},
    plugins: [
      cornerPasskey(env),
      bearer(),
      emailOTP({
        storeOTP: 'hashed',
        expiresIn: 300,
        allowedAttempts: 3,
        sendVerificationOTP: async ({ email, otp }) => {
          try {
            await sendEmail(env, email, otp);
          } catch (error) {
            delivery && (delivery.error = '邮件发送失败。请检查发件域名和 Resend 配置。');
            throw error;
          }
        },
      }),
    ],
  });
}
