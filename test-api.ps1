# Simple Bank API Test Script
# Chạy script này để test các API endpoints

Write-Host "Testing Simple Bank API..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Create User
Write-Host "Test 1: Creating new user..." -ForegroundColor Yellow
$createUserBody = @{
    username = "alice_$(Get-Random -Maximum 9999)"
    password = "password123"
    full_name = "Alice Nguyen"
    email = "alice$(Get-Random -Maximum 9999)@example.com"
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/create_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $createUserBody
    
    Write-Host "User created successfully!" -ForegroundColor Green
    Write-Host "   Username: $($createResponse.user.username)" -ForegroundColor Gray
    Write-Host "   Email: $($createResponse.user.email)" -ForegroundColor Gray
    Write-Host ""
    
    $username = $createResponse.user.username
    
    # Test 2: Login
    Write-Host "Test 2: Logging in..." -ForegroundColor Yellow
    $loginBody = @{
        username = $username
        password = "password123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/login_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host "   Access Token: $($loginResponse.access_token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "   Session ID: $($loginResponse.session_id)" -ForegroundColor Gray
    Write-Host ""
    
    $accessToken = $loginResponse.access_token
    
    # Test 3: Update User (with authentication)
    Write-Host "Test 3: Updating user profile..." -ForegroundColor Yellow
    $updateBody = @{
        username = $username
        full_name = "Alice Tran"
    } | ConvertTo-Json
    
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/update_user" `
        -Method Patch `
        -ContentType "application/json" `
        -Headers $headers `
        -Body $updateBody
    
    Write-Host "User updated successfully!" -ForegroundColor Green
    Write-Host "   New Full Name: $($updateResponse.user.full_name)" -ForegroundColor Gray
    Write-Host ""
    
    # Success Summary
    Write-Host "All tests passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "   - Open Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor Gray
    Write-Host "   - View API logs: docker compose logs -f api" -ForegroundColor Gray
    Write-Host "   - Run frontend: cd frontend; npm install; npm run dev" -ForegroundColor Gray
    
} catch {
    Write-Host "Test failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Check if services are running: docker compose ps" -ForegroundColor Gray
    Write-Host "   - View logs: docker compose logs api" -ForegroundColor Gray
    Write-Host "   - Restart services: docker compose restart" -ForegroundColor Gray
}
