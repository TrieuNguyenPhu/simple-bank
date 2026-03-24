# Project Context

## Purpose
Simple Bank is a full-stack banking simulation system demonstrating production-grade backend architecture patterns including database transactions, authentication, async task processing, and dual API protocols (gRPC + HTTP).

## Tech Stack Core
- **Language**: Go 1.26
- **Database**: PostgreSQL 17 with pgx/v5 driver
- **API Protocols**: gRPC (primary), HTTP/JSON via gRPC-Gateway
- **Auth**: PASETO tokens (32-char symmetric key)
- **Task Queue**: Redis 7 + Asynq for background jobs
- **Code Generation**: sqlc (SQL→Go), protoc (proto→gRPC/OpenAPI)
- **Frontend**: Vue 3 + TypeScript + Vite

## Domain
Financial services simulation with:
- Multi-currency accounts per user
- Money transfers between accounts
- Email verification workflow
- Role-based access control (depositor, banker)
- Session management with refresh tokens

## Deployment Context
- Local: Docker Compose (PostgreSQL, Redis, API)
- Production: AWS EKS with NGINX ingress
- CI/CD: GitHub Actions (test on push, deploy on release)
- Auto-migration on startup via golang-migrate

## Key Architecture Decisions
1. **Dual Protocol**: gRPC for performance, HTTP gateway for browser compatibility
2. **Token Strategy**: Short-lived access tokens (15m default) + refresh tokens (24h default)
3. **Async Email**: Non-blocking user creation with background email tasks
4. **Transaction Safety**: Database-level locking and ordered updates prevent deadlocks
5. **Embedded Docs**: Swagger UI bundled in binary via statik

## Configuration
Environment-based via `app.env` or env vars. Critical settings:
- `TOKEN_SYMMETRIC_KEY`: Must be exactly 32 characters
- `DB_SOURCE`: PostgreSQL connection string
- `REDIS_ADDRESS`: Task queue backend
- `EMAIL_SENDER_*`: Gmail SMTP for verification emails
- `ALLOWED_ORIGINS`: CORS whitelist for frontend

## Project Origin
Full-stack banking demo with Vue frontend, Docker orchestration, and Kubernetes deployment manifests.
