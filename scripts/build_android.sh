#!/usr/bin/env bash
# Build Android reproducible para 2D_Goddot (Godot 4.4).
#
# Uso:
#   bash scripts/build_android.sh            # APK debug (overlay de diagnóstico incluido)
#   bash scripts/build_android.sh --release  # APK release (sin overlay, firma de release)
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

CONFIG="debug"
case "${1:-}" in
  --release) CONFIG="release" ;;
  --debug|"") : ;;
  *) echo "[build-android] ERROR: opción desconocida '$1' (usa --release o nada)" >&2; exit 2 ;;
esac

if [[ "$CONFIG" == "release" ]]; then
  PRESET="${PRESET:-Android Release}"
  : "${OUTPUT:=build/android/mmorpg-2d-release.apk}"
  # Credenciales de firma de release: SIEMPRE fuera del repositorio.
  ENV_RELEASE="$HOME/.android/mmorpg2d-release.env"
  if [[ -f "$ENV_RELEASE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_RELEASE"
  fi
  if [[ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]]; then
    echo "[build-android] ERROR: release requiere firma. Crea $ENV_RELEASE con" >&2
    echo "  GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/ruta/fuera/del/repo/keystore" >&2
    echo "  GODOT_ANDROID_KEYSTORE_RELEASE_USER=<alias>" >&2
    echo "  GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=<password>" >&2
    exit 1
  fi
  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH GODOT_ANDROID_KEYSTORE_RELEASE_USER GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
else
  PRESET="${PRESET:-Android Debug}"
  : "${OUTPUT:=build/android/mmorpg-2d-debug.apk}"
fi
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
# Evita builds sobre un árbol con copias de conflicto de iCloud/Finder.
if command -v python3 >/dev/null 2>&1; then
  python3 "$ROOT/tools/check_workspace_clean.py" \
    || fail "hay copias de conflicto en el proyecto (ejecuta: python3 tools/check_workspace_clean.py --mover)"
fi

# Evita publicar un APK si el editor reescribió project.godot y se perdieron los
# flags de input táctil (regresión TASK-003.5).
if command -v python3 >/dev/null 2>&1; then
  log "verificando contrato de input táctil"
  python3 "$ROOT/tools/check_input_contract.py" \
    || fail "contrato de input táctil incompleto. Restaura project.godot: git update-index --no-skip-worktree project.godot && git restore project.godot && git update-index --skip-worktree project.godot"
fi

# ---------------------------------------------------------------- Export
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT" "$OUTPUT.idsig"

EXPECTED_OVERLAY="presente"
if [[ "$CONFIG" == "release" ]]; then EXPECTED_OVERLAY="ausente"; fi
log "exportando preset '$PRESET' (overlay de diagnóstico: $EXPECTED_OVERLAY) → $OUTPUT"
LOG="build/android/export-$(date +%Y%m%d-%H%M%S).log"
set +e
if [[ "$CONFIG" == "release" ]]; then
  "$GODOT" --headless --path "$ROOT" --export-release "$PRESET" "$OUTPUT" >"$LOG" 2>&1
else
  "$GODOT" --headless --path "$ROOT" --export-debug "$PRESET" "$OUTPUT" >"$LOG" 2>&1
fi
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
  if [[ "$CONFIG" == "release" ]] && printf '%s' "$LISTADO" | grep -q "debug_overlay"; then
    fail "el APK de release incluye el overlay de diagnóstico (revisa exclude_filter del preset)"
  fi
  if [[ "$CONFIG" == "debug" ]] && ! printf '%s' "$LISTADO" | grep -q "debug_overlay"; then
    log "aviso: el APK debug no incluye debug_overlay (el overlay no aparecerá)"
  fi
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
