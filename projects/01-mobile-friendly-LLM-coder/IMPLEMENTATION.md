# Implementation Planning

## POC: Voice → Claude Code Terminal

Voice input → transcription → text sent to Claude Code in terminal

## Stack Decisions  
- **Frontend**: React + Vite from day one
- **Voice transcription**: Integrate with provider selected in `05-voice-llm-transcription-comparison`
- **Method**: WebSocket streaming (all three support it)
- **Async pattern**: Event emitters for transcripts + promises for connection lifecycle
- **Session management**: Auto-start Claude Code with web app  
- **Deployment**: Single container with both processes (no network communication)

## Implementation Sequence

### External Dependency: Voice API Evaluation
- Project `05-voice-llm-transcription-comparison` owns the AssemblyAI vs Deepgram vs Wispr Flow comparison and produces the recommendation for this build.

### Phase 1: Core POC
1. Basic HTML + ttyd terminal integration
2. Voice recording and transcription pipeline (using selected API)
3. Text injection into Claude Code session

## Future Features (Not POC)
- Voice/typing toggle
- Editable buffer before sending
