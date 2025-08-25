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
App works deployment-agnostically as web interface to Claude Code. Two deployment modes:
- **Local**: Serves web interface on LAN/WiFi for desktop multitasking
- **Cloud**: Deployed on server with git project + Claude Code, accessed over internet

Architecture remains identical - only access method (LAN vs WAN endpoint) differs.

### Mobile Notifications  
PWA push notifications for multitasking scenarios:
- Task completion (builds, tests, long-running commands)
- Other use cases TBD but probably not in scope
