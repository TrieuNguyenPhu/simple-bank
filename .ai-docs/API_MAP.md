# API Map

## Active APIs (gRPC + HTTP Gateway)
All endpoints served by `gapi/` implementation. gRPC runs on `:9090`, HTTP gateway on `:8080`.

### CreateUser
**gRPC**: `SimpleBank.CreateUser`  
**HTTP**: `POST /v1/create_user`  
**Auth**: None  
**Request**:
```json
{
  "username": "string (3-100 chars, alphanumeric + underscore)",
  "password": "string (min 6 chars)",
  "full_name": "string (3-100 chars)",
  "email": "string (valid email format)"
}
```
**Response**:
```json
{
  "user": {
    "username": "string",
    "full_name": "string",
    "email": "string",
    "password_changed_at": "timestamp",
    "created_at": "timestamp",
    "is_email_verified": false,
    "role": "depositor"
  }
}
```
**Side Effects**: Enqueues background email verification task  
**Errors**: `ALREADY_EXISTS` if username/email taken

---

### LoginUser
**gRPC**: `SimpleBank.LoginUser`  
**HTTP**: `POST /v1/login_user`  
**Auth**: None  
**Request**:
```json
{
  "username": "string",
  "password": "string"
}
```
**Response**:
```json
{
  "user": { /* user object */ },
  "session_id": "uuid",
  "access_token": "string (PASETO)",
  "refresh_token": "string (PASETO)",
  "access_token_expires_at": "timestamp",
  "refresh_token_expires_at": "timestamp"
}
```
**Side Effects**: Creates session record in database  
**Errors**: `NOT_FOUND` if user missing or password wrong

---

### UpdateUser
**gRPC**: `SimpleBank.UpdateUser`  
**HTTP**: `PATCH /v1/update_user`  
**Auth**: Bearer access token in `Authorization` header  
**Request** (all fields optional):
```json
{
  "username": "string (cannot be changed, for identification)",
  "password": "string (min 6 chars)",
  "full_name": "string (3-100 chars)",
  "email": "string (valid email format)"
}
```
**Response**: Updated user object  
**Authorization Rules**:
- Users can update their own account
- `banker` role can update any account
- Changing another user's data without `banker` role → `PERMISSION_DENIED`

**Errors**: `UNAUTHENTICATED` if token invalid/expired

---

### VerifyEmail
**gRPC**: `SimpleBank.VerifyEmail`  
**HTTP**: `GET /v1/verify_email?email_id=<id>&secret_code=<code>`  
**Auth**: None (secured by secret code)  
**Request**:
- `email_id`: int64 (verification record ID)
- `secret_code`: string (32-char random string from email)

**Response**:
```json
{
  "is_verified": true
}
```
**Side Effects**: 
- Marks `verify_emails` record as used
- Sets `users.is_email_verified = true`

**Errors**: `NOT_FOUND` if invalid ID/code, `INVALID_ARGUMENT` if already used or expired

---

## Legacy REST Endpoints (api/)
**Status**: Implemented but NOT served by main.go

These Gin REST endpoints are served on the same HTTP server as the gRPC gateway (paths `/users`, `/accounts`, `/transfers`, `/tokens/renew_access`).

### User Management
- `POST /users` - Create user
- `POST /users/login` - Login
- `POST /tokens/renew_access` - Refresh token

### Account Management (Auth Required)
- `POST /accounts` - Create account
- `GET /accounts/:id` - Get single account
- `GET /accounts?page_id=X&page_size=Y` - List user's accounts

### Transfers (Auth Required)
- `POST /transfers` - Create money transfer

---

## Token Types

### Access Token
- **Duration**: Configurable (default 15m)
- **Purpose**: API authentication
- **Type**: `access_token` (validated on use)
- **Storage**: Client-side only (memory/local storage)

### Refresh Token
- **Duration**: Configurable (default 24h)
- **Purpose**: Generate new access tokens
- **Type**: `refresh_token` (validated on use)
- **Storage**: Database session + client-side

### Token Structure (PASETO Payload)
```json
{
  "id": "uuid",
  "username": "string",
  "role": "depositor|banker",
  "token_type": "access_token|refresh_token",
  "issued_at": "timestamp",
  "expired_at": "timestamp"
}
```

---

## Error Response Format
gRPC errors mapped to HTTP status codes via gateway:
- `INVALID_ARGUMENT` → 400 Bad Request
- `UNAUTHENTICATED` → 401 Unauthorized
- `PERMISSION_DENIED` → 403 Forbidden
- `NOT_FOUND` → 404 Not Found
- `ALREADY_EXISTS` → 409 Conflict
- `INTERNAL` → 500 Internal Server Error

**Validation Errors** include field-level details:
```json
{
  "code": 3,
  "message": "invalid CreateUser.Request",
  "details": [
    {
      "field_violations": [
        {
          "field": "password",
          "description": "must be at least 6 characters"
        }
      ]
    }
  ]
}
```

---

## CORS Configuration
Controlled by `ALLOWED_ORIGINS` env var (comma-separated list).  
Default development origin: `http://localhost:3000`

Allowed methods: HEAD, OPTIONS, GET, POST, PUT, PATCH, DELETE  
Allowed headers: Content-Type, Authorization  
Credentials: Allowed

---

## API Documentation
- **Swagger UI**: `http://localhost:8080/swagger/index.html`
- **OpenAPI Spec**: `http://localhost:8080/swagger/simple_bank.swagger.json`
- **gRPC Reflection**: Enabled on port 9090 (use Evans CLI)

---

## Rate Limiting & Security
**Current Implementation**: None  
**Recommendations for Production**:
- Add rate limiting middleware
- Implement request ID tracing
- Add API versioning beyond URL prefix
- Consider API key requirements for sensitive endpoints
