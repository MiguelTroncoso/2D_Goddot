# REVISIÓN DE FASE 1 — Movimiento offline + joystick + export Android

> Fecha de auditoría: 2026-10-01 · Rama auditada: `feature/phase1-offline-movement-controls`
> Referencias: [roadmap](../03-roadmap.md), [checklist INDEX](../design/INDEX.md), [ADR-004](../decisions/004-android-first.md), [ADR-009](../decisions/009-phase1-offline-composition.md)

## Estado actual

**Tareas completadas**

| Commit / tarea | Resultado |
|----------------|-----------|
| `b09a80a` feat: implement Phase 1 offline movement and controls | Escena offline, input teclado/táctil, colisiones, cámara con seguimiento, HUD fijo, joystick virtual |
| `0b2c6f8` fix: enable Android texture formats for debug export | `etc2_astc` habilitado, export Android Debug configurado |
| TASK-001 (esta sesión) | `scripts/build_android.sh`, `docs/agent/*`, auditoría de fase |

**Deuda técnica**

| # | Deuda | Impacto | Nota |
|---|-------|---------|------|
| D1 | El APK no es *byte-reproducible* (mismo tamaño y contenido, `sha256` distinto por timestamps del empaquetado) | Bajo | Godot no expone `SOURCE_DATE_EPOCH` en el exportador Android |
| D2 | Sin verificación en dispositivo físico | Alto | Bloquea el DoD de Fase 1 |
| D3 | `src/domain/` está vacío: la cobertura ≥80 % aún no es medible | Medio | Se vuelve exigible desde Fase 2 |
| D4 | FPS reales y consumo de batería sin medir en dispositivo | Medio | Requiere D2 |
| D5 | Sin prueba en 3 densidades de pantalla (5", 6,5", tablet) | Medio | Requiere D2 |
| D6 | `docs/design/*` y `docs/agent/*` sin integrar en el índice del README | Bajo | Se corrige en TASK-003 |

**Métricas**

| Métrica | Valor | Evidencia |
|---------|-------|-----------|
| Tests automáticos | **50 checks, 0 failures** | `build/android/godot-validation.log`, `PHASE1_TEST_RESULT` |
| Cobertura en `domain/` | No medible (sin código) | `src/domain/` vacío |
| Tamaño APK | 51,7 MB (54.220.359 bytes) | `build/android/mmorpg-2d-debug.apk` |
| `sha256` APK (2026-10-01) | `9389115024cf5be60fa6c6e4f5c0e1762bda70d85ed2db185d1b5db4fe000948` | `scripts/build_android.sh` |
| Instrumentación declarada | `armeabi-v7a`, `arm64-v8a`; sin permiso de internet | `build/android/apk-validation.json` |
| Firma | Debug v2 verificada | `apksigner verify --verbose` |
| FPS gama baja | Sin medir | Requiere dispositivo |
| Latencia de sync | n/a (sin red en Fase 1) | — |
| Concurrentes probados | 0 | Fase 4 |

## Objetivo de esta iteración

Cerrar el DoD de Fase 1 dejando el build de Android reproducible por script y verificable, con la prueba física como único bloqueante externo.

## Auditoría contra el roadmap y el checklist

| Criterio de Fase 1 | Estado | Evidencia / gap |
|--------------------|--------|-----------------|
| Escena de prueba estática con placeholders propios | ✅ | `src/world/test_map.tscn`, ADR-009 |
| Jugador `CharacterBody2D` con movimiento | ✅ | `src/entities/player.gd`, 50 checks |
| Joystick virtual táctil | ✅ | `src/ui/virtual_joystick.gd` |
| Cámara con seguimiento suave | ✅ | `PASS: camera follows player movement` |
| Colisiones con el entorno | ✅ | 8 checks de colisión (muros y bloques) |
| HUD mínimo | ✅ | `src/ui/hud.tscn` |
| Main scene asignada | ✅ | `project.godot` → `res://src/main.tscn` |
| Export Android configurado | ✅ | `export_presets.cfg` preset "Android Debug" |
| **Build reproducible por script** | ✅ (nuevo) | `scripts/build_android.sh` genera APK + hash |
| APK en dispositivo real | ❌ | **Bloqueante**: requiere el teléfono del PO |
| CI en verde | ✅ (evidencia local) | `validate_godot.py` pasa; workflow `.github/workflows/ci.yml` |
| Checklist `docs/design/INDEX.md` | ⚠️ | 12 numéricas + 15 de sistemas: coherentes en documento; su implementación es de Fases 2–10 |

### Matriz de priorización (impacto / esfuerzo) de los gaps

| Prioridad | Gap | Impacto | Esfuerzo | Tarea |
|-----------|-----|---------|----------|-------|
| 1 | Verificación física del APK (D2, D4, D5) | Alto | Bajo (humano con teléfono) | TASK-002 |
| 2 | Población de `src/domain/` con tests y cobertura (D3) | Alto | Alto | TASK-003 (arranque de Fase 2) |
| 3 | Rebuild byte-reproducible (D1) | Bajo | Medio | Backlog |
| 4 | README con índice de `docs/design` y `docs/agent` (D6) | Bajo | Bajo | TASK-003 |

## Instrucciones ejecutadas

1. **Auditoría** del repo contra el roadmap de Fase 1 + checklist del INDEX → §Auditoría.
2. **Gaps** detectados: dispositivo físico, `domain/` vacío, README desactualizado, `sha256` no determinista.
3. **Priorización** por impacto/esfuerzo → matriz superior.
4. **Ejecución de la tarea de mayor prioridad viable sin hardware**: build reproducible (hecho); la prueba física queda asignada al PO.
5. **`docs/03-roadmap.md`** actualizado con el estado real.

## Restricciones respetadas

- No se avanzó a Fase 2: el DoD de Fase 1 sigue abierto por el bloqueante externo (dispositivo).
- No se introdujeron decisiones ambiguas de GDD: no aplica en esta fase.
- FPS: sin datos de dispositivo; no se declara cumplido.
