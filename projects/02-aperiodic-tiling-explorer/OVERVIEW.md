# Aperiodic Tiling Explorer

## Goal & Problem
Personal tool for discovering rep-tiles and generating aperiodic tilings to notice visual patterns. Focus on polyX-minoes across various base tilings with sophisticated context-aware coloring.

## Stack Choices
- **Rendering**: WebGPU (WebGL2 fallback) for maximum performance with massive tilings
- **Language**: TypeScript for rule definitions and core logic
- **Base tilings**: All 24 regular (3), Archimedean (8), and Catalan (13) tilings
- **UI Framework**: TBD - needs efficient GPU integration

## Core User Flows
1. Select base tiling (square, triangular, Cairo pentagonal, etc.)
2. Define/discover polyX-mino shapes that could be rep-tiles
3. Apply substitution rules to generate large aperiodic patterns
4. Write TypeScript coloring rules based on shape, rotation, neighbors
5. Interactive pan/zoom exploration to discover patterns
6. Adjust colors via UI picker, re-run rules instantly

## Technical Architecture
- **Tiling engine**: Generates polyX-minoes on selected base grid
- **Rep-tile detector**: Tests multi-shape combinations for replication
- **GPU renderer**: WebGPU compute shaders for neighbor queries, instanced rendering
- **Rule system**: Pluggable TS modules with access to tile properties
- **Viewport**: Infinite canvas with dynamic tile loading

## Miscellaneous
- Multi-shape combinations required (not just single rep-tiles)
- Other rep-n detection features TBD based on complexity
- Export capability secondary to interactive exploration