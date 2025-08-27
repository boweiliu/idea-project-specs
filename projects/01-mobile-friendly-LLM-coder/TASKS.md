# Parallelizable Tasks

## Immediate Parallel Tasks (All can start now, no dependencies)

### Task 1: Voice Recording Frontend
**Scope**: Vite + React app with voice recording capability
**Deliverable**: Web app with:
- Button to start/stop recording
- Audio chunks saved to memory
- Test button to playback single chunk or full stream
**Verification**: Human listens to playback and confirms audio quality

### Task 2a: AssemblyAI Streaming POC
**Scope**: Standalone script that sends hardcoded audio to AssemblyAI
**Deliverable**: Script that streams audio file to API and prints transcribed text
**Verification**: Measure latency, verify transcript accuracy against known text

### Task 2b: Deepgram Streaming POC  
**Scope**: Standalone script that sends hardcoded audio to Deepgram
**Deliverable**: Script that streams audio file to API and prints transcribed text
**Verification**: Measure latency, verify transcript accuracy against known text

### Task 2c: Wispr Flow Streaming POC
**Scope**: Standalone script that sends hardcoded audio to Wispr Flow
**Deliverable**: Script that streams audio file to API and prints transcribed text  
**Verification**: Measure latency, verify transcript accuracy against known text

### Task 3: ttyd + Claude Code Integration
**Scope**: Web page that spawns and controls Claude Code via Phoenix backend
**Deliverable**: Page that:
- Calls backend to spawn ttyd with Claude Code
- Feeds hardcoded text string to terminal
- Has shutdown button to clean up resources
**Verification**: Claude responds to input, processes terminate on shutdown

### Task 4: Deployment Script
**Scope**: Single script to build and run everything locally
**Deliverable**: `deploy.sh` that sets up the full environment
**Verification**: Fresh clone + ./deploy.sh produces working system

---

## Future Integration Tasks

### Phase 0: Voice API Evaluation (3 parallel tasks, 1 day)

#### Task 0.1: AssemblyAI Test Implementation
**Scope**: Single HTML page with AssemblyAI WebSocket integration
**Deliverable**: Working demo that records audio, streams to AssemblyAI, displays transcripts with latency metrics
**Dependencies**: None

#### Task 0.2: Deepgram Test Implementation  
**Scope**: Single HTML page with Deepgram WebSocket integration
**Deliverable**: Working demo that records audio, streams to Deepgram, displays transcripts with latency metrics
**Dependencies**: None

#### Task 0.3: Wispr Flow Test Implementation
**Scope**: Single HTML page with Wispr Flow WebSocket integration  
**Deliverable**: Working demo that records audio, streams to Wispr Flow, displays transcripts with latency metrics
**Dependencies**: None

#### Task 0.4: API Comparison Report (Sequential after 0.1-0.3)
**Scope**: Test all three demos, measure performance, document findings
**Deliverable**: Decision matrix with selected provider + rationale
**Dependencies**: Tasks 0.1, 0.2, 0.3 complete

### Phase 1: Core Infrastructure (2 parallel tracks)

#### Track A: Terminal Integration

##### Task 1.A.1: ttyd Container Setup
**Scope**: Dockerfile with ttyd + Claude Code pre-installed
**Deliverable**: Container that auto-starts Claude Code session on port 7681
**Dependencies**: None

##### Task 1.A.2: Session Management Script
**Scope**: Bash script to manage Claude Code lifecycle within ttyd
**Deliverable**: Script that starts/restarts Claude Code, handles crashes
**Dependencies**: None

#### Track B: Frontend Foundation  

##### Task 1.B.1: React + Vite Setup
**Scope**: Basic React app with Vite, TypeScript, minimal UI
**Deliverable**: Dev server running on port 5173 with hot reload
**Dependencies**: None

##### Task 1.B.2: WebSocket Client Module
**Scope**: Reusable WebSocket connection manager with event emitters
**Deliverable**: TypeScript module with connect/disconnect/reconnect logic
**Dependencies**: None

### Phase 2: Integration (Sequential, depends on Phase 1)

#### Task 2.1: Voice Recording UI
**Scope**: React component with push-to-talk button, visual feedback
**Deliverable**: Component that captures audio stream, shows recording state
**Dependencies**: Task 1.B.1

#### Task 2.2: Transcription Integration  
**Scope**: Connect voice UI to selected API from Phase 0
**Deliverable**: Real-time transcript display as user speaks
**Dependencies**: Tasks 0.4, 1.B.2, 2.1

#### Task 2.3: Terminal Injection
**Scope**: Send transcribed text to ttyd WebSocket
**Deliverable**: Text appears in Claude Code terminal when speaking stops
**Dependencies**: Tasks 1.A.1, 2.2

#### Task 2.4: Combined Container
**Scope**: Single Dockerfile serving both React app and ttyd
**Deliverable**: Container with web UI on port 3000, terminal on 7681
**Dependencies**: Tasks 1.A.1, 1.B.1

### Phase 3: POC Completion (Sequential, 1 day)

#### Task 3.1: End-to-End Testing
**Scope**: Test voice → transcript → Claude Code flow
**Deliverable**: Working demo video + bug list
**Dependencies**: All Phase 2 tasks

#### Task 3.2: Deployment Script
**Scope**: One-command local deployment
**Deliverable**: `./deploy.sh` that builds and runs the container
**Dependencies**: Task 2.4

### Parallelization Summary

- **Phase 0**: 3 engineers can work on Tasks 0.1-0.3 simultaneously (1 day)
- **Phase 1**: 2 engineers can work on Track A and Track B in parallel (1 day)
- **Phase 2**: Sequential but fast iterations (2 days)
- **Phase 3**: Final integration and polish (1 day)

**Total Timeline**: 5 days with 3 engineers, or 7-8 days with 2 engineers