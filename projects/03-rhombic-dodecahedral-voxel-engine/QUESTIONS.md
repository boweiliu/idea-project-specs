# Voxel Engine (Archimedean/Catalan) — Design Questions

Use this list to drive decisions. I’ll keep “Answered” in sync as we go.

## Parked Questions
1. Initial tilings to implement: pick 2–3 (e.g., cubes/SC, rhombic dodecahedron/FCC, truncated octahedron/BCC, hexagonal prism, gyrobifastigium, elongated dodecahedron, tetrahedral/prismatic tilings). Context: validates the tiling-agnostic interface.
2. Platform & stack: desktop/web/VR? Preferred language/engine/tooling. Context: determines renderer and scope.
3. Scale & performance: view distance, FPS target, hardware tier. Context: drives chunking, LOD, and budgets.
4. Data & persistence: save/load, streaming chunks, networking, exports (glTF/PLY/OBJ). Context: storage and pipeline design.
5. Visual features: AO, shadows, water, volumetrics — rank by priority. Context: renderer complexity and sequencing.
6. Grid step definition: move to all neighbors or a subset? Context: each tiling has a distinct neighbor set.
7. Rotation increments: discrete angles tied to tiling symmetry or universal steps (e.g., 45° yaw)? Context: affects UX consistency across tilings.
8. Editing granularity: single-cell only or brushes (line/plane/fill)? Context: UX and data-path complexity.
9. Unit scale: world units per cell across tilings for consistent camera speed/feel. Context: normalization layer decisions.
10. MVP scope & timebox: must-haves vs deferrable. Context: schedules and cutlines.
11. Non-goals: explicitly out of scope for v1. Context: avoids scope creep.

## Answered
- Primary use case: Play — users add/remove voxel blocks and move around the world.
- Movement model: Grid/lattice-based movement and discrete rotations; no continuous WASD physics required.
- Rendering requirement: Support full quaternion rotation and interpolation for cameras/entities.
- Tiling model: Engine should be tiling-agnostic with pluggable tiling modules.
