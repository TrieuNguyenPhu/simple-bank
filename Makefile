DB_URL=postgresql://trieunguyen:trieu080604@localhost:5432/simple_bank?sslmode=disable

compose-up:
	docker compose up -d

createdb:
	docker exec -it postgres17 createdb --username=trieunguyen --owner=trieunguyen simple_bank

dropdb:
	docker exec -it postgres17 dropdb --username=trieunguyen simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

sqlc:
	sqlc generate

.PHONY: compose-up compose-down compose-restart compose-logs compose-ps compose-build createdb dropdb migrateup migratedown sqlc
