# ADR-007: Backend Deferred to Phase 5

## Status
Accepted

## Context
The game will eventually need a backend for user accounts, persistent data, and authentication. Options:
1. Build the backend early (Phase 1-2)
2. Defer the backend until persistence is actually needed (Phase 5)
3. Use a BaaS (Backend as a Service) like Firebase

## Decision
**Defer** the backend (Node.js / TypeScript + PostgreSQL) to **Phase 5**. Phases 1-4 operate without external persistence.

## Alternatives Considered

### Build Backend Early
- Pro: Auth and persistence available from the start
- Con: Significant additional complexity in early phases
- Con: Backend maintenance overhead while game mechanics are still in flux
- Con: Premature — no players to persist data for yet

### Use Firebase / BaaS
- Pro: Faster setup, managed infrastructure
- Con: Vendor lock-in
- Con: Less control over data model
- Con: Ongoing costs that scale unpredictably
- Con: May not suit game-specific persistence patterns (event-driven saves)

## Consequences

### Positive
- Early phases focus purely on game mechanics
- No backend maintenance during rapid iteration
- Backend can be designed based on actual persistence needs (known by Phase 4)
- Team can learn the game's data patterns before committing to a schema

### Negative
- No persistent accounts until Phase 5
- Testing multiplayer in Phase 3-4 uses ephemeral sessions
- Backend design may need to accommodate patterns established without it

### Future Backend Stack
- Runtime: Node.js with TypeScript
- Database: PostgreSQL
- Cache: Redis (when demonstrably needed, not by default)
- Persistence model: save-by-event (login/logout, trade, level-up), not per-tick
