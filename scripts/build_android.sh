#!/usr/bin/env bash
# Build Android reproducible para 2D_Goddot (Godot 4.4).
#
# Uso:
#   bash scripts/build_android.sh                 # preset "Android Debug"
#   PRESET="Android Release" bash scripts/build_android.sh
#
# Variables opcionales:
#   GODOT_BIN     Ruta al ejecutable de Godot 4.4
#   JAVA_HOME     JDK 17+ (Godot lo exige para Android)
#   ANDROID_HOME  SDK de Android (por defecto ~/Library/Android/sdk)
#   OUTPUT        Ruta del APK (por defecto la del preset)
#
# Sale con código != 0 y mensaje claro si falta cualquier dependencia.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PRESET="${PRESET:-Android Debug}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

log() { printf '[build-android] %s\n' "$*"; }
fail() { printf '[build-android] ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- Godot
find_godot() {
  if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]]; then
    printf '%s' "$GODOT_BIN"; return 0
  fi
  local candidates=(
    "$HOME/Library/Application Support/MMORPG2D/Tools/Godot-4.4.app/Contents/MacOS/Godot"
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
    "/opt/homebrew/bin/godot"
    "/usr/local/bin/godot"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then printf '%s' "$candidate"; return 0; fi
  done
  if command -v godot >/dev/null 2>&1; then command -v godot; return 0; fi
  return 1
}

GODOT="$(find_godot)" || fail "Godot 4.4 no encontrado. Define GODOT_BIN=/ruta/a/Godot"
GODOT_VERSION="$("$GODOT" --version 2>/dev/null | head -1)"
[[ "$GODOT_VERSION" == 4.4.* ]] || fail "se requiere Godot 4.4.x, encontrado: $GODOT_VERSION"
log "Godot: $GODOT ($GODOT_VERSION)"

# ---------------------------------------------------------------- JDK 17+
find_java_home() {
  local candidates=(
    "${JAVA_HOME:-}"
    "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
    "/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    [[ -n "$candidate" && -x "$candidate/bin/java" ]] || continue
    local major
    major="$("$candidate/bin/java" -version 2>&1 | sed -n 's/.*version "\([0-9]*\).*/\1/p' | head -1)"
    [[ -n "$major" && "$major" -ge 17 ]] && { printf '%s' "$candidate"; return 0; }
  done
  return 1
}

if JAVA_HOME_RESOLVED="$(find_java_home)"; then
  export JAVA_HOME="$JAVA_HOME_RESOLVED"
  log "JAVA_HOME: $JAVA_HOME"
else
  fail "se requiere JDK 17+ (el de Android Studio o 'brew install openjdk'). Define JAVA_HOME."
fi

# ---------------------------------------------------------------- Android SDK
[[ -d "$ANDROID_HOME" ]] || fail "SDK de Android no encontrado en $ANDROID_HOME. Define ANDROID_HOME."
APKSIGNER="$(find "$ANDROID_HOME/build-tools" -maxdepth 2 -name apksigner -type f 2>/dev/null | sort -V | tail -1)"
[[ -n "$APKSIGNER" ]] || fail "apksigner no encontrado en $ANDROID_HOME/build-tools"
export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"
log "ANDROID_HOME: $ANDROID_HOME (build-tools $(basename "$(dirname "$APKSIGNER")"))"

# ---------------------------------------------------------------- Export templates
TEMPLATE_DIR="$HOME/Library/Application Support/Godot/export_templates/4.4.stable"
[[ -d "$TEMPLATE_DIR" ]] || fail "faltan plantillas de exportación 4.4.stable en $TEMPLATE_DIR"
[[ -f "$HOME/.android/debug.keystore" ]] || log "aviso: no hay ~/.android/debug.keystore; Godot intentará crearlo"

# ---------------------------------------------------------------- Contrato de input
# Evita publicar un APK si el editor reescribió project.godot y se perdieron los
# flags de input táctil (regresión TASK-003.5).
if command -v python3 >/dev/null 2>&1; then
  log "verificando contrato de input táctil"
  python3 "$ROOT/tools/check_input_contract.py" \
    || fail "contrato de input táctil incompleto. Restaura project.godot: git update-index --no-skip-worktree project.godot && git restore project.godot && git update-index --skip-worktree project.godot"
fi

# ---------------------------------------------------------------- Export
OUTPUT="${OUTPUT:-build/android/mmorpg-2d-debug.apk}"
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT" "$OUTPUT.idsig"

log "exportando preset '$PRESET' → $OUTPUT"
LOG="build/android/export-$(date +%Y%m%d-%H%M%S).log"
set +e
"$GODOT" --headless --path "$ROOT" --export-debug "$PRESET" "$OUTPUT" >"$LOG" 2>&1
EXPORT_STATUS=$?
set -e
if [[ $EXPORT_STATUS -ne 0 || ! -f "$OUTPUT" ]]; then
  tail -30 "$LOG" >&2
  fail "la exportación falló (exit=$EXPORT_STATUS). Ver $LOG"
fi

# ---------------------------------------------------------------- Verificación
"$APKSIGNER" verify --verbose "$OUTPUT" >/dev/null 2>&1 || fail "el APK no está firmado correctamente"

# ---------------------------------------------------------------- Contenido del APK
# Regresión TASK-003.5: con export_filter="scenes" los preload() de los scripts no
# llegaban al paquete y el juego arrancaba sin joystick ni movimiento en Android.
if command -v unzip >/dev/null 2>&1; then
  log "verificando contenido del APK"
  LISTADO="$(unzip -l "$OUTPUT")"
  for requerido in "assets/src/main.gdc" "assets/src/systems/" "assets/src/ui/virtual_joystick.gdc"; do
    printf '%s' "$LISTADO" | grep -q "$requerido" \
      || fail "el APK no contiene '$requerido'. Revisa export_filter en export_presets.cfg (debe ser all_resources)"
  done
  if printf '%s' "$LISTADO" | grep -q "assets/addons/gut/"; then
    log "aviso: el APK incluye addons/gut (revisar exclude_filter: no debería viajar a producción)"
  fi
fi

SIZE_BYTES="$(stat -f%z "$OUTPUT" 2>/dev/null || stat -c%s "$OUTPUT")"
SHA256="$(shasum -a 256 "$OUTPUT" | awk '{print $1}')"
log "OK: $OUTPUT"
log "tamaño: $(( SIZE_BYTES / 1024 / 1024 )) MB ($SIZE_BYTES bytes)"
log "sha256: $SHA256"
log "log: $LOG"
