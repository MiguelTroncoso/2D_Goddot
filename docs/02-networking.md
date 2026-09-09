# Networking Design

> This document is a plan for Phase 3+. No networking is implemented in Phase 0 or Phase 1.

## Architecture

**Authoritative server** — the server owns all game state. Clients send inputs; the server validates, computes, and replicates results.

```
Client                          Server
  │                               │
  │──── Input (move direction) ──►│
  │                               │── Validate input
  │                               │── Update position
  │◄── State update (position) ──│
  │                               │
```

## Transport

- **ENet** via Godot's built-in high-level multiplayer API
- UDP-based, reliable and unreliable channels
- Suitable for real-time games with 10–20 players per zone

## Server Authority Model

The server is authoritative over:

| System          | Client Role          | Server Role                        |
|-----------------|----------------------|------------------------------------|
| Movement        | Sends input vector   | Validates, applies, replicates     |
| Combat          | Sends attack intent  | Calculates damage, applies effects |
| Loot            | None                 | Determines drops, assigns to player|
| Inventory       | Requests actions     | Validates, modifies, confirms      |
| Economy         | Requests trades      | Validates balances, executes       |
| Progression     | None                 | Calculates XP, handles level-ups   |

## Client-Side Prediction (Phase 3+)

For responsive movement:
1. Client applies input locally (prediction)
2. Client sends input to server
3. Server validates and sends authoritative position
4. Client reconciles if prediction diverged

This is not built into Godot — it must be implemented manually.

## Interpolation

- Buffer server snapshots
- Interpolate between them for smooth rendering
- Typically ~100ms behind server time

## Godot Multiplayer Nodes

| Node                      | Purpose                                         |
|---------------------------|--------------------------------------------------|
| `MultiplayerSpawner`      | Replicate dynamically created entities           |
| `MultiplayerSynchronizer` | Sync properties at configurable intervals        |
| `@rpc`                    | Discrete events (attack, chat, use item)         |

## Area of Interest (Phase 6+)

Players only receive updates for entities within their visibility range. Implemented as a grid-based system where the server tracks which cells each player can see.

## Protocol

- Byte-packed messages for bandwidth efficiency
- No JSON over the wire — use Godot's built-in serialization or custom PackedByteArray
- Reference implementation: godot-tiny-mmo

## Bandwidth Budget (Target)

| Data               | Frequency     | Estimated Size |
|--------------------|---------------|----------------|
| Player position    | 20 Hz         | ~12 bytes      |
| Entity state       | 10 Hz         | ~20 bytes      |
| Combat events      | On occurrence | ~16 bytes      |
| Chat messages      | On occurrence | Variable       |

## Security Considerations

- Never trust client-reported positions, damage, or inventory changes
- Rate-limit all RPC calls
- Validate all inputs server-side before applying
- Disconnect clients that send impossible inputs
- See: `06-security.md` for full security policy

## Open Questions (to resolve before Phase 3)

1. Exact tick rate for server simulation
2. Client prediction implementation strategy
3. Interest management grid cell size
4. Reconnection and state recovery protocol
5. Maximum players per server instance (load testing needed)
