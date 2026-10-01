# Roadmap

## Phase 0 — Foundation (audited baseline)

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

## Phase 1 — Offline Movement & Controls Foundation — ✅ CERRADA (2026-10-01)

**Estado: cerrada con validación física en dispositivo** (TASK-005). Evidencia en
[PHASE-1.md](phase-reviews/PHASE-1.md) y
[ADR-010](decisions/010-phase1-closure-exception.md). Tag: `fase-1-complete`.

**Objective:** A single-player offline prototype with core movement, controls, and Android export.

**Implementation status (auditado 2026-10-01, ver
[revisión de Fase 1](phase-reviews/PHASE-1.md)):** offline scene, teclado, joystick
táctil, colisiones, cámara, HUD fijo y tests nativos están implementados y en verde
(`PHASE1_TEST_RESULT: 50 checks, 0 failures`). El export Android Debug **ya no está
bloqueado**: `scripts/build_android.sh` resuelve Godot 4.4, JDK 17+, SDK de Android y
plantillas, firma y verifica el APK, y en la auditoría produjo
`build/android/mmorpg-2d-debug.apk` (54.220.359 bytes, `sha256`
`9389115024cf5be60fa6c6e4f5c0e1762bda70d85ed2db185d1b5db4fe000948`, firma debug v2
verificada). Queda **un único bloqueante**: la prueba física en un dispositivo
Android del PO (`adb install -r`), junto con la medición de FPS, batería y safe area.
Los criterios de aceptación Android de abajo siguen **sin cumplirse** hasta que esa
prueba ocurra. Ver [Android development](08-android-development.md) y
[testing](07-testing.md).

**Deliverables:**
- Small static test map with original geometric placeholders (ADR-009)
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

**Implementation status (2026-10-01, actualizado):** **en pausa**. El PO probó el APK de
Fase 1 en su teléfono y el input táctil no funcionaba; la Fase 1 se reabre
([ADR-010](decisions/010-phase1-closure-exception.md) enmendado) y TASK-003.5 corrige el
joystick dinámico, la zona segura y añade verificación en dispositivo
([regresión](phase-reviews/PHASE-1-REGRESSION.md)). No se apilan tareas de UI sobre una
feature sin validar. El núcleo de dominio de TASK-003 sigue en pie:
tipos de daño, mitigación, críticos, fórmula de daño con desglose auditable, curva de
XP 1–150, `StatBlock` y `EnemyArchetype`. Suite GUT 9.4.0 en verde (52 tests, 378
asserts) y cobertura de API del dominio del 100 % (gate ≥ 80 % en CI). Pendiente del
resto de la fase: entidades de escena, IA, loot, HUD de combate y primer set T1. La
prueba física de Fase 1 sigue diferida en [TASK-002](plans/TASK-002.md) por
[ADR-010](decisions/010-phase1-closure-exception.md).

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
