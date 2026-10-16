import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { Env, Variables } from './types';
import { exploreRoutes } from './routes/explore';
import { mapRoutes } from './routes/map';
import { vibesRoutes } from './routes/vibes';
import { profileRoutes } from './routes/profile';
import { mediaRoutes } from './routes/media';

const app = new Hono<{ Bindings: Env; Variables: Variables }>();

// 1. Global Edge Middleware (CORS + Logger + Auth Context)
app.use('*', logger());
app.use(
  '/api/*',
  cors({
    origin: '*',
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-Corner-User-Id'],
  })
);

app.use('/api/*', async (c, next) => {
  const userId = c.req.header('X-Corner-User-Id') || 'usr_clara';
  c.set('userId', userId);
  await next();
});

// 2. Root & Health Check
app.get('/', (c) =>
  c.json({
    service: 'Corner Edge API (Warm Editorial Sanctuary v2.0)',
    stack: ['Cloudflare Workers', 'Hono', 'D1 SQLite', 'R2', 'Vectorize', 'Workers AI'],
    status: 'ok',
    endpoints: [
      'GET  /api/v1/health',
      'GET  /api/v1/explore/feed',
      'POST /api/v1/explore/ask-ai',
      'GET  /api/v1/map/spots',
      'GET  /api/v1/vibes/feed',
      'POST /api/v1/vibes/notes',
      'POST /api/v1/vibes/notes/:id/react',
      'GET  /api/v1/profile/:handle',
      'POST /api/v1/profile/bookmarks/:spotId',
      'PUT  /api/v1/media/:key',
    ],
  })
);

app.get('/api/v1/health', async (c) => {
  const spotCount = await c.env.DB.prepare(
    'SELECT COUNT(*) AS total FROM spots'
  ).first<{ total: number }>();

  return c.json({
    ok: true,
    edge_region: (c.req.raw as any)?.cf?.colo || 'LOCAL-EDGE',
    d1_spots_indexed: spotCount?.total ?? 0,
    timestamp: new Date().toISOString(),
  });
});

// 3. Mount Feature Routes
app.route('/api/v1/explore', exploreRoutes);
app.route('/api/v1/map', mapRoutes);
app.route('/api/v1/vibes', vibesRoutes);
app.route('/api/v1/profile', profileRoutes);
app.route('/api/v1/media', mediaRoutes);

export default app;
