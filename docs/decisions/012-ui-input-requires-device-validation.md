# ADR-012: Ninguna feature de UI o input se cierra sin prueba física

## Status

Accepted — 2026-10-01

## Context

La Fase 1 se declaró cerrada con la prueba física diferida ([ADR-010](010-phase1-closure-exception.md))
argumentando que el build estaba verificado por software. El PO probó el APK en su
teléfono: **el personaje no se movía y el joystick no aparecía**. La fase entera
consistía en eso, así que la excepción convirtió la validación en una suposición.

La causa documentada en [PHASE-1-REGRESSION.md](../phase-reviews/PHASE-1-REGRESSION.md)
está confirmada: el preset usaba `export_filter="scenes"`, que empaqueta la escena y sus
dependencias de escena pero **no los `preload()` de los scripts**. `src/systems/` nunca
llegó al APK, así que `main.gd` y `virtual_joystick.gd` fallaban al cargar en el teléfono:
el mapa y el HUD se dibujaban, el joystick no aparecía y no había movimiento. A eso se
sumaban dos defectos secundarios corregidos en el mismo PR: el joystick exigía un *hit
test* con transformaciones de canvas (exacto solo con escala 1,0) y no respetaba la zona
segura del sistema.

Además, la suite de tests inyectaba toques en coordenadas locales del viewport
(`push_input(evento, true)`), saltándose la conversión sistema→viewport, que es
exactamente el tramo donde la escala del dispositivo puede diferir. CI pasaba en verde
mientras el juego era injugable en el hardware objetivo.

## Decision

1. **Ninguna feature de UI, input, orientación, *safe area* o rendimiento se declara
   cerrada sin prueba física** en un dispositivo real, o sin una emulación táctil que
   el PO haya validado explícitamente.
2. CI verde **no sustituye** la prueba de hardware para esas áreas. CI sigue siendo
   necesario, pero nunca suficiente.
3. Toda tarea de UI/input entrega:
   - el APK con `sha256`,
   - instrucciones de verificación con `adb`,
   - qué observar en pantalla,
   - y queda en estado **pending PO validation** hasta la confirmación.
4. Los tests de input deben usar el mismo camino que el sistema operativo:
   `push_input(evento, false)` (coordenadas de pantalla) al menos en un caso por
   control, además de la prueba en coordenadas locales.
5. Todo control táctil debe pasar por una **zona de activación** independiente de
   transformaciones (desplazamiento relativo desde el punto de contacto), para que un
   error de escala degrade la precisión y no apague el control.
6. El HUD debe respetar `DisplayServer.get_display_safe_area()`.
7. `scripts/build_android.sh` verifica el contrato de input
   (`tools/check_input_contract.py`) antes de exportar.
8. Toda feature de UI/input exige verificar el **contenido del artefacto**, no solo el
   código fuente: `tools/check_export_contract.py` y la inspección del APK en el script de
   build cubren la clase de bug "funciona en CI, falta en el paquete".

## Alternatives Considered

### Mantener la excepción y seguir con Fase 2

- Pro: no frena el desarrollo del dominio.
- Con: se construye HUD de combate sobre un pipeline de input no verificado.
- Con: repite el mismo error con más superficie (safe area, botones de acción, multitoque).

### Confiar en emuladores

- Pro: automatizable en CI.
- Con: un emulador no reproduce DPI, muescas, barra de gestos ni el comportamiento del
  fabricante; el bug del joystick apareció precisamente por esas diferencias.

### Probar solo en escritorio con emulación táctil

- Pro: rápido y sin hardware.
- Con: precisamente el escenario que ocultó la regresión (escala 1,0).

## Consequences

### Positive

- El input vuelve a ser lo primero que se valida, no lo último.
- Existe un gate mecánico (contrato de input + tests de regresión con coordenadas de
  pantalla) que habría bloqueado esta regresión.
- El diagnóstico en pantalla convierte la próxima prueba de hardware en evidencia
  objetiva (contadores de eventos), no en una impresión.

### Negative

- Las features de UI/input tardan más en declararse cerradas: dependen del PO y su
  teléfono.
- El diagnóstico en pantalla debe retirarse (o quedar detrás de un flag) antes del
  lanzamiento.

### Follow-up

- `docs/plans/TASK-002.md` — prueba física general de Fase 1 (sigue abierta).
- `docs/plans/TASK-003.5.md` — este fix, en estado **pending PO validation**.
- Antes de retirar el overlay: moverlo a un flag de compilación o a un menú de desarrollo.
