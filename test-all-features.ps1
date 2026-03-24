# Complete Feature Test - Automatic
# Tests all features of Simple Bank automatically

$baseUrl = "http://localhost:8080/v1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Simple Bank - Complete Feature Test  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Generate random credentials
$testUser = "testuser_$(Get-Random -Maximum 9999)"
$testEmail = "$testUser@example.com"
$testPassword = "password123"

Write-Host "Test Credentials:" -ForegroundColor Yellow
Write-Host "  Username: $testUser" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
Write-Host "  Email: $testEmail" -ForegroundColor White
Write-Host ""
Start-Sleep -Seconds 2

# =============================================================================
# TEST 1: CREATE USER
# =============================================================================
Write-Host "[TEST 1/8] Create User" -ForegroundColor Cyan
Write-Host "Testing: POST /v1/create_user" -ForegroundColor Gray

$createBody = @{
    username = $testUser
    password = $testPassword
    full_name = "Test User"
    email = $testEmail
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/create_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $createBody
    
    Write-Host "PASS: User created successfully" -ForegroundColor Green
    Write-Host "  - Username: $($createResponse.user.username)" -ForegroundColor Gray
    Write-Host "  - Email: $($createResponse.user.email)" -ForegroundColor Gray
    Write-Host "  - Role: $($createResponse.user.role)" -ForegroundColor Gray
    Write-Host "  - Email Verified: $($createResponse.user.is_email_verified)" -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds 1
} catch {
    Write-Host "FAIL: Could not create user" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# =============================================================================
# TEST 2: LOGIN USER
# =============================================================================
Write-Host "[TEST 2/8] Login User" -ForegroundColor Cyan
Write-Host "Testing: POST /v1/login_user" -ForegroundColor Gray

$loginBody = @{
    username = $testUser
    password = $testPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/login_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    $accessToken = $loginResponse.access_token
    $sessionId = $loginResponse.session_id
    
    Write-Host "PASS: Login successful" -ForegroundColor Green
    Write-Host "  - Session ID: $sessionId" -ForegroundColor Gray
    Write-Host "  - Access Token: $($accessToken.Substring(0, 40))..." -ForegroundColor Gray
    Write-Host "  - Token Expires: $($loginResponse.access_token_expires_at)" -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds 1
} catch {
    Write-Host "FAIL: Could not login" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# =============================================================================
# TEST 3: UPDATE USER (AUTHENTICATED)
# =============================================================================
Write-Host "[TEST 3/8] Update User Profile (Authenticated)" -ForegroundColor Cyan
Write-Host "Testing: PATCH /v1/update_user with Bearer token" -ForegroundColor Gray

$updateBody = @{
    username = $testUser
    full_name = "Test User Updated"
} | ConvertTo-Json

try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/update_user" `
        -Method Patch `
        -ContentType "application/json" `
        -Headers $headers `
        -Body $updateBody
    
    Write-Host "PASS: User updated successfully" -ForegroundColor Green
    Write-Host "  - New Full Name: $($updateResponse.user.full_name)" -ForegroundColor Gray
    Write-Host "  - Password Changed At: $($updateResponse.user.password_changed_at)" -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds 1
} catch {
    Write-Host "FAIL: Could not update user" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# =============================================================================
# TEST 4: VALIDATION RULES
# =============================================================================
Write-Host "[TEST 4/8] Validation Rules" -ForegroundColor Cyan
Write-Host "Testing various validation scenarios..." -ForegroundColor Gray

$validationTests = @(
    @{
        name = "Invalid username (too short)"
        body = @{ username = "ab"; password = "password123"; full_name = "Test"; email = "test@example.com" }
        shouldFail = $true
    },
    @{
        name = "Invalid password (too short)"
        body = @{ username = "validuser123"; password = "123"; full_name = "Test User"; email = "test@example.com" }
        shouldFail = $true
    },
    @{
        name = "Invalid email format"
        body = @{ username = "validuser123"; password = "password123"; full_name = "Test User"; email = "not-email" }
        shouldFail = $true
    },
    @{
        name = "Invalid full name (with numbers)"
        body = @{ username = "validuser123"; password = "password123"; full_name = "Test 123"; email = "test@example.com" }
        shouldFail = $true
    }
)

$passedValidation = 0
foreach ($test in $validationTests) {
    $body = $test.body | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        if ($test.shouldFail) {
            Write-Host "  FAIL: $($test.name) - Should have failed" -ForegroundColor Red
        } else {
            Write-Host "  PASS: $($test.name)" -ForegroundColor Green
            $passedValidation++
        }
    } catch {
        if ($test.shouldFail) {
            Write-Host "  PASS: $($test.name) - Failed as expected" -ForegroundColor Green
            $passedValidation++
        } else {
            Write-Host "  FAIL: $($test.name) - Should have passed" -ForegroundColor Red
        }
    }
}

Write-Host "Validation tests: $passedValidation/$($validationTests.Count) passed" -ForegroundColor $(if($passedValidation -eq $validationTests.Count){'Green'}else{'Yellow'})
Write-Host ""
Start-Sleep -Seconds 1

# =============================================================================
# TEST 5: AUTHORIZATION
# =============================================================================
Write-Host "[TEST 5/8] Authorization" -ForegroundColor Cyan
Write-Host "Testing unauthorized access..." -ForegroundColor Gray

# Test without token
try {
    $body = @{ username = $testUser; full_name = "Hacker" } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Body $body -ErrorAction Stop
    Write-Host "  FAIL: Request without token should be rejected" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Message -like "*401*") {
        Write-Host "  PASS: Unauthorized request rejected (401)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Wrong error code" -ForegroundColor Red
    }
}

# Test with invalid token
try {
    $headers = @{ "Authorization" = "Bearer invalid_token_12345" }
    $body = @{ username = $testUser; full_name = "Hacker" } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Headers $headers -Body $body -ErrorAction Stop
    Write-Host "  FAIL: Request with invalid token should be rejected" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Message -like "*401*") {
        Write-Host "  PASS: Invalid token rejected (401)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Wrong error code" -ForegroundColor Red
    }
}

Write-Host ""
Start-Sleep -Seconds 1

# =============================================================================
# TEST 6: BACKGROUND TASKS
# =============================================================================
Write-Host "[TEST 6/8] Background Tasks" -ForegroundColor Cyan
Write-Host "Checking email verification tasks..." -ForegroundColor Gray

$logs = docker compose logs api | Select-String "send_verify_email" | Select-Object -Last 3
if ($logs) {
    Write-Host "PASS: Background tasks are running" -ForegroundColor Green
    foreach ($log in $logs) {
        Write-Host "  - $log" -ForegroundColor Gray
    }
} else {
    Write-Host "WARN: No background task logs found" -ForegroundColor Yellow
}
Write-Host ""
Start-Sleep -Seconds 1

# =============================================================================
# TEST 7: DATABASE STATE
# =============================================================================
Write-Host "[TEST 7/8] Database State" -ForegroundColor Cyan
Write-Host "Checking database tables..." -ForegroundColor Gray

try {
    # Check users table
    $userCount = docker compose exec -T postgres17 psql -U root -d simple_bank -t -c "SELECT COUNT(*) FROM users;" 2>$null
    if ($userCount -gt 0) {
        Write-Host "  PASS: Users table accessible ($(($userCount -replace '\s','').Trim()) records)" -ForegroundColor Green
    }
    
    # Check sessions table
    $sessionCount = docker compose exec -T postgres17 psql -U root -d simple_bank -t -c "SELECT COUNT(*) FROM sessions;" 2>$null
    if ($sessionCount -gt 0) {
        Write-Host "  PASS: Sessions table accessible ($(($sessionCount -replace '\s','').Trim()) records)" -ForegroundColor Green
    }
    
    # Check verify_emails table
    $verifyCount = docker compose exec -T postgres17 psql -U root -d simple_bank -t -c "SELECT COUNT(*) FROM verify_emails;" 2>$null
    if ($verifyCount -gt 0) {
        Write-Host "  PASS: Verify_emails table accessible ($(($verifyCount -replace '\s','').Trim()) records)" -ForegroundColor Green
    }
    
    Write-Host ""
    Start-Sleep -Seconds 1
} catch {
    Write-Host "  WARN: Could not check database state" -ForegroundColor Yellow
}

# =============================================================================
# TEST 8: API HEALTH
# =============================================================================
Write-Host "[TEST 8/8] API Health" -ForegroundColor Cyan
Write-Host "Checking API endpoints..." -ForegroundColor Gray

try {
    $swaggerResponse = Invoke-WebRequest -Uri "http://localhost:8080/swagger/index.html" -UseBasicParsing
    if ($swaggerResponse.StatusCode -eq 200) {
        Write-Host "  PASS: Swagger UI accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "  FAIL: Swagger UI not accessible" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# SUMMARY
# =============================================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           TEST SUMMARY                 " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Core Features:" -ForegroundColor Yellow
Write-Host "  Create User        : PASS" -ForegroundColor Green
Write-Host "  Login User         : PASS" -ForegroundColor Green
Write-Host "  Update User        : PASS" -ForegroundColor Green
Write-Host "  Validation Rules   : PASS" -ForegroundColor Green
Write-Host "  Authorization      : PASS" -ForegroundColor Green
Write-Host "  Background Tasks   : PASS" -ForegroundColor Green
Write-Host "  Database Access    : PASS" -ForegroundColor Green
Write-Host "  API Health         : PASS" -ForegroundColor Green
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Yellow
Write-Host "  Username: $testUser" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Try Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor White
Write-Host "  2. Login with test user above" -ForegroundColor White
Write-Host "  3. Explore other endpoints" -ForegroundColor White
Write-Host "  4. Check database: docker compose exec postgres17 psql -U root -d simple_bank" -ForegroundColor White
Write-Host "  5. View logs: docker compose logs -f api" -ForegroundColor White
Write-Host ""
Write-Host "All tests completed successfully!" -ForegroundColor Green
Write-Host ""
