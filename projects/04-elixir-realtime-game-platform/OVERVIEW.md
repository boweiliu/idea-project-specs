# Elixir Real-Time Game Platform

## Goal & Problem

Build a performant real-time multiplayer game platform combining flexible client transport, high-performance compute workers, and a 3D hex grid factory automation game. Current solutions either sacrifice transport flexibility (WebSocket-only), compute performance (pure Elixir), or game complexity (simple turn-based).

**Core Need**: Phoenix backend supporting multiple client types, dirty NIF workers for intensive computation, and a procedurally generated 3D hex world with Game of Life-inspired simulation running at interactive speeds.

## Stack Choices

**Backend**: Elixir Phoenix for concurrent client handling and supervision
**Transport Layer**: Phoenix Channels (WebSocket), REST + long polling fallback, manual curl mailbox API
**IPC/Compute**: Dirty NIFs with shared memory (shmem/mmap) + futex/eventfd synchronization
**Worker Processes**: Rust or Zig for compute-intensive simulation (optional: pure Elixir for simpler tasks)
**World Geometry**: 3D hex grid on sub-triangle subdivision surface
**Game Logic**: Cellular automaton variant with factory automation mechanics

*Rationale*: REST + mailbox enable curl scripting and offline-capable clients. Dirty NIFs + shmem eliminate serialization overhead for simulation data. Rust/Zig provides compute speed while preserving Elixir supervision.

## Core User Flows

### Subproject 1: Multi-Transport Client Communication

**Primary Flow**: Client connects via preferred transport method
1. Client chooses connection method (WebSocket, REST polling, or curl mailbox)
2. Phoenix backend establishes session, assigns mailbox identifier
3. Client sends game actions, receives world updates
4. Backend routes messages to game simulation workers
5. Updates pushed (WebSocket), polled (REST), or fetched manually (curl)

**Mailbox-Style API**: Curl client GETs `/mailbox/:id/messages` to fetch queued updates, POSTs actions to `/mailbox/:id/actions`. Messages accumulate server-side until fetched.

### Subproject 2: High-Performance Worker IPC

**Primary Flow**: Phoenix delegates compute to worker process
1. Phoenix receives expensive operation (simulate 1000 world ticks)
2. Writes request to shared memory region, signals worker via futex/eventfd
3. Worker (Rust/Zig/Elixir) processes in tight loop without GC pauses
4. Worker writes results to shmem, signals completion
5. Phoenix reads results, responds to clients

**Fallback Coordination**: If futex unavailable (older kernels), use eventfd. Final fallback: Linux signals (SIGUSR1/SIGUSR2).

### Subproject 3: 3D Hex Grid Factory Game

**Primary Flow**: Player explores and automates production
1. Player spawns in procedurally generated 3D hex world on sub-triangle mesh
2. World simulates continuously (GoL-inspired rules): resources grow, spread, transform
3. Player places prototypes (buildings, machines) that interact with adjacent hexes
4. Recipes define crafting chains: gather → process → combine → produce
5. Automation systems expand production without manual intervention
6. Procedural generation ensures infinite explorable space

**Simulation**: Each hex cell has state (resource type, quantity, machine type). Update rules check neighbors (6 in 2D, varies by position on 3D surface). Factory machines read inputs from adjacent cells, execute recipes, output to other cells.

## Technical Architecture

### Component Breakdown

**1. Transport Layer (Subproject 1)**
- **Phoenix Channels**: Standard WebSocket connection, presence tracking
- **REST Polling Controller**: `/poll/:session_id` endpoint, long-polling with 30s timeout
- **Mailbox API Controller**: `/mailbox/:id/messages` (GET queued messages), `/mailbox/:id/actions` (POST commands)
- **Session Manager**: GenServer tracking active sessions across all transports
- **Message Router**: Dispatches client messages to simulation workers, routes worker responses to correct transport

**2. Compute Worker IPC (Subproject 2)**
- **Shared Memory Manager**: Allocates mmap regions for request/response buffers
- **Synchronization Primitives**: Futex-based signaling (primary), eventfd (fallback 1), signals (fallback 2)
- **Port/NIF Adapter**: Wraps worker process communication in Elixir Port or NIF interface
- **Worker Supervisor**: Monitors worker health, restarts on crashes
- **Worker Implementation**: Rust/Zig binary or Elixir process implementing compute loop
- **Buffer Protocol**: Fixed-size ring buffer or lockless queue for request/response passing

**3. Game Simulation (Subproject 3)**
- **World Generator**: Procedural hex grid on sub-triangle mesh, noise-based resource distribution
- **Cellular Automaton Engine**: Tick-based simulation updating all cells according to rules
- **Prototype System**: Definitions for buildings, machines, and their behaviors
- **Recipe Database**: Crafting recipes with input/output specifications
- **Chunk Manager**: Loads/unloads world regions based on player proximity
- **State Serialization**: Saves/loads world state for persistence

### Module Structure

```
lib/game_platform/
  transport/        # WebSocket, REST polling, mailbox API, session tracking
  compute/          # Shmem manager, sync primitives, worker adapters
  game/
    world/          # Generation, chunks, hex math
    simulation/     # Automaton rules, tick scheduler
    factory/        # Prototypes, recipes, automation
    state/          # Serialization
```

## Miscellaneous

**Performance Targets**: 60 tick/sec simulation for active chunks, <50ms client update latency via WebSocket, <5s curl mailbox fetch interval.

**Platform Support**: Linux-only (futex, shmem, eventfd). macOS/BSD: signals fallback, reduced performance acceptable.

**Hex Grid Details**: Icosahedron base subdivided into triangles, hex tiles mapped onto surface. Each hex has variable neighbor count at triangle vertices (5 or 7 instead of 6). Addresses wrapping naturally (closed spherical surface).

**Future Considerations**: Horizontal scaling (multiple Phoenix nodes), distributed simulation (chunk sharding across workers), multiplayer interaction primitives (ownership, combat, trading).

**Undecided**:
- Worker process count (1 per Phoenix node? Pool?)
- Exact cellular automaton ruleset for resource behavior
- Recipe complexity depth
- Client rendering strategy (server-authoritative pushed state vs client-side interpolation)
