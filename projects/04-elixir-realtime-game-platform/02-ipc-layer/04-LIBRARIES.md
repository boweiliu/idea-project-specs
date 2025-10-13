# Library & Framework Notes

## Elixir / OTP Glue
- **`rustler`**: Easiest bridge for dirty NIFs and shared binary resources; supports resource handles that wrap file descriptors. Use `schedule = :dirty_io` for blocking shmem ops. Risk: adds build dependency on Rust toolchain.
- **`:telemetry` + `opentelemetry`**: Core instrumentation stack; pair with `opentelemetry_exporter` (OTLP) to stream metrics/traces; reuse across broader platform.
- **`:persistent_term`**: Store immutable layout metadata generated from `07-layout.toml` to avoid repeated parsing on hot path.
- **`:telemetry_poller`**: Gather periodic worker health metrics from shared memory without bespoke GenServers.
- **`:mix release` hooks**: Add pre-start script to validate `07-layout.toml` compatibility before boot; prevents production drift.

## Rust Worker Stack
- **`nix` crate**: Thin POSIX wrappers for `shm_open`, `mmap`, `futex`, `eventfd`; battle-tested and actively maintained.
- **`memmap2`**: Ergonomic memory-mapped file abstraction; falls back to raw `libc` if finer control needed.
- **`crossbeam`**: Offers lock-free queues and atomics; reuse logic for ring buffer helpers.
- **`serde` + `bincode`**: Compact binary serialization for payloads when data exceeds simple structs; ensure deterministic endianness.
- **`opentelemetry` crate**: Export worker-side spans/metrics; integrate via OTLP/HTTP so telemetry aligns with Elixir side.
- **`anyhow` + `thiserror`**: Uniform error context; pipe into shared health reporter for debugging.

## Zig Option Set
- **`std.posix`**: Covers `mmap`, `shm_open`, futex wrappers; ideal for lean workers if Rust toolchain overhead is concern.
- **`mach-eventfd` wrapper**: Community package offering eventfd bindings; vet stability before adoption.

## Testing & Tooling
- **`criterion`**: Micro-bench requests vs responses to tune buffer sizes and futex wake cadence.
- **`cargo nextest`**: Parallel test runner; integrates with CI for worker crates.
- **`benchee` (Elixir)**: Profile dispatcher hot path, especially serialization overheads.
- **`propcheck` / `stream_data`**: Property tests to fuzz request/response encoding and ensure round-trip safety.
