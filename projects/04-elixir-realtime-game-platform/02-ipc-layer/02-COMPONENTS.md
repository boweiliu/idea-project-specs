# Code Components

## Elixir Manager Surface
- **WorkerRegistry**: Tracks dedicated workers, shared-memory handles, protocol versions, heartbeat timestamps; provides lookup APIs for dispatcher and exposes health telemetry.
- **JobDispatcher**: Accepts Phoenix-side compute requests, resolves target worker via registry, enqueues payload metadata into shared buffer, issues wake signal, handles backpressure (queue depth thresholds + drop/deferral policy).
- **ResultIngestor**: Watches completion ring, materializes worker responses into Elixir structs, reconciles with awaiting callers, and emits debug traces per `06-TELEMETRY-SAMPLES.md`.
- **PortSupervisor**: Supervises native ports/NIFs, enforces serialized hot-reload, captures stderr/stdout for diagnostics, and restarts workers with exponential backoff.
- **SchemaGuard**: Validates request/response structs against shared layout version (see `07-layout.toml`), negotiates migrations, and rejects incompatible workers with actionable errors.
- **DiagnosticsCLI**: Provides `mix ipc.inspect` command to view live registry state, buffer fill levels, worker-to-worker links, and recent errors for ops triage.

## Native Binding Layer
- **NIF Bridge**: Minimal C/Zig/Rust module exposing `shm_open`, `mmap`, futex/eventfd helpers, and safe descriptor passing into BEAM. Rustler optional; ensure ABI-compatible exports so alternative languages can plug in.
- **LayoutLoader**: Parses `07-layout.toml`, stores derived offsets in `:persistent_term`, and surfaces to both NIF and pure Elixir worker shims.
- **HandshakeDriver**: Shared behaviour that marshals CLI/env payloads for Rust/Zig workers; ensures correlation IDs and layout digest propagate consistently.

## Shared-Memory Workers (Rust / Zig)
- **ArenaAllocator**: Wraps POSIX shared memory, applies guard pages, and surfaces typed slices for request/response/control regions.
- **RingBuffer**: Lock-free SPSC queue (request + response) with batch draining. Reuse identical struct definitions across Rust/Zig to guarantee layout parity.
- **FutexGate**: Wait/wake abstraction supporting futex → eventfd → signal fallback cascade; records last-used strategy in telemetry block.
- **CodecLayer**: Encodes/decodes `Envelope` headers, validates CRC, negotiates compression flags, and maps opcodes to worker routines.
- **WorkerLoop**: Role-specific dispatcher executing simulation, pathfinding, world-gen, or analytics routines. Must respect shutdown signals and publish completion metadata.
- **HealthReporter**: Emits heartbeat counters into telemetry block every 500ms; includes last job duration, queue depth, and error codes.

## Elixir Worker Shim
- **BeamWorkerLoop**: Pure Elixir implementation honoring the same job envelope; useful for smoke tests and fallback tasks without native dependencies.
- **InMemoryRing**: ETS-backed ring buffer mirroring shared-memory semantics so dispatcher codepath remains identical.

## Worker-to-Worker Fabric
- **LinkManager**: Runs inside Elixir Manager, authorizes direct worker channels, and distributes shared offsets while maintaining audit log.
- **PeerProtocol**: Lightweight message schema for native-native chatter (e.g., simulation worker requesting precomputed path from Zig helper) with completion notifications relayed back to Manager.

## Tooling & Support
- **07-layout.toml**: Single source of truth describing shared-memory struct layout, field offsets, endianess; auto-generated bindings for Elixir, Rust, and Zig.
- **IntegrationTestHarness**: Mix task spinning loopback worker (mock compute fn) to stress-test shared buffers, fallback pathways, and verify zero-copy semantics by comparing CRCs.
- **ChaosMonkey Hooks**: Config toggles to inject artificial stalls, crashes, or oversized payloads so instrumentation and recovery paths can be validated early.
