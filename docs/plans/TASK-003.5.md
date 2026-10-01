# TASK-003.5 — Fix del input táctil en dispositivo (regresión de Fase 1)

- **Rama:** `fix/TASK-003.5-input-tactil`
- **Estado:** implementado, **pending PO validation** (ADR-012)
- **Origen:** regresión reportada por el PO sobre `mmorpg-2d-debug.apk`
- **Diagnóstico:** [PHASE-1-REGRESSION.md](../phase-reviews/PHASE-1-REGRESSION.md)

## Objetivo

Que el personaje se mueva con el dedo en un Android real y que el joystick sea visible y
descubrible, sin depender de la densidad, la muesca ni la escala del dispositivo.

## Archivos

| Acción | Ruta | Contenido |
|--------|------|-----------|
| Editar | `src/systems/movement_input.gd` | `delta_desde_origen`, `vector_desde_origen`, `en_zona_activacion` |
| Crear | `src/systems/safe_area.gd` | Conversión de zona segura a márgenes lógicos |
| Reescribir | `src/ui/virtual_joystick.gd` | Joystick dinámico, relativo, con anillo de reposo y contadores |
| Editar | `src/ui/virtual_joystick.tscn` | Control a pantalla completa |
| Crear | `src/ui/hud.gd` | Zona segura + panel de diagnóstico |
| Editar | `src/ui/hud.tscn` | Script del HUD y etiqueta de diagnóstico |
| Editar | `src/main.gd` | Enlaza el jugador al HUD |
| Editar | `tests/run_tests.gd` | La zona de activación reemplaza el hit test circular |
| Crear | `tests/systems/test_movement_input.gd`, `tests/systems/test_safe_area.gd` | Cobertura de la matemática nueva |
| Crear | `tests/presentation/test_joystick_regression.gd` | Regresión con coordenadas de pantalla |
| Crear | `tools/check_input_contract.py` | Gate estructural de escenas y flags |
| Editar | `scripts/build_android.sh`, `.github/workflows/ci.yml` | Chequeo previo al build y en CI |
| Crear | `docs/phase-reviews/PHASE-1-REGRESSION.md`, `docs/decisions/012-*.md` | Diagnóstico y lección |

## DoD

1. Joystick visible y funcional en horizontal, dentro de la zona segura.
2. Movimiento en 4 direcciones con arrastre táctil; WASD/flechas intactos en escritorio.
3. La dirección se calcula en `systems/`; `entities/player.gd` solo aplica velocidad.
4. Tests: unitarios del mapeo (sin nodos) + regresión de escena con evento en
   coordenadas de pantalla; 50 checks nativos de Fase 1 siguen en verde.
5. CI: contrato de input + GUT (dominio, sistemas, presentación) + cobertura ≥80 % en
   `domain/` y `systems/`.
6. APK reconstruido con `sha256` nuevo e instrucciones `adb` de verificación.
7. Estado **pending PO validation** hasta confirmación en dispositivo.

## Riesgos

| Riesgo | Mitigación |
|--------|------------|
| El dispositivo no entrega `InputEventScreenTouch` en absoluto | El panel de diagnóstico muestra los contadores; si quedan en 0, el siguiente paso es activar `emulate_mouse_from_touch=true` |
| El joystick tapa el área de acciones futuras | Zona de activación limitada a la mitad izquierda y con margen superior |
| El overlay de diagnóstico llega a producción | Queda documentado como temporal: antes del lanzamiento se mueve a un flag o menú de desarrollo |
| Los tests nativos dependían del modelo antiguo | Se actualizaron en el mismo PR y siguen pasando (50/50) |
