# REVISIÓN DE FASE [N]

## Estado actual
- Tareas completadas: [lista]
- Deuda técnica: [lista]
- Métricas: cobertura tests [X]% | tamaño APK [X] MB | FPS gama baja [X] |
  latencia sync [X] ms | concurrentes probados [X]

## Objetivo de esta iteración
[1 frase concreta]

## Instrucciones
1. Audita el estado actual del repo contra el roadmap de la fase + checklist INDEX.md.
2. Detecta gaps, bugs, violaciones de arquitectura, deuda técnica.
3. Prioriza por impacto/esfuerzo (matriz Eisenhower).
4. Ejecuta las 3 tareas de mayor prioridad con el ciclo completo
   (plan → código → tests → CI → auditoría → reporte).
5. Actualiza `docs/03-roadmap.md` marcando lo completado.

## Restricciones
- No avances a la siguiente fase hasta cerrar DoD.
- Ambigüedad en GDD → 2 opciones con pros/contras + elección + ADR.
- FPS <30 en gama media → optimiza antes de seguir.
- Si la fase actual requiere volumen (ej.: 10 sets), completa el volumen
  completo antes de cerrar la fase, aunque tome varios PRs.
