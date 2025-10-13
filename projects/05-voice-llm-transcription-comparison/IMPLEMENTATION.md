# Evaluation Plan

## Test Harness
Build a lightweight web app capable of recording audio, streaming it to all three providers in parallel, and capturing transcripts plus timing data. Use identical audio chunks to ensure comparable results.

## Phase 0: Voice API Evaluation
1. Build comparison harness with 3 parallel transcription services:
   - **AssemblyAI** streaming (`$0.0025/min` list price)
   - **Deepgram** Nova streaming (`$0.0043/min` list price)
   - **Wispr Flow** (quote-based pricing; contact sales)
2. Capture latency, accuracy, and API ergonomics for each provider.
3. Produce a decision matrix that ranks providers and selects the default for integration back in project `01-mobile-friendly-LLM-coder`.

## Integration Guidance
- Prefer WebSocket streaming APIs so the same client code can be reused later.
- Normalize transcript events into a shared interface (timestamp, confidence, text).
- Record qualitative notes about SDK quality, documentation clarity, and rate limits.
- Document any prerequisites (API keys, account setup) that affect onboarding time.
