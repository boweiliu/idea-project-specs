# Aperiodic Tiling Explorer - Design Questions

## Core Concept
Building a tool for discovering rep-tiles and creating aperiodic tilings with context-aware coloring based on shape, rotation, neighbors, etc.

## Rep-tile Discovery & Generation

### Search Space
How do you want to define/discover rep-tiles?
- [ ] Start with known rep-tiles (sphinx, L-triomino, chair) and explore variations
- [ ] Parametric exploration (e.g., varying angles/ratios in polyominoes)
- [x] **Grid-based discovery** - polyX-minoes on all regular, Archimedean, and Catalan tilings
- [ ] Freeform drawing with automatic rep-tile detection

**DECIDED**: Support all regular (3), Archimedean (8), and Catalan (13) base tilings from the start

### Replication Rules
- [?] Find how a shape tiles into n copies of itself (maybe)
- [?] Explore different n-values (rep-4, rep-9, etc.) (maybe)
- [?] Support fractional/irrational scaling factors (maybe)
- [x] **Handle combinations where multiple shapes create larger versions** (definite)

**DECIDED**: Must support multi-shape combinations. Other features TBD based on implementation complexity.

### Aperiodicity Generation
How to create aperiodic patterns from rep-tiles?
- [ ] Substitution rules with controlled irregularity
- [ ] Mixed scaling generations
- [ ] Combining different rep-tiles with compatible scaling
- [ ] Random vs deterministic rule application

## Interactive Coloring System

### Neighbor-Based Rules
How should the rules compose?
- [ ] Simple conditions ("if north neighbor is type A, color me blue")
- [ ] Boolean logic ("if 2+ neighbors are rotated 90°, use gradient")
- [ ] Cascading/iterative coloring (colors propagate through the tiling)
- [ ] Probabilistic rules for variation

### Rule Definition Interface
- [ ] Visual rule builder with drag-drop conditions
- [ ] Simple scripting language/DSL
- [ ] Preset rules you can tweak with sliders
- [ ] Node-based visual programming
- [x] **TypeScript interface implementation** - write coloring rules as TS modules, select via UI buttons

**DECIDED**: Modular TypeScript code interface where you implement rule classes/functions, UI has buttons to switch between implementations + color picker(s) to pass colors to the rule functions

### Real-time Updates
When you change a coloring rule:
- [ ] Instant update of entire visible tiling
- [ ] Progressive update showing the propagation
- [ ] Need to manually trigger recoloring

### Shape/Rotation Detection
- [ ] Discrete rotations only (0°, 90°, 180°, 270°)
- [ ] Continuous rotation angles
- [ ] Mirror/flip transformations too
- [ ] Handle slightly distorted versions of "same" shape

## Technical Choices

### Platform
- [x] **Web-based** - for flexibility and easy sharing
- [ ] Native app (better performance for large tilings)
- [x] **GPU acceleration critical** - WebGPU if available, WebGL2 fallback

**DECIDED**: WebGPU for maximum performance (with WebGL2 fallback). Complexity acceptable for performance gains.

### Coloring Features Priority
Rank these 1-6 (1=most important):
- [ ] Multi-hop neighbors (neighbor's neighbor's color)
- [ ] Historical coloring (based on generation/substitution depth)
- [ ] Edge-based coloring (different colors per edge, not just per tile)
- [ ] Animation between rule changes
- [ ] Color based on local pattern matching
- [ ] Export coloring rules as reusable templates

## Workflow

### Discovery Focus
What's most important?
- [ ] Quickly test if a shape is a rep-tile
- [ ] Visualize the hierarchical/fractal structure
- [ ] Generate large aperiodic arrangements
- [ ] Export the substitution rules themselves

### Starting Complexity
Begin with:
- [ ] 2D polygonal rep-tiles only
- [ ] Include curves/smooth boundaries
- [ ] Support disconnected rep-tiles

### Visual Output
- [ ] High-resolution static images you can save/print
- [x] **Interactive exploration where you can zoom/pan around massive tilings** (primary)
- [ ] Both equally

**DECIDED**: Focus on interactive pan/zoom for pattern discovery. Export is secondary.

### Usage Pattern
- [ ] Quickly generate many variations to browse
- [ ] Deeply explore/tweak a single tiling
- [ ] Build a library of saved configurations

## Additional Notes
(Add any other requirements, ideas, or constraints here)