export interface Env {
  DB: D1Database;
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
