# ADR-001: Godot 4.4 with GDScript

## Status
Accepted

## Context
The project needs a game engine for a 2D MMORPG targeting Android. The primary options are:
- Godot with GDScript
- Godot with C#
- Unity with C#
- Custom engine

## Decision
Use **Godot 4.4 (stable)** with **GDScript** as the primary language.

## Alternatives Considered

### Godot with C#
- Pro: Familiar to developers with C#/Unity background; stronger typing
- Con: C# export to Android is **experimental** in Godot 4.x with known limitations
- Con: Mono runtime adds APK size and complexity
- Con: Fewer community resources for Godot + C# on mobile

### Unity with C#
- Pro: Mature ecosystem, large community, proven for mobile
- Con: License costs and royalty changes (Runtime Fee concerns)
- Con: Not open source; vendor lock-in
- Con: Heavier than needed for 2D pixel art

### Custom Engine
- Con: Massive development overhead
- Con: No editor, no tooling, no community
- Con: Not viable for a small team

## Consequences

### Positive
- GDScript is the stable, first-class language for Godot on all platforms including Android
- Godot is free, open source, no royalties
- Large community and documentation for GDScript
- Lightweight engine suitable for 2D mobile games
- Built-in multiplayer API (ENet)
- Headless server mode for dedicated servers

### Negative
- GDScript is dynamically typed (mitigated by static typing annotations in Godot 4)
- Smaller ecosystem than Unity
- Team members may need to learn GDScript
- Some advanced patterns are less ergonomic than in C#

### Risks
- If C# Android export matures significantly, we may want to reconsider (low probability for project timeline)
- GDScript performance for compute-heavy server logic may need profiling (mitigated by keeping server logic simple for 10-20 players)
