# Corner (`corner: curate & share places`)

> *"Real palates. More time in the real world."*

Corner v2.0 **Minimalist Editorial Sanctuary** 全栈 Monorepo 仓库，包含移动端 Flutter 客户端与 Cloudflare Serverless Edge 后端服务。

## 目录结构 (Monorepo Layout)

```text
.
├── corner_story/          # Flutter 移动端应用 (iOS / Android)
│   ├── lib/               # 核心源码 (Explore / Map / Vibes / Profile / Theme / API Client)
│   ├── assets/            # 离线高保真摄影图集与 Newsreader / Plus Jakarta Sans 字体
│   └── stitch_ui_style_redesign/ # 原始 PRD 与 Stitch 设计规范稿
└── corner_api/            # Cloudflare 全家桶无服务器后端 (Workers + Hono + D1 + KV + R2 + Vectorize)
    ├── src/               # Hono 边缘 API 路由与业务层
    ├── migrations/        # Cloudflare D1 (SQLite + Geohash) 建表与种子数据
    └── wrangler.toml      # Cloudflare 资源绑定配置
```

## 快速启动

### 1. 启动 Cloudflare 边缘后端 (`corner_api`)

```bash
cd corner_api
npm install
npm run db:setup:local
npm run dev
# 本地服务运行于 http://127.0.0.1:8787
```

### 2. 启动 Flutter 移动端 (`corner_story`)

```bash
cd corner_story
flutter pub get
flutter run
```
