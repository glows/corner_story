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
npm run db:auth:local
npm run db:privacy:local

# 3. 启动本地 Cloudflare Edge 模拟服务 (http://localhost:8787)
npm run dev
```

### 真实纽约地点数据

`data/nyc_places.json` 收录 12 个纽约地点，资料于 2026-10-16 核查。每条包含官网/资料来源、地址、当地营业时间及 NYC GeoSearch 地址点坐标。坐标不代表测量过的入口位置；未核实的评分、价格、声压值、步行时间、实时客流与地点照片均不编造。地点照片为空时前端显示明确的占位状态。

更新主数据后运行 `npm run data:nyc:build`，生成 Flutter 离线资源和 `0005_verified_nyc_places.sql`。现有本地库只需执行 `npm run db:places:local`；该增量操作可重复运行，保留收藏、手记和其他地点。远端迁移命令是 `npm run db:places:remote`，本次未部署远端。

Explore、地图和地点搜索只返回有核查来源的地点。旧设计示例保留在数据库中以维持历史收藏和手记关联，不混入这批检索结果。The Four Horsemen 的服务时间因来源冲突未录入确定值；Radio Bakery 的售罄情况、Paley Park 的假期/冬季时间及其他地点临时变动需以店家当天公告为准。

### Better Auth 邮箱登录

登录使用 Better Auth 的 Email OTP 和 Bearer 插件。先为本地开发创建被 Git 忽略的 `.dev.vars`，设置 `BETTER_AUTH_SECRET`（至少 32 位随机值）、`RESEND_API_KEY` 和 `AUTH_EMAIL_FROM`（已在 Resend 验证的发件地址）。生产环境通过 Wrangler secrets 设置 `BETTER_AUTH_SECRET`、`RESEND_API_KEY` 和 `AUTH_EMAIL_FROM`，并将 `BETTER_AUTH_URL` 改为生产 API 的 HTTPS 地址。邮件服务未配置时，验证码请求会失败，不会产生假登录。

Google 登录使用 Better Auth 的 Google social provider 和原生 Google ID Token。后端另需 `GOOGLE_WEB_CLIENT_ID`、`GOOGLE_CLIENT_SECRET`；iOS 和 Android 的 OAuth 客户端 ID 可分别配置为 `GOOGLE_IOS_CLIENT_ID` 和 `GOOGLE_ANDROID_CLIENT_ID`，以便接受各平台签发的 ID Token。这些 ID 必须属于同一个 Google Cloud 项目。Flutter 启动时传入 `--dart-define=CORNER_GOOGLE_WEB_CLIENT_ID=...`，iOS 还需 `--dart-define=CORNER_GOOGLE_IOS_CLIENT_ID=...`，并将 iOS OAuth 客户端的 `REVERSED_CLIENT_ID` 写入 `corner_story/ios/Flutter/GoogleSignIn.xcconfig`。Android 需在 Google Cloud 中登记实际应用包名与签名证书 SHA-1。未配置客户端 ID 时，按钮会显示配置错误，不会伪装登录成功。

对已有数据库按需运行 `db:auth:*`、`db:privacy:*` 和 `db:places:*` 新增迁移；`0001_schema.sql` 会重建旧表，不能用于升级现有数据。Flutter 默认连接 `https://corner-api.flymind.org`。本地开发可用 `--dart-define=CORNER_API_BASE_URL=http://127.0.0.1:8787` 指定本地 API；Android 模拟器应改为 `http://10.0.2.2:8787`。本地 Web 调试端口为 8080，若改变端口或部署 Web 前端，需同步更新 `AUTH_TRUSTED_ORIGINS` 并重新部署。

`/api/auth/*` 由 Better Auth 提供；`/api/v1/privacy` 保存可见范围与隐私开关、管理圈子、导出 JSON、删除账号。写操作使用 Bearer 会话验证，`X-Corner-User-Id` 不再授予写入权限。

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

# 3. 将输出的 database_id 与 kv id 填入 wrangler.toml。
# 以下初始化命令只用于全新的空数据库；已有数据只运行新增迁移。
npm run db:migrate:remote
npm run db:seed:remote
npm run db:auth:remote
npm run db:privacy:remote

# 4. 一键发布全球边缘节点
npm run deploy
```

---

## 3. 已实现的接口列表

纽约地点照片的原图、出处页、摄影署名及核对日期保存在 `data/nyc_places.json`。
照片压缩后的上传源文件保存在 `data/place_photos/`（共约 2.9 MB），不再随 Flutter 打包。应用统一通过线上 API 从 R2 `corner-editorial-media` 桶读取。
`node scripts/upload-place-photos.cjs` 上传并核对内容指纹；R2 键为 `nyc_<地点>_<SHA256前12位>.jpg`，支持长期不可变缓存。使用现有公开 GET 图片接口，不开放桶写权限。
`node scripts/build-nyc-places.cjs` 同步目录、线上图片映射和迁移；上传成功后，已有数据库执行 `migrations/0009_photo_custom_domain.sql`（仅更新图片字段）。原图地址保留在 `image_original_url`。图片统一通过 `https://corner-api.flymind.org/api/v1/media/` 读取；不要再写入手机网络不可达的 `workers.dev` 地址。首页封面跟随地点目录中的图片地址，避免将域名写死在页面里。
官网公开图片并不等同于开放许可证；商用发布前需确认图片使用授权。Roman’s 署名 Julia Gillard / The Infatuation，Abraço 来源 Manhattan Sideways，Four Horsemen 来源设计师 Ole Sondresen Architect，其余来源为地点官网。

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
