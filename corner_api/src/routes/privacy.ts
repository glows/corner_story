import { Hono } from 'hono';
import type { Env, Variables } from '../types';

export const privacyRoutes = new Hono<{ Bindings: Env; Variables: Variables }>();

privacyRoutes.get('/', async (c) => {
  const userId = c.get('userId');
  const settings = await c.env.DB.prepare(
    'SELECT map_scope, ghost_saves, hide_visits, fuzzy_geo FROM privacy_settings WHERE user_id = ?1'
  ).bind(userId).first();
  const circle = await c.env.DB.prepare(
    `SELECT u.id, u.display_name, u.avatar_url, u.taste_badge
     FROM user_relations r JOIN users u ON u.id = r.target_user_id
     WHERE r.user_id = ?1 AND r.relation_type = 'friend_irl' ORDER BY u.display_name`
  ).bind(userId).all();
  return c.json({
    settings: settings ?? { map_scope: 'inner', ghost_saves: 1, hide_visits: 1, fuzzy_geo: 0 },
    circle: circle.results,
  });
});

privacyRoutes.put('/', async (c) => {
  const body = await c.req.json<Record<string, unknown>>().catch(() => null);
  if (!body || !['inner', 'radar', 'ghost'].includes(String(body.map_scope)) ||
      !['ghost_saves', 'hide_visits', 'fuzzy_geo'].every((key) => typeof body[key] === 'boolean')) {
    return c.json({ error: 'Invalid privacy settings' }, 400);
  }
  const userId = c.get('userId');
  await c.env.DB.prepare(
    `INSERT INTO privacy_settings (user_id, map_scope, ghost_saves, hide_visits, fuzzy_geo, updated_at)
     VALUES (?1, ?2, ?3, ?4, ?5, unixepoch())
     ON CONFLICT(user_id) DO UPDATE SET map_scope=excluded.map_scope,
       ghost_saves=excluded.ghost_saves, hide_visits=excluded.hide_visits,
       fuzzy_geo=excluded.fuzzy_geo, updated_at=excluded.updated_at`
  ).bind(userId, body.map_scope, Number(body.ghost_saves), Number(body.hide_visits), Number(body.fuzzy_geo)).run();
  return c.json({ saved: true });
});

privacyRoutes.delete('/circle/:id', async (c) => {
  const result = await c.env.DB.prepare(
    `DELETE FROM user_relations WHERE user_id = ?1 AND target_user_id = ?2 AND relation_type = 'friend_irl'`
  ).bind(c.get('userId'), c.req.param('id')).run();
  return c.json({ removed: result.meta.changes > 0 });
});

privacyRoutes.get('/export', async (c) => {
  const userId = c.get('userId');
  const [identity, profile, settings, saved, notes, circle] = await Promise.all([
    c.env.DB.prepare('SELECT id, name, email, createdAt FROM "user" WHERE id = ?1').bind(userId).first(),
    c.env.DB.prepare('SELECT * FROM users WHERE id = ?1').bind(userId).first(),
    c.env.DB.prepare('SELECT * FROM privacy_settings WHERE user_id = ?1').bind(userId).first(),
    c.env.DB.prepare('SELECT * FROM saved_spots WHERE user_id = ?1').bind(userId).all(),
    c.env.DB.prepare('SELECT * FROM field_notes WHERE author_id = ?1').bind(userId).all(),
    c.env.DB.prepare('SELECT * FROM user_relations WHERE user_id = ?1').bind(userId).all(),
  ]);
  c.header('Content-Disposition', 'attachment; filename="corner-export.json"');
  return c.json({ exported_at: new Date().toISOString(), identity, profile, settings,
    saved_spots: saved.results, field_notes: notes.results, circle: circle.results });
});

privacyRoutes.delete('/account', async (c) => {
  const body = await c.req.json<Record<string, unknown>>().catch(() => null);
  if (body?.confirm !== 'DELETE MY CORNER') return c.json({ error: 'Confirmation required' }, 400);
  const id = c.get('userId');
  await c.env.DB.batch([
    c.env.DB.prepare('DELETE FROM privacy_settings WHERE user_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM saved_spots WHERE user_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM field_notes WHERE author_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM user_relations WHERE user_id = ?1 OR target_user_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM candid_moments WHERE user_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM collections WHERE curator_id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM users WHERE id = ?1').bind(id),
    c.env.DB.prepare('DELETE FROM "user" WHERE id = ?1').bind(id),
  ]);
  return c.json({ deleted: true });
});
