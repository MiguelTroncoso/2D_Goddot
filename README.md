# MMORPG 2D (Working Title)

A 2D top-down MMORPG for Android, built with Godot 4.4 and GDScript.

## Vision

An online multiplayer RPG with pixel-art aesthetics, open world exploration, PvE combat, inventory/crafting, and social systems — inspired by games like Pixel Knights Online, Heartwood Online, Darza's Dominion, Albion Online, and GrowStone Online.

The identity, characters, world, and lore will be **entirely original**. Reference games are inspiration for mechanics and UX only.

## Scope

This is an indie project. The goal is **not** to build a massive MMO from day one, but to produce a technically solid and fun **vertical slice** — a playable loop that demonstrates core mechanics end-to-end.

**Initial architecture target:** 10–20 concurrent players per zone/instance.

A "vertical slice" means: one small map, one player class, basic movement, combat, enemies, loot, XP, and a complete gameplay loop — all running with authoritative server validation. It proves the tech works before scaling.

## Stack

| Component          | Technology                        |
|--------------------|-----------------------------------|
| Engine             | Godot 4.4 (stable)                |
| Language           | GDScript                          |
| Initial Client     | Android                           |
| Server             | Godot Dedicated Server (headless) |
| Networking         | ENet (authoritative server)       |
| Future Backend     | Node.js / TypeScript + PostgreSQL |
| Testing            | GUT (Godot Unit Test)             |
| CI                 | GitHub Actions                    |

## Architecture

The project uses a **single Godot project** that runs as either client or server via feature tags (`OS.has_feature("dedicated_server")`). This avoids the pain of synchronizing two separate projects.

### Layer Separation

```
domain/     Pure game rules: entities, calculations (XP, damage, loot).
            NO Godot nodes, NO networking, NO UI. Testable with GUT.

systems/    Use cases: combat flow, inventory operations, progression.
            Orchestrates domain logic.

net/        Networking layer: @rpc, MultiplayerSynchronizer, authority,
            protocol, Area of Interest.

world/      Maps, zones, TileMap, transitions.

entities/   Scene files: player.tscn, enemy.tscn, npc.tscn + scripts.

ui/         HUD, virtual joystick, inventory UI, menus (Control nodes).

data/       Resource files (.tres): items, enemies, skills, loot tables.
```

**Fundamental rule:** `domain/` must NEVER depend on UI, networking, scenes, or Godot nodes. Core logic must be testable in isolation.

### Authoritative Server

The server is the authority over:
- Movement validation
- Combat, damage, death
- Mob behavior and spawning
- Loot drops
- Inventory
- Economy
- Progression

The client is **never trusted**. It sends inputs; the server validates and responds with authoritative state.

### Autoloads (Singletons)

| Autoload       | Responsibility                                    |
|----------------|---------------------------------------------------|
| GameManager    | Global state, startup, client vs server detection |
| Network        | Peer creation (ENet), connection, RPC routing     |
| EventBus       | Global signals for decoupling systems and UI      |
| SceneLoader    | Async map/zone loading and unloading              |
| AudioManager   | Zone music and SFX                                |
| Config         | Settings, touch UI sizing, language               |

## Repository Structure

```
mmorpg-2d/
├── README.md                    # This file — project contract
├── CREDITS.md                   # Asset attribution and licenses
├── .gitignore                   # Godot-specific ignores
├── project.godot                # Godot project configuration
├── icon.svg                     # Project icon
├── .github/
│   └── workflows/
│       └── ci.yml               # CI: validate project, run tests
├── docs/
│   ├── 00-blueprint.md          # Original blueprint (reference)
│   ├── 01-architecture.md       # Architecture details
│   ├── 02-networking.md         # Networking design
│   ├── 03-roadmap.md            # Phase-by-phase roadmap
│   ├── 04-game-design.md        # Game design document
│   ├── 05-assets-licenses.md    # Asset policy and license guide
│   ├── 06-security.md           # Security policy
│   ├── 07-testing.md            # Testing strategy
│   ├── decisions/               # Architecture Decision Records
│   └── prompts/                 # Reusable prompts for AI tools
├── src/
│   ├── autoload/                # Singletons (GameManager, Network, etc.)
│   ├── domain/                  # Pure game rules (no nodes, no net)
│   ├── systems/                 # Use cases (combat, inventory, etc.)
│   ├── net/                     # Networking layer (@rpc, sync)
│   ├── world/                   # Maps, zones, transitions
│   ├── entities/                # Player, enemy, NPC scenes + scripts
│   ├── ui/                      # HUD, joystick, menus
│   └── data/                    # .tres resources (items, enemies, etc.)
├── server/
│   └── main_server.gd           # Headless server entry point
├── assets/                      # Imported sprites, tilesets, audio, fonts
├── art-src/                     # Editable source files (.aseprite, .blend)
└── tests/                       # GUT test scripts
```

## Roadmap

| Phase | Name                     | Summary                                                     |
|-------|--------------------------|-------------------------------------------------------------|
| 0     | Foundation               | Repo structure, docs, CI, project config (CURRENT)          |
| 1     | Vertical Slice Offline   | Small map, character, movement, camera, joystick, HUD       |
| 2     | Gameplay Offline         | Enemy, combat, damage, death, loot, XP, first game loop     |
| 3     | Multiplayer Foundation   | Dedicated server, 2+ clients, sync, interpolation           |
| 4     | RPG Online               | Authoritative combat, mobs, inventory, equipment             |
| 5     | Accounts & Persistence   | Backend, auth, persistent characters/inventory/progress     |
| 6     | MMORPG World             | Multiple zones, NPCs, quests, chat, AoI, scaling            |
| 7     | Economy                  | Currencies, NPC shops, crafting, drops, rarity balance       |
| 8     | Social / MMO             | Party, friends, player trade, PvP                           |
| 9     | Production               | Cosmetics, shop, metrics, security, optimization, release   |

Full details: [docs/03-roadmap.md](docs/03-roadmap.md)

## Testing

- **Framework:** GUT (Godot Unit Test)
- **Priority:** `domain/` layer — pure logic, no scene dependencies
- **Rule:** Never weaken a test to make it pass. A red test is valuable information.
- **CI:** Tests run on every push via GitHub Actions

Details: [docs/07-testing.md](docs/07-testing.md)

## Security

- Client is never trusted; server validates everything
- No secrets in the repository (use environment variables)
- All server-side validation before state changes
- Rate limiting planned for networking layer
- Anti-cheat through server authority, not client-side detection

Details: [docs/06-security.md](docs/06-security.md)

## Asset Policy

- **Prefer CC0** for prototyping (Kenney is the safest source)
- **Register every asset** in CREDITS.md before committing
- **Verify individual licenses** — "free" does not mean "any use allowed"
- **Maintain visual coherence** — one style, one sprite size, one author per category
- **No asset is approved** until: author, license, source, and commercial-use status are documented

Details: [docs/05-assets-licenses.md](docs/05-assets-licenses.md)

## Development Workflow

```
ChatGPT       →  Architecture, planning, technical direction
Claude         →  Phase 0 foundation (this phase)
Codex          →  Primary implementation (Phase 1+)
Antigravity    →  Independent audit (architecture, security, quality)
Human          →  Final decisions and real-device testing
```

### Git Convention

```
1 TASK = 1 ISSUE = 1 BRANCH = 1 PR = AUDIT = MERGE
```

- Branch from the latest default branch
- Small, focused commits with clear messages
- PR requires audit before merge
- No direct pushes to `main`

### Definition of Done

A task is "done" when:
1. Code implements the specification
2. Tests pass (where applicable)
3. No secrets or credentials in the diff
4. CREDITS.md updated if new assets added
5. Documentation updated if architecture changed
6. CI passes
7. Audit approved

## Platforms

| Platform | Status   | Notes                            |
|----------|----------|----------------------------------|
| Android  | Primary  | Initial target, touch-first UX   |
| iOS      | Planned  | After Android vertical slice     |
| Desktop  | Dev only | For development and testing      |

## License

To be determined. The project source code license will be decided before public release. All third-party assets retain their original licenses as documented in CREDITS.md.
