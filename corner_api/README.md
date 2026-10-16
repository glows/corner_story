# Corner API — Cloudflare Serverless Edge Stack

**Corner (`curate & share places`)** 配套后端服务工程，基于 **Cloudflare Workers + Hono + D1 (SQLite) + R2 + KV + Vectorize + Workers AI** 构建。

---

## 1. 本地一键初始化与运行

```powershell
cd d:\内容故事\corner_api

# 1. 安装依赖
npm install

# 2. 初始化本地 D1 数据库表结构并写入 Corner v2.0 种子数据
npm run db:setup:local

# 3. 启动本地 Cloudflare Edge 模拟服务 (http://localhost:8787)
npm run dev
```

---

## 2. 生产环境部署至 Cloudflare

```powershell
# 1. 登录 Cloudflare 账号
npx wrangler login

# 2. 创建生产环境 D1 数据库、KV 命名空间、R2 存储桶与 Vectorize 索引
npx wrangler d1 create corner-prod-db
npx wrangler kv namespace create CACHE
npx wrangler r2 bucket create corner-editorial-media
npx wrangler vectorize create corner-spots-index --dimensions=768 --metric=cosine

# 3. 将输出的 database_id 与 kv id 填入 wrangler.toml 后，推送数据库结构与种子数据
npm run db:migrate:remote
npm run db:seed:remote

# 4. 一键发布全球边缘节点
npm run deploy
```

---

## 3. 已实现的接口列表

- `GET  /api/v1/health` — 边缘节点与 D1 索引健康检查
- `GET  /api/v1/explore/feed?city=New+York&category=For+You&q=` — Explore 特刊与策展地点流
- `POST /api/v1/explore/ask-ai` — **Ask Corner AI** 自然语言氛围检索（Workers AI + Vectorize / D1 双引擎）
- `GET  /api/v1/map/spots?city=New+York&friendsOnly=true` — 地图视野地点 + 熟人好友头像栈聚合
- `GET  /api/v1/vibes/feed?scope=Friends+IRL` — 去广告真实动态手记流
- `POST /api/v1/vibes/notes` — 发布新的探店手记（Field Note）
- `POST /api/v1/vibes/notes/:id/react` — 手记互动（`agreed` / `cozy` / `saved`）
- `GET  /api/v1/profile/:handle?city=all` — 品味策展人主页、2x2 主题合辑与纪实摄影流
- `POST /api/v1/profile/bookmarks/:spotId` — 收藏/取消收藏地点
- `PUT  /api/v1/media/:key` & `GET /api/v1/media/:key` — R2 胶片原图直传与 CDN 缓存读取
