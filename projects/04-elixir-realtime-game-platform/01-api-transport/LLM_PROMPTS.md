# Suggested LLM Prompts

## Implement Transport Session Manager
```
You are pairing on the Elixir `TransportSessionManager` (`lib/game_platform/transport/session_manager.ex`). 
Goal: supervise multi-transport sessions (WebSocket, REST, mailbox) with shared state, TTL, and keepalives.
Deliver:
- `start_link/1`, `init/1` with ETS table bootstrap.
- APIs: `open_session(opts)`, `get(session_id)`, `touch(session_id, metadata)`, `expire_idle()`.
- Enforce configurable TTL (minutes) and max mailbox depth.
- Emit `[:transport, :session, :open|:touch|:expire]` telemetry events.
Follow configurations from `config/runtime.exs`: `:session_ttl_minutes`, `:max_mailbox_messages`.
Return code only; no commentary.
```

## Build REST Long-Poll Controller Test
```
Context: Phoenix controller `RestPollController` handling GET `/poll/:session_id`.
Write an ExUnit test module under `test/game_platform/transport/rest_poll_controller_test.exs` that:
1. boots the Phoenix endpoint,
2. seeds the `MailboxStore` with messages,
3. simulates GET with `since` cursor and asserts streamed JSON payload + reconnection hints,
4. covers timeout path (30s default) using `@endpoint` configuration.
Include setup blocks, use `Phoenix.ConnTest`, and assert telemetry events captured via `with_telemetry_events`.
```

## Instrument Mailbox Store
```
We need telemetry + metrics for `MailboxStore`.
Add instrumentation emitting `[:transport, :mailbox, :enqueue]`, `[:transport, :mailbox, :deliver]`, `[:transport, :mailbox, :drop]`.
Ensure ETS counters updated atomically.
Document metric names and units in `instrumentation.md`.
```

## Load Test Script Outline
```
Draft a k6 script template that stresses REST polling at 200 rps, with jittered long-poll durations.
Include setup to fetch auth token, scenario for message fetch, and thresholds for latency.
Reference transport endpoints: `/actions/:session_id`, `/poll/:session_id`.
```
