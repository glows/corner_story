import { Hono } from 'hono';
import { Env, Variables } from '../types';

export const mediaRoutes = new Hono<{ Bindings: Env; Variables: Variables }>();

/**
 * PUT /api/v1/media/:key
 * Uploads film photography directly to Cloudflare R2 (Zero-Egress Object Storage)
 */
mediaRoutes.put('/:key', async (c) => {
  if (!c.env.MEDIA_BUCKET) {
    return c.json({ error: 'R2 MEDIA_BUCKET binding not configured' }, 501);
  }
  const key = c.req.param('key');
  const contentType = c.req.header('content-type') || 'image/jpeg';
  const body = await c.req.arrayBuffer();

  await c.env.MEDIA_BUCKET.put(key, body, {
    httpMetadata: { contentType },
  });

  return c.json({
    key,
    url: `/api/v1/media/${encodeURIComponent(key)}`,
    size: body.byteLength,
  });
});

/**
 * GET /api/v1/media/:key
 * Streams film photography from Cloudflare R2 with aggressive Edge Cache-Control headers
 */
mediaRoutes.get('/:key', async (c) => {
  if (!c.env.MEDIA_BUCKET) {
    return c.json({ error: 'R2 MEDIA_BUCKET binding not configured' }, 501);
  }
  const key = c.req.param('key');
  const object = await c.env.MEDIA_BUCKET.get(key);

  if (!object) {
    return c.json({ error: 'Media asset not found' }, 404);
  }

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('etag', object.httpEtag);
  headers.set('cache-control', 'public, max-age=31536000, immutable');

  return new Response(object.body, { headers });
});
