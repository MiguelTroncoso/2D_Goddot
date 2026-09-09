# Asset Policy & License Guide

## Golden Rule

**No asset enters the repository without a documented license and entry in CREDITS.md.**

## License Types

| License    | Credit Required | Commercial Use | Derivatives Must Share | Notes                     |
|------------|:--------------:|:--------------:|:---------------------:|---------------------------|
| CC0        | No             | Yes            | No                    | Safest for any use        |
| CC-BY 3.0  | Yes            | Yes            | No                    | Must credit author        |
| CC-BY 4.0  | Yes            | Yes            | No                    | Must credit author        |
| CC-BY-SA   | Yes            | Yes            | Yes                   | Adaptations of the artwork must share under same terms (see below) |
| GPL        | Yes            | Yes            | Yes                   | Review exact version, dual-license options, and distribution (see below) |
| MIT        | Yes            | Yes            | No                    | Include license text      |
| Custom     | Check          | Check          | Check                 | Read the full license     |

## Approval Checklist

Before adding any asset, answer ALL of these:

- [ ] Who is the author?
- [ ] What is the exact license?
- [ ] Where was it downloaded from? (URL)
- [ ] Does the license allow commercial use?
- [ ] Does the license require attribution?
- [ ] Does the license have share-alike clauses? (If so, what scope do they cover?)
- [ ] Is the asset entry added to CREDITS.md?

If **any** answer is unknown → the asset is **NOT approved for production**.

## Recommended Sources (Priority Order)

### Tier 1 — Safe for Production
1. **Kenney** (kenney.nl) — CC0, no attribution needed
2. **Original art** — Created specifically for this project

### Tier 2 — Safe with Attribution
3. **game-icons.net** — CC-BY 3.0, credit required, 4000+ icons
4. **OpenGameArt** — Varies per asset, many CC0/CC-BY
5. **LPC (Liberated Pixel Cup)** — CC-BY-SA/CC-BY/GPL, check each piece

### Tier 3 — Verify Carefully
6. **itch.io game assets** — Each has its own license, many are free but not CC0
7. **CraftPix** — Mix of free and premium, check license per pack
8. **Poly Pizza** — CC0, 3D assets (only if using Blender pipeline)

## Visual Coherence Rules

1. **One sprite resolution** — Choose 16x16 or 32x32 and commit to it project-wide
2. **One style per category** — Don't mix pixel styles from different authors for characters
3. **One palette** — Fix a color palette early (use Lospec) and apply to all art
4. **LPC for characters** — If using LPC, use LPC for ALL character-related assets
5. **Rarity palette** — Define item rarity colors before populating inventory

## Rarity Color Suggestions

| Tier        | Color           | Hex       |
|-------------|-----------------|-----------|
| Common      | White / Gray    | `#CCCCCC` |
| Uncommon    | Green           | `#2ECC71` |
| Rare        | Blue            | `#3498DB` |
| Epic        | Purple          | `#9B59B6` |
| Legendary   | Orange / Gold   | `#F39C12` |

## Asset Categories

Based on the project's asset reference document:

1. Inventory & Item UI — slots, rarity frames, tooltips
2. Icons — weapons, armor, skills, accessories
3. Base packs — all-in-one sprite/tile collections
4. Weapons — inventory icons and equipped sprites
5. Armor — inventory icons and visible equipment layers
6. Characters — modular spritesheet system (LPC recommended)
7. NPCs — villagers, merchants, quest givers
8. Mobs / Enemies — animated monster sprites
9. Pets — companion animals
10. Mounts — rideable creatures
11. Costumes / Skins — cosmetic overlays
12. Accessories — rings, amulets, cloaks
13. Loot & Consumables — potions, chests, crafting materials

## File Organization

```
assets/          # Imported, ready-to-use files (PNG, WAV, OGG)
art-src/         # Editable source files (.aseprite, .blend, .psd)
```

Never commit editable source files without also committing the exported versions in `assets/`.

## Share-Alike License Guidance

### CC-BY-SA
- Share-Alike obligations apply to **adaptations and derivatives of the covered artwork** under the applicable license terms
- Using a CC-BY-SA sprite in your game does NOT automatically require unrelated GDScript source code to become CC-BY-SA
- However, any **modified or adapted version** of the artwork itself must be shared under the same or a compatible license
- The exact scope depends on the license version (3.0 vs 4.0) and what constitutes an "adaptation" under that version
- When in doubt, treat the asset as NOT production-approved until reviewed

### GPL (Common in LPC Assets)
- Many LPC assets are dual-licensed (e.g., GPL 3.0 + CC-BY-SA 3.0) — you may choose which license to follow
- GPL obligations depend on the exact version, how the asset is modified, and how the final product is distributed
- Do NOT make broad legal conclusions about GPL scope in this project
- For any GPL-licensed asset, document: exact license version, available dual-license options, whether the asset is modified, and the distribution method

### Project Policy
- If licensing implications of a specific asset are uncertain, the asset is **NOT production-approved** until independently reviewed
- This project does not provide legal guarantees about license interpretations
- CC0 remains the preferred license for prototyping to avoid these complexities entirely
