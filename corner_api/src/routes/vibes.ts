import { Hono } from 'hono';
import { Env, Variables } from '../types';

export const vibesRoutes = new Hono<{ Bindings: Env; Variables: Variables }>();

/**
 * GET /api/v1/vibes/feed
 * Query params: scope ('Friends IRL' | 'Taste Radar' | 'Following' | 'Wine & Cellars')
 */
vibesRoutes.get('/feed', async (c) => {
  const scope = c.req.query('scope') || 'Friends IRL';

  let sql = `
    SELECT
      fn.id,
      fn.scope,
      fn.quote,
      fn.photos_json,
      fn.sensory_tags_json,
      fn.agreed_count,
      fn.cozy_count,
      fn.saved_count,
      fn.created_at,
      u.id AS author_id,
      u.handle AS author_handle,
      u.display_name AS author_name,
      u.role_label AS author_role,
      u.avatar_url AS author_avatar,
      s.id AS spot_id,
      s.name AS spot_name,
      s.neighborhood AS spot_neighborhood,
      s.price_tier AS spot_price
    FROM field_notes fn
    JOIN users u ON u.id = fn.author_id
    JOIN spots s ON s.id = fn.spot_id
  `;
  const params: unknown[] = [];

  if (scope === 'Wine & Cellars') {
    sql += ` WHERE s.category IN ('Natural Wine', 'Natural Cellar')`;
  }

  sql += ` ORDER BY fn.created_at DESC LIMIT 25`;

  const { results } = await c.env.DB.prepare(sql).bind(...params).all();

  const notes = results.map((row: any) => ({
    ...row,
    photos: JSON.parse(row.photos_json || '[]'),
    sensory_tags: JSON.parse(row.sensory_tags_json || '[]'),
  }));

  return c.json({
    dispatch_label: 'DISPATCH NO. 04 • FIELD NOTES',
    zero_sponsored: true,
    scope,
    notes,
  });
});

/**
 * POST /api/v1/vibes/notes
 * Body: { spot_name: string, quote: string, sensory_tags?: string[], photos?: {url: string, label: string}[] }
 */
vibesRoutes.post('/notes', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json<{
    spot_id?: string;
    spot_name?: string;
    quote: string;
    sensory_tags?: string[];
    photos?: Array<{ url: string; label?: string }>;
  }>();

  if (!body.quote || body.quote.trim().length === 0) {
    return c.json({ error: 'Quote is required' }, 400);
  }

  let spotId = body.spot_id || 'spot_radio';
  if (!body.spot_id && body.spot_name) {
    const foundSpot = await c.env.DB.prepare(
      'SELECT id FROM spots WHERE LOWER(name) LIKE ?1 LIMIT 1'
    )
      .bind(`%${body.spot_name.toLowerCase()}%`)
      .first<{ id: string }>();
    if (foundSpot) {
      spotId = foundSpot.id;
    }
  }

  const noteId = `note_${Date.now()}`;
  const photosJson = JSON.stringify(body.photos || []);
  const tagsJson = JSON.stringify(
    body.sensory_tags || ['Field Note', 'Zero Sponsored']
  );

  await c.env.DB.prepare(
    `INSERT INTO field_notes (id, author_id, spot_id, scope, quote, photos_json, sensory_tags_json)
     VALUES (?1, ?2, ?3, 'Friends IRL', ?4, ?5, ?6)`
  )
    .bind(noteId, userId, spotId, body.quote.trim(), photosJson, tagsJson)
    .run();

  return c.json({
    id: noteId,
    status: 'published',
  }, 201);
});

/**
 * POST /api/v1/vibes/notes/:id/react
 * Body: { type: 'agreed' | 'cozy' | 'saved', delta?: 1 | -1 }
 */
vibesRoutes.post('/notes/:id/react', async (c) => {
  const noteId = c.req.param('id');
  const body = await c.req.json<{
    type: 'agreed' | 'cozy' | 'saved';
    delta?: number;
  }>();
  const delta = body.delta === -1 ? -1 : 1;

  const columnMap: Record<string, string> = {
    agreed: 'agreed_count',
    cozy: 'cozy_count',
    saved: 'saved_count',
  };
  const col = columnMap[body.type];
  if (!col) {
    return c.json({ error: 'Invalid reaction type' }, 400);
  }

  await c.env.DB.prepare(
    `UPDATE field_notes SET ${col} = MAX(0, ${col} + ?1) WHERE id = ?2`
  )
    .bind(delta, noteId)
    .run();

  const updated = await c.env.DB.prepare(
    'SELECT id, agreed_count, cozy_count, saved_count FROM field_notes WHERE id = ?1'
  )
    .bind(noteId)
    .first();

  return c.json({ note: updated });
});
