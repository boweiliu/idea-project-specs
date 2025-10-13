# Debug Telemetry Samples

> Goal: convenient instrumentation for tests and local runs; emits structured logs without requiring full observability stack. Compatible with `:telemetry` if we add it later.

## Helper Module

```elixir
defmodule GamePlatform.IPC.DebugTrace do
  @moduledoc """
  Lightweight tracing helpers for IPC dispatch and completion events.
  Designed for use in tests; can forward to :telemetry later.
  """

  require Logger

  @type tags :: %{required(:worker) => atom(), optional(:job) => binary(), optional(:corr_id) => binary()}

  def log_dispatch(tags, payload_size_bytes) when is_map(tags) do
    Logger.debug(fn ->
      "[ipc.dispatch] worker=#{tags.worker} corr=#{tags[:corr_id]} size=#{payload_size_bytes}"
    end)
  end

  def wrap_job(tags, fun) when is_function(fun, 0) do
    started_at = System.monotonic_time(:microsecond)

    try do
      result = fun.()
      log_completion(tags, :ok, started_at)
      result
    catch
      kind, reason ->
        log_completion(tags, {:error, {kind, reason}}, started_at)
        :erlang.raise(kind, reason, __STACKTRACE__)
    end
  end

  defp log_completion(tags, status, started_at_us) do
    elapsed = System.monotonic_time(:microsecond) - started_at_us
    Logger.debug(fn ->
      "[ipc.complete] worker=#{tags.worker} corr=#{tags[:corr_id]} status=#{inspect(status)} elapsed_us=#{elapsed}"
    end)
  end
end
```

## Dispatcher Call Site

```elixir
def handle_cast({:dispatch, job}, state) do
  tags = %{worker: job.worker, corr_id: job.correlation_id}

  DebugTrace.log_dispatch(tags, byte_size(job.payload))

  :ok =
    DebugTrace.wrap_job(tags, fn ->
      ShmemWriter.enqueue(job, state.shared_buffer)
      FutexGate.wake(state.signal_fd)
    end)

  {:noreply, state}
end
```

## Test Usage

```elixir
test "logs dispatch and completion" do
  log =
    ExUnit.CaptureLog.capture_log(fn ->
      result =
        DebugTrace.wrap_job(%{worker: :sim, corr_id: "abc123"}, fn ->
          :timer.sleep(5)
          :ok
        end)

      assert :ok = result
    end)

  assert log =~ "[ipc.dispatch]"
  assert log =~ "[ipc.complete]"
  assert log =~ "elapsed_us="
end
```

## Optional Telemetry Bridge

```elixir
defmodule GamePlatform.IPC.TelemetryBridge do
  @dispatch_event [:ipc, :dispatch]
  @complete_event [:ipc, :complete]

  def log_dispatch(tags, size) do
    :telemetry.execute(@dispatch_event, %{payload_bytes: size}, tags)
    DebugTrace.log_dispatch(tags, size)
  end

  def log_completion(tags, metadata) do
    :telemetry.execute(@complete_event, metadata, tags)
    # reuse DebugTrace output for tests
  end
end
```

Keep the optional bridge in mind if we standardize on `:telemetry`; until then, the plain `DebugTrace` helper keeps call sites short while producing actionable logs in tests.
