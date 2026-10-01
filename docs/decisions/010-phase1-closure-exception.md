# ADR-010: Cierre de Fase 1 con la prueba física diferida

## Status

**Closed with device validation — 2026-10-01 (TASK-005).** La excepción original fue
revocada el mismo día al descubrirse que el input táctil no funcionaba
([PHASE-1-REGRESSION.md](../phase-reviews/PHASE-1-REGRESSION.md)); tras corregir el
filtro de exportación (TASK-003.5), el PO validó el APK en su teléfono y los cinco
criterios se cumplieron. Ver la enmienda de cierre al final de este documento.

## Context

El DoD de Fase 1 exige tres cosas: movimiento offline con joystick, export Android
funcional y **APK ejecutándose en un dispositivo real**. En la auditoría del
2026-10-01 (`docs/phase-reviews/PHASE-1.md`) el build dejó de estar bloqueado:
`scripts/build_android.sh` produce y firma el APK, y los 50 checks nativos pasan.

Sin embargo, el agente de desarrollo no tiene acceso a un dispositivo Android
físico del propietario. La verificación en dispositivo incluye cosas que no se
pueden simular de forma concluyente: latencia táctil real, safe area y cutouts,
FPS sostenidos, consumo de batería y comportamiento al suspender/reanudar.

## Decision

Cerrar la Fase 1 **con excepción documentada**: se aceptan todos los criterios
verificables por software y se difiere únicamente la prueba física al
`TASK-002`, marcado como `deferred, no bloquea Fase 2`.

Condiciones de la excepción:

1. El APK existe, está firmado y verificado (`apksigner`), con hash registrado.
2. La suite nativa (50 checks) y la suite de dominio (GUT) pasan en CI.
3. El `TASK-002` queda escrito con criterios de aceptación explícitos.
4. **Criterios para reabrir la Fase 1**: cualquier APK que falle al instalar en
   el dispositivo del PO, cualquier crash en los primeros 5 minutos de juego,
   FPS < 30 sostenido en gama media, o error de layout por safe area/notch obliga
   a reabrir la fase y congelar la incorporación de contenido nuevo hasta
   corregirlo.
5. Todo el trabajo de Fase 2 que se apoye en presentación (HUD de combate, VFX)
   queda marcado como "provisional hasta validación física".

## Alternatives Considered

### No cerrar la fase y esperar al dispositivo

- Pro: el DoD se cumple al pie de la letra.
- Con: bloquea meses de trabajo de dominio (que es puro y no depende de la pantalla).
- Con: el trabajo de `domain/` no aporta riesgo de presentación.

### Cerrar la fase sin registrar la excepción

- Pro: no hay papeleo.
- Con: se pierde la trazabilidad de qué falta y por qué.
- Con: un fallo en dispositivo aparecería sin contexto ni criterios de reapertura.

### Comprar o emular un dispositivo

- Pro: cierra el DoD completo.
- Con: un emulador no valida táctil real, batería ni thermals; sería una prueba falsa.

## Consequences

### Positive

- El desarrollo de `domain/` (combate, progresión, entidades) avanza sin riesgo de presentación.
- La deuda queda explícita y con criterios objetivos de reapertura.
- La rama de Fase 2 no queda bloqueada por un elemento externo.

### Negative

- La Fase 1 figura como "cerrada con excepción", no como cerrada.
- El HUD de combate de Fase 2 se construye sin evidencia de rendimiento real.

### Follow-up

- `docs/plans/TASK-002.md` — prueba física en dispositivo.
- `docs/phase-reviews/PHASE-1.md` — métricas pendientes de dispositivo (FPS, batería, safe area).

## Amendment (2026-10-01) — Por qué la excepción fue un error

El razonamiento original asumía que "todo lo verificable por software" cubría la fase.
No era así: la fase consistía en **una sola** funcionalidad, el movimiento táctil, y su
única verificación válida era el hardware. El APK existía, estaba firmado, los 50 checks
pasaban y CI estaba verde — y aun así el juego no se podía jugar.

Lecciones incorporadas como reglas en [ADR-012](012-ui-input-requires-device-validation.md):

1. Una excepción de validación solo es aceptable si **queda trabajo verificable e
   independiente** que no dependa del elemento diferido. Aquí no lo había.
2. Los tests que inyectan eventos en coordenadas locales no cubren el camino del sistema
   operativo; hace falta al menos un caso con coordenadas de pantalla.
3. Todo control táctil debe ser tolerante a errores de escala (zona de activación +
   desplazamiento relativo), no depender de un *hit test* geométrico exacto.

**Criterio de reapertura y cierre de Fase 1:** el fix se considera cerrado solo cuando
el PO confirme en su dispositivo los cinco puntos de
[PHASE-1-REGRESSION.md](../phase-reviews/PHASE-1-REGRESSION.md) §5.

## Amendment (2026-10-01, TASK-005) — Cierre con validación física

El PO validó el APK corregido en su dispositivo. Evidencia:

| Criterio | Resultado | Evidencia |
|----------|-----------|-----------|
| 1. Anillo de reposo visible, fuera de la muesca | ✅ | Capturas abajo; `safe L76` confirma el inset real de 76 px |
| 2. Arrastre en la mitad izquierda mueve al personaje | ✅ | `joy (-0.98, 0.19) → vel (-235, 46)` y `joy (0.71, -0.71) → vel (170, -169)` |
| 3. Al soltar se detiene | ✅ | Reporte del PO |
| 4. WASD/flechas en escritorio | ✅ | `PHASE1_TEST_RESULT: 50 checks, 0 failures` (incluye teclado) |
| 5. Sin `FATAL`/`Exception` | ✅ | Reporte del PO |

| Captura | Qué muestra |
|---------|-------------|
| [device-01-joystick-izquierda.jpg](../phase-reviews/evidence/device-01-joystick-izquierda.jpg) | `FPS 117 · vp 1600x720 · win 2712x1220 · safe L76 · touch 1 · drag 432 · joy (-0.98, 0.19) · vel (-235, 46)` |
| [device-02-joystick-arriba-derecha.jpg](../phase-reviews/evidence/device-02-joystick-arriba-derecha.jpg) | `FPS 120 · joy (0.71, -0.71) · vel (170, -169)` |

**Lección permanente (ADR-012):** una excepción de validación no puede cubrir la única
funcionalidad de una fase, y CI verde nunca sustituye la prueba de hardware para UI,
input, orientación, *safe area* o rendimiento.
