# Roadmap

## Phase 0 — Foundation (CURRENT)

**Objective:** Create a professional, reproducible, auditable project foundation.

**Deliverables:**
- Repository structure following layered architecture
- Godot 4.4 project configuration
- Complete documentation suite
- Architecture Decision Records
- CI pipeline (validation + test runner)
- Asset policy and CREDITS.md
- Security policy
- Testing strategy

**Done when:**
- All documentation written and internally consistent
- project.godot valid for Godot 4.4
- CI workflow passes
- No secrets in repository
- Audit approved

---

## Phase 1 — Offline Movement & Controls Foundation

**Objective:** A single-player offline prototype with core movement, controls, and Android export.

**Deliverables:**
- Small TileMap level
- Player character (CharacterBody2D) with 4-direction movement
- Virtual joystick for Android touch input
- Camera2D with smooth following
- Basic collisions with environment
- Minimal HUD (placeholder)
- Main scene assigned in project.godot
- Android export working on real device
- Initial domain tests where applicable

**Explicitly NOT in Phase 1:**
- No combat
- No enemies
- No loot
- No XP or progression
- No networking or multiplayer
- No backend or database

**Done when:**
- Player moves in a small map with touch controls on Android
- Camera follows smoothly
- Collisions work correctly
- APK runs on a real device
- CI passes

---

## Phase 2 — Gameplay Offline

**Objective:** First complete game loop — fight, loot, level up.

**Deliverables:**
- Enemy entity with basic AI (idle, chase, attack)
- Combat system (attack, damage, death) — logic in domain/
- Loot drops on enemy death
- XP gain and level-up system
- Basic inventory UI
- Death and respawn

**Done when:**
- Player can fight enemies, collect loot, gain XP, and level up
- Complete loop playable offline
- Domain logic covered by GUT tests

---

## Phase 3 — Multiplayer Foundation

**Objective:** Two or more players connected to a dedicated server.

**Deliverables:**
- Godot dedicated server (headless via feature tag)
- ENet connection (client connects to server)
- Player spawning via MultiplayerSpawner
- Position sync via MultiplayerSynchronizer
- Basic interpolation for remote players
- Server-side movement validation

**Done when:**
- 2+ clients connect to a headless server
- Players see each other and move in real time
- Server validates positions
- No client-side cheating of movement possible

---

## Phase 4 — RPG Online

**Objective:** RPG systems running with server authority.

**Deliverables:**
- Authoritative combat (server calculates all damage)
- Server-controlled mob spawning and AI
- Synced inventory system
- Equipment slots with visual feedback
- Synced XP and progression

**Done when:**
- Full RPG loop (fight, loot, equip, level) works online
- All game logic validated server-side
- 10–20 concurrent players stable in one zone

---

## Phase 5 — Accounts & Persistence

**Objective:** Persistent player data with a real backend.

**Deliverables:**
- Backend service (Node.js / TypeScript + PostgreSQL)
- User authentication (email/password or OAuth)
- Character creation and selection
- Persistent inventory, equipment, and progression
- Redis for sessions/caching (when demonstrably needed)
- Save-by-event (login/logout, trade, level-up)

**Done when:**
- Players log in, play, log out, and return with their progress intact
- Backend deployed and accessible
- Auth is secure (hashed passwords, HTTPS)

---

## Phase 6 — MMORPG World

**Objective:** Multiple zones with transitions and scaling.

**Deliverables:**
- Multiple connected maps/zones
- Zone transitions (loading, unloading)
- NPC system (quest givers, merchants)
- Quest system (basic fetch/kill quests)
- Chat system (zone, global channels)
- Area of Interest (grid-based)
- Progressive scaling past 20 players

**Done when:**
- Players traverse between zones
- NPCs offer quests and services
- Chat works across zones
- AoI reduces bandwidth for 20+ players

---

## Phase 7 — Economy

**Objective:** Functional in-game economy.

**Deliverables:**
- Currency system (gold/coins)
- NPC shops (buy/sell)
- Crafting system (combine materials)
- Drop tables with rarity tiers
- Economic balance tuning

**Done when:**
- Players earn, spend, and trade currency
- Crafting produces useful items
- Economy doesn't collapse under normal play

---

## Phase 8 — Social / MMO

**Objective:** Social features for community.

**Deliverables:**
- Party system
- Friends list
- Player-to-player trading
- PvP (optional arenas or zones)
- Guild system (stretch goal)

**Done when:**
- Players can group, trade, and interact socially
- PvP works in designated areas

---

## Phase 9 — Production

**Objective:** Ship the game.

**Deliverables:**
- Cosmetics and in-game shop
- Battle pass or similar progression reward
- Metrics and analytics
- Security hardening
- Performance optimization
- iOS build
- Beta testing program
- Google Play / App Store submission

**Done when:**
- Game is live on Google Play
- Monetization is functional and fair (no pay-to-win)
- Metrics show player retention
