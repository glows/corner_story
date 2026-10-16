import { Hono } from 'hono';
import { Env, Variables } from '../types';

export const profileRoutes = new Hono<{
  Bindings: Env;
  Variables: Variables;
}>();

/**
 * GET /api/v1/profile/:handle
 * Returns: Tastemaker identity, metrics, active chapters, collections 2x2 grid, and candid moments
 */
profileRoutes.get('/:handle', async (c) => {
  const handle = c.req.param('handle').replace(/^@/, '');
  const cityFilter = c.req.query('city') || 'all';

  const user = await c.env.DB.prepare(
    'SELECT * FROM users WHERE handle = ?1 LIMIT 1'
  )
    .bind(handle)
    .first<any>();

  if (!user) {
    return c.json({ error: 'Tastemaker not found' }, 404);
  }

  let colSql = 'SELECT * FROM collections WHERE curator_id = ?1';
  const colParams: unknown[] = [user.id];
  if (cityFilter !== 'all') {
    colSql += ' AND city_filter = ?2';
    colParams.push(cityFilter);
  }

  const [{ results: collections }, { results: moments }] = await Promise.all([
    c.env.DB.prepare(colSql).bind(...colParams).all(),
    c.env.DB.prepare(
      'SELECT * FROM candid_moments WHERE user_id = ?1 ORDER BY is_featured DESC'
    )
      .bind(user.id)
      .all(),
  ]);

  return c.json({
    user,
    chapters: [
      { key: 'all', label: 'All (86)', count: 86 },
      { key: 'nyc', label: 'New York (52)', count: 52 },
      { key: 'kyoto', label: 'Kyoto (21)', count: 21 },
      { key: 'milan', label: 'Milan (13)', count: 13 },
    ],
    collections,
    candid_moments: moments,
  });
});

/**
 * POST /api/v1/profile/bookmarks/:spotId
 * Toggles saving a spot to the user's Corner
 */
profileRoutes.post('/bookmarks/:spotId', async (c) => {
  const userId = c.get('userId');
  const spotId = c.req.param('spotId');

  const existing = await c.env.DB.prepare(
    'SELECT * FROM saved_spots WHERE user_id = ?1 AND spot_id = ?2'
  )
    .bind(userId, spotId)
    .first();

  if (existing) {
    await c.env.DB.prepare(
      'DELETE FROM saved_spots WHERE user_id = ?1 AND spot_id = ?2'
    )
      .bind(userId, spotId)
      .run();
    return c.json({ spot_id: spotId, saved: false });
  } else {
    await c.env.DB.prepare(
      'INSERT INTO saved_spots (user_id, spot_id, save_type) VALUES (?1, ?2, ?3)'
    )
      .bind(userId, spotId, 'curated')
      .run();
    return c.json({ spot_id: spotId, saved: true });
  }
});
