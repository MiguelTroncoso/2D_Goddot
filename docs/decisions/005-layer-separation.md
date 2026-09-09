# ADR-005: Layer Separation (Domain / Systems / Net / UI)

## Status
Accepted

## Context
Game code tends to become a tangled monolith where UI, networking, and game logic are mixed together. This makes testing difficult, refactoring dangerous, and bugs hard to isolate.

## Decision
Enforce strict layer separation inspired by Clean Architecture principles, adapted for Godot:

```
domain/   → Pure game rules (no Godot nodes, no net, no UI)
systems/  → Use cases that orchestrate domain logic
net/      → Networking layer (@rpc, sync, authority)
ui/       → User interface (Control nodes, HUD, menus)
world/    → Maps, zones, transitions
entities/ → Scene files (.tscn) and their scripts
data/     → Resource files (.tres)
```

## Alternatives Considered

### Flat Structure (All in One)
- Pro: Simpler initial setup
- Con: Untestable — game logic coupled to scenes and networking
- Con: Refactoring networking means touching game logic
- Con: Cannot validate game rules without running the full engine

### Feature-Based Folders
- Pro: Related code grouped together (e.g., `combat/` has logic + UI + net)
- Con: Layer boundaries become unclear
- Con: Harder to enforce the "domain has no dependencies" rule

## Consequences

### Positive
- `domain/` is testable with GUT without opening any scene
- Networking solution can be swapped without touching game logic
- UI can be redesigned without modifying calculations
- Clear dependency direction: domain ← systems ← net/ui
- Easier to onboard new developers

### Negative
- More directories to navigate
- Requires discipline to maintain boundaries
- Some Godot patterns (signals on nodes) tempt shortcuts across layers

### Rules
1. `domain/` imports NOTHING from `net/`, `ui/`, `entities/`, or `world/`
2. `domain/` may use basic Godot types (Vector2, Dictionary) but not nodes
3. `systems/` may call `domain/` but not `net/` or `ui/` directly
4. `ui/` reads state through `EventBus` signals, never modifies game state directly
5. `net/` delegates game logic to `systems/`, never implements rules itself
