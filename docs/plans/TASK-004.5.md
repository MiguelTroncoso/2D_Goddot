# TASK-004.5 — Quick wins visuales sobre Fase 1 validada (sin assets reales)

- **Estado:** `pending` (siguiente tarea tras TASK-005)
- **Rama prevista:** `feat/TASK-004.5-visual-quick-wins`
- **Alcance:** solo `entities/`, `ui/` y `world/`. Cero lógica de negocio nueva.

## 1. Tileset CC0

- Fuente primaria: **Kenney** (*Tiny Dungeon* o *RPG Urban Pack*), licencia CC0.
- Descargar solo el ZIP necesario, extraer los tiles a `assets/tilesets/t1/`.
- Generar el `TileSet` con un script (`tools/generate_tileset.gd`) en vez de escribirlo a mano:
  atlas source con suelo y pared.
- `src/world/test_map.tscn`: reemplazar los rectángulos por dos `TileMapLayer` (suelo y props),
  conservando los `StaticBody2D` actuales hasta migrar las colisiones (los 8 checks de colisión
  de `tests/run_tests.gd` deben seguir pasando).
- **Registrar en `CREDITS.md` antes del commit** (autor, licencia, URL, fecha de descarga).

## 2. Jugador animado

- `AnimatedSprite2D` con 4 frames de caminata y 4 direcciones; izquierda/derecha por *flip*.
- Si el pack no trae personaje compatible, generar el placeholder proceduralmente (obra propia,
  registrada como tal en `CREDITS.md`).
- Mantener `CharacterBody2D`, `CollisionShape2D` y el contrato `movement_intent` intactos.

## 3. Cámara

- `position_smoothing_speed = 5.0` y deadzone de 200×200; `limit_*` sin cambios.
- Verificar que "camera follows player movement" siga pasando.

## 4. Atmósfera

- `CanvasModulate` oscuro en `world/`.
- `PointLight2D` hijo del jugador, radio 250, gradiente propio y sombras suaves.
- Medir FPS en dispositivo antes/después (objetivo ≥30 en gama media).

## 5. Partículas de polvo

- `GPUParticles2D` con 10–15 partículas, color oscuro, `lifetime` 0,4 s, emisión al moverse.

## 6. Tipografía del HUD

- Kenney Fonts (CC0) o fuente con licencia comercial verificada, registrada en `CREDITS.md`.

## DoD

1. Todos los assets nuevos registrados en `CREDITS.md` con licencia CC0/comercial clara.
2. Tests GUT en verde (≥69 tests, ≥438 asserts, 0 fallos) y 50 checks nativos intactos.
3. FPS medidos en dispositivo y reportados (ADR-012: UI/rendimiento exige prueba física).
4. APK con `sha256` + instrucciones de verificación; tarea en `pending PO validation`.
5. Sin lógica de negocio nueva fuera de `domain/`/`systems/`.
