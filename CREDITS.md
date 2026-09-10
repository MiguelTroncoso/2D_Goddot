# Credits & Asset Licenses

This file tracks every external asset used in the project.
**Every asset must be registered here before being committed.**

## License Quick Reference

| License    | Credit Required | Commercial Use | Share-Alike |
|------------|:--------------:|:--------------:|:-----------:|
| CC0        | No             | Yes            | No          |
| CC-BY 3.0  | Yes            | Yes            | No          |
| CC-BY 4.0  | Yes            | Yes            | No          |
| CC-BY-SA   | Yes            | Yes            | Yes — see note below |
| GPL        | Yes            | Yes            | Yes — see note below |
| MIT        | Yes            | Yes            | No          |

## Asset Registry

### Placeholder Icon

| Field          | Value                           |
|----------------|----------------------------------|
| Asset          | Project icon (icon.svg)          |
| Author         | Project team                     |
| License        | Original work                    |
| Source          | Created for this project         |
| Attribution    | N/A                              |
| Commercial Use | Yes                              |

### Phase 1 geometric placeholders

| Field | Value |
|-------|-------|
| Asset | Player polygons, map/grid/blocks, joystick and HUD shapes |
| Author | Project team (created for this implementation) |
| License | Original work; same source-license status as the project |
| Source | Godot scene geometry and drawing code in `src/` |
| Attribution | N/A |
| Commercial Use | No external asset restrictions |

No external art, asset packs, fonts, sounds or test addons were imported in Phase 1.
Godot's built-in font is used. The engine is development tooling, not vendored in
this repository. CI uses the official engine release and GitHub checkout action
pinned to a SHA; no additional runtime dependencies were introduced.

---

## How to Add an Asset

Copy this template for each new asset:

```markdown
### [Asset Name]

| Field          | Value           |
|----------------|-----------------|
| Asset          | [description]   |
| Author         | [name]          |
| License        | [CC0/CC-BY/...] |
| Source          | [URL]           |
| Attribution    | [required text] |
| Commercial Use | [Yes/No/Check]  |
```

## Approved Sources (prefer in order)

1. **Kenney** (CC0) — safest for prototyping and production
2. **OpenGameArt** (varies) — verify per-asset
3. **itch.io game assets** (varies) — verify per-asset
4. **game-icons.net** (CC-BY 3.0) — credit required
5. **LPC / Liberated Pixel Cup** (CC-BY-SA / CC-BY / GPL) — credit required, check share-alike

## Rules

- NO asset is approved for production until registered here
- Every asset must answer: Who made it? What license? Can we ship it commercially?
- If any answer is unknown, the asset is **NOT approved**
- **CC-BY-SA:** Share-Alike obligations apply to adaptations and derivatives of the covered artwork under the applicable license terms. Using a CC-BY-SA sprite does not automatically require unrelated source code to become CC-BY-SA, but any modified or adapted version of the artwork itself must be shared under the same terms. Review the specific license version and your modifications before production use.
- **GPL:** The exact asset, license version, dual-license options, modification status, and distribution method must all be reviewed before production use. Many LPC assets offer dual licensing (GPL + CC-BY-SA); the chosen license determines obligations. If implications are uncertain, the asset is NOT production-approved until reviewed.
- Prefer CC0 for prototyping phases
