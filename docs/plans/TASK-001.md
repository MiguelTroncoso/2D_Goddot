# TASK-001 — Bootstrap del orquestador y cierre del build reproducible de Fase 1

- **Rama:** `feat/TASK-001-bootstrap-orquestador`
- **Fase:** 1 — Movimiento offline + joystick + export Android
- **Objetivo:** dejar el repo con el sistema de trabajo autónomo (`docs/agent/`) y cerrar el gap de build reproducible de Fase 1 con evidencia real.

## Archivos

| Acción | Ruta | Contenido |
|--------|------|-----------|
| Crear | `docs/agent/PROMPT_MASTER.md` | Rol, alcance, arquitectura de capas, ciclo por tarea, DoD "Game Ready" |
| Crear | `docs/agent/PHASE_TEMPLATE.md` | Plantilla de revisión de fase |
| Crear | `docs/agent/RELEASE_AUDIT.md` | Auditoría final de release v1.0 |
| Crear | `docs/agent/BOOTSTRAP.md` | Arranque de sesión del orquestador |
| Crear | `docs/plans/TASK-001.md` | Este plan |
| Crear | `docs/phase-reviews/PHASE-1.md` | Auditoría de Fase 1 contra roadmap + INDEX.md |
| Crear | `scripts/build_android.sh` | Build Android reproducible (GODOT_BIN/JAVA_HOME/ANDROID_HOME explícitos) |
| Editar | `docs/03-roadmap.md` | Estado real de Fase 1 con evidencia y bloqueante restante |
| Editar | `docs/08-android-development.md` | Procedimiento reproducible con el script |

## Tests

- `python3 .github/scripts/validate_godot.py --godot "$GODOT_BIN"` → import, parseo de todos los `.gd`, arranque de escena y `PHASE1_TEST_RESULT`.
- `bash scripts/build_android.sh` → APK firmado + `sha256` + `apksigner verify`.
- Sin tests nuevos de `domain/` en esta tarea: todavía no existe código en `src/domain/` (Fase 2 lo introduce). El gate de arquitectura se documenta para Fase 2.

## DoD

1. Los 4 archivos de `docs/agent/` existen y son coherentes con `docs/design/INDEX.md`.
2. Auditoría de Fase 1 escrita con evidencia verificable (rutas, hashes, comandos).
3. `scripts/build_android.sh` genera APK desde cero y falla con mensaje claro si falta Godot, JDK o SDK.
4. APK generado en este turno con hash registrado.
5. `docs/03-roadmap.md` refleja el estado real y el único bloqueante restante (prueba física).
6. CI existente sigue en verde (validación + Godot 4.4).

## Riesgos

| Riesgo | Mitigación |
|--------|------------|
| JDK del sistema es 1.8 y Godot 4.4 necesita 17+ | El script detecta y resuelve `JAVA_HOME` (brew openjdk) antes de exportar |
| Godot no está en `PATH` | El script busca `GODOT_BIN`, rutas conocidas de macOS y `PATH` |
| El APK no debe entrar al repo (binario pesado, CI lo bloquea >50 MB) | `build/` está en `.gitignore`; se registra hash y métricas, no el binario |
| La prueba física no se puede hacer desde el agente | Se documenta como bloqueante explícito para el PO |
