# Business Rules

## User Management

### Registration
1. **Username**: Must be unique, 3-100 characters, alphanumeric + underscore only
2. **Email**: Must be unique, valid email format
3. **Password**: Minimum 6 characters, stored as bcrypt hash (cost 10)
4. **Default Role**: New users start as `depositor`
5. **Email Verification**: Account created immediately but `is_email_verified = false`
   - Verification email queued as background task (non-blocking)
   - Email contains link with `email_id` + 32-char `secret_code`
   - Verification links expire after 15 minutes
   - Can only be used once (`is_used` flag)

### Authentication
1. **Password Check**: Uses bcrypt comparison (constant-time)
2. **Session Creation**: Each login creates new session record
   - Stores refresh token, user agent, client IP
   - Can be blocked via `is_blocked` flag (immediate logout)
3. **Token Generation**:
   - Access token: Short-lived (default 15m), for API calls
   - Refresh token: Long-lived (default 24h), stored in session table
4. **Token Validation**:
   - Must not be expired
   - Must match expected token type (access vs refresh)
   - Username and role extracted from payload

### Profile Updates
1. **Self-Update**: Users can update their own profile (password, full_name, email)
2. **Banker Privilege**: `banker` role can update any user's profile
3. **Email Change**: Resets `is_email_verified` to false (implementation TBD)
4. **Password Change**: Updates `password_changed_at` timestamp

### Roles
- **depositor**: Default role, can manage own accounts
- **banker**: Admin role, can update any user

---

## Account Management

### Account Creation
1. **Ownership**: Each account belongs to exactly one user (`owner` → `users.username`)
2. **Currency**: Must be one of: `USD`, `EUR`, `CAD` (validated by custom validator)
3. **Unique Constraint**: User can only have ONE account per currency
4. **Initial Balance**: Set at creation (can be 0 or positive)

### Account Balances
1. **Data Type**: int64 representing smallest currency unit (e.g., cents for USD)
2. **Negative Balance**: Allowed by schema but should be prevented by transfer logic
3. **Updates**: Only via transfer transactions (no direct balance modifications)

---

## Transfer System

### Transfer Rules
1. **Amount**: Must be positive integer (validated in create)
2. **Currency Matching**: From and to accounts must have same currency (validation happens at API layer)
3. **Sufficient Funds**: Not enforced at DB level (should be checked in API layer)
4. **Self-Transfer**: Technically allowed by schema but should be prevented

### Transaction Guarantees
1. **Atomicity**: Transfer, entries, and balance updates in single DB transaction
2. **Consistency**: 
   - Transfer record shows movement: `from_account_id → to_account_id`
   - Two entries created: one negative (from), one positive (to)
   - Balance changes sum to zero across both accounts
3. **Deadlock Prevention**: 
   - Always update accounts in ascending ID order
   - If `from_account_id < to_account_id`: update from first, then to
   - Otherwise: update to first, then from
4. **Isolation**: Uses PostgreSQL's default READ COMMITTED isolation level

### Entry Records
- **Purpose**: Audit trail of all balance changes
- **Amount**: Can be negative (withdrawal) or positive (deposit)
- **Immutable**: Never updated or deleted

---

## Email Verification

### Verification Workflow
1. User registers → `verify_emails` record created with random 32-char code
2. Email sent with link: `http://localhost:8080/v1/verify_email?email_id=X&secret_code=Y`
3. User clicks link → `verify_emails` marked as used, `users.is_email_verified = true`

### Security Rules
1. **Expiration**: 15 minutes from creation (enforced by `expired_at` column)
2. **One-Time Use**: Cannot verify with same link twice (`is_used` flag)
3. **No Authentication**: Link itself is the credential (no token required)
4. **Code Entropy**: 32 random alphanumeric characters

### Failure Handling
1. **Email Send Failure**: Task retries up to 10 times with exponential backoff
2. **Expired Links**: User must request new verification email (endpoint TBD)
3. **Invalid Code/ID**: Returns `NOT_FOUND` error

---

## Session Management

### Session Lifecycle
1. **Creation**: On successful login
2. **Expiration**: Matches refresh token expiry (default 24h)
3. **Blocking**: `is_blocked` flag allows immediate invalidation
4. **Deletion**: Sessions should be cleaned up periodically (implementation TBD)

### Session Security
1. **Unique ID**: UUID from refresh token payload
2. **Binding**: Stores user agent and client IP
3. **Token Storage**: Refresh token stored in plaintext (consider hashing for production)

---

## Authorization Matrix

| Operation | No Auth | Depositor (Self) | Depositor (Other) | Banker |
|-----------|---------|------------------|-------------------|--------|
| Create User | ✓ | ✓ | ✓ | ✓ |
| Login User | ✓ | ✓ | ✓ | ✓ |
| Update Own User | ✗ | ✓ | ✗ | ✓ |
| Update Other User | ✗ | ✗ | ✗ | ✓ |
| Verify Email | ✓ | ✓ | ✓ | ✓ |
| Create Account | ✗ | ✓ | ✗ | ✓ |
| View Own Account | ✗ | ✓ | ✗ | ✓ |
| View Other Account | ✗ | ✗ | ✗ | ✓ |
| Transfer (Own Accounts) | ✗ | ✓ | ✗ | ✓ |

---

## Data Validation Summary

### Username
- Length: 3-100 characters
- Pattern: `^[a-z0-9_]+$`

### Password
- Minimum: 6 characters
- No maximum (bcrypt handles up to 72 bytes)

### Full Name
- Length: 3-100 characters

### Email
- Standard email regex validation
- Must be unique across users

### Currency
- Enum: `USD`, `EUR`, `CAD`
- Validated by custom Gin validator

### Amount (Transfers)
- Must be positive integer
- Represents smallest currency unit

---

## Constraints & Invariants

### Database Constraints
1. User email must be unique
2. User username is primary key
3. Account (owner, currency) pair must be unique
4. Transfer amount must be positive (enforced by comment, not CHECK constraint)
5. Entry amounts can be negative (explicitly allowed)

### Application Invariants
1. Sum of all entries for an account = current balance
2. For each transfer: exists exactly 2 entries (one positive, one negative)
3. Access tokens only used for authentication, never stored
4. Refresh tokens stored in sessions table

### Soft Rules (Not Enforced)
1. Users should verify email before performing sensitive operations
2. Accounts should not go negative
3. Self-transfers should be prevented
4. Large transfers might need additional verification (fraud detection TBD)
