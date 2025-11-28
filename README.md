# RDispatch

Smart notification gateway with priority-based delivery, multi-channel routing, and SLA enforcement.

## Architecture

```
                ┌──────────────┐
Clients ──────▶ │  Gateway API  │ ──▶ Priority Queue (heap) ──▶ NATS JetStream
                │  REST + gRPC  │                                     │
                └──────────────┘                                     ▼
                                                          ┌─────────────────┐
                                                          │ Delivery Worker  │
                                                          ├─────────────────┤
                                                          │ Webhook (HMAC)  │
                                                          │ Telegram Bot    │
                                                          │ Slack Incoming  │
                                                          │ Email (SMTP)    │
                                                          │ Log (stdout)    │
                                                          └─────────────────┘
```

## Features

- **Priority Queue with SLA** — CRITICAL: <1s, HIGH: <10s, NORMAL: <60s, LOW: best-effort. Custom heap implementation
- **Multi-channel delivery** — Webhook, Telegram, Slack, Email, Log
- **Smart deduplication** — content fingerprint prevents duplicate notifications within TTL window
- **Per-client rate limiting** — token bucket algorithm
- **Retry with exponential backoff** — configurable max attempts with jitter
- **Dead Letter Queue** — failed notifications stored for replay
- **Delivery analytics** — success rate, latency per channel

## Quick Start

```bash
# Start infrastructure
docker-compose up -d

# Build
make build

# Run (separate terminals)
./bin/gateway-api        # REST API on :8090
./bin/delivery-worker    # Consumes from NATS

# Send a test notification
curl -X POST http://localhost:8090/api/v1/notifications \
  -H "Content-Type: application/json" \
  -d '{"priority":"CRITICAL","recipient":"admin@example.com","subject":"Alert","body":"Test","channel":"log"}'
```

## Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| API | go-chi/chi | Lightweight, stdlib-compatible HTTP router |
| Broker | NATS JetStream | Low-latency, built-in DLQ, simpler ops than Kafka |
| Database | PostgreSQL + pgx | Templates, delivery receipts, analytics |
| Queue | Custom heap | O(log n) insert/extract, SLA-aware priority |
| Observability | zap + Prometheus + OpenTelemetry | Structured logs, metrics, distributed tracing |

## Configuration

All configuration via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `GATEWAY_HTTP_PORT` | 8090 | REST API port |
| `GATEWAY_NATS_URL` | nats://localhost:4222 | NATS server |
| `DELIVERY_NATS_URL` | nats://localhost:4222 | NATS server |
| `DELIVERY_WEBHOOK_URL` | — | Webhook endpoint |
| `DELIVERY_WEBHOOK_SECRET` | — | HMAC-SHA256 signing key |
| `DELIVERY_TELEGRAM_TOKEN` | — | Telegram bot token |
| `DELIVERY_TELEGRAM_CHAT` | — | Telegram chat ID |
| `DELIVERY_SLACK_WEBHOOK` | — | Slack incoming webhook URL |

## License

MIT
