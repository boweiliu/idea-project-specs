# Mobile-Friendly Claude Code Web Interface

## Goal & Problem

Enable Claude Code usage on mobile while desktop is occupied (gaming, intensive tasks). Current desktop-only interface prevents coding continuity during resource conflicts.

**Core Need**: Portrait-mode web interface for coding on phone with full Claude Code functionality.

## Stack Choices

**Frontend**: Vite + React with hot reload
**Backend**: Elixir Phoenix with LiveReload  
**Communication**: Phoenix Channels (WebSocket)
**Voice**: LLM-based speech-to-text API
**Storage**: Database + Git integration

*Rationale*: Hot reload on both ends for rapid development. Phoenix Channels for real-time sync. External voice API for quality over phone built-ins.

## Core User Flows

### Primary Flow: Desktop → Mobile Transition
1. Start coding session on desktop Claude Code
2. Switch to mobile web interface
3. Continue same project/conversation seamlessly
4. Voice input for reduced typing
5. All interactions persisted and committed to Git

### Display Modes
- **Terminal Mode**: Embedded ttyd for full shell access
- **Chat Mode**: Mobile-optimized conversation interface

### Input Methods
- Touch typing (traditional)
- Voice-to-text (primary for mobile)
- Push-to-talk with visual feedback

## Technical Architecture

### Modularity
- **Display Components**: Pluggable terminal vs chat views
- **Voice Pipeline**: Audio capture → LLM transcription → text processing  
- **Persistence Layer**: Message storage + Git commit automation
- **Sync Engine**: Real-time state between desktop/mobile sessions

### Key Systems
- WebSocket-based session synchronization
- Mobile-first responsive design (portrait optimization)
- Progressive Web App capabilities
- Session recovery across device switches

## Miscellaneous Details

**Performance Targets**: <2s voice transcription, <100ms UI interactions
**Browser Support**: Chrome, Safari, Firefox (mobile focus)
**Fallbacks**: Voice → text input, mobile → desktop graceful degradation
**Not in scope**: Offline mode, gesture controls, tablet optimization

## WIP: Refinements Under Development

### Deployment Architecture
Semi-separated deployment system handles both app deployment and network configuration (LAN/WAN). Hot-reload on FE+BE can cause broken states, requiring out-of-band deployment management.

**Deployment Manager**: Separate system with simple web interface (no LLM APIs):
- Deploy/rollback app versions via touch UI
- Network configuration management (LAN/WAN endpoints)  
- Version tracking and app health monitoring
- Emergency rollback when hot-reload breaks main app

**App Modes**: Local (LAN/WiFi) vs Cloud (internet access) - architecture identical, deployment manager handles network differences.

### Mobile Notifications  
PWA push notifications for multitasking scenarios:
- Task completion (builds, tests, long-running commands)
- Other use cases TBD but probably not in scope

### Session Persistence
Each Claude Code session (mobile or desktop) persists chat/prompt history to project storage. Fresh sessions can load full conversation context from any previous session in that project. No live process handoff needed - just persistent conversation history accessible across device switches.

### Voice Processing 
Voice input targets chat messages primarily. Terminal commands possible but not core supported flow. Speech-to-text API choice prioritizes easy integration + low latency + sufficient accuracy. Options: OpenAI Whisper, Whisper Flow, others TBD based on integration ease.

### File Operations
Mobile interface provides read-only code display with line numbers. User reviews code and provides commentary via chat, but no direct code editing. Keeps mobile interaction focused on communication rather than complex editing workflows.
