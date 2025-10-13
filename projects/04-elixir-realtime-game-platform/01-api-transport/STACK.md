# Library & Framework Notes

## Core Phoenix Stack
- **Phoenix 1.7 Channels**: Native WebSocket transport, presence, intercepts. Use `Phoenix.Socket.Transport` for custom protocol tweaks.
- **Bandit** (preferred HTTP adapter): Unified HTTP/1.1 + HTTP/2 + WebSocket, async responses friendly to long-polling.
- **Plug.Telemetry** + **Phoenix.LoggerJSON**: Structured request logs + correlation IDs across transports.

## Session & Routing Helpers
- **Phoenix.Token**: HMAC-signed tokens for session bootstrap; configurable max age matches TTL decisions (#1-3).
- **NimbleOptions**: Validate transport config (timeouts, limits) at compile time.
- **Registry** or **Horde**: Distributed process registry for session manager (choose once multiplayer footprint defined).

## Rate Limiting & Abuse Prevention
- **ExRated** (ETS counter buckets) or **Hammer**: minimal dependencies, token bucket semantics; plug into controllers/channels.
- **Req/Slib** optional: enforce IP-based bans if anonymous mailbox allowed.

## Queue & State Storage
- **ETS** + **:persistent_term** for mailbox queues and session metadata; leverage `:ets.update_counter` for metrics.
- **Cachex** alternative if eviction policies need richer callbacks.

## Serialization
- **Jason**: JSON encoding for REST/mailbox.
- **protobuf-elixir** or **msgpax** (MessagePack) if binary framing desired for bandwidth-sensitive clients.
- **:erlang.term_to_binary** reserved for internal Router ↔ Worker payloads.

## Observability
- **Telemetry.Metrics**, **TelemetryPoller**: feed metrics into Prometheus via **prom_ex** or StatsD via **telemetry_metrics_statsd**.
- **OpenTelemetry** instrumentation (`opentelemetry_telemetry`, `opentelemetry_phoenix`) for trace propagation.
- **LoggerFileBackend** (optional) for request audit logs.

## Testing & Tooling
- **Mox** for mocking worker interfaces during transport tests.
- **Wallaby** or **Playwright** (external) for full-stack transport validation (WS + REST).
- **k6** or **Vegeta** for load testing (document scripts under `/ops/load-tests` later).

## CLI Mailbox Support
- **Finch** for server-initiated HTTP clients if we need to push webhooks/notifications.
- **Plug.Parsers** configuration ensuring large JSON payloads handled without DOS.
- **Erlang :queue** for per-session message buffers if ETS not enough; pair with `:gb_sets` for deduplication.

## Future Options To Monitor
- **Livebook Smart Cells** for interactive transport debugging.
- **Nebulex** if distributed cache required once scaling to multiple nodes.
