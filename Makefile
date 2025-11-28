.PHONY: build test lint fmt clean docker-up docker-down

# ─── Build ──────────────────────────────────────────────────────────────────────
build:
	@echo "==> Building RDispatch services..."
	@mkdir -p bin
	@echo "  -> gateway-api"
	@go build -ldflags="-s -w" -o bin/gateway-api ./cmd/gateway-api
	@echo "  -> delivery-worker"
	@go build -ldflags="-s -w" -o bin/delivery-worker ./cmd/delivery-worker
	@echo "==> Done."

# ─── Test ───────────────────────────────────────────────────────────────────────
test:
	@echo "==> Running tests..."
	@go test ./... ./pkg/...

test-coverage:
	@go test -coverprofile=coverage.out ./... ./pkg/...
	@go tool cover -func=coverage.out

bench:
	@go test -bench=. -benchmem ./...

# ─── Lint ───────────────────────────────────────────────────────────────────────
lint:
	@echo "==> Running linters..."
	@golangci-lint run ./... ./pkg/...

fmt:
	@gofumpt -l -w .

# ─── Docker ─────────────────────────────────────────────────────────────────────
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

# ─── Clean ──────────────────────────────────────────────────────────────────────
clean:
	rm -rf bin/ coverage.out
