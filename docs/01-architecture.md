# Architecture

## Overview

Single Godot 4.4 project running as client or server via feature tags.

```
┌─────────────────────────────────────────────────┐
│                  Godot Project                   │
│                                                   │
│  ┌─────────┐    ┌──────────┐    ┌─────────────┐ │
│  │ domain/ │◄───│ systems/ │◄───│   net/       │ │
│  │ (pure)  │    │ (use     │    │ (networking) │ │
│  │         │    │  cases)  │    │              │ │
│  └─────────┘    └──────────┘    └─────────────┘ │
│       ▲              ▲               ▲           │
│       │              │               │           │
│  ┌─────────┐    ┌──────────┐    ┌─────────────┐ │
│  │  data/  │    │ entities/│    │    ui/       │ │
│  │ (.tres) │    │ (scenes) │    │ (controls)  │ │
│  └─────────┘    └──────────┘    └─────────────┘ │
│                                                   │
│  ┌───────────────────────────────────────────────┐│
│  │              autoload/ (singletons)           ││
│  │  GameManager | Network | EventBus | Config    ││
│  │  SceneLoader | AudioManager                   ││
│  └───────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## Layer Rules

### domain/ — Pure Game Logic
- Contains: entities, value objects, calculations (XP curves, damage formulas, loot tables)
- Dependencies: **NONE** (no Godot nodes, no UI, no networking)
- Testable: Yes, with GUT, without opening any scene
- Example: `DamageCalculator`, `XPCurve`, `LootRoller`

### systems/ — Use Cases
- Contains: orchestration of domain logic for game flows
- Dependencies: domain/ (calls domain objects)
- May reference: Godot signals for event-driven flow
- Example: `CombatSystem`, `InventorySystem`, `ProgressionSystem`

### net/ — Networking
- Contains: `@rpc` functions, `MultiplayerSynchronizer`, `MultiplayerSpawner`, protocol definitions, Area of Interest
- Dependencies: systems/ (delegates to use cases), domain/ (reads state)
- Server authority: all state changes go through here
- Example: `NetworkManager`, `PlayerSync`, `EntityAuthority`

### world/ — Maps and Zones
- Contains: TileMap configurations, zone definitions, transitions, spawn points
- Dependencies: entities/ (places entities), net/ (syncs with server)

### entities/ — Scene Files
- Contains: `.tscn` files and their scripts for Player, Enemy, NPC
- Dependencies: domain/ (for stats/behavior), net/ (for sync)

### ui/ — User Interface
- Contains: HUD, virtual joystick, inventory UI, menus, chat
- Dependencies: systems/ (reads game state), EventBus (listens for updates)
- Rule: UI never modifies game state directly — it requests actions through systems/

### data/ — Resources
- Contains: `.tres` files defining items, enemies, skills, loot tables
- Pure data — no scripts, no logic
- Editable in Godot editor

## Client vs Server

The same project runs in both modes:

```gdscript
if OS.has_feature("dedicated_server"):
    # Headless server mode — no rendering, no UI
    # Entry: server/main_server.gd
else:
    # Client mode — full rendering, UI, input
    # Entry: project main scene
```

In the editor, test with Debug > Customizable Run Instances (1 server + N clients).

## Autoloads

Registered in `project.godot` as autoload singletons:

| Name          | Script                          | Purpose                           |
|---------------|----------------------------------|-----------------------------------|
| GameManager   | `src/autoload/game_manager.gd`  | Global state, mode detection      |
| Network       | `src/autoload/network.gd`       | Peer creation, connection, RPC    |
| EventBus      | `src/autoload/event_bus.gd`     | Global signal bus                 |
| SceneLoader   | `src/autoload/scene_loader.gd`  | Async scene loading               |
| AudioManager  | `src/autoload/audio_manager.gd` | Music and SFX                     |
| Config        | `src/autoload/config.gd`        | Settings, UI scale, language      |

## Data-Driven Design

Game data uses Godot Resources (`.tres`):
- Item definitions
- Enemy stat blocks
- Skill trees
- Loot tables
- XP curves

Resources are editable in the Godot editor and version-controlled. No hardcoded game data in scripts.

## Multiplayer Architecture (Future — Phase 3+)

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ Client 1 │────►│          │◄────│ Client N │
└──────────┘     │  Server  │     └──────────┘
                 │ (Godot   │
                 │ headless)│
                 └────┬─────┘
                      │
                 ┌────▼─────┐
                 │ Backend  │  (Phase 5+)
                 │ Node/TS  │
                 │ Postgres │
                 └──────────┘
```

Key networking nodes:
- `MultiplayerSpawner` — replicates dynamically created scenes
- `MultiplayerSynchronizer` — syncs properties (position, health)
- `@rpc` — point events (attack, use item, chat)

Protocol: byte-packed for bandwidth efficiency (reference: godot-tiny-mmo).
