# Dumpster Launchpad - Laconic Stack

Unified stack that deploys the full Dumpster Launchpad: Next.js frontend, Bun/Hono backend, PostgreSQL, and Redis.

## Quick Start

```bash
cd dumpster-stack
export CERC_REPO_BASE_DIR=$(cd .. && pwd)

laconic-so --stack stack-orchestrator/stacks/dumpster build-containers
laconic-so --stack stack-orchestrator/stacks/dumpster deploy init --output spec.yml
laconic-so --stack stack-orchestrator/stacks/dumpster deploy create --spec-file spec.yml --deployment-dir dumpster-deployment
laconic-so deployment --dir dumpster-deployment start
```

Frontend at `http://localhost:3000`, API at `http://localhost:3200`.

## Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| dumpster-frontend | cerc/dumpster-frontend:local | 3000 | Next.js web app |
| dumpster-backend | cerc/dumpster-backend:local | 3200 | Bun + Hono API with WebSocket + BullMQ workers |
| dumpster-db | postgres:14-alpine | (internal) | PostgreSQL database |
| dumpster-redis | redis:7-alpine | (internal) | Redis for caching + job queues |

## Environment Variables

Set these in your spec or `config.env`:

### Backend

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `JWT_SECRET` | Yes | - | 32+ char secret for JWT signing |
| `RPC_URL` | Yes | `https://rpc.trashscan.io` | Gorbagana RPC endpoint |
| `R2_ACCESS_KEY` | Yes | - | Cloudflare R2 access key |
| `R2_SECRET_KEY` | Yes | - | Cloudflare R2 secret key |
| `R2_BUCKET` | Yes | `dumpster-uploads` | R2 bucket name |
| `R2_ACCOUNT_ID` | Yes | - | Cloudflare account ID |
| `R2_ENDPOINT` | Yes | - | R2 endpoint URL |
| `R2_PUBLIC_BASE_URL` | Yes | - | Public URL for uploaded files |
| `PINATA_JWT` | Yes | - | Pinata API JWT for IPFS |
| `ENCRYPTION_KEY` | Yes | - | 32-byte hex (64 chars) encryption key |
| `PINATA_GATEWAY` | No | `gateway.pinata.cloud` | Pinata gateway URL |
| `SENTRY_DSN` | No | - | Sentry error tracking DSN |
| `MIGRATION_KEYPAIR` | No | - | Base58 secret key for migration bot |
| `ADMIN_WALLETS` | No | - | Comma-separated admin wallet pubkeys |
| `CORS_ORIGIN` | No | - | Comma-separated allowed origins |
| `METADATA_FETCH_ALLOWLIST` | No | - | Comma-separated extra metadata hosts |
| `DB_USER` | No | `dumpster` | Postgres username |
| `DB_PASSWORD` | No | `password` | Postgres password |
| `DB_NAME` | No | `dumpster` | Postgres database name |

### Frontend

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | No | `http://dumpster-backend:3200` | Backend API URL |
| `NEXT_PUBLIC_WS_URL` | No | `ws://dumpster-backend:3200/ws` | Backend WebSocket URL |
| `NEXT_PUBLIC_RPC_URL` | Yes | `http://127.0.0.1:8899` | Gorbagana RPC endpoint |
| `NEXT_PUBLIC_SITE_URL` | No | `https://dumpster.cash` | Canonical site URL |

### Ports

| Variable | Default | Description |
|----------|---------|-------------|
| `FRONTEND_HOST_PORT` | `3000` | Frontend port on host |
| `BACKEND_HOST_PORT` | `3200` | Backend port on host |

## Commands

```bash
laconic-so deployment --dir dumpster-deployment ps
laconic-so deployment --dir dumpster-deployment logs
laconic-so deployment --dir dumpster-deployment logs --follow
laconic-so deployment --dir dumpster-deployment stop
laconic-so deployment --dir dumpster-deployment stop --delete-volumes
```
