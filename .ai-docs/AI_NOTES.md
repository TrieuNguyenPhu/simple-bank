# AI Agent Notes

## Quick Start Context
**What**: Banking simulation with user auth, accounts, transfers, email verification  
**How**: gRPC + HTTP gateway serving 4 RPCs, PostgreSQL for data, Redis for tasks  
**Run**: `docker compose up` (needs ports 5432, 8080, 9090)  
**Test**: Swagger UI at `http://localhost:8080/swagger/index.html`

## Critical Paths

### Adding New RPC
1. Define in `proto/rpc_*.proto`
2. Add to `proto/service_simple_bank.proto` with HTTP annotations
3. Run `make proto` to regenerate pb/, OpenAPI, Swagger bundle
4. Implement in `gapi/rpc_*.go` with validation
5. Update this doc's API_MAP.md

### Adding DB Table/Column
1. Create migration: `make new_migration name=add_something`
2. Write up.sql and down.sql in `db/migration/`
3. Update `doc/db.dbml` to match
4. Add queries in `db/query/*.sql`
5. Run `make sqlc` to regenerate Go code
6. If complex logic needed, add transaction in `db/sqlc/tx_*.go`

### Authentication Flow
- All protected endpoints check `Authorization: Bearer <token>` via middleware
- Token extracted → `tokenMaker.VerifyToken()` → payload has username + role
- For self-service ops: compare `payload.username` with request target
- For admin ops: check `payload.role == BankerRole`

## Code Generation Dependencies
- **sqlc**: SQL → Go (config in `sqlc.yaml`)
- **protoc**: Proto → gRPC + Gateway + OpenAPI
- **statik**: Embeds `doc/swagger/` into `doc/statik/statik.go`
- **mockgen**: Generates test mocks for Store and TaskDistributor

## Testing Strategy
- Unit tests with mock store: `api/*_test.go`, `gapi/*_test.go`
- Integration tests with real DB: `db/sqlc/*_test.go`
- Run with `make test` (requires PostgreSQL and migrations applied)
- Short mode flag skips Gmail-dependent tests

## Common Gotchas

### 1. Legacy api/ Package
`api/` REST endpoints for accounts and transfers are mounted on the same HTTP port as the gRPC gateway (`/users`, `/accounts`, `/transfers`, alongside `/v1/*`).

### 2. Token Types
Access and refresh tokens use identical PASETO format but different `token_type` field. Verification explicitly checks type matches expected use. Don't use refresh tokens for API auth.

### 3. Migration Auto-Run
`main.go` applies migrations on every startup. Failed migrations crash the app. Test migrations locally before deploying.

### 4. Environment Variables
`app.env` only loaded from working directory. In Docker, it's copied to `/app/`. For Kubernetes, config loaded from AWS Secrets Manager in deploy workflow.

### 5. Deadlock Prevention
Transfer transaction MUST update accounts in ID order. Never modify `addMoney` logic or change update sequence.

### 6. Currency Validation
Custom Gin validator registered in `setupRouter`. When adding currencies, update `util/currency.go` constants.

## File Locations Quick Reference
```
proto/                     → API contracts
gapi/                      → gRPC implementations (ACTIVE)
api/                       → REST implementations (INACTIVE)
db/query/                  → SQL source for sqlc
db/sqlc/                   → Generated + custom transactions
db/migration/              → Schema versions
worker/                    → Background tasks
token/                     → PASETO/JWT makers
util/                      → Config, validation, helpers
val/                       → gRPC request validators
pb/                        → Generated protobuf code
doc/swagger/               → OpenAPI + UI assets
doc/statik/                → Embedded assets for binary
```

## Environment Variables Checklist
**Required**:
- `DB_SOURCE` - PostgreSQL connection string
- `TOKEN_SYMMETRIC_KEY` - Exactly 32 chars for PASETO
- `HTTP_SERVER_ADDRESS` - Gateway bind address
- `GRPC_SERVER_ADDRESS` - gRPC bind address

**Email (Optional but needed for verification)**:
- `EMAIL_SENDER_NAME` - Display name
- `EMAIL_SENDER_ADDRESS` - Gmail account
- `EMAIL_SENDER_PASSWORD` - Gmail app password (not account password)

**Task Queue (Required)**:
- `REDIS_ADDRESS` - Redis host:port for Asynq

**Security**:
- `ALLOWED_ORIGINS` - CORS whitelist (comma-separated)

## Key Interfaces
```go
// db/sqlc/store.go
type Store interface {
    Querier  // All CRUD operations
    TransferTx(ctx, TransferTxParams) (TransferTxResult, error)
    CreateUserTx(ctx, CreateUserTxParams) (CreateUserTxResult, error)
    VerifyEmailTx(ctx, VerifyEmailTxParams) (VerifyEmailTxResult, error)
}

// token/maker.go
type Maker interface {
    CreateToken(username, role, duration, tokenType) (token, *Payload, error)
    VerifyToken(token, tokenType) (*Payload, error)
}

// worker/distributor.go
type TaskDistributor interface {
    DistributeTaskSendVerifyEmail(ctx, *PayloadSendVerifyEmail, ...options) error
}
```

## Database Schema Summary
- **users**: username (PK), email (unique), hashed_password, role, is_email_verified
- **accounts**: id (PK), owner → users, balance, currency (unique per owner)
- **entries**: id (PK), account_id → accounts, amount (can be negative)
- **transfers**: id (PK), from_account_id → accounts, to_account_id → accounts, amount (positive only)
- **sessions**: id (PK, UUID), username → users, refresh_token, is_blocked, expires_at
- **verify_emails**: id (PK), username → users, secret_code, is_used, expired_at (15m default)

## Makefile Common Commands
```bash
make postgres        # Start PostgreSQL container
make createdb        # Create database
make migrateup       # Apply all migrations
make migrateup1      # Apply next migration only
make migratedown1    # Rollback last migration
make sqlc            # Regenerate db/ code from queries
make proto           # Regenerate pb/, OpenAPI, Swagger
make mock            # Regenerate test mocks
make test            # Run all tests (needs DB)
make server          # Run main.go locally
make evans           # Open gRPC REPL for testing
```

## Roles & Permissions
- **depositor**: Default role, can manage own resources
- **banker**: Admin role, can manage all resources
- Check in `gapi/` methods via `authPayload.Role == util.BankerRole`

## Zero-Downtime Deployment Pattern
1. Migrations are forward-only (no destructive changes)
2. New code deployed after schema changes
3. Old code continues working during rollout
4. Kubernetes rolling update with 2 replicas

## Future Enhancement Hints
- Account/transfer endpoints in `api/` not exposed—integrate into gRPC
- Email resend functionality (verification expired)
- Session cleanup job (delete expired sessions)
- Rate limiting middleware
- Webhook support for external notifications
- Transaction reversal/dispute system
- Multi-factor authentication
- Audit logging table for sensitive operations
