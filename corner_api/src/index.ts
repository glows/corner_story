import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { Env, Variables } from './types';
import { exploreRoutes } from './routes/explore';
import { mapRoutes } from './routes/map';
import { vibesRoutes } from './routes/vibes';
import { profileRoutes } from './routes/profile';
import { mediaRoutes } from './routes/media';
import { privacyRoutes } from './routes/privacy';
import { createAuth } from './auth';
import { androidFingerprints } from './passkeys';

const app = new Hono<{ Bindings: Env; Variables: Variables }>();

app.get('/.well-known/assetlinks.json', (c) => c.json([{
  relation: ['delegate_permission/common.get_login_creds'],
  target: { namespace: 'android_app', package_name: 'com.example.corner_story',
    sha256_cert_fingerprints: androidFingerprints(c.env) },
}]));
app.get('/app', (c) => c.redirect('/app/'));
app.get('/app/*', (c) => {
  if (!c.env.ASSETS) return c.text('Web app is unavailable.', 503);
  const url = new URL(c.req.url);
  url.pathname = url.pathname.slice(4) || '/';
  return c.env.ASSETS.fetch(new Request(url, c.req.raw));
});

// 1. Global Edge Middleware (CORS + Logger + Auth Context)
app.use('*', logger());
app.use(
  '/api/*',
  cors({
    origin: (origin, c) => {
      const allowed = c.env.AUTH_TRUSTED_ORIGINS?.split(',').map((value: string) => value.trim()) ?? [];
      return allowed.includes(origin) ? origin : '';
    },
    credentials: true,
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-Corner-User-Id'],
    exposeHeaders: ['set-auth-token'],
  })
);

app.post('/api/auth/email-otp/send-verification-otp', async (c) => {
  if (!c.env.RESEND_API_KEY || !c.env.AUTH_EMAIL_FROM) {
    return c.json({ error: 'Email sign-in is not configured on this server' }, 503);
  }
  const delivery: { error?: string } = {};
  const response = await createAuth(c.env, delivery).handler(c.req.raw);
  if (delivery.error) return c.json({ error: delivery.error }, 502);
  return response;
});
app.all('/api/auth/*', (c) => createAuth(c.env).handler(c.req.raw));

app.use('/api/v1/*', async (c, next) => {
  const session = await createAuth(c.env).api.getSession({ headers: c.req.raw.headers });
  const protectedPath = c.req.path.startsWith('/api/v1/privacy') ||
    (c.req.method !== 'GET' && (
      c.req.path.startsWith('/api/v1/profile/bookmarks') ||
      c.req.path.startsWith('/api/v1/vibes/notes') ||
      c.req.path.startsWith('/api/v1/media/')
    ));
  if (protectedPath && !session) return c.json({ error: 'Sign in required' }, 401);
  if (session) {
    c.set('userId', session.user.id);
    await c.env.DB.prepare(
      `INSERT OR IGNORE INTO users (id, handle, display_name, avatar_url)
       VALUES (?1, ?2, ?3, '')`
    ).bind(session.user.id, `member_${session.user.id.replace(/[^a-zA-Z0-9]/g, '').slice(0, 16)}`,
      session.user.name || 'Corner member').run();
  } else {
    // Public editorial previews still use seeded data.
    c.set('userId', 'usr_clara');
  }
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
app.route('/api/v1/privacy', privacyRoutes);

export default app;
