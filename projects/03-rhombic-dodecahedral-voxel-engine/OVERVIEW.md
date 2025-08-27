# 3D Voxel Engine on Archimedean/Catalan Tiling

## Goal & Problem
Enable play-focused interaction: users add/remove voxel blocks and move around a tiled 3D world. Movement is grid/lattice-based with discrete rotations; no continuous WASD physics required. The renderer must support smooth quaternion rotation and interpolation for cameras/entities. The engine is tiling-agnostic: multiple space-filling 3D tilings can be used interchangeably via a pluggable interface.

## Stack Choices
[To be defined through Q&A]

## Core User Flows
- Move along the lattice in discrete steps (neighbor-to-neighbor), rotate in discrete increments.
- Place and remove voxel blocks at targeted lattice cells.
- Look/aim with smooth quaternion-based camera rotation and interpolation.

## Technical Architecture
- Tiling abstraction: a tiling module supplies (a) lattice <-> world transforms, (b) neighbor graph, (c) cell geometry/face taxonomy for meshing, (d) raycast/selection on cells/faces, and (e) chunk indexing scheme.
- Movement/navigation: grid-based traversal on the tiling’s neighbor graph; no rigidbody physics.
- Editing: add/remove operations against lattice cells; selection via cursor/raycast via the active tiling module.
- Rendering: quaternion-based transforms and interpolation for camera/entities; module-provided geometry drives meshing and draw calls.

## Miscellaneous
- Initial tiling set, stack, performance targets, and export needs to be defined through Q&A.
