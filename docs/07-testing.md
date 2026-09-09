# Testing Strategy

## Framework

**GUT (Godot Unit Test)** — the standard unit testing framework for Godot 4.

- Repository: https://github.com/bitwes/Gut
- Installed as a Godot addon
- Tests run from the editor or CLI (for CI)

## Test Priority

### Tier 1 — Must Test (domain/)
Pure game logic with no dependencies on Godot nodes or networking:
- Damage calculations
- XP curves and level-up logic
- Loot table rolls
- Inventory operations (add, remove, stack, equip)
- Stat calculations
- Economy transactions

These are the easiest to test and the most important to get right.

### Tier 2 — Should Test (systems/)
Use cases that orchestrate domain logic:
- Combat flow (sequence of events)
- Progression system (XP → level → stat changes)
- Inventory management (equip/unequip flow)

May require mocking signals or simple stubs.

### Tier 3 — Integration Tests (future)
- Network protocol (client sends input → server responds correctly)
- Scene loading and transitions
- Persistence (save → load → verify)

These require more setup and are deferred to later phases.

## Test Structure

```
tests/
├── test_domain/           # Tests for src/domain/
│   ├── test_damage.gd
│   ├── test_xp_curve.gd
│   └── test_loot.gd
├── test_systems/          # Tests for src/systems/
│   ├── test_combat.gd
│   └── test_inventory.gd
└── .gutconfig.json        # GUT configuration
```

## Naming Convention

- Test files: `test_<module>.gd`
- Test classes: extend `GutTest`
- Test methods: `test_<what_it_tests>()`

Example:
```gdscript
extends GutTest

func test_damage_is_positive():
    var result = DamageCalculator.calculate(10, 3)
    assert_gt(result, 0, "Damage should be positive")

func test_zero_attack_deals_no_damage():
    var result = DamageCalculator.calculate(0, 5)
    assert_eq(result, 0, "Zero attack should deal zero damage")
```

## Rules

1. **Never weaken a test to make it pass.** Fix the code, not the test.
2. **Never skip a test to get green CI.** A skipped test is a hidden bug.
3. **Never declare something tested that wasn't executed.**
4. **Domain tests must not require scenes.** If a domain test needs a scene, the domain code has a bad dependency.
5. **Test behavior, not implementation.** Test what the function returns, not how it computes it.

## CI Integration

Tests run automatically on every push via GitHub Actions:
- GUT runs in headless mode
- Exit code 0 = all tests pass
- Any failure fails the CI pipeline

## Coverage Goals

| Phase | Coverage Target                          |
|-------|------------------------------------------|
| 0     | Framework installed, no tests yet        |
| 1     | Movement logic if any domain code exists |
| 2     | All domain/ code (damage, XP, loot)      |
| 3     | Network protocol validation              |
| 4+    | Comprehensive domain + systems coverage  |

## GUT Installation (Phase 1)

GUT will be added as a Godot addon in Phase 1 when the first testable domain code is written. In Phase 0, the test directory structure and configuration are prepared.

The `.gutconfig.json` will be configured to:
- Look for tests in `res://tests/`
- Use the `test_` prefix for test files
- Output results to stdout for CI parsing
