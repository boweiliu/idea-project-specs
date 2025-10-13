# Transport Instrumentation Plan

## Metrics (Prometheus Names)
- `transport_session_active_total` (gauge): active sessions by transport (`transport="ws|rest|mailbox"`).
- `transport_mailbox_messages_queued` (gauge): queued messages per mailbox; emits high-water mark histogram.
- `transport_mailbox_enqueue_total` (counter): messages enqueued; labels `source="router|system"`.
- `transport_mailbox_delivery_total` (counter): messages delivered; labels `transport`.
- `transport_mailbox_drop_total` (counter): drops due to TTL expiry or overflow (`reason="ttl|overflow|transport-closed"`).
- `transport_inbound_actions_total` (counter): actions received per transport + action type.
- `transport_outbound_payload_bytes` (histogram): serialized payload size for sends.
- `transport_dispatch_latency_ms` (histogram): end-to-end action dispatch latency (receive → worker response).
- `transport_poll_duration_ms` (histogram): REST long-poll duration; expect plateau near timeout.
- `transport_rate_limit_trigger_total` (counter): rate limit hits by transport + IP bucket.

## Logs
- Structured JSON logs via `Phoenix.LoggerJSON`; include `session_id`, `transport`, `trace_id`, `message_type`.
- Log levels: `info` for connect/disconnect, `debug` for payload traces (disabled in prod), `warn` for drops/rate limit.

## Traces
- Leverage `opentelemetry_phoenix` to span request lifecycle.
- Custom spans:
  - `Transport.Router.handle_action/3`
  - `Transport.Mailbox.fetch/2`
  - `Transport.Mailbox.deliver/2`
- Inject trace context into outbound messages so worker pipeline can continue spans.

## Alerts & SLOs
- 99p WebSocket latency < 150 ms.
- REST poll success rate ≥ 99%.
- Mailbox drop ratio < 0.1% of deliveries per hour.
- Raise alert when `transport_session_active_total{transport="mailbox"}` > configured capacity or `transport_rate_limit_trigger_total` spikes > baseline.

## Instrumentation Backlog
- Write Telemetry handlers publishing metrics via `PromEx` and StatsD.
- Add integration tests asserting telemetry events fire for session open/close and mailbox drops.
