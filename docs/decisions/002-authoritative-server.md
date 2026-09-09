# ADR-002: Authoritative Server Architecture

## Status
Accepted

## Context
An MMORPG requires a networking model that prevents cheating and ensures consistent game state across all clients. The main options are:
- Client-authoritative (peer-to-peer)
- Server-authoritative
- Hybrid (client-predicted, server-validated)

## Decision
Use a **server-authoritative** architecture where the Godot dedicated server is the single source of truth for all game state.

## Alternatives Considered

### Client-Authoritative (P2P)
- Pro: Simpler to implement initially
- Con: Trivially cheatable — any client can lie about its state
- Con: No central point of truth
- Con: Unsuitable for any game with economy or competitive elements

### Hybrid (Client Prediction + Server Reconciliation)
- Pro: Best player experience (responsive + secure)
- Con: Complex to implement correctly
- Note: This is the eventual target — server authority with client-side prediction added in Phase 3+

## Consequences

### Positive
- Cheating is fundamentally limited — clients cannot modify authoritative state
- Consistent game state for all players
- Server logs provide complete audit trail
- Economy and progression are secure by design

### Negative
- Higher latency for player actions (input → server → response)
- Server becomes a single point of failure
- Server hardware costs
- More complex to develop than client-authoritative

### Mitigation
- Client-side prediction will be added in Phase 3+ for movement responsiveness
- Initial target of 10-20 players reduces server load
- Godot headless mode is lightweight enough for a single server

### Implementation Notes
- Server runs the same Godot project in headless mode via feature tag
- `MultiplayerSynchronizer` handles state replication
- All game logic runs on the server; clients display results
- The `net/` layer handles all communication; `domain/` is unaware of networking
