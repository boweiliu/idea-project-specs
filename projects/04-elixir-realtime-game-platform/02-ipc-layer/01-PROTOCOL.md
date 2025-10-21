# IPC Protocol Blueprint

Anchors the multi-component contract across Elixir managers, native bindings, and heterogeneous workers. Emphasize determinism, forward-compat layout negotiation, and precise signaling semantics.

## Participants

- **Elixir Manager Node**
  - Phoenix app + supervision tree.
  - Owns shared-memory arenas and synchronization words.
  - Exposes Port/NIF interface (raw C/Zig/Rustler acceptable) that brokers shared handles to native workers.
- **Elixir Worker Node**
  - Pure Elixir processes handling lightweight jobs or acting as shims during prototyping.
  - Communicates via same dispatcher/ingestor interfaces but without shared-memory handoff (uses in-memory queue with identical envelope structure).
- **Rust Worker Node**
  - Native executable optimized for compute-heavy tasks.
  - Links against POSIX bindings (Rustler optional; raw NIF C glue permitted).
  - Must honor layout version handshake and publish health metrics via shared telemetry block.
- **Zig Worker Node**
  - Alternative native executable mirroring Rust behaviour for roles favoring Zig (low footprint, systems-level tweaks).
  - Connects through identical shared-memory protocol; compiled layout header generated from `07-layout.toml`.
- **Worker-to-Worker Channel**
  - Optional low-latency coordination path (e.g., Rust simulation worker ↔ Zig pathfinding worker).
  - Uses shared memory slices brokered by Elixir Manager, but negotiation still flows through control messages so Manager observes topology.

## Lifecycle

1. **Arena Provisioning**
   - Elixir Manager creates POSIX shared memory object per worker role (`/gp_ipc/<role>`), sizes per `07-layout.toml`.
   - Guard pages inserted before/after ring buffers.
2. **Binding Negotiation**
   - Manager loads native binding (raw C NIF, Rustler, or Zig NIF) that exposes `init(worker_spec)` returning FD descriptors and layout digest.
   - Binding verifies `schema_version` and `crc32` hash; emits actionable error if mismatch.
3. **Handshake**
   - Worker process receives CLI/env payload containing:
     - Role identifier and responsibilities.
     - File descriptor numbers for request/response, control, telemetry segments.
     - Expected layout digest (SHA256 of `07-layout.toml`).
     - Signal strategy preference (futex → eventfd → signals).
4. **Heartbeat & Control**
   - Worker writes status struct into telemetry block every 500ms (configurable).
   - Manager polls and updates `WorkerRegistry` heartbeat timestamps; stale heartbeats mark worker `:degraded`.
5. **Job Dispatch**
   - Manager enqueues jobs into request ring with envelope `{opcode, payload_len, correlation_id, flags}`.
   - Wakes worker via selected signaling primitive.
6. **Completion & Acknowledgement**
   - Worker writes response envelope mirroring request shape, toggles completion flag, and wakes Manager.
   - Manager ingests responses, correlates with pending callers, and logs via `06-TELEMETRY-SAMPLES.md`.
7. **Worker-to-Worker Coordination (Optional)**
   - Manager issues `link` control message granting shared buffer offsets to two workers.
   - Workers coordinate via agreed protocol (e.g., handshake ring) but send summary notifications back to Manager for observability.
8. **Shutdown**
   - Manager sets `shutdown_flag` in control page, sends wake.
   - Worker drains outstanding jobs, flips `status` to `:offline`, unmaps memory, exits cleanly.

## Envelope Format

```
struct Envelope {
  uint16_t version;
  uint16_t opcode;
  uint32_t flags;
  uint32_t payload_len;
  uint64_t correlation_id;
  uint64_t checksum;       // CRC32 placed in upper bits for padding
  uint64_t reserved[2];    // future use, keeps header 64 bytes
};
```

- `flags` bitmask indicates compression, priority, or worker-to-worker routing.
- `reserved` fields reserved for timeline markers or QoS hints.

## ASCII Layout Map

```
┌───────────────────────────────────────────────────────────┐
│ Shared Control Page (4 KB)                                │
│   0x00 futex_word             → primary wait/wake flag     │
│   0x08 eventfd_counter        → fallback wake counter      │
│   0x10 shutdown_flag          → manager-initiated stop     │
│   0x18 layout_digest[32]      → schema hash                │
│   0x38 reserved               → future control knobs       │
├───────────────────────────────────────────────────────────┤
│ Guard Page (4 KB, PROT_NONE)                              │
├───────────────────────────────────────────────────────────┤
│ Request Ring Buffer Region                                │
│   Header: head/tail indices, slot_count, slot_stride       │
│   ┌──────────┬──────────┬──────────┬──────────┐            │
│   │Slot 0 hdr│Slot 0 payload (≤64 KB)         │            │
│   ├──────────┼──────────┼──────────┼──────────┤            │
│   │Slot 1 hdr│Slot 1 payload                   │            │
│   ├──────────┴──────────┴──────────┴──────────┤            │
│   │ ...                                       │            │
│   └────────────────────────────────────────────┘            │
├───────────────────────────────────────────────────────────┤
│ Guard Page (4 KB, PROT_NONE)                              │
├───────────────────────────────────────────────────────────┤
│ Response Ring Buffer Region                               │
│   Same layout as request ring                             │
├───────────────────────────────────────────────────────────┤
│ Guard Page (4 KB, PROT_NONE)                              │
├───────────────────────────────────────────────────────────┤
│ Telemetry Block (cache-line aligned struct)               │
│   last_heartbeat_unix_ms                                  │
│   avg_job_duration_us                                     │
│   jobs_completed_total                                    │
│   queue_depth_current                                     │
│   queue_depth_high_watermark                              │
│   fallback_path (enum)                                    │
│   reserved (future metrics)                               │
├───────────────────────────────────────────────────────────┤
│ Guard Page (4 KB, PROT_NONE)                              │
└───────────────────────────────────────────────────────────┘
```

## Binding Strategy

- Default to lightweight NIF exposing `shm_open`, `mmap`, and signaling wrappers; can be authored in C, Zig, or Rust.
- Provide optional Rustler helper for teams already invested in Rust; ensure both paths share FFI boundary defined by `Envelope`.
- Expose same APIs to Elixir worker processes so test harnesses can run without native dependencies (in-memory ring simulation).

Document any protocol changes in this file first, then update `07-layout.toml` and `02-COMPONENTS.md` to match so implementers have a canonical reference.
