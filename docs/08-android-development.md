# Android development export — Phase 1

## Current configuration

`export_presets.cfg` defines **Android Debug** for an offline development APK:

- Godot **4.4-stable**, GDScript, existing Mobile renderer retained.
- 1280 × 720 landscape baseline with responsive canvas anchors.
- ARMv7 and ARM64 native architectures; no x86 emulator target in this preset.
- Package ID `org.mmorpg2d.prototype`, development version `0.1.0` / code `1`.
- Exports the main scene and its dependencies. Test scripts, server placeholder,
  documentation and editable art are excluded from the game export.
- `INTERNET` and network-state permissions are disabled for this offline phase.
  Revisit `INTERNET` in Phase 3 as required by ADR-004; networking is not active.
- Signed debug export, with credentials supplied locally. No credentials or
  machine-specific paths are included in the preset.

## Local prerequisites

Follow the [official Godot 4.4 Android export guide](https://docs.godotengine.org/en/4.4/tutorials/export/exporting_for_android.html)
and [Android export option reference](https://docs.godotengine.org/en/4.4/classes/class_editorexportplatformandroid.html).

Install OpenJDK 17, Android SDK platform-tools, build-tools 34.0.0 and platform 34.
The guide also lists command-line tools, CMake 3.10.2.4988404 and NDK 23.2.8568313.
Install the official **4.4-stable export templates** through Godot's export
template manager. Set Java SDK Path and Android SDK Path in local Editor Settings.
Configure a local development signing key there (or the documented
`GODOT_ANDROID_KEYSTORE_DEBUG_*` environment variables). Keep the signing material
outside the repository. Never add release credentials to this development preset.

From the repository root, with `godot` pointing to the pinned engine:

```sh
mkdir -p build/android
godot --headless --path . --export-debug "Android Debug" build/android/mmorpg-2d-debug.apk
```

The output directory, APKs, `.godot/` export credentials, `.keystore` and `.jks`
files are ignored. Inspect `export_presets.cfg` before every commit if it has
been edited through the GUI. The SDK and signing setup are local prerequisites,
not repository secrets needed by CI.

## Device validation

On an authorized Android development device, install the APK with `adb install -r`
or Godot's one-click deploy. Verify landscape orientation, readable HUD, comfortable
left joystick, all movement directions, boundary/obstacle collisions, camera
tracking, release outside the joystick and background/resume without drift.
Check narrow/wide landscape screens and display cutouts; margins and anchors are
a baseline, not a claim of device-safe-area certification. The Mobile renderer's
Vulkan support and performance also need a real-device check.

## Implementation environment result

**ANDROID EXPORT: BLOCKED BY ENVIRONMENT.** The real Godot export command was
attempted and exited 1: 4.4 Android templates, JDK 17, Android SDK tools and a
configured debug signing key were unavailable. Godot recognized the Android Debug
preset, but no APK was produced. No Android device test has been executed.

CI validates engine import, scripts, main-scene startup and native tests. It does
not install Android tooling, build an APK or claim device validation. Phase 1's
real-device roadmap acceptance remains pending until the steps above pass.
