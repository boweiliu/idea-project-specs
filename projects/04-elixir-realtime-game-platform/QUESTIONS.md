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
    **Answer (2025-10-13)**: Target "soft multiplayer" — support multiple simultaneous clients architecturally for shared dev/demo sessions, but defer gameplay/griefing/permission mechanics.

15. **World persistence**: Should worlds save between sessions? Per-player worlds or shared persistent world?

16. **Procedural generation algorithm**: Simplex noise for resource distribution? Biomes? Completely uniform initial state with emergent patterns?

17. **Chunk size**: How many hex cells per chunk? What's the active simulation radius around players?

18. **Client rendering**: Should server push full state diffs, or just events for client to interpolate? 2D projection of 3D hex grid, or full 3D rendering?

## Subproject 4: React Web Client

22. **Rendering engine**: Canvas 2D (simpler) or WebGL/Three.js (more flexible, better performance)? What's the visual complexity target?

23. **Interpolation strategy**: Linear lerp between snapshots, or more sophisticated (cubic, physics-based)? How many past snapshots to buffer?

24. **Optimistic updates**: Which actions show optimistically (movement, building placement)? How to handle rollback on server rejection?

25. **Client-side prediction**: Should client predict world simulation locally between updates, or just interpolate?

26. **Build system**: Vite, Create React App, or custom webpack? TypeScript or JavaScript?

## Subproject 5: SQL Persistence Schema

27. **Schema design**: Normalize (separate tables for cell types, recipes) or denormalize (JSONB blobs)? Trade-off: query flexibility vs write performance?

28. **Event log retention**: How long to keep event history? Snapshot frequency (every N ticks, or time-based)?

29. **Neon.db branch strategy**: Auto-create branch per git branch, or manual mapping? How to handle branch deletion?

30. **Migration workflow**: Run migrations on app boot, or separate migration step? How to handle schema conflicts across branches?

## Subproject 6: In-Memory Cache Layer

31. **Cache eviction**: LRU (least recently used), TTL (time-to-live), or manual eviction? How much memory budget?

32. **Dirty record flushing**: Time-based batching (every N seconds) or size-based (every N records)? What's the flush failure retry strategy?

33. **Cache warming**: Pre-populate cache on server start with common data (spawn zones, starter recipes), or load on demand?

34. **Consistency guarantees**: Eventual consistency acceptable for most data, or some data needs strong consistency?

## Subproject 7: Inter-Component Messaging

35. **Topology defaults**: Hub-spoke (all messages through central router) or peer-to-peer (direct connections)? Performance vs simplicity trade-off?

36. **Serialization format**: Erlang term format (native), MessagePack (compact), JSON (debuggable)? Cross-language compatibility needed?

37. **Backpressure handling**: What happens when subscriber can't keep up with publisher? Drop messages, buffer, block publisher?

38. **Distributed mode**: Support distributed Elixir nodes from day 1, or add later? Network partition handling?

## Subproject 8: Multiplayer Handling

39. **Player count target**: 10 concurrent players, 100, 1000? Impacts architecture decisions (single world process vs sharded)?

40. **PvP mechanics**: Allow player-vs-player conflict (combat, sabotage), or purely cooperative? Affects ownership validation complexity?

41. **Chat/social features**: In-game chat needed? Guilds/teams? Friend lists?

42. **Griefing prevention**: How to prevent players from blocking others' expansion? Ownership claim limits? Inactive player cleanup?

## Subproject 9: Version-Tracked Code References

43. **API surface**: Just file content reads (`File.read("/versions/abc/file.ex")`), or also function calls (`VersionRef.call("abc", Module, :function, args)`)?

44. **Version specification**: Git commit hashes only, or also tags, branch names? Relative refs ("HEAD~3")?

45. **Performance**: Cache all version reads in memory, or cache intelligently (only test-accessed versions)? Disk cache?

46. **Security**: Restrict accessible paths (only lib/, test/), or allow arbitrary file access? Prevent shell injection in git commands?

## Architecture & Integration

47. **Error handling strategy**: How should transport layer handle worker crashes? Queue requests and retry, or immediately return error to client?

48. **Telemetry/observability**: What metrics matter? Tick rate, message latency, worker utilization, active session count, cache hit rate?

49. **Development priority**: Which subproject to implement first? Dependencies: Messaging (7) needed early? Client (4) can be parallel to backend?
    **Answer (2025-10-13)**: Plan to advance the major subprojects in parallel so teams can iterate concurrently; sequence dependencies case-by-case instead of hard serial ordering.

50. **Data flow**: Does simulation read from cache (6), or cache mirrors simulation state? Who owns authoritative state?

51. **Component boundaries**: Should messaging abstraction (7) be used for all inter-component communication, or just specific hot paths?
