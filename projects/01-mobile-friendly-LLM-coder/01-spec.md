# 01 Spec: Mobile-Friendly Claude Code Web Interface

## Project Overview

A mobile-optimized web application that provides access to Claude Code functionality through a portrait-mode friendly interface. The system enables developers to continue coding projects on mobile devices while their desktop computers are occupied with other tasks.

## Technical Architecture

### Frontend Stack
- **Framework**: Vite + React
- **Target**: Portrait-mode mobile devices (phones primarily)
- **Hot Reload**: Vite HMR for rapid development

### Backend Stack
- **Framework**: Elixir Phoenix
- **Hot Reload**: Phoenix LiveReload for backend changes
- **WebSocket**: Phoenix Channels for real-time communication
- **Voice API**: LLM-based voice recognition service integration
- **Persistence**: Message history storage and Git commit automation

### Display Modularity
The interface supports two distinct display modes:

1. **Terminal Mode**: Embedded ttyd terminal interface
2. **Chat Mode**: Parsed and reconstituted chat interface optimized for mobile interaction

## Core Features

### Mobile-Optimized Chat Interface
- Portrait-mode layout optimized for thumb navigation
- Touch-friendly message composition
- **Voice Input**: LLM-powered speech-to-text for hands-free interaction
- Text input fallback for traditional typing
- Syntax highlighting adapted for small screens
- Collapsible code blocks for better readability

### Embedded Terminal Access
- ttyd integration for full terminal access
- Mobile keyboard optimization
- Gesture controls for common terminal operations
- Responsive terminal sizing

### Real-Time Synchronization
- WebSocket-based communication between mobile and desktop sessions
- Live project state synchronization
- Hot reload capabilities on both frontend and backend

## User Experience Goals

### Primary Use Case
Developer working on projects via Claude Code while desktop is busy with other applications (gaming, intensive tasks, etc.)

### Interaction Patterns
- Thumb-first navigation design
- Minimal typing requirements where possible
- Quick access to common development operations
- Seamless switching between terminal and chat modes

## Technical Requirements

### Performance
- Fast initial load times on mobile networks
- Efficient WebSocket communication
- Minimal battery impact

### Responsiveness
- Sub-100ms interface interactions
- Real-time terminal responsiveness
- Smooth transitions between modes

### Compatibility
- Modern mobile browsers (Chrome, Safari, Firefox)
- iOS Safari and Android Chrome primary targets
- Progressive Web App capabilities

## Development Approach

### Hot Reload Setup
- Frontend: Vite HMR with React Fast Refresh
- Backend: Phoenix LiveReload with automatic recompilation
- Full-stack development workflow optimization

### Modular Architecture
- Pluggable display components (terminal vs chat)
- Configurable interface layouts
- Extensible for future mobile-specific features

## Success Criteria

1. Functional parity with essential Claude Code features on mobile
2. Smooth, responsive mobile user experience
3. Reliable real-time synchronization between desktop and mobile
4. Developer productivity maintained when switching to mobile interface
5. Hot reload functioning on both frontend and backend during development