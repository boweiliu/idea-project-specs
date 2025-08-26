# Implementation Planning

## POC: Voice → Claude Code Terminal

Voice input → transcription → text sent to Claude Code in terminal

## Stack Decisions  
- **Frontend**: React + Vite from day one
- **Voice transcription**: Compare AssemblyAI, Deepgram, Wispr Flow via test webapp
- **Method**: WebSocket streaming (all three support it)
- **Async pattern**: Event emitters for transcripts + promises for connection lifecycle
- **Session management**: Auto-start Claude Code with web app  
- **Deployment**: Single container with both processes (no network communication)

## Implementation Sequence

### Phase 0: Voice API Evaluation
1. Build comparison webapp with 3 parallel transcription services
   - AssemblyAI ($0.0025/min streaming)
   - Deepgram ($0.0043/min Nova)
   - Wispr Flow (contact for API pricing)
2. Test latency, accuracy, and API ergonomics
3. Select primary provider based on results

### Phase 1: Core POC
1. Basic HTML + ttyd terminal integration
2. Voice recording and transcription pipeline (using selected API)
3. Text injection into Claude Code session

## Future Features (Not POC)
- Voice/typing toggle
- Editable buffer before sending