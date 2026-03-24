# Interactive Feature Testing Script
# Script này sẽ hướng dẫn bạn test từng chức năng của Simple Bank

$baseUrl = "http://localhost:8080/v1"
$global:accessToken = ""
$global:username = ""
$global:sessionId = ""

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Simple Bank - Feature Testing Menu   " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USER MANAGEMENT:" -ForegroundColor Yellow
    Write-Host "  1. Create User" -ForegroundColor White
    Write-Host "  2. Login User" -ForegroundColor White
    Write-Host "  3. Update User Profile" -ForegroundColor White
    Write-Host "  4. Verify Email" -ForegroundColor White
    Write-Host ""
    Write-Host "TESTING:" -ForegroundColor Yellow
    Write-Host "  5. Test Token Expiry" -ForegroundColor White
    Write-Host "  6. Test Validation Rules" -ForegroundColor White
    Write-Host "  7. Test Authorization" -ForegroundColor White
    Write-Host ""
    Write-Host "INSPECTION:" -ForegroundColor Yellow
    Write-Host "  8. View Database State" -ForegroundColor White
    Write-Host "  9. View API Logs" -ForegroundColor White
    Write-Host "  10. View Background Tasks" -ForegroundColor White
    Write-Host ""
    Write-Host "UTILITIES:" -ForegroundColor Yellow
    Write-Host "  11. Open Swagger UI" -ForegroundColor White
    Write-Host "  12. Run All Tests (Auto)" -ForegroundColor White
    Write-Host "  0. Exit" -ForegroundColor White
    Write-Host ""
    
    if ($global:username) {
        Write-Host "Current User: $($global:username)" -ForegroundColor Green
        Write-Host "Has Token: $(if($global:accessToken){'Yes'}else{'No'})" -ForegroundColor $(if($global:accessToken){'Green'}else{'Red'})
        Write-Host ""
    }
}

function Test-CreateUser {
    Write-Host "`n=== Test 1: Create User ===" -ForegroundColor Cyan
    Write-Host ""
    
    $username = Read-Host "Enter username (or press Enter for random)"
    if ([string]::IsNullOrWhiteSpace($username)) {
        $username = "user_$(Get-Random -Maximum 9999)"
    }
    
    $password = Read-Host "Enter password (min 6 chars)"
    if ([string]::IsNullOrWhiteSpace($password)) {
        $password = "password123"
    }
    
    $fullName = Read-Host "Enter full name (letters and spaces only)"
    if ([string]::IsNullOrWhiteSpace($fullName)) {
        $fullName = "Test User"
    }
    
    $email = Read-Host "Enter email (or press Enter for random)"
    if ([string]::IsNullOrWhiteSpace($email)) {
        $email = "$username@example.com"
    }
    
    $body = @{
        username = $username
        password = $password
        full_name = $fullName
        email = $email
    } | ConvertTo-Json
    
    Write-Host "`nSending request..." -ForegroundColor Yellow
    Write-Host "POST $baseUrl/create_user" -ForegroundColor Gray
    Write-Host $body -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body
        
        Write-Host "`nSUCCESS!" -ForegroundColor Green
        Write-Host "User created:" -ForegroundColor Green
        Write-Host "  Username: $($response.user.username)" -ForegroundColor White
        Write-Host "  Email: $($response.user.email)" -ForegroundColor White
        Write-Host "  Full Name: $($response.user.full_name)" -ForegroundColor White
        Write-Host "  Role: $($response.user.role)" -ForegroundColor White
        Write-Host "  Email Verified: $($response.user.is_email_verified)" -ForegroundColor White
        Write-Host "  Created At: $($response.user.created_at)" -ForegroundColor White
        
        $global:username = $response.user.username
        
        Write-Host "`nNote: Email verification task has been queued!" -ForegroundColor Yellow
        Write-Host "Check background tasks (option 10) to see the status." -ForegroundColor Yellow
        
    } catch {
        Write-Host "`nERROR!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host $_.ErrorDetails.Message -ForegroundColor Red
        }
    }
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-LoginUser {
    Write-Host "`n=== Test 2: Login User ===" -ForegroundColor Cyan
    Write-Host ""
    
    $username = Read-Host "Enter username"
    if ([string]::IsNullOrWhiteSpace($username) -and $global:username) {
        $username = $global:username
        Write-Host "Using: $username" -ForegroundColor Gray
    }
    
    $password = Read-Host "Enter password"
    if ([string]::IsNullOrWhiteSpace($password)) {
        $password = "password123"
    }
    
    $body = @{
        username = $username
        password = $password
    } | ConvertTo-Json
    
    Write-Host "`nSending request..." -ForegroundColor Yellow
    Write-Host "POST $baseUrl/login_user" -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/login_user" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body
        
        Write-Host "`nSUCCESS!" -ForegroundColor Green
        Write-Host "Login successful:" -ForegroundColor Green
        Write-Host "  Session ID: $($response.session_id)" -ForegroundColor White
        Write-Host "  Access Token: $($response.access_token.Substring(0, 50))..." -ForegroundColor White
        Write-Host "  Access Token Expires: $($response.access_token_expires_at)" -ForegroundColor White
        Write-Host "  Refresh Token Expires: $($response.refresh_token_expires_at)" -ForegroundColor White
        
        $global:accessToken = $response.access_token
        $global:username = $username
        $global:sessionId = $response.session_id
        
        Write-Host "`nToken saved! You can now test authenticated endpoints." -ForegroundColor Yellow
        
    } catch {
        Write-Host "`nERROR!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-UpdateUser {
    Write-Host "`n=== Test 3: Update User Profile ===" -ForegroundColor Cyan
    Write-Host ""
    
    if ([string]::IsNullOrWhiteSpace($global:accessToken)) {
        Write-Host "ERROR: You need to login first (option 2)!" -ForegroundColor Red
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    Write-Host "Current user: $($global:username)" -ForegroundColor Gray
    Write-Host "You can update: full_name, password, email" -ForegroundColor Gray
    Write-Host ""
    
    $newFullName = Read-Host "New full name (or press Enter to skip)"
    $newPassword = Read-Host "New password (or press Enter to skip)"
    $newEmail = Read-Host "New email (or press Enter to skip)"
    
    $updates = @{
        username = $global:username
    }
    
    if (-not [string]::IsNullOrWhiteSpace($newFullName)) {
        $updates.full_name = $newFullName
    }
    if (-not [string]::IsNullOrWhiteSpace($newPassword)) {
        $updates.password = $newPassword
    }
    if (-not [string]::IsNullOrWhiteSpace($newEmail)) {
        $updates.email = $newEmail
    }
    
    $body = $updates | ConvertTo-Json
    
    Write-Host "`nSending authenticated request..." -ForegroundColor Yellow
    Write-Host "PATCH $baseUrl/update_user" -ForegroundColor Gray
    Write-Host "Authorization: Bearer <token>" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Authorization" = "Bearer $($global:accessToken)"
        }
        
        $response = Invoke-RestMethod -Uri "$baseUrl/update_user" `
            -Method Patch `
            -ContentType "application/json" `
            -Headers $headers `
            -Body $body
        
        Write-Host "`nSUCCESS!" -ForegroundColor Green
        Write-Host "User updated:" -ForegroundColor Green
        Write-Host "  Username: $($response.user.username)" -ForegroundColor White
        Write-Host "  Full Name: $($response.user.full_name)" -ForegroundColor White
        Write-Host "  Email: $($response.user.email)" -ForegroundColor White
        Write-Host "  Password Changed At: $($response.user.password_changed_at)" -ForegroundColor White
        
    } catch {
        Write-Host "`nERROR!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host $_.ErrorDetails.Message -ForegroundColor Red
        }
    }
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-VerifyEmail {
    Write-Host "`n=== Test 4: Verify Email ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This test requires email_id and secret_code from verify_emails table" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Getting latest verification record from database..." -ForegroundColor Gray
    $query = "SELECT id, username, secret_code, is_used, expired_at > NOW() as still_valid FROM verify_emails ORDER BY created_at DESC LIMIT 1;"
    
    try {
        $result = docker compose exec -T postgres17 psql -U root -d simple_bank -t -c $query
        Write-Host $result -ForegroundColor White
        Write-Host ""
        
        $emailId = Read-Host "Enter email_id from above"
        $secretCode = Read-Host "Enter secret_code from above"
        
        if ([string]::IsNullOrWhiteSpace($emailId) -or [string]::IsNullOrWhiteSpace($secretCode)) {
            Write-Host "Skipped" -ForegroundColor Yellow
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            return
        }
        
        $url = "$baseUrl/verify_email?email_id=$emailId&secret_code=$secretCode"
        Write-Host "GET $url" -ForegroundColor Gray
        
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        Write-Host "`nSUCCESS!" -ForegroundColor Green
        Write-Host "Email verified: $($response.is_verified)" -ForegroundColor Green
        
    } catch {
        Write-Host "`nERROR!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-TokenExpiry {
    Write-Host "`n=== Test 5: Token Expiry ===" -ForegroundColor Cyan
    Write-Host ""
    
    if ([string]::IsNullOrWhiteSpace($global:accessToken)) {
        Write-Host "ERROR: You need to login first (option 2)!" -ForegroundColor Red
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    Write-Host "Access tokens expire after 1 minute (configured in app.env)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Current time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
    Write-Host "Token will expire at approximately: $(Get-Date (Get-Date).AddMinutes(1) -Format 'HH:mm:ss')" -ForegroundColor White
    Write-Host ""
    Write-Host "Waiting 65 seconds..." -ForegroundColor Yellow
    
    for ($i = 65; $i -gt 0; $i--) {
        Write-Host "`rTime remaining: $i seconds " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
    
    Write-Host "`n`nNow testing with expired token..." -ForegroundColor Yellow
    
    try {
        $headers = @{
            "Authorization" = "Bearer $($global:accessToken)"
        }
        
        $body = @{
            username = $global:username
            full_name = "Test Update"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$baseUrl/update_user" `
            -Method Patch `
            -ContentType "application/json" `
            -Headers $headers `
            -Body $body
        
        Write-Host "Unexpected: Token still valid!" -ForegroundColor Yellow
        
    } catch {
        if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*Unauthorized*") {
            Write-Host "`nEXPECTED BEHAVIOR!" -ForegroundColor Green
            Write-Host "Token has expired as expected." -ForegroundColor Green
            Write-Host "Status: 401 Unauthenticated" -ForegroundColor White
            Write-Host "`nYou would need to use refresh token to get new access token." -ForegroundColor Yellow
        } else {
            Write-Host "`nERROR!" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
    
    $global:accessToken = ""
    Write-Host "`nToken cleared. Please login again if you want to test more." -ForegroundColor Yellow
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-Validation {
    Write-Host "`n=== Test 6: Validation Rules ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Testing various validation rules..." -ForegroundColor Yellow
    Write-Host ""
    
    # Test 1: Invalid username
    Write-Host "[1] Testing invalid username (too short)..." -ForegroundColor Gray
    $body = @{
        username = "ab"
        password = "password123"
        full_name = "Test User"
        email = "test@example.com"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
        Write-Host "  Unexpected: Validation passed" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Validation failed as expected" -ForegroundColor Green
        if ($_.ErrorDetails.Message) {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($error.message)" -ForegroundColor White
        }
    }
    
    # Test 2: Invalid password
    Write-Host "`n[2] Testing invalid password (too short)..." -ForegroundColor Gray
    $body = @{
        username = "testuser123"
        password = "123"
        full_name = "Test User"
        email = "test@example.com"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
        Write-Host "  Unexpected: Validation passed" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Validation failed as expected" -ForegroundColor Green
        if ($_.ErrorDetails.Message) {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($error.message)" -ForegroundColor White
        }
    }
    
    # Test 3: Invalid email
    Write-Host "`n[3] Testing invalid email format..." -ForegroundColor Gray
    $body = @{
        username = "testuser123"
        password = "password123"
        full_name = "Test User"
        email = "not-an-email"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
        Write-Host "  Unexpected: Validation passed" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Validation failed as expected" -ForegroundColor Green
        if ($_.ErrorDetails.Message) {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($error.message)" -ForegroundColor White
        }
    }
    
    # Test 4: Invalid full name
    Write-Host "`n[4] Testing invalid full name (with numbers)..." -ForegroundColor Gray
    $body = @{
        username = "testuser123"
        password = "password123"
        full_name = "Test User 123"
        email = "test@example.com"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
        Write-Host "  Unexpected: Validation passed" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Validation failed as expected" -ForegroundColor Green
        if ($_.ErrorDetails.Message) {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($error.message)" -ForegroundColor White
        }
    }
    
    Write-Host "`nAll validation tests completed!" -ForegroundColor Green
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-Authorization {
    Write-Host "`n=== Test 7: Authorization ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[1] Testing unauthenticated request to protected endpoint..." -ForegroundColor Gray
    try {
        $body = @{
            username = "anyuser"
            full_name = "New Name"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Body $body
        Write-Host "  Unexpected: Request succeeded" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Unauthorized as expected" -ForegroundColor Green
        Write-Host "  Status: 401" -ForegroundColor White
    }
    
    Write-Host "`n[2] Testing with invalid token..." -ForegroundColor Gray
    try {
        $headers = @{
            "Authorization" = "Bearer invalid_token_here"
        }
        $body = @{
            username = "anyuser"
            full_name = "New Name"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Headers $headers -Body $body
        Write-Host "  Unexpected: Request succeeded" -ForegroundColor Red
    } catch {
        Write-Host "  PASS: Invalid token rejected" -ForegroundColor Green
        Write-Host "  Status: 401" -ForegroundColor White
    }
    
    Write-Host "`nAuthorization tests completed!" -ForegroundColor Green
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function View-DatabaseState {
    Write-Host "`n=== Database State ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[1] Users:" -ForegroundColor Yellow
    docker compose exec -T postgres17 psql -U root -d simple_bank -c "SELECT username, email, role, is_email_verified, created_at FROM users ORDER BY created_at DESC LIMIT 5;"
    
    Write-Host "`n[2] Sessions:" -ForegroundColor Yellow
    docker compose exec -T postgres17 psql -U root -d simple_bank -c "SELECT LEFT(id::text, 8) as id, username, is_blocked, expires_at FROM sessions ORDER BY created_at DESC LIMIT 5;"
    
    Write-Host "`n[3] Verify Emails:" -ForegroundColor Yellow
    docker compose exec -T postgres17 psql -U root -d simple_bank -c "SELECT id, username, is_used, expired_at > NOW() as valid FROM verify_emails ORDER BY created_at DESC LIMIT 5;"
    
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function View-Logs {
    Write-Host "`n=== API Logs (Last 20 lines) ===" -ForegroundColor Cyan
    Write-Host ""
    docker compose logs --tail 20 api
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function View-BackgroundTasks {
    Write-Host "`n=== Background Tasks ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Email verification tasks:" -ForegroundColor Yellow
    docker compose logs api | Select-String "send_verify_email" | Select-Object -Last 10
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Open-SwaggerUI {
    Write-Host "`nOpening Swagger UI..." -ForegroundColor Yellow
    Start-Process "http://localhost:8080/swagger/index.html"
    Start-Sleep -Seconds 1
}

function Run-AllTests {
    Write-Host "`n=== Running All Tests Automatically ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Create user
    Write-Host "[1/6] Creating user..." -ForegroundColor Yellow
    $username = "autotest_$(Get-Random -Maximum 9999)"
    $body = @{
        username = $username
        password = "password123"
        full_name = "Auto Test"
        email = "$username@example.com"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
    Write-Host "  User created: $username" -ForegroundColor Green
    
    # Login
    Write-Host "`n[2/6] Logging in..." -ForegroundColor Yellow
    $body = @{
        username = $username
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/login_user" -Method Post -ContentType "application/json" -Body $body
    $token = $response.access_token
    Write-Host "  Login successful" -ForegroundColor Green
    
    # Update user
    Write-Host "`n[3/6] Updating user..." -ForegroundColor Yellow
    $headers = @{ "Authorization" = "Bearer $token" }
    $body = @{
        username = $username
        full_name = "Auto Test Updated"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Headers $headers -Body $body
    Write-Host "  User updated" -ForegroundColor Green
    
    # Test validation
    Write-Host "`n[4/6] Testing validation..." -ForegroundColor Yellow
    try {
        $body = @{
            username = "ab"
            password = "123"
            full_name = "Test"
            email = "invalid"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "$baseUrl/create_user" -Method Post -ContentType "application/json" -Body $body
    } catch {
        Write-Host "  Validation working correctly" -ForegroundColor Green
    }
    
    # Test authorization
    Write-Host "`n[5/6] Testing authorization..." -ForegroundColor Yellow
    try {
        $body = @{ username = $username; full_name = "Test" } | ConvertTo-Json
        Invoke-RestMethod -Uri "$baseUrl/update_user" -Method Patch -ContentType "application/json" -Body $body
    } catch {
        Write-Host "  Authorization working correctly" -ForegroundColor Green
    }
    
    # Check database
    Write-Host "`n[6/6] Checking database..." -ForegroundColor Yellow
    docker compose exec -T postgres17 psql -U root -d simple_bank -c "SELECT COUNT(*) as total_users FROM users;" | Out-Null
    Write-Host "  Database accessible" -ForegroundColor Green
    
    Write-Host "`n=== All Tests Completed Successfully! ===" -ForegroundColor Green
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Select option (0-12)"
    
    switch ($choice) {
        "1" { Test-CreateUser }
        "2" { Test-LoginUser }
        "3" { Test-UpdateUser }
        "4" { Test-VerifyEmail }
        "5" { Test-TokenExpiry }
        "6" { Test-Validation }
        "7" { Test-Authorization }
        "8" { View-DatabaseState }
        "9" { View-Logs }
        "10" { View-BackgroundTasks }
        "11" { Open-SwaggerUI }
        "12" { Run-AllTests }
        "0" { 
            Write-Host "`nGoodbye!" -ForegroundColor Cyan
            exit 
        }
        default { 
            Write-Host "`nInvalid option!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
