# ADR-008: Asset Policy and Licensing Strategy

## Status
Accepted

## Context
An MMORPG requires many visual and audio assets. An indie team must balance speed (using free assets) with legal safety (proper licensing) and visual quality (style coherence).

## Decision
Adopt a strict asset policy:
1. **Prefer CC0** assets for prototyping (Kenney as primary source)
2. **Register every asset** in CREDITS.md with full provenance
3. **Verify individual licenses** before incorporating any asset
4. **Maintain visual coherence** — one style, one sprite size, one author per category
5. **No asset is approved** without documented author, license, source, and commercial-use status

## Alternatives Considered

### No Asset Policy
- Pro: Move faster
- Con: Legal risk in production
- Con: Visual incoherence
- Con: No audit trail

### Commission All Art
- Pro: Original, coherent, no license concerns
- Con: Expensive
- Con: Slow — blocks development on art delivery
- Note: May be the long-term strategy for production art

## Consequences

### Positive
- Legal safety — every asset's license is documented and verified
- Audit trail — CREDITS.md answers "where did this come from?"
- Visual coherence enforced from the start
- CC0 assets allow shipping without legal review
- Clear upgrade path: replace placeholder CC0 with commissioned art later

### Negative
- Overhead of documenting every asset
- Limited to free/CC0 sources for prototyping
- May need to replace assets when transitioning to production art

### Key Sources
- Kenney (CC0) — safest, broadest library
- game-icons.net (CC-BY 3.0) — best icon library, requires credit
- LPC (CC-BY-SA/GPL) — best modular character system, viral license
- OpenGameArt (varies) — large library, check each asset
- itch.io (varies) — indie marketplace, verify per-pack
