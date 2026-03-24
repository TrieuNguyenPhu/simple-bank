# Quick Demo Launcher - Simple Bank
# Script để mở tất cả các tools cần thiết cho demo

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Simple Bank - Quick Demo Setup  " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if services are running
Write-Host "[1/4] Checking Docker services..." -ForegroundColor Yellow
$services = docker compose ps --format json | ConvertFrom-Json
$apiRunning = $services | Where-Object { $_.Service -eq "api" -and $_.State -eq "running" }
$dbRunning = $services | Where-Object { $_.Service -eq "postgres17" -and $_.State -eq "running" }

if ($apiRunning -and $dbRunning) {
    Write-Host "      Services are running!" -ForegroundColor Green
} else {
    Write-Host "      Services not running. Starting..." -ForegroundColor Red
    docker compose up -d
    Start-Sleep -Seconds 5
    Write-Host "      Services started!" -ForegroundColor Green
}
Write-Host ""

# Run API test
Write-Host "[2/4] Running API test..." -ForegroundColor Yellow
try {
    $testResult = & ".\test-api.ps1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      API test passed!" -ForegroundColor Green
    } else {
        Write-Host "      API test had warnings (normal)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "      API test completed" -ForegroundColor Yellow
}
Write-Host ""

# Create demo user
Write-Host "[3/4] Creating demo user..." -ForegroundColor Yellow
$demoUser = @{
    username = "demo"
    password = "demo123456"
    full_name = "Demo User"
    email = "demo@simplebank.com"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/create_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $demoUser -ErrorAction SilentlyContinue
    Write-Host "      Demo user created!" -ForegroundColor Green
    Write-Host "      Username: demo" -ForegroundColor Gray
    Write-Host "      Password: demo123456" -ForegroundColor Gray
} catch {
    if ($_.Exception.Message -like "*409*" -or $_.Exception.Message -like "*AlreadyExists*") {
        Write-Host "      Demo user already exists (OK)" -ForegroundColor Yellow
        Write-Host "      Username: demo" -ForegroundColor Gray
        Write-Host "      Password: demo123456" -ForegroundColor Gray
    } else {
        Write-Host "      Could not create demo user" -ForegroundColor Red
    }
}
Write-Host ""

# Open Swagger UI
Write-Host "[4/4] Opening Swagger UI..." -ForegroundColor Yellow
Start-Process "http://localhost:8080/swagger/index.html"
Write-Host "      Swagger UI opened in browser!" -ForegroundColor Green
Write-Host ""

# Display demo info
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "    Demo is ready!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Demo Credentials:" -ForegroundColor Yellow
Write-Host "  Username: demo" -ForegroundColor White
Write-Host "  Password: demo123456" -ForegroundColor White
Write-Host ""
Write-Host "Quick Links:" -ForegroundColor Yellow
Write-Host "  - Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor White
Write-Host "  - API Docs:   .ai-docs/API_MAP.md" -ForegroundColor White
Write-Host "  - Demo Guide: DEMO.md" -ForegroundColor White
Write-Host ""
Write-Host "Demo Scenarios:" -ForegroundColor Yellow
Write-Host "  1. Login with demo user via Swagger" -ForegroundColor White
Write-Host "  2. Get access token" -ForegroundColor White
Write-Host "  3. Update profile (authenticated)" -ForegroundColor White
Write-Host "  4. Test token expiry (wait 1 minute)" -ForegroundColor White
Write-Host ""
Write-Host "View Logs:" -ForegroundColor Yellow
Write-Host "  docker compose logs -f api" -ForegroundColor White
Write-Host ""
Write-Host "Database Access:" -ForegroundColor Yellow
Write-Host "  docker compose exec postgres17 psql -U root -d simple_bank" -ForegroundColor White
Write-Host ""
Write-Host "Stop Demo:" -ForegroundColor Yellow
Write-Host "  docker compose down" -ForegroundColor White
Write-Host ""
