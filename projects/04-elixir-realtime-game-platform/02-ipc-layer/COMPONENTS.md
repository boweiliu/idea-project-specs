# Code Components

## Elixir OTP Surface
- **WorkerRegistry**: Tracks dedicated workers, shared-memory handles, protocol versions, heartbeat timestamps; provides lookup APIs for dispatcher and exposes health telemetry.
- **JobDispatcher**: Accepts Phoenix-side compute requests, resolves target worker via registry, enqueues payload metadata into shared buffer, issues wake signal, handles backpressure (queue depth thresholds + drop/deferral policy).
- **ResultIngestor**: Watches completion ring, materializes worker responses into Elixir structs, reconciles with awaiting callers, and emits telemetry events.
- **PortSupervisor**: Supervises native ports/NIFs, enforces serialized hot-reload, captures stderr/stdout for diagnostics, and restarts workers with exponential backoff.
- **SchemaGuard**: Validates request/response structs against shared layout version (see `layout.toml`), negotiates migrations, and rejects incompatible workers with actionable errors.
- **TelemetryBridge**: Emits `:telemetry` / OpenTelemetry spans for enqueue latency, worker runtime, buffer utilization, crash counts, and signal fallback activations; forwards counters to observability stack.
- **DiagnosticsCLI**: Provides `mix ipc.inspect` command to view live registry state, buffer fill levels, and recent errors for ops triage.

## Shared Memory Runtime (Rust-first, Zig optional)
- **ArenaAllocator**: Wraps `shm_open` + `mmap`, segments fixed pages per worker, tracks offsets, enforces guard pages, and surfaces file descriptors back to Elixir via control channel.
- **RingBuffer**: Lock-free SPSC ring (request + response) with head/tail indices in shared header; supports batching and vectorized copies; ensures natural alignment and padding for futex cache lines.
- **FutexGate**: Thin wrapper over `libc::futex` for wait/wake semantics with pluggable timeouts; records metrics into shared telemetry block; exposes `eventfd` fallback when futex unavailable.
- **SignalFallback**: Minimal POSIX signal handler (SIGUSR1/2) path used only if futex/eventfd unsupported; throttles signal storms and confirms delivery acknowledgements.
- **CodecLayer**: Defines binary format (header with op code, payload size, correlation id, checksum) shared with Elixir via `layout.toml`; includes serde helpers for simulation payloads.
- **WorkerLoop**: Dedicated executable per job family; pulls jobs, executes compute routine (simulation ticks, pathfinding, etc.), writes results, updates completion index, and handles cancellation flag.
- **HealthReporter**: Periodically writes health heartbeat + perf counters (ticks/s, avg job duration, memory usage) into shared status struct; allows Elixir to detect stalls without extra syscalls.

## Tooling & Support
- **layout.toml**: Single source-of-truth describing shared-memory struct layout, field offsets, endianess; auto-generated bindings for Elixir (via `:persistent_term`) and Rust/Zig (via build script).
- **IntegrationTestHarness**: Mix task spinning loopback worker (mock compute fn) to stress-test shared buffers, fallback pathways, and verifies zero-copy semantics by comparing CRCs.
- **ChaosMonkey Hooks**: Config toggles to inject artificial stalls, crashes, or oversized payloads so instrumentation and recovery paths can be validated early.
