# Spec Writing Guidelines

## Core Principles

**Succinctness**: Every sentence must add value. Cut fluff, redundancy, and obvious statements.

**Distinct Sections**: Each section serves a specific purpose. No overlap. Clear boundaries.

**Scannable Structure**: Busy readers should grasp the project in 2 minutes.

## Standard Structure

### 1. Goal & Problem
- What problem are we solving? 
- Why does this matter?
- One clear primary use case

### 2. Stack Choices  
- Technology decisions with brief rationale
- Key architectural choices
- Why not alternatives?

### 3. Core User Flows
- Primary user journey (80% use case)
- Key interaction patterns  
- Major features/modes

### 4. Technical Architecture
- System design and modularity
- How components interact
- Key technical constraints

### 5. Miscellaneous (Optional)
- Performance targets
- Browser/platform support  
- Future considerations
- Undecided implementation details

## Writing Style

**Be Definitive**: "We will use Phoenix" not "We might consider Phoenix"
**Front-load Important Info**: Most critical details first
**Use Bullets**: Easier to scan than paragraphs
**Minimize Repetition**: Say it once, say it well
**Rationale When Needed**: Explain non-obvious choices

## Common Mistakes to Avoid

- Restating the same point in different sections
- Over-explaining obvious technology choices
- Mixing implementation details with high-level goals
- Writing for completeness instead of clarity
- Creating sections that don't serve distinct purposes