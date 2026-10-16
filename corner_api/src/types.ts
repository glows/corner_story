export interface Env {
  ANDROID_SHA256_CERT_FINGERPRINTS?: string;
  ASSETS?: Fetcher;
  DB: D1Database;
  BETTER_AUTH_SECRET?: string;
  BETTER_AUTH_URL?: string;
  AUTH_TRUSTED_ORIGINS?: string;
  RESEND_API_KEY?: string;
  AUTH_EMAIL_FROM?: string;
  GOOGLE_WEB_CLIENT_ID?: string;
  GOOGLE_IOS_CLIENT_ID?: string;
  GOOGLE_ANDROID_CLIENT_ID?: string;
  GOOGLE_CLIENT_SECRET?: string;
  CACHE?: KVNamespace;
  MEDIA_BUCKET?: R2Bucket;
  SPOT_VECTORS?: VectorizeIndex;
  AI?: {
    run: (model: string, input: Record<string, unknown>) => Promise<any>;
  };
}

export type Variables = {
  userId: string;
};
