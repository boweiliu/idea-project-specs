# Spec Writing Guidelines

## Priority #1: Succinctness & Zero Repetition

Every sentence adds unique value. Cut fluff. Say it once, perfectly.

Busy readers must grasp the project in 2 minutes.

## Standard Structure

### 1. Goal & Problem
What problem and why it matters. One primary use case.

### 2. Stack Choices  
Technology decisions with rationale. Why not alternatives?

### 3. Core User Flows
Primary journey (80% use case). Key interaction patterns.

### 4. Technical Architecture
System design, modularity, component interactions.

### 5. Miscellaneous (Optional)
Performance targets, platform support, future considerations, undecided details.

## Writing Rules

- **Definitive**: "We will use Phoenix" not "We might consider Phoenix"
- **Front-load**: Most critical details first
- **Bullets**: Easier to scan than paragraphs  
- **Rationale**: Only for non-obvious choices
- **Distinct Sections**: No overlap between sections

## Development Flow

### Conversational Refinement
Use question-and-answer flow to drive exploration and refinement. Questions unlock assumptions, reveal constraints, and force concrete decisions.

If an LLM is involved, e.g. claude code, the LLM should take on the questioner role.

### Implementation Ordering
Feature sequencing decisions require Q&A exploration. LLM questions should uncover:
- User priorities and constraints  
- Technical dependencies and risks
- MVP definition and success criteria
- Resource limitations and timeline pressures

### Spec Creation
1. **Filter decisions**: Keep what's needed for the spec
2. **Archive leads**: Store promising threads for future exploration
3. **Review against template**: Follow structure above

The conversation generates the thinking. The spec captures only the decisions.
