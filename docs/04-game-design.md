# Game Design Document

## Genre

2D top-down MMORPG with pixel-art aesthetics.

## Core Pillars

1. **Accessible** — Touch-first design for mobile; simple to learn, deep to master
2. **Social** — Multiplayer at the core; playing with others is the point
3. **Rewarding** — Clear progression loop; every session feels like progress
4. **Fair** — No pay-to-win; monetization through cosmetics only

## View and Camera

- Top-down 2D perspective
- Camera2D with smooth following
- Viewport sized for mobile screens (portrait or landscape TBD — start landscape)

## Art Style

- Pixel art, consistent resolution across all assets
- Sprite size: to be decided (16x16 or 32x32 — see ADR)
- Single color palette for visual coherence (use Lospec as reference)
- Recommended base system: LPC (Liberated Pixel Cup) for modular characters

## Player Character

- CharacterBody2D
- 4-direction (or 8-direction) movement
- Modular appearance: body, hair, armor, weapon as separate sprite layers
- Equipment visually reflected on the character (LPC layer system)

## Classes (Future — Phase 4+)

To be designed. Initial ideas:
- Warrior (melee, tank)
- Mage (ranged, AoE)
- Rogue (melee, fast, stealth)
- Ranger (ranged, pets)

Phase 1-2 use a single generic character class.

## Combat

- Real-time, action-based
- Tap/button to attack
- Damage calculated server-side (Phase 3+)
- Death → respawn at last safe point
- No friendly fire in PvE zones

## Enemies

- Server-controlled AI (Phase 3+; offline AI in Phase 2)
- Behavior: idle → detect player → chase → attack → return to patrol
- Grouped by zone difficulty
- Bosses at key locations

## Inventory

- Grid-based (like Diablo/Ragnarok) or list-based (TBD)
- Item stacking for consumables
- Equipment slots: weapon, helmet, chest, legs, boots, accessory
- Rarity tiers by color (common → uncommon → rare → epic → legendary)

## Progression

- XP gained from killing enemies and completing quests
- Level-up curve (exponential scaling)
- Stat increases per level
- Skill points (future)
- All calculations in domain/ layer

## Economy (Future — Phase 7)

- Primary currency: Gold (earned in-game)
- Premium currency: Gems (purchased, cosmetics only)
- NPC shops for basic items
- Crafting system
- Player-to-player trading (Phase 8)

## Monetization (Future — Phase 9)

- Cosmetics only (skins, mounts, pets, costumes)
- No gameplay advantages for purchase
- Battle pass for seasonal cosmetics
- No ads (premium model)

## World

- Multiple connected zones (Phase 6)
- Safe zones (towns, no monsters)
- Danger zones (field, dungeons)
- Zone transitions with loading screens
- Instanced dungeons (future)

## Social

- Chat (zone, global, party, whisper)
- Party system (shared XP, coordinated play)
- Friends list
- Guilds (stretch goal)
- Player trading

## Mobile UX

- Virtual joystick for movement (thumb-accessible)
- Action buttons on right side
- Auto-attack option
- Minimap
- Touch-friendly inventory (large tap targets)
- All UI elements sized for fingers, not mouse cursors
