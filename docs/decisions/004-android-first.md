# ADR-004: Android-First Development

## Status
Accepted

## Context
The game targets mobile players. Choose a primary platform to optimize for first.

## Decision
**Android** is the primary target platform. iOS and desktop are secondary.

## Alternatives Considered

### iOS First
- Pro: Higher average revenue per user
- Con: Requires macOS for builds, Apple Developer account ($99/yr)
- Con: Stricter review process
- Con: Smaller addressable market globally

### Desktop First, Then Port
- Pro: Easier development/testing cycle
- Con: Desktop and mobile UX are fundamentally different (mouse vs touch)
- Con: Risks building UI patterns that don't translate to mobile

## Consequences

### Positive
- Largest mobile market (globally)
- Android development is free (Google Play fee is one-time $25)
- Godot has mature Android export support
- Touch-first design ensures mobile UX quality
- APK testing on real devices is straightforward

### Negative
- Touch input must be designed from day one (virtual joystick, large tap targets)
- Screen size variability across Android devices
- Performance varies significantly across devices
- Desktop development uses touch emulation (less natural)

### Requirements
- Godot Android export configured with proper SDK/JDK
- `INTERNET` permission in Android manifest (for networking phases)
- Touch input emulation enabled for desktop testing
- UI elements sized for fingers (minimum 48dp tap targets)
- Testing on at least one real Android device per phase
