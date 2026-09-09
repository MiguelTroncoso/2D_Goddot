# Blueprint — MMORPG 2D para Android (Godot)

> Original blueprint document, preserved as reference.
> Definitive architecture decisions are in `01-architecture.md` and the ADRs in `decisions/`.

## References

Style references (mechanics/UX inspiration only — no IP copied):
- Pixel Knights Online
- Heartwood Online
- Darza's Dominion
- Albion Online
- GrowStone Online

## Stack

| Component       | Choice                              |
|-----------------|-------------------------------------|
| Engine          | Godot 4.4 (stable)                  |
| Language        | GDScript                            |
| Client          | Android (initial), iOS (later)      |
| Server          | Godot Dedicated Server (headless)   |
| Networking      | ENet, authoritative server          |
| Backend (future)| Node.js / TypeScript + PostgreSQL   |
| Testing         | GUT                                 |
| CI              | GitHub Actions                      |
| Art tools       | Aseprite, Blender (optional)        |

## Technical Decisions

See: `decisions/` folder for formal ADRs.

Key decisions:
1. **GDScript over C#** — C# Android export is experimental in Godot 4; GDScript is the stable path.
2. **Authoritative server** — Server validates all game state; client sends inputs only.
3. **Single project** — Client and server share a Godot project, differentiated by feature tags.
4. **Layer separation** — `domain/` (pure logic) separated from `net/`, `ui/`, and engine nodes.
5. **10–20 players per zone** — Initial architecture target; scale later.
6. **Backend deferred** — No PostgreSQL/Redis until Phase 5.

## Workflow

```
ChatGPT   → Architecture, planning, direction
Claude    → Phase 0 foundation
Codex     → Implementation (Phase 1+)
Antigravity → Audit
Human     → Decisions, real-device testing
```

## Original Blueprint Source

The full original blueprint is preserved in the project's source documents. This file summarizes the decisions that remain valid and points to the ADRs for any modifications.
