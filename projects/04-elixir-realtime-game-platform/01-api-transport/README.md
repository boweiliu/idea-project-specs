# API Transport Subproject

## Goal & Problem
- Deliver multi-transport client connectivity (Phoenix Channels, REST long-poll, curl mailbox) that routes game actions and world updates with <50 ms median latency and deterministic ordering.
- Remove superfluous serialization hops between transports and simulation workers while enforcing session security for both authenticated and scriptable clients.

## Scope & Deliverables
- Production-ready transport surface for WebSocket, REST, and mailbox clients with shared session contracts.
- Configurable session lifecycle, rate limits, and retention policies surfaced in Phoenix config.
- Transport telemetry + trace propagation compatible with platform-wide observability (metrics, logs, traces).
- Migration-ready documentation for hand-off to implementation team and external API consumers.

## Key Decisions & Constraints
- Phoenix app stays single Phoenix.Endpoint; transports plug into Endpoint router/channels.
- Authentication undecided (QUESTIONS.md #4); design assumes pluggable token verifier that can be swapped without invasive rewrites.
- Session expiration windows, mailbox retention, and polling timeout unresolved (QUESTIONS.md #1-3); note the touchpoints in components below.
- CLI mailbox must tolerate offline workflows: server queues outbound messages until TTL or explicit ACK.
- Transport layer emits telemetry events on every send/receive for back-pressure visibility.

## Code Components To Build
- `lib/game_platform/transport/application.ex`: supervision tree mounting routers, channels, and background workers.
- `TransportSessionManager` (`GenServer`): owns session registry, transport-agnostic metadata, TTL enforcement, token validation hooks, keepalive timers.
- `TransportIdGenerator`: monotonic ID generator (ULID/UUIDv7) to avoid collisions across transports.
- `ChannelGateway` (`Phoenix.Channel`): handshake, presence sync, fast-path outbound diff streaming, flow control (throttled push).
- `RestPollController` (`Phoenix.Controller`): long-poll GET `/poll/:session_id`, streaming responses via `Plug.Conn.send_chunked`, handles timeout negotiation and reconnection hints.
- `RestActionController`: POST `/actions/:session_id`, validates payload, enqueues into router, returns ACK/next-poll hints.
- `MailboxController`: GET `/mailbox/:id/messages` + POST `/mailbox/:id/actions`, wraps queue cursor & delivery semantics, supports `since` param for incremental fetch, enforces max queue length.
- `MailboxStore` (`ETS` backed): per-session message queues with TTL, ack tracking, optional compression for bulk payloads.
- `MessageRouter` (`GenServer` or `Broadway` pipeline): normalizes inbound messages, dispatches to simulation, fans out responses to correct transport, enforces ordering guarantees.
- `TransportCodec`: shared encode/decode layer (Erlang term binary for internal, JSON/protobuf for clients) with schema versioning.
- `TransportRateLimiter`: pluggable (default `ExRated`) guard to prevent DoS across transports.
- `TransportTelemetry`: instrumentation module emitting `[:transport, :receive]`, `[:transport, :send]`, `[:transport, :drop]` events (metrics/traces).
- `TransportBackpressureSupervisor`: monitors queue depth, triggers load-shedding strategies (drop oldest mailbox messages, pause polling).

## Flows To Instrument/Test
- Session creation via each transport (WS connect handshake, REST auth, mailbox activation) → expect consistent session IDs + metadata.
- Message dispatch path: client action → router → worker dispatch → response broadcast; verify ordering, latency, error propagation.
- Mailbox fetch cycles: message enqueue, fetch with ACK, TTL expiry, overflow eviction.
- REST long-poll reconnect: client timeout, resume with `since` cursor, ensure idempotent responses.
- Backpressure scenarios: artificially fill outbound queues, confirm rate limiter + load shedding triggers telemetry and protective behavior.
- Transport failover: upgrade from REST to WebSocket mid-session without losing state (session manager migration path).
- Observability: ensure telemetry events surface metrics/traces/log correlation IDs per flow.

## Artifacts To Produce (Next Contributors)
- API contract doc (request/response schemas, error codes, pagination) once open questions #1-4 settle.
- Session policy matrix covering TTL, keepalive cadence, auth requirements per transport.
- Handbook entries for running transport-focused load tests and chaos drills.

## Open Items Requiring Input
- Message retention TTL & queue depth caps (QUESTIONS.md #1).
- Default long-poll timeout + reconnection jitter (QUESTIONS.md #2).
- Session inactivity timeout + keepalive cadence (QUESTIONS.md #3).
- Authentication strategy (token-based vs unauthenticated with rate limits) (QUESTIONS.md #4).

