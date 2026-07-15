# 🚀 Setup Guide - Simple Bank

Hướng dẫn chi tiết để setup và chạy Simple Bank project trên Windows.

## ✅ Yêu cầu hệ thống

- [x] **Docker Desktop** 20.10+ với Docker Compose
- [x] **Go** 1.26+ (cho development)
- [x] **Make** (optional, có thể dùng Git Bash hoặc cài GNU Make for Windows)
- [ ] **Node.js** 20+ (chỉ cần nếu chạy frontend)

## 🎯 Phương pháp 1: Chạy nhanh với Docker Compose (Khuyến nghị)

### Bước 1: Khởi động tất cả services

```bash
docker compose up --build -d
```

**Giải thích các flags:**
- `--build`: Build lại image (cần lần đầu hoặc khi có thay đổi code)
- `-d`: Chạy ở background (detached mode)

### Bước 2: Kiểm tra services đã chạy chưa

```bash
docker compose ps
```

Bạn sẽ thấy 3 services:
- `postgres17` - Database
- `redis` - Task queue
- `api` - Backend server

### Bước 3: Xem logs (nếu cần debug)

```bash
# Xem tất cả logs
docker compose logs -f

# Chỉ xem logs của API
docker compose logs -f api

# Chỉ xem logs của PostgreSQL
docker compose logs -f postgres17
```

### Bước 4: Kiểm tra API hoạt động

**Mở trình duyệt:**
- Swagger UI: http://localhost:8080/swagger/index.html
- Hoặc test bằng curl:

```bash
curl http://localhost:8080/v1/create_user -X POST -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"password123\",\"full_name\":\"Test User\",\"email\":\"test@example.com\"}"
```

### Bước 5: Dừng services

```bash
# Dừng nhưng giữ data
docker compose down

# Dừng và XÓA data (database sẽ bị reset)
docker compose down -v
```

---

## 🛠️ Phương pháp 2: Chạy Backend Local (Cho Development)

### Bước 1: Chỉ khởi động PostgreSQL và Redis

```bash
# Chạy PostgreSQL
docker compose up -d postgres17

# Chạy Redis (cần port 6379 exposed)
docker run --name redis -p 6379:6379 -d redis:7-alpine
```

### Bước 2: Tạo database (chỉ cần lần đầu)

```bash
# Trên Windows PowerShell/CMD
docker exec -it postgres17 psql -U root -c "CREATE DATABASE simple_bank;"

# Hoặc nếu database đã tồn tại, bỏ qua lỗi
```

### Bước 3: Download dependencies

```bash
go mod download
```

### Bước 4: Chạy migrations (nếu chưa có Make)

**Option A: Dùng Make (nếu đã cài)**
```bash
make migrateup
```

**Option B: Không dùng Make**
```bash
# Cài golang-migrate trước (chỉ lần đầu)
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Chạy migration
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up
```

### Bước 5: Chạy backend

```bash
go run main.go
```

Bạn sẽ thấy:
```
{"level":"info","time":"...","message":"db migrated successfully"}
{"level":"info","time":"...","message":"start task processor"}
{"level":"info","time":"...","message":"start gRPC server at 0.0.0.0:9090"}
{"level":"info","time":"...","message":"start HTTP gateway server at 0.0.0.0:8080"}
```

### Bước 6: Test API

Mở Swagger UI: http://localhost:8080/swagger/index.html

---

## 🎨 Phương pháp 3: Chạy Frontend (Optional)

### Bước 1: Đảm bảo backend đang chạy

Kiểm tra: http://localhost:8080/swagger/index.html

### Bước 2: Setup frontend

```bash
cd frontend
npm install
```

### Bước 3: Chạy dev server

```bash
npm run dev
```

Frontend sẽ chạy tại: http://localhost:3000

### Bước 4: Tạo user và login

1. Mở http://localhost:8080/swagger/index.html
2. Tạo user mới qua endpoint `POST /v1/create_user`
3. Quay lại http://localhost:3000 và login

---

## 🧪 Testing

### Chạy tất cả tests

```bash
# Cần PostgreSQL đang chạy và migration đã áp dụng
make test

# Hoặc
go test -v -cover -short ./...
```

### Chỉ chạy unit tests (không cần DB)

```bash
go test -v -short ./api/... ./token/... ./util/...
```

---

## 🐛 Troubleshooting

### Lỗi: Port 5432 đã được sử dụng

```bash
# Tìm process đang dùng port 5432
netstat -ano | findstr :5432

# Dừng PostgreSQL khác hoặc thay đổi port trong docker-compose.yaml
```

### Lỗi: Migration failed

```bash
# Xem logs chi tiết
docker compose logs api

# Reset database
docker compose down -v
docker compose up -d postgres17
# Đợi vài giây cho DB khởi động
docker compose up api
```

### Lỗi: Cannot connect to database

```bash
# Kiểm tra PostgreSQL đã ready chưa
docker compose exec postgres17 pg_isready -U root

# Nếu chưa ready, đợi thêm vài giây
```

### Lỗi: Token symmetric key invalid

`TOKEN_SYMMETRIC_KEY` phải đúng 32 ký tự. Kiểm tra file `app.env`:
```bash
TOKEN_SYMMETRIC_KEY=12345678901234567890123456789012
```

### Lỗi: Redis connection refused (khi chạy local)

```bash
# Kiểm tra Redis đang chạy
docker ps | findstr redis

# Nếu không thấy, khởi động lại
docker run --name redis -p 6379:6379 -d redis:7-alpine
```

---

## 📋 Các lệnh hữu ích

### Docker Compose Commands

```bash
# Khởi động tất cả
docker compose up -d

# Khởi động và build lại
docker compose up --build -d

# Xem logs realtime
docker compose logs -f

# Xem logs của 1 service
docker compose logs -f api

# Xem status
docker compose ps

# Dừng tất cả
docker compose down

# Dừng và xóa volumes (reset data)
docker compose down -v

# Restart một service
docker compose restart api
```

### Development Commands (với Make)

```bash
make postgres       # Start PostgreSQL container
make redis          # Start Redis container
make createdb       # Create database
make dropdb         # Drop database
make migrateup      # Apply all migrations
make migratedown1   # Rollback last migration
make sqlc           # Generate Go code from SQL
make proto          # Generate protobuf/gRPC code
make mock           # Generate mocks for testing
make test           # Run all tests
make server         # Run backend locally
```

### Database Commands

```bash
# Connect to PostgreSQL
docker compose exec postgres17 psql -U root -d simple_bank

# Backup database
docker compose exec postgres17 pg_dump -U root simple_bank > backup.sql

# Restore database
docker compose exec -T postgres17 psql -U root simple_bank < backup.sql
```

---

## 🎯 Quick Start Summary

**Cách nhanh nhất để bắt đầu:**

```bash
# 1. Clone repo (nếu chưa có)
git clone <repo-url>
cd simple-bank

# 2. Khởi động tất cả
docker compose up --build -d

# 3. Đợi 10 giây cho DB khởi động, sau đó kiểm tra
docker compose logs api

# 4. Mở Swagger UI
start http://localhost:8080/swagger/index.html
```

**Thế thôi! 🎉**

---

## 📚 Next Steps

Sau khi setup xong, hãy xem:
- [.ai-docs/AI_NOTES.md](.ai-docs/AI_NOTES.md) - Hướng dẫn development
- [.ai-docs/API_MAP.md](.ai-docs/API_MAP.md) - API reference đầy đủ
- http://localhost:8080/swagger/index.html - Interactive API docs

## 🆘 Cần trợ giúp?

- Kiểm tra [Troubleshooting](#-troubleshooting) section phía trên
- Xem logs: `docker compose logs -f`
- Đọc [.ai-docs/](.ai-docs/) để hiểu rõ hơn về architecture
