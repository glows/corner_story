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
      s.*,
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
    LEFT JOIN saved_spots my_save
      ON my_save.spot_id = s.id AND my_save.user_id = ?1
    LEFT JOIN saved_spots friend_save
      ON friend_save.spot_id = s.id
    LEFT JOIN user_relations ur
      ON ur.user_id = ?1
      AND ur.target_user_id = friend_save.user_id
      AND ur.relation_type = 'friend_irl'
    LEFT JOIN users u
      ON u.id = ur.target_user_id
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
