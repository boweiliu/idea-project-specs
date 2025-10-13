# Elixir Real-Time Game Platform

## Goal & Problem

Build a performant real-time multiplayer game platform with flexible client transport (WebSocket/REST/curl), high-performance compute workers, and a 3D hex grid factory automation game. Current solutions sacrifice either transport flexibility, compute speed, or game complexity.

**Core Need**: Phoenix backend with multi-transport support, dirty NIF workers, procedurally generated 3D hex world, GoL-inspired simulation at interactive speeds (20-60 UPS), multiplayer with ownership, and full persistence.

## Stack Choices

**Backend**: Elixir Phoenix for concurrent client handling and supervision
**Transport Layer**: Phoenix Channels (WebSocket), REST + long polling fallback, manual curl mailbox API
**IPC/Compute**: Dirty NIFs with shared memory (shmem/mmap) + futex/eventfd synchronization
**Worker Processes**: Rust or Zig for compute-intensive simulation (optional: pure Elixir for simpler tasks)
**Frontend**: React web client with FPS-based rendering (decoupled from backend UPS)
**Persistence**: Neon.db (branchable Postgres) with in-memory cache layer
**Messaging**: ZMQ-like request/reply + Kafka-like event streaming for inter-component communication
**World Geometry**: 3D hex grid on sub-triangle subdivision surface
**Game Logic**: Cellular automaton variant with factory automation mechanics
**Multiplayer**: Shared world state with player ownership and interaction primitives

*Rationale*: REST + mailbox enable curl scripting and offline-capable clients. Dirty NIFs + shmem eliminate serialization overhead. React FPS rendering decouples visual smoothness from simulation tick rate. Neon.db branching supports dev/staging/prod without separate infra. In-memory cache prevents DB bottlenecks. Dual messaging patterns (sync RPC + async events) handle both request-response and pub-sub needs. ZMQ/Kafka-style abstractions avoid vendor lock-in.

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

**Deep Dive Artifacts**: `02-ipc-layer/00-README.md` indexes the protocol deep dive; start with `01-PROTOCOL.md` before referencing component, flow, and layout docs.

### Subproject 3: 3D Hex Grid Factory Game

**Primary Flow**: Player explores and automates production
1. Player spawns in procedurally generated 3D hex world on sub-triangle mesh
2. World simulates continuously (GoL-inspired rules): resources grow, spread, transform
3. Player places prototypes (buildings, machines) that interact with adjacent hexes
4. Recipes define crafting chains: gather → process → combine → produce
5. Automation systems expand production without manual intervention
6. Procedural generation ensures infinite explorable space

**Simulation**: Each hex cell has state (resource type, quantity, machine type). Update rules check neighbors (6 in 2D, varies by position on 3D surface). Factory machines read inputs from adjacent cells, execute recipes, output to other cells.

### Subproject 4: React Web Client

**Primary Flow**: Client renders game state at consistent FPS
1. Client connects to Phoenix backend via WebSocket
2. Backend sends initial world state snapshot
3. Client renders 3D hex grid and game entities at 60 FPS
4. Backend streams state updates at simulation rate (e.g., 20 UPS)
5. Client interpolates between updates for smooth rendering
6. User clicks hex cells or UI buttons to send actions
7. Client shows optimistic updates while awaiting server confirmation

**Rendering Loop**: RequestAnimationFrame drives render cycle independent of backend tick rate. Client maintains local state buffer, lerps between received snapshots.

### Subproject 5: SQL Persistence Schema

**Primary Flow**: Save game state to Postgres
1. Simulation generates world state changes (chunk updates, player actions)
2. In-memory cache accumulates dirty records
3. Background worker flushes batches to Neon.db asynchronously
4. On server restart, load latest snapshot + replay event log
5. Neon.db branches enable isolated testing (feature branches → schema branches)

**Schema**: Tables for chunks (id, position, cell_states), players (id, position, inventory), prototypes (type, properties), events (timestamp, type, payload).

### Subproject 6: In-Memory Cache Layer

**Primary Flow**: Fast reads, async writes to SQL
1. Simulation reads world state from in-memory ETS tables
2. Cache serves reads at microsecond latency (no DB roundtrip)
3. Writes update cache immediately, mark records dirty
4. Background GenServer polls dirty records, batches SQL writes
5. On write success, clear dirty flags
6. On cache miss, load from SQL, populate cache

**Write-Through Fallback**: Critical writes (player save on logout) block until SQL confirms.

### Subproject 7: Inter-Component Messaging

**Primary Flow**: Components communicate via dual patterns
1. **ZMQ-style (Request/Reply)**: Client sends "get_chunk(x,y)", waits for response. Supports spoke-hub (all → router → worker) or direct (peer-to-peer) topology.
2. **Kafka-style (Event Streaming)**: Simulation publishes "cell_updated" event, multiple subscribers react (renderer, persistence, analytics). Topic-based routing, at-least-once delivery.

**Abstractions**: `ReqSocket`/`RepSocket` modules for sync RPC. `Publisher`/`Subscriber` modules for async events. Both support process-to-process (local) and node-to-node (distributed).

### Subproject 8: Multiplayer Handling

**Primary Flow**: Multiple players share world state
1. Players connect, assigned unique IDs
2. Each player has world position, inventory, ownership claims
3. Actions validated: only modify owned structures or adjacent unowned cells
4. Simulation broadcasts state diffs to all connected clients
5. Conflicts resolved server-authoritative (race conditions → first action wins)
6. Player disconnects → structures remain, can reconnect to resume

**Ownership Model**: Cells have optional owner_id. Structures inherit owner from placement cell. Unclaimed cells open to all players.

### Subproject 9: Version-Tracked Code References

**Primary Flow**: Unit tests access old code versions
1. Developer writes test for data migration: v1 format → v2 format
2. Test references old serialization code via pseudofile path: `/versions/abc123/serializer.ex`
3. Pseudofile backed by append-only linkage: `abc123` → git commit hash
4. Test reads old code implementation via FIFO-like interface
5. Test validates old data parses correctly with old code
6. Migration test compares old code output vs new code output

**Implementation**: Custom Elixir module intercepts `/versions/` reads, shells out to `git show <commit>:<path>`, returns content via pipe. Append-only: commits never change, safe to cache aggressively.

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

**4. React Web Client (Subproject 4)**
- **WebSocket Client**: Connects to Phoenix, handles reconnection
- **Render Loop**: RequestAnimationFrame at 60 FPS
- **State Buffer**: Stores recent backend snapshots, interpolates between them
- **Hex Renderer**: Canvas or WebGL drawing of 3D hex grid
- **UI Components**: Buttons, inventory, crafting menus

**5. SQL Persistence (Subproject 5)**
- **Neon.db Connection**: Postgres client with branch awareness
- **Migration Runner**: Schema versioning, branch-specific migrations
- **Schema**: Chunks, players, prototypes, events tables

**6. In-Memory Cache (Subproject 6)**
- **ETS Tables**: Fast read/write for world state, player data
- **Dirty Tracking**: Marks records needing SQL sync
- **Flush Worker**: GenServer batching writes to Postgres
- **Cache Loader**: Populates cache from SQL on miss

**7. Messaging Abstractions (Subproject 7)**
- **ReqSocket/RepSocket**: ZMQ-style sync request/reply, hub-spoke or peer-to-peer
- **Publisher/Subscriber**: Kafka-style async events, topic routing
- **Transport Layer**: GenServer-based for local, :rpc for distributed

**8. Multiplayer System (Subproject 8)**
- **Player Registry**: Tracks active players, positions, sessions
- **Ownership Manager**: Validates actions against cell ownership
- **Conflict Resolver**: Server-authoritative action ordering
- **Broadcast Manager**: Sends state diffs to all clients

**9. Version Reference System (Subproject 9)**
- **Pseudofile Handler**: Intercepts `/versions/` paths
- **Git Adapter**: Shells to `git show` for commit content
- **Cache Layer**: Aggressive caching (commits immutable)
- **Test Helpers**: Convenience macros for version-pinned imports

### Module Structure

```
lib/game_platform/
  transport/        # WebSocket, REST polling, mailbox API, session tracking
  compute/          # Shmem manager, sync primitives, worker adapters
  game/
    world/          # Generation, chunks, hex math
    simulation/     # Automaton rules, tick scheduler
    factory/        # Prototypes, recipes, automation
  persistence/
    cache/          # ETS tables, dirty tracking, flush worker
    sql/            # Neon.db adapter, migrations
  messaging/
    req_rep/        # ZMQ-style sync messaging
    pub_sub/        # Kafka-style event streaming
  multiplayer/      # Player registry, ownership, conflict resolution
  version_ref/      # Pseudofile handler, git adapter

web/
  client/           # React frontend (separate repo possible)
    components/     # UI elements
    rendering/      # Canvas/WebGL hex renderer
    state/          # Client-side state management, interpolation
```

## Miscellaneous

**Performance Targets**: 60 FPS client rendering, 20-60 UPS backend simulation, <50ms WebSocket latency, <100μs cache reads, <5s curl mailbox polling.

**Platform Support**: Linux-only (futex, shmem, eventfd). macOS/BSD: signals fallback, reduced performance acceptable.

**Hex Grid Details**: Icosahedron base subdivided into triangles, hex tiles mapped onto surface. Each hex has variable neighbor count at triangle vertices (5 or 7 instead of 6). Addresses wrapping naturally (closed spherical surface).

**Neon.db Branching**: Database branches mirror git branches (feature/foo → neon.db/feature/foo). Enables isolated schema changes, parallel testing.

**Version Reference Use Cases**: Migration tests (v1 → v2 data), regression tests (old bug → fixed), compatibility tests (current code vs old data format).

**Future Considerations**: Horizontal scaling (multiple Phoenix nodes), distributed simulation (chunk sharding), advanced multiplayer (combat, trading, alliances).

**Undecided**:
- Worker process count (1 per Phoenix node? Pool?)
- Exact cellular automaton ruleset for resource behavior
- Recipe complexity depth (3-step chains vs 10+)
- Client rendering engine (Canvas 2D vs WebGL/Three.js)
- Messaging topology defaults (hub-spoke vs peer-to-peer)
- Cache eviction policy (LRU, TTL, manual)
- Multiplayer player count target (10? 100? 1000?)
- Version reference API surface (just file reads, or function calls?)
