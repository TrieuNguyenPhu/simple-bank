createdb:
	docker exec -it postgres17 createdb --username=trieunguyen --owner=trieunguyen simple_bank

dropdb:
	docker exec -it postgres17 dropdb --username=trieunguyen simple_bank

migrateup:
	docker exec -it postgres17 migrate -path db/migration -database "postgresql://trieunguyen:trieu080604@localhost:5432/simple_bank?sslmode=disable" -verbose up

migratedown:
	docker exec -it postgres17 migrate -path db/migration -database "postgresql://trieunguyen:trieu080604@localhost:5432/simple_bank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

.PHONY: createdb dropdb migrateup migratedown sqlc