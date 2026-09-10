# Testing Strategy

## Phase 1: native Godot runner

Phase 1 uses `tests/run_tests.gd`, a native `SceneTree` runner, without third-party
addons. See [ADR-009](decisions/009-phase1-offline-composition.md). GUT remains the
planned framework for future domain gameplay rules; it has **not** been installed.

Use the exact official **Godot 4.4-stable** (`4.4.stable.official.4c311cbee`). No
engine migration is part of this phase. Python 3 standard library is sufficient
for the wrapper; it invokes the engine, not a replacement parser.

From the repository root:

```sh
python3 .github/scripts/validate_godot.py --godot godot
```

Pass an absolute executable path after `--godot` when it is not on PATH. On macOS,
the executable is `Godot.app/Contents/MacOS/Godot` inside the downloaded app bundle.
The [official CLI reference](https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html)
describes these commands, executed sequentially by the wrapper:

```sh
godot --headless --path . --import
godot --headless --path . --check-only --script src/entities/player.gd
# The script check is repeated for every .gd in src/, server/ and tests/.
godot --headless --path . --quit-after 60
godot --headless --path . --script tests/run_tests.gd
```

The server placeholder is parsed but never launched. The main scene is loaded
as an offline game. The runner uses explicit expectations and exits 1 on failure;
it does not rely on release-disabled `assert` statements. The wrapper imposes
process timeouts, rejects engine/script errors even with exit code 0, and requires
a nonempty successful test completion marker.

### Known engine import warning

Godot 4.4-stable has an upstream editor-import regression:
[godotengine/godot#103398](https://github.com/godotengine/godot/issues/103398).
Its progress-dialog errors can occur even on an empty valid project. The wrapper
prints them and reports a warning. Only the three exact diagnostic/location pairs
from `editor/progress_dialog.cpp` are tolerated **during import**, with the engine
version checked first. Every other import error fails; all script/startup/test
errors fail without this exception. Keeping 4.4 avoids an unrequested upgrade.
The local editor may also report missing Android build-tools; actual export is
separately recorded as blocked, never inferred from a successful project load.

### Automated coverage

The runner currently performs 50 checks, covering:

- Idle, four cardinal directions, diagonal normalization, mixed input clamping,
  opposing inputs and preservation of analog speed.
- Joystick dead zone, boundary behavior, maximum drag, zero travel and smooth
  rescaling outside the dead zone.
- Real player displacement over one second at 30 and 60 physics ticks, and stop
  on keyboard release. Physical W and arrow events also verify the action mappings
  and normalized diagonal velocity in the running player.
- Player shape collisions against all four boundaries and all four obstacles,
  plus a held-input test that stops against a block using `move_and_slide`.
- Touch events routed through the viewport and connected to player physics;
  one-finger ownership, second-finger isolation, dragging/releasing outside the
  control, cancellation, hidden controls and focus loss.
- Active player camera, camera following and the fixed health placeholder.

Viewport touch injection uses local viewport coordinates (`push_input(event,
true)`); it is an automated input-path test, not a claim of real-device touch or
operating-system mouse emulation validation. Integration tests use physics frames
and behavior checks, not screenshot pixel matching.

### Manual checklist

Run `godot --path .` or F5 in the editor. Verify player visibility, WASD/arrows,
mouse joystick drag and release, obstacle collision, camera tracking, readable HUD,
window resizing and background/resume without stuck input. Test actual Android
hardware separately using the [export guide](08-android-development.md).

A native graphical launch was inspected on macOS with the existing Mobile renderer.
The player, obstacles, HUD and joystick rendered. Automated checks cover movement,
collision and camera. OS mouse/key actions were attempted through desktop
control tooling, but did not establish sustained movement: the synthesized mouse
sequence emitted press/release without a touch-drag event. Full hands-on control
verification remains pending; it is not counted as a manual gameplay pass.
Android hardware validation remains **NOT EXECUTED**.

## Future framework: GUT

[GUT](https://github.com/bitwes/Gut) is the planned test addon when Phase 2 adds
domain rules. Recheck compatibility with the engine, pin the selected release and
document its license before installation. The following priorities and examples
are future guidance; their files are not implemented in Phase 1.

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

`.github/workflows/ci.yml` has two jobs:

1. Structural directory/file checks, the existing basic secret-pattern scan,
   documentation links and tiered large-file checks from Phase 0.
2. Official Godot 4.4-stable Linux runtime validation and the native test runner.

Branch filters include slashes, so feature branch pushes are validated. Checkout
is pinned to the v4.3.1 commit; the official engine archive is pinned by SHA-512.
The runtime archive stays in the runner's temporary directory. CI permissions are
read-only and project validation needs no repository secrets. The INI surrogate
check was replaced because `project.godot` now contains Godot's multiline input
objects; the actual engine is the parser.

CI does **not** export Android or run real-device/visual tests. See the
[Android guide](08-android-development.md) for its missing local prerequisites.

## Coverage Goals

| Phase | Coverage target |
|-------|-----------------|
| 0 | Structural safeguards (audited baseline; no runtime tests then) |
| 1 | Native input math, scene/physics/control integration checks |
| 2 | GUT for domain code (damage, XP, loot) |
| 3 | Network protocol validation |
| 4+ | Comprehensive domain and systems coverage |
