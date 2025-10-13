# LLM Prompt Seeds

1. **Dedicated Worker Registry (Elixir)**
   ```
   You are writing Elixir OTP code for the Elixir real-time game platform. Implement a `GamePlatform.IPC.WorkerRegistry` GenServer that manages dedicated workers. Each worker record stores: `id`, `role`, `layout_version`, `shmem_fd`, `request_offset`, `response_offset`, `heartbeat_at`, and `status` (`:ready | :degraded | :offline`). Expose APIs:
   - `register(worker_record)`
   - `lookup(role)`
   - `mark_degraded(id, reason)`
   - `heartbeat(id, metrics)`
   Persist registry state in ETS for fast lookups, emit `:telemetry` events on state changes, and enforce that `layout_version` matches the latest `layout.toml` digest. Include module docs summarizing behaviour and public API.
   ```

2. **Rust Worker Loop Skeleton**
   ```
   You are creating the Rust executable for a Phoenix shared-memory worker. Implement a binary that:
   - Parses CLI flags: `--role`, `--request-fd`, `--response-fd`, `--layout-toml`, `--telemetry-endpoint`.
   - Opens the provided shared memory regions using `memmap2`.
   - Waits on a futex-backed flag; on wake, drains all pending jobs from the request ring buffer, runs a placeholder `simulate_tick(payload)` stub, writes responses, and signals completion by updating the response head and waking the futex.
   - Periodically (every 1s) publishes health metrics (queue depth, avg job duration) to the telemetry endpoint over OTLP.
   Use `nix` for POSIX syscalls, structure code into modules (`ipc`, `codec`, `telemetry`), and include TODOs where domain logic will plug in.
   ```

3. **Instrumentation & Backpressure Tests**
   ```
   Generate Elixir ExUnit tests for `GamePlatform.IPC.JobDispatcher` that cover:
   - Successful dispatch with telemetry assertions (`ipc.dispatch.latency`, `ipc.worker.runtime`).
   - Backpressure when queue depth exceeds configurable max; dispatcher should return `{:error, :queue_full}` and record `ipc.queue.backpressure`.
   - Eventfd fallback path triggered by injecting a futex error (mocked NIF).
   Use `StreamData` to fuzz payload sizes and ensure schema validation rejects oversized requests cleanly.
   ```

4. **Diagnostics CLI**
   ```
   Write a `Mix.Tasks.Ipc.Inspect` task that prints live IPC state in a human-friendly table. It should query `WorkerRegistry` for all workers, display role, status, heartbeat age, current queue depth, and last error reason. Include options:
   - `--json` to emit machine-readable output
   - `--watch` to refresh every 2 seconds until interrupted
   The task must handle unavailable registry (print actionable message) and exit non-zero on errors.
   ```
