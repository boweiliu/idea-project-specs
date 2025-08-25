# Implementation Planning

## POC: Voice → Claude Code Terminal

Voice input → transcription → text sent to Claude Code in terminal

## Stack Decisions  
- **Frontend**: React + Vite from day one
- **Voice transcription**: TBD based on API availability and examples
- **Method**: Chunk vs streaming TBD based on complexity
- **Session management**: Auto-start Claude Code with web app  
- **Deployment**: Single container with both processes (no network communication)

## Implementation Sequence
1. Basic HTML + ttyd terminal integration
2. Voice recording and transcription pipeline
3. Text injection into Claude Code session

## Future Features (Not POC)
- Voice/typing toggle
- Editable buffer before sending