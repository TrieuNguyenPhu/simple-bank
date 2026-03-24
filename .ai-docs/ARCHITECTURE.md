# Architecture

## System Overview
```
Frontend (Vue:3000) → HTTP Gateway (:8080) → gRPC Server (:9090)
                              ↓                      ↓
                         PostgreSQL 17         Task Queue
                              ↑                      ↓
                         Migrations            Redis 7 ← Worker
                                                       ↓
                                                  Gmail SMTP
```

## Process Architecture
**Single Binary, Three Goroutines** (main.go):
1. **HTTP Gateway Server** - gRPC-Gateway + CORS + Swagger UI
2. **gRPC Server** - Core business logic with reflection enabled
3. **Asynq Worker** - Background task processor

All three start concurrently using `errgroup` with graceful shutdown on SIGTERM/SIGINT.

## Layer Breakdown

### 1. API Layer
**Location**: `gapi/` (gRPC + gateway `/v1/*`), `api/` (Gin REST for accounts/transfers on the same HTTP port)

**gRPC Implementation**:
- `Server` struct holds config, store, token maker, task distributor
- Each RPC method in separate file: `rpc_create_user.go`, `rpc_login_user.go`, etc.
- Validation via `val/` package with gRPC error details
- Metadata extraction for client IP and user agent

**HTTP Gateway**:
- Auto-generated from proto annotations via protoc-gen-grpc-gateway
- JSON marshaling with proto field names (snake_case)
- CORS middleware applied to all routes
- Swagger UI served at `/swagger/` from embedded statik filesystem

### 2. Business Logic Layer
**Location**: `db/sqlc/` (transactions)

**Custom Transactions**:
- `TransferTx`: Creates transfer record, entries, updates balances atomically
  - **Deadlock Prevention**: Updates accounts in ascending ID order
- `CreateUserTx`: Creates user + enqueues verification email via callback
- `VerifyEmailTx`: Marks email verified + updates user status

**Store Interface**:
```go
type Store interface {
    Querier  // Auto-generated CRUD methods
    TransferTx(ctx, params) (result, error)
    CreateUserTx(ctx, params) (result, error)
    VerifyEmailTx(ctx, params) (result, error)
}
```

### 3. Data Layer
**Location**: `db/sqlc/` (generated), `db/query/` (source SQL)

**Code Generation**:
- SQL queries → Go methods via sqlc
- Type-safe parameters and results
- Automatic NULL handling with pgtype

**Connection Pool**: `pgxpool.Pool` for efficient PostgreSQL connections

### 4. Auth Layer
**Location**: `token/`

**PASETO Maker**:
- Symmetric encryption (ChaCha20-Poly1305)
- Payload includes username, role, token type, expiry
- Two token types: `access_token`, `refresh_token`
- Verification validates expiry and type mismatch

**JWT Maker** (available but not used): Reference implementation

### 5. Background Task Layer
**Location**: `worker/`

**Components**:
- `TaskDistributor`: Enqueues tasks to Redis
- `TaskProcessor`: Consumes tasks from queues
- Queue priorities: `critical` (10), `default` (5)

**Current Tasks**:
- `TaskSendVerifyEmail`: Creates verification record, sends email with link
  - Max retries: 10
  - Delay: 10 seconds
  - On failure: Logs error, retries with exponential backoff

### 6. Email Layer
**Location**: `mail/`

**Gmail Sender**:
- Uses Gmail SMTP with app passwords
- Sends HTML emails
- Supports CC, BCC, attachments

## Data Flow Examples

### User Registration
1. Client → `POST /v1/create_user` (HTTP Gateway)
2. Gateway → `CreateUser` RPC (gRPC Server)
3. Hash password with bcrypt
4. Begin DB transaction:
   - Insert into `users` table
   - Callback: Enqueue `TaskSendVerifyEmail` to Redis
5. Return user object (no wait for email)
6. Worker picks up task:
   - Create `verify_emails` record with secret code
   - Send email via Gmail SMTP
   - Retry up to 10 times on failure

### Money Transfer
1. Client → `POST /v1/transfer` (requires access token)
2. Middleware validates token, extracts username
3. Begin DB transaction:
   - Insert `transfers` record
   - Insert two `entries` (from: negative, to: positive)
   - Update account balances in ID order (deadlock prevention)
4. Return transfer result with updated balances

### Login & Session
1. Client → `POST /v1/login_user`
2. Verify password hash
3. Create access token (15m) and refresh token (24h)
4. Store session in PostgreSQL with:
   - Session ID = refresh token ID
   - User agent, client IP, expiry
5. Return both tokens + user data

## Middleware Chain
**gRPC**: Unary interceptor for logging
**HTTP**: CORS → Logger → gRPC-Gateway → API handlers

## Migration Strategy
- Migrations in `db/migration/` (up/down pairs)
- Applied automatically on startup via `runDBMigration`
- Managed with golang-migrate CLI
- Current version: 000005 (role field)

## Code Generation Workflow
1. Edit SQL queries in `db/query/` → run `make sqlc`
2. Edit proto in `proto/` → run `make proto` (regenerates gRPC + OpenAPI + Swagger bundle)
3. Change Store interface → run `make mock` (regenerates test mocks)

## Concurrency & Safety
- Database transactions prevent race conditions
- Context cancellation propagated through all layers
- Graceful shutdown waits for in-flight requests
- Worker retries failed tasks with exponential backoff
- Session blocking flag allows immediate logout
