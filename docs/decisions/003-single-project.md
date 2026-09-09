# ADR-003: Single Godot Project for Client and Server

## Status
Accepted

## Context
The project needs both a game client and a dedicated server. Options:
1. Single project with feature tags to differentiate client/server mode
2. Two separate projects with shared code as an addon

## Decision
Use a **single Godot project** that runs as client or server based on the `dedicated_server` feature tag.

## Alternatives Considered

### Two Separate Projects
- Pro: Cleaner conceptual separation
- Con: Sharing code between projects is painful in Godot (addons have limitations)
- Con: Two projects to maintain, sync, and test
- Con: Higher risk of client/server code divergence

## Consequences

### Positive
- All code in one place — easy to navigate and maintain
- Shared types, resources, and scenes without duplication
- Proven pattern (used by godot-tiny-mmo and other references)
- Simpler CI/CD pipeline
- Editor testing with multiple instances (1 server + N clients)

### Negative
- Client code is present in the server build (mitigated: unused code doesn't affect headless performance)
- Must be disciplined about separating client-only and server-only code
- Feature tag detection is runtime, not compile-time

### Implementation
```gdscript
if OS.has_feature("dedicated_server"):
    # Server mode
else:
    # Client mode
```

Server entry point: `server/main_server.gd`
