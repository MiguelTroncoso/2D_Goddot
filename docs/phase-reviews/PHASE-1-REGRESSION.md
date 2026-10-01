# REGRESIÓN FASE 1 — El APK no responde al input táctil

> Reportada por el PO el 2026-10-01 sobre `build/android/mmorpg-2d-debug.apk`
> (sha256 `9389115024cf5be60fa6c6e4f5c0e1762bda70d85ed2db185d1b5db4fe000948`).
> Síntoma: el jugador no se mueve, no se ve el joystick, la pantalla solo muestra el
> HUD placeholder y el texto "Move: WASD / arrows / drag joystick".
> Corrige: TASK-003.5 · Reabre: Fase 1 ([ADR-010](../decisions/010-phase1-closure-exception.md)) · Lección: [ADR-012](../decisions/012-ui-input-requires-device-validation.md)

## 1. Causa raíz

### C1 — El APK no empaquetaba `src/systems/` (causa raíz confirmada)

`export_presets.cfg` usaba:

```ini
export_filter="scenes"
export_files=PackedStringArray("res://src/main.tscn")
```

El modo *scenes* empaqueta la escena listada y sus dependencias **de escena** (sub-escenas,
tiles, texturas), pero **no sigue los `preload()` que están dentro de los scripts**. El
proyecto tiene dos:

```gdscript
# src/main.gd y src/ui/virtual_joystick.gd
const MovementInput = preload("res://src/systems/movement_input.gd")
```

Evidencia en el APK defectuoso (`unzip -l build/android/mmorpg-2d-debug.apk`):

| Contenido esperado | Resultado |
|--------------------|-----------|
| `assets/src/main.gdc` | ✅ presente |
| `assets/src/ui/virtual_joystick.gdc` | ✅ presente |
| `assets/src/systems/movement_input.gdc` | ❌ **ausente** |
| `assets/src/systems/` (cualquier archivo) | ❌ **ausente** |
| Ocurrencias de la cadena `movement_input` en el APK | **0** |

**Efecto en el teléfono:** al no existir el recurso del `preload`, el motor no puede cargar
esos scripts. La escena `main.tscn` se instancia igual (sus hijos son nodos de escena), así
que el mapa y el HUD —incluido el texto de ayuda— se dibujan; pero:

- `src/main.gd` no corre → nadie conecta el joystick con el jugador ni lee el teclado;
- `src/ui/virtual_joystick.gd` no corre → el joystick no se dibuja ni recibe toques.

Es exactamente el síntoma reportado, y explica también por qué el fallo era total en vez
de parcial.

### C2 — El joystick dependía de un *hit test* con transformaciones (defecto secundario)

La versión anterior solo aceptaba un toque que cayera dentro de un círculo de 100 px
calculado así:

```gdscript
var offset := _local_offset(event.position)   # evento en coords de viewport
if offset.length() <= BASE_RADIUS:            # 100 px

func _local_offset(viewport_position: Vector2) -> Vector2:
    return get_global_transform_with_canvas().affine_inverse() * viewport_position - size * 0.5
```

El cálculo solo es exacto cuando la transformación es la identidad (escritorio a
1280×720). Como hay una única condición de aceptación, cualquier desajuste de escala del
dispositivo apagaría el control por completo en vez de degradarlo. No se reprodujo en
escritorio (sonda a 1920×1080 con escala 1,5: el toque funcionaba), pero el diseño era
frágil por construcción.

### C3 — El joystick no respetaba la zona segura (defecto secundario)

El anillo se dibujaba a 48 px del borde inferior-izquierdo sin consultar nunca
`DisplayServer.get_display_safe_area()`: en horizontal, la muesca y la barra de gestos de
Android viven justo ahí. En Fase 1 había **0 referencias** a esa API en todo el proyecto.

### C4 — La fase se cerró sin probar su única funcionalidad

ADR-010 difirió la prueba física. La Fase 1 consistía exclusivamente en movimiento táctil:
diferirla equivalía a no verificar nada.

### Hipótesis descartadas con evidencia

| Hipótesis | Verificación | Resultado |
|-----------|--------------|-----------|
| La escena del joystick no llegó al APK | `unzip -l`: `export-…-virtual_joystick.scn` y `virtual_joystick.gdc` presentes | ❌ Descartada (lo que faltaba era su dependencia en `src/systems/`) |
| El HUD no instancia el joystick | `src/ui/hud.tscn` lo instancia; sonda en runtime: nodo presente | ❌ Descartada |
| El joystick queda fuera de pantalla en otras resoluciones | Sonda a 1280×720, 1600×720, 1920×1080 y 2400×1080: `global_rect` siempre dentro del viewport | ❌ Descartada |
| El mapeo de coordenadas falla con escala ≠ 1 | Sonda a 1920×1080 (escala 1,5) con `push_input(evento, false)`: el toque activa y el arrastre produce `(1, 0)` | ❌ Descartada como causa; se corrige igual por robustez |

## 2. Por qué CI y los tests no lo detectaron

| Motivo | Evidencia |
|--------|-----------|
| CI ejecuta el **proyecto fuente**, donde los `preload()` resuelven; nunca inspecciona el **contenido del APK** | `.github/workflows/ci.yml`: job `Godot 4.4 — parse, load and test` |
| Los tests inyectan el toque en coordenadas locales del viewport (`push_input(evento, true)`), saltándose la conversión sistema→viewport | `tests/run_tests.gd`, `_touch()` y `_drag()` |
| Los tests solo comprueban `joystick.output`; nunca visibilidad, rect en pantalla ni zona segura | `tests/run_tests.gd`, bloque "Touch goes through the viewport input route" |
| No existía ningún check estructural de preset de exportación ni de escenas | `.github/workflows/ci.yml` antes de TASK-003.5 |
| `apk-validation.json` validaba firma, arquitecturas y orientación, pero **no la completitud de scripts** | `build/android/apk-validation.json` del build anterior |
| La prueba física se declaró diferible | [ADR-010](../decisions/010-phase1-closure-exception.md) |

## 3. Qué check debió existir (y ahora existe)

1. **`tools/check_export_contract.py`** — exige `export_filter="all_resources"` y que el
   `exclude_filter` no tape código de runtime (`src/**`) ni olvide excluir `addons/*`.
   Se ejecuta en CI y antes de cada build.
2. **Verificación del contenido del APK** dentro de `scripts/build_android.sh`: el
   artefacto debe contener `assets/src/main.gdc`, `assets/src/systems/` y
   `assets/src/ui/virtual_joystick.gdc`; avisa si `addons/gut` viaja al paquete.
3. **`tools/check_input_contract.py`** — flags táctiles, joystick a pantalla completa,
   instanciación en el HUD y mapeo relativo presente.
4. **`tests/presentation/test_joystick_regression.gd`** — el joystick existe, es visible,
   su anillo cabe en pantalla, la mitad derecha no lo activa y un toque **en coordenadas
   de pantalla** (`push_input(evento, false)`) mueve al jugador y lo detiene al soltar.
5. **Regla de proceso ([ADR-012](../decisions/012-ui-input-requires-device-validation.md))** —
   ninguna feature de UI/input se cierra sin prueba física.

## 4. Corrección aplicada

| # | Cambio | Archivo |
|---|--------|---------|
| 1 | **`export_filter="all_resources"`** con exclusiones explícitas (`tests`, `docs`, `server`, `art-src`, `addons`, `tools`, `.github`) — ahora todo el código de runtime se empaqueta | `export_presets.cfg` |
| 2 | Verificación post-export del contenido del APK, con fallo explícito | `scripts/build_android.sh` |
| 3 | Chequeo estático del contrato de exportación en CI | `tools/check_export_contract.py`, `.github/workflows/ci.yml` |
| 4 | Joystick **dinámico** con desplazamiento relativo (sin transformaciones) | `src/systems/movement_input.gd`, `src/ui/virtual_joystick.gd` |
| 5 | Zona de activación en la mitad izquierda con margen superior | `src/systems/movement_input.gd` |
| 6 | Zona segura aplicada a HUD y joystick | `src/systems/safe_area.gd`, `src/ui/hud.gd` |
| 7 | Anillo de reposo siempre visible y anillo activo bajo el dedo | `src/ui/virtual_joystick.gd` |
| 8 | Diagnóstico en pantalla (FPS, resolución, insets, contadores de toque, vector, velocidad) | `src/ui/hud.gd`, `src/ui/hud.tscn` |

## 5. Artefacto entregado

| Campo | Valor |
|-------|-------|
| APK | `build/android/mmorpg-2d-debug.apk` |
| Tamaño | 54.292.434 bytes (51,8 MB) |
| sha256 | `c07a1cc65337a1e97035a9039c1ae1692280859d03f52498fa068f9c545a3cb5` |
| Firma | Debug v2 verificada con `apksigner` |
| Contenido verificado | `assets/src/systems/` presente · `assets/src/domain/` presente · `addons/`, `tests/`, `docs/` ausentes |

## 6. Cómo verificar en dispositivo que el fix funciona

```sh
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# 0. Conectar el teléfono por USB con depuración habilitada y autorizar el equipo
adb devices -l

# 1. Instalar el APK nuevo (reemplaza la versión anterior)
adb install -r build/android/mmorpg-2d-debug.apk

# 2. Lanzar y limpiar el log
adb logcat -c
adb shell am start -n org.mmorpg2d.prototype/com.godot.game.GodotApp

# 3. Captura inicial
adb exec-out screencap -p > build/android/device-01-inicio.png

# 4. Prueba táctil real: deslizar en la mitad izquierda (joystick dinámico)
adb shell input swipe 300 600 520 600 800
adb exec-out screencap -p > build/android/device-02-drag.png

# 5. Log del motor
adb logcat -d | grep -iE "godot|fatal|exception" > build/android/device-logcat.txt
```

**Qué observar en pantalla (panel de diagnóstico, arriba a la derecha):**

| Línea | Qué debe pasar | Qué significa si no pasa |
|-------|----------------|--------------------------|
| `vp 1280x720 · win <real>` | Muestra la resolución real del teléfono | Si `win` no coincide, reportar el valor |
| `safe L… T… R… B…` | Con muesca o barra de gestos, algún valor > 0 | Si todo es 0 y el teléfono tiene muesca, el sistema no reporta zona segura |
| `touch N · drag M · último …` | **Al tocar la mitad izquierda, `touch` sube; al arrastrar, `drag` sube** | Si no suben, el dispositivo no entrega `InputEventScreenTouch` (siguiente paso: `emulate_mouse_from_touch=true`) |
| `joy (x, y)` | Cambia al arrastrar y vuelve a `(0.00, 0.00)` al soltar | Si se queda en 0 con `touch` subiendo, el problema es el mapeo |
| `vel (x, y)` | Distinto de cero mientras se mantiene el arrastre | Si el joystick responde pero `vel` es 0, el problema está en la conexión con el jugador |
| Anillo de reposo | Visible abajo a la izquierda, completo y fuera de la muesca | Si no aparece, el script del joystick no cargó: revisar `device-logcat.txt` |

**Criterios de aceptación del fix:**

1. El anillo de reposo se ve abajo a la izquierda, completo y fuera de la muesca.
2. Al arrastrar el pulgar desde la mitad izquierda, el anillo aparece bajo el dedo y el personaje se mueve en las cuatro direcciones del arrastre.
3. Al soltar, el personaje se detiene y el anillo vuelve a su posición de reposo.
4. WASD y flechas siguen funcionando en escritorio.
5. Sin errores `FATAL`/`Exception` en `device-logcat.txt`.

La tarea queda en estado **pending PO validation** hasta que estos cinco puntos se
confirmen en el dispositivo.
