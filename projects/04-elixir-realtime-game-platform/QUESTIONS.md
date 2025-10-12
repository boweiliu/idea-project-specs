# Open Questions

## Subproject 1: Multi-Transport Client Communication

1. **Mailbox message retention**: How long should messages persist in mailbox before expiring? Should there be a max queue size per mailbox?

2. **REST long-polling timeout**: 30s timeout reasonable, or should this be configurable per client? What's the reconnection strategy?

3. **Session lifecycle**: When does a mailbox/session expire? After N hours of inactivity? Should curl clients send keepalives?

4. **Authentication**: Is authentication needed for mailbox access? Simple token-based, or public access with rate limiting?

## Subproject 2: High-Performance Worker IPC

5. **Worker process model**: Single worker per Phoenix node, or a pool? How to handle worker crashes during expensive operations?

6. **Shared memory sizing**: Fixed size buffers or dynamic allocation? How to handle requests that don't fit in shmem region?

7. **Rust vs Zig vs Elixir**: Which worker implementation for MVP? Can we start with Elixir worker and optimize to Rust later?

8. **Synchronization primitive priority**: Is futex availability guaranteed on target Linux versions? Should we implement all three mechanisms or just start with eventfd?

9. **Worker API surface**: What operations should workers expose? Just simulation ticks, or also pathfinding, worldgen, etc.?

## Subproject 3: 3D Hex Grid Factory Game

10. **Cellular automaton rules**: What specific GoL-inspired rules? Should resources spread probabilistically, or deterministically? Overpopulation/underpopulation mechanics?

11. **Sub-triangle mesh resolution**: How many subdivision levels on the icosahedron? Performance vs world size tradeoff?

12. **Recipe complexity**: How deep should crafting chains go? 3-step (raw → processed → product), or deeper (10+ steps)?

13. **Prototype scope**: How many building types for MVP? Just extractors and assemblers, or also logistics (conveyors, pipes)?

14. **Player interaction model**: Single-player only, or should architecture support multiplayer from the start? If multiplayer, how many concurrent players per world?

15. **World persistence**: Should worlds save between sessions? Per-player worlds or shared persistent world?

16. **Procedural generation algorithm**: Simplex noise for resource distribution? Biomes? Completely uniform initial state with emergent patterns?

17. **Chunk size**: How many hex cells per chunk? What's the active simulation radius around players?

18. **Client rendering**: Should server push full state diffs, or just events for client to interpolate? 2D projection of 3D hex grid, or full 3D rendering?

## Architecture & Integration

19. **Error handling strategy**: How should transport layer handle worker crashes? Queue requests and retry, or immediately return error to client?

20. **Telemetry/observability**: What metrics matter? Tick rate, message latency, worker utilization, active session count?

21. **Development priority**: Which subproject to implement first? Are they sequential dependencies or can they be parallelized?
