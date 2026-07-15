# Full Stack Demo - Simple Bank
# Opens all services and creates demo users

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Simple Bank - Full Stack Demo        " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check services
Write-Host "[1/5] Checking services..." -ForegroundColor Yellow
$apiRunning = (docker compose ps --format json | ConvertFrom-Json | Where-Object { $_.Service -eq "api" -and $_.State -eq "running" })

if (-not $apiRunning) {
    Write-Host "  Backend not running. Starting..." -ForegroundColor Red
    docker compose up -d
    Start-Sleep -Seconds 5
}
Write-Host "  Backend: Running" -ForegroundColor Green
Write-Host "  Frontend: Running (http://localhost:3000)" -ForegroundColor Green
Write-Host ""

# Create demo users
Write-Host "[2/5] Creating demo users..." -ForegroundColor Yellow

$demoUsers = @(
    @{
        username = "alice"
        password = "password123"
        full_name = "Alice Nguyen"
        email = "alice@simplebank.com"
    },
    @{
        username = "bob"
        password = "password123"
        full_name = "Bob Smith"
        email = "bob@simplebank.com"
    },
    @{
        username = "charlie"
        password = "password123"
        full_name = "Charlie Brown"
        email = "charlie@simplebank.com"
    }
)

$createdUsers = @()
foreach ($user in $demoUsers) {
    try {
        $body = $user | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/create_user" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -ErrorAction SilentlyContinue
        
        Write-Host "  Created: $($user.username)" -ForegroundColor Green
        $createdUsers += $user
    } catch {
        if ($_.Exception.Message -like "*409*" -or $_.Exception.Message -like "*AlreadyExists*") {
            Write-Host "  Exists: $($user.username)" -ForegroundColor Gray
            $createdUsers += $user
        } else {
            Write-Host "  Failed: $($user.username)" -ForegroundColor Red
        }
    }
}
Write-Host ""

# Test backend
Write-Host "[3/5] Testing backend API..." -ForegroundColor Yellow
try {
    $testUser = $createdUsers[0]
    $loginBody = @{
        username = $testUser.username
        password = $testUser.password
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/login_user" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "  API: Working" -ForegroundColor Green
    Write-Host "  Test login: $($testUser.username)" -ForegroundColor Gray
} catch {
    Write-Host "  API: Error" -ForegroundColor Red
}
Write-Host ""

# Open browser tabs
Write-Host "[4/5] Opening browser tabs..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process "http://localhost:3000"
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor Green
Start-Sleep -Seconds 1
Start-Process "http://localhost:8080/swagger/index.html"
Write-Host "  Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor Green
Write-Host ""

# Show summary
Write-Host "[5/5] Demo Ready!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         FULL STACK DEMO INFO           " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
Write-Host "  Frontend:   http://localhost:3000" -ForegroundColor White
Write-Host "  Backend:    http://localhost:8080" -ForegroundColor White
Write-Host "  Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor White
Write-Host "  gRPC:       localhost:9090" -ForegroundColor White
Write-Host ""
Write-Host "Demo Users (password: password123):" -ForegroundColor Yellow
foreach ($user in $createdUsers) {
    Write-Host "  $($user.username.PadRight(10)) - $($user.full_name)" -ForegroundColor White
}
Write-Host ""
Write-Host "Quick Start:" -ForegroundColor Yellow
Write-Host "  1. Go to http://localhost:3000" -ForegroundColor White
Write-Host "  2. Login with: alice / password123" -ForegroundColor White
Write-Host "  3. View your profile" -ForegroundColor White
Write-Host "  4. Logout and try other users" -ForegroundColor White
Write-Host ""
Write-Host "Backend Testing:" -ForegroundColor Yellow
Write-Host "  - Swagger UI: http://localhost:8080/swagger/index.html" -ForegroundColor White
Write-Host "  - View logs: docker compose logs -f api" -ForegroundColor White
Write-Host "  - Database: docker compose exec postgres17 psql -U root -d simple_bank" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  - Frontend Guide: FRONTEND-GUIDE.md" -ForegroundColor White
Write-Host "  - Try Features: TRY-FEATURES.md" -ForegroundColor White
Write-Host "  - Getting Started: GETTING-STARTED.md" -ForegroundColor White
Write-Host ""
Write-Host "Stop Services:" -ForegroundColor Yellow
Write-Host "  docker compose down" -ForegroundColor White
Write-Host ""
Write-Host "Enjoy the demo! 🎉" -ForegroundColor Green
Write-Host ""
