import { Hono } from 'hono';
import { Env, Variables } from '../types';

export const mapRoutes = new Hono<{ Bindings: Env; Variables: Variables }>();

/**
 * GET /api/v1/map/spots
 * Query params: city, minLat, maxLat, minLng, maxLng, friendsOnly, openNow
 * Returns: Geo-located spots in viewport + IRL friend avatars who saved each spot
 */
mapRoutes.get('/spots', async (c) => {
  const userId = c.get('userId');
  const city = c.req.query('city') || 'New York';
  const minLat = c.req.query('minLat');
  const maxLat = c.req.query('maxLat');
  const minLng = c.req.query('minLng');
  const maxLng = c.req.query('maxLng');
  const friendsOnly = c.req.query('friendsOnly') === 'true';

  let sql = `
    SELECT
      s.*, source.website_url, source.sources_json, source.verified_at,
      source.notes AS verification_notes,
      CASE WHEN my_save.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_saved,
      json_group_array(
        CASE
          WHEN u.id IS NOT NULL THEN json_object(
            'id', u.id,
            'handle', u.handle,
            'name', u.display_name,
            'avatar_url', u.avatar_url
          )
          ELSE NULL
        END
      ) AS raw_friend_endorsements
    FROM spots s
    JOIN spot_sources source ON source.spot_id = s.id
    LEFT JOIN saved_spots my_save
      ON my_save.spot_id = s.id AND my_save.user_id = ?1
    LEFT JOIN saved_spots friend_save
      ON friend_save.spot_id = s.id
    LEFT JOIN user_relations ur
      ON ur.user_id = ?1
      AND ur.target_user_id = friend_save.user_id
      AND ur.relation_type = 'friend_irl'
    LEFT JOIN privacy_settings privacy
      ON privacy.user_id = friend_save.user_id
    LEFT JOIN users u
      ON u.id = friend_save.user_id
      AND COALESCE(privacy.map_scope, 'inner') != 'ghost'
      AND COALESCE(privacy.ghost_saves, 0) = 0
      AND (ur.target_user_id IS NOT NULL OR privacy.map_scope = 'radar')
    WHERE s.city = ?2
  `;
  const params: unknown[] = [userId, city];

  if (minLat && maxLat && minLng && maxLng) {
    sql += ` AND s.lat BETWEEN ?3 AND ?4 AND s.lng BETWEEN ?5 AND ?6`;
    params.push(Number(minLat), Number(maxLat), Number(minLng), Number(maxLng));
  }

  sql += ` GROUP BY s.id`;

  if (friendsOnly) {
    sql += ` HAVING COUNT(u.id) > 0 OR my_save.user_id IS NOT NULL`;
  }

  sql += ` ORDER BY s.rating DESC LIMIT 30`;

  const { results } = await c.env.DB.prepare(sql).bind(...params).all();

  const spots = results.map((row: any) => {
    let friends: any[] = [];
    try {
      const parsed = JSON.parse(row.raw_friend_endorsements || '[]');
      friends = parsed.filter((item: any) => item !== null);
    } catch (_) {
      friends = [];
    }
    const { raw_friend_endorsements, ...rest } = row;
    return {
      ...rest,
      friend_endorsements: friends,
    };
  });

  return c.json({
    city,
    count: spots.length,
    spots,
  });
});
