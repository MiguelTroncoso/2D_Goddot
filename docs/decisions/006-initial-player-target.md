# ADR-006: Initial Target of 10–20 Concurrent Players

## Status
Accepted

## Context
An "MMO" suggests thousands of concurrent players, but that requires infrastructure and engineering that is premature for an indie project's first iteration.

## Decision
Architecture the initial version for **10–20 concurrent players per zone/instance**. Scale later.

## Alternatives Considered

### Build for 100+ Players from Day One
- Pro: No rearchitecting later
- Con: Massive engineering overhead for networking, AoI, load balancing
- Con: Delays the first playable prototype indefinitely
- Con: Premature optimization before the game is proven fun

### Single Player First, Add Multiplayer Later
- Pro: Fastest path to a playable game
- Con: Retrofitting networking is extremely painful
- Con: Architecture decisions made without networking in mind often conflict with it

## Consequences

### Positive
- A single Godot server instance can easily handle 10-20 players
- Simple ENet networking without complex infrastructure
- Focus on making the game fun before scaling
- Architecture decisions are networking-aware but not over-engineered

### Negative
- Will need scaling work for larger player counts
- Area of Interest not needed initially (but planned for Phase 6)
- May give a false sense of "MMO" readiness

### Scaling Path
1. Phase 3: 10-20 players in one zone, one server
2. Phase 6: Area of Interest for more players per zone
3. Future: Multiple server instances, zone sharding, gateway architecture
