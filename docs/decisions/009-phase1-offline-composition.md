# ADR-009: Minimal offline scene composition and native tests

## Status

Accepted for Phase 1.

## Context

The Phase 1 implementation contract permits simple geometry and native tests,
and prohibits early networking, server behavior and unnecessary managers.
The Phase 0 architecture and GUT descriptions describe a broader future game.
There are no domain gameplay rules to implement or test yet.

## Decision

- `src/main.gd` composes the playable scene. It collects keyboard input and the
  joystick's signal before the player's physics callback, then supplies one
  movement intent. UI produces input and never changes the player's state.
- `src/systems/movement_input.gd` contains only pure vector math. It depends on
  no nodes, UI, world, domain gameplay or networking. Player physics stays in
  `src/entities/`; the reusable joystick stays in `src/ui/`.
- Use a small scene with static rectangular colliders and original drawn shapes
  rather than a tileset dependency for the test map. TileMaps can be considered
  when map content actually requires them.
- Use a native `SceneTree` test runner for this phase's vector math and a bounded
  integration check of the real scene. GUT remains the planned domain testing
  framework; reassess and pin its Godot-compatible release when Phase 2 needs it.
- Add no autoload/EventBus, networking abstraction or server mode routing in
  this phase. The health HUD is fixed presentation and reads no game state.

## Consequences

Godot 4.4 itself runs all tests without an addon or third-party code. Failures
exit nonzero and the CI wrapper also checks diagnostics and a completion marker.
The native runner does not offer GUT fixtures, reports or mocking; revisit when
the test suite grows. Existing layer boundaries and later-phase decisions remain
applicable. No engine migration is made.
