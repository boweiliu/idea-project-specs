# Evaluation Tasks

## Immediate Workstreams

### Task 1: Comparison Harness Frontend
**Scope**: Single-page web app that records audio, streams it to all three providers, and displays live transcripts with latency metrics.
**Deliverable**: Working demo with start/stop recording, per-provider transcript panes, and raw timing data export.
**Verification**: Manually review latency logs and verify transcripts against scripted prompts.

### Task 2a: AssemblyAI Streaming Adapter
**Scope**: Standalone module that connects the harness to AssemblyAI's WebSocket API.
**Deliverable**: Module returning interim and final transcripts with timestamps.
**Verification**: Stream canned audio, confirm transcript accuracy and timing.

### Task 2b: Deepgram Streaming Adapter
**Scope**: Standalone module that connects the harness to Deepgram Nova.
**Deliverable**: Module mirroring the AssemblyAI interface so the harness can swap providers.
**Verification**: Run identical audio through Deepgram, capture latency metrics.

### Task 2c: Wispr Flow Streaming Adapter
**Scope**: Standalone module that integrates Wispr Flow's streaming endpoint.
**Deliverable**: Module compatible with the shared transcript interface.
**Verification**: Execute the same test audio, note any SDK or auth differences.

### Task 3: Decision Matrix Report
**Scope**: Consolidate metrics and qualitative observations into a single report.
**Deliverable**: Ranked recommendation with cost breakdown and integration notes for project `01-mobile-friendly-LLM-coder`.
**Verification**: Review with stakeholders and confirm selected provider meets mobile app requirements.
