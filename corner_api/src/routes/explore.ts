import { Hono } from 'hono';
import { Env, Variables } from '../types';

export const exploreRoutes = new Hono<{ Bindings: Env; Variables: Variables }>();

/**
 * GET /api/v1/explore/feed
 * Query params: city, category, q
 * Returns: Curated Dispatch hero issue + filtered Curated Spot cards
 */
exploreRoutes.get('/feed', async (c) => {
  const userId = c.get('userId');
  const city = c.req.query('city') || 'New York';
  const category = c.req.query('category') || 'For You';
  const q = (c.req.query('q') || '').trim();

  // 1. Fetch latest Curated Dispatch issue (with optional KV cache)
  let dispatch = null;
  if (c.env.CACHE) {
    const cached = await c.env.CACHE.get(`dispatch:${city}`, 'json');
    if (cached) dispatch = cached;
  }
  if (!dispatch) {
    dispatch = await c.env.DB.prepare(
      'SELECT * FROM dispatches WHERE city = ?1 ORDER BY created_at DESC LIMIT 1'
    )
      .bind(city)
      .first();
    if (dispatch && c.env.CACHE) {
      await c.env.CACHE.put(`dispatch:${city}`, JSON.stringify(dispatch), {
        expirationTtl: 600,
      });
    }
  }

  // 2. Fetch Curated Spots with user bookmark status
  let sql = `
    SELECT s.*,
      CASE WHEN ss.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_saved
    FROM spots s
    LEFT JOIN saved_spots ss ON ss.spot_id = s.id AND ss.user_id = ?1
    WHERE s.city = ?2
  `;
  const params: unknown[] = [userId, city];

  if (category !== 'For You') {
    sql += ` AND s.category = ?${params.length + 1}`;
    params.push(category);
  }

  if (q.length > 0) {
    sql += ` AND (s.name LIKE ?${params.length + 1} OR s.description LIKE ?${params.length + 1} OR s.badge LIKE ?${params.length + 1})`;
    params.push(`%${q}%`);
  }

  sql += ' ORDER BY s.rating DESC LIMIT 20';

  const { results: spots } = await c.env.DB.prepare(sql).bind(...params).all();

  return c.json({
    dispatch,
    spots,
    meta: { city, category, count: spots.length },
  });
});

/**
 * POST /api/v1/explore/ask-ai
 * Body: { prompt: string, city?: string }
 * Uses Cloudflare Workers AI (@cf/baai/bge-base-en-v1.5) + Vectorize in production,
 * with automatic D1 full-text & acoustic fallback in local mode.
 */
exploreRoutes.post('/ask-ai', async (c) => {
  const body = await c.req.json<{ prompt?: string; city?: string }>();
  const prompt = (body.prompt || '').trim();
  const city = body.city || 'New York';

  if (!prompt) {
    return c.json({ error: 'Prompt is required' }, 400);
  }

  // Path A: Cloudflare Workers AI + Vectorize Semantic Search (when bound)
  if (c.env.AI && c.env.SPOT_VECTORS) {
    try {
      const embeddingResponse = await c.env.AI.run(
        '@cf/baai/bge-base-en-v1.5',
        { text: [prompt] }
      );
      const vector: number[] = embeddingResponse.data[0];
      const vectorMatches = await c.env.SPOT_VECTORS.query(vector, {
        topK: 5,
        returnMetadata: true,
      });

      const ids = vectorMatches.matches.map((m) => m.id);
      if (ids.length > 0) {
        const placeholders = ids.map(() => '?').join(',');
        const { results } = await c.env.DB.prepare(
          `SELECT * FROM spots WHERE id IN (${placeholders})`
        )
          .bind(...ids)
          .all();
        return c.json({
          engine: 'workers-ai-vectorize',
          prompt,
          spots: results,
        });
      }
    } catch (_) {
      // Fallback to D1 semantic keyword matching below
    }
  }

  // Path B: Local D1 Smart Keyword & Acoustic Vibe Matching
  const keywords = prompt
    .toLowerCase()
    .split(/\s+/)
    .filter((w) => w.length >= 3);

  let sql = 'SELECT * FROM spots WHERE city = ?1';
  const params: unknown[] = [city];

  if (keywords.length > 0) {
    const clauses = keywords.map((_, idx) => {
      const pIdx = idx + 2;
      return `(LOWER(name) LIKE ?${pIdx} OR LOWER(description) LIKE ?${pIdx} OR LOWER(acoustic_note) LIKE ?${pIdx} OR LOWER(badge) LIKE ?${pIdx})`;
    });
    sql += ` AND (${clauses.join(' OR ')})`;
    keywords.forEach((kw) => params.push(`%${kw}%`));
  }

  sql += ' ORDER BY rating DESC LIMIT 5';
  const { results } = await c.env.DB.prepare(sql).bind(...params).all();

  return c.json({
    engine: 'd1-acoustic-vibe-matcher',
    prompt,
    spots: results,
  });
});
