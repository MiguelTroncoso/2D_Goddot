# ADR-011: GUT 9.4.0 como framework de tests del dominio y cobertura de API

## Status

Accepted — 2026-10-01

## Context

`docs/07-testing.md` establece que la Fase 1 usa el runner nativo
`tests/run_tests.gd` y que **GUT es el framework previsto para las reglas de
dominio**. Al abrir la Fase 2 aparece el primer código en `src/domain/`, por lo
que corresponde instalar ese framework.

Restricciones encontradas durante la instalación:

1. **GUT 9.6.1 (última) no es compatible con Godot 4.4-stable**: su
   `version_numbers.gd` falla al parsear con la versión de GDScript del motor
   fijado por ADR-001 y `docs/07-testing.md`.
2. **GUT 9.4.0 sí funciona** headless con `4.4.stable.official.4c311cbee`
   (verificado: 52 tests, 378 asserts, 0 fallos).
3. **GUT ≥ 9.6 eliminó su herramienta de cobertura**: no existe una opción de
   cobertura por línea en la CLI.

## Decision

1. Adoptar **GUT 9.4.0** (MIT, vendored en `addons/gut/`) para todos los tests de
   `domain/` y `systems/`, registrado en `CREDITS.md` según ADR-008.
2. Mantener `tests/run_tests.gd` (runner nativo) para las regresiones de Fase 1:
   movimiento, joystick, colisiones y escena. No se reescribe lo que ya está en
   verde y en CI.
3. Medir cobertura con `tools/domain_coverage.py`, un verificador propio de
   **cobertura de API**: cada función pública de `src/domain/**/*.gd` debe estar
   referenciada por al menos un test. Umbral en CI: **≥ 80 %**.
4. Documentar explícitamente que la cobertura de API **no** es cobertura de
   líneas ni de ramas; el comportamiento lo valida la suite GUT que corre en CI.

## Alternatives Considered

### Reescribir los tests de Fase 1 en GUT

- Pro: un solo framework.
- Con: riesgo de romper regresiones que hoy están verdes; no aporta cobertura nueva.

### Quedarse solo con el runner nativo

- Pro: cero dependencias nuevas.
- Con: contradice `docs/07-testing.md` y el stack declarado en `docs/agent/PROMPT_MASTER.md`.
- Con: sin organización por casos ni salida estándar, la suite de dominio crecería mal.

### Adoptar gdUnit4 por su cobertura por línea

- Pro: cobertura real de líneas desde CLI.
- Con: otra dependencia pesada, sin necesidad demostrada en el primer PR de dominio.
- Con: más superficie de fallo para CI que un addon ya planificado.

## Consequences

### Positive

- Los tests de dominio quedan organizados, aislados por caso y con salida legible.
- El gate de cobertura de API es barato (segundos) y sin dependencias externas en CI.
- La decisión queda trazada: si más adelante se necesita cobertura de líneas, el
  reemplazo es local a `tools/domain_coverage.py`.

### Negative

- Se mantienen dos runners en el repositorio (nativo para presentación, GUT para dominio).
- `addons/gut/` añade ~2,7 MB y ~250 archivos al repo.
- La cobertura de API puede dar falsa confianza si un test referencia una función
  sin ejercer sus casos borde; se mitiga con casos límite obligatorios en la revisión de cada PR.

### Rules

1. `tests/domain/**` usa GUT. `tests/run_tests.gd` conserva las regresiones de presentación.
2. Toda función pública nueva en `src/domain/` debe llegar con al menos un test.
3. Los casos borde (nivel 1, nivel 150, valores fuera de rango, topes) son obligatorios.
4. No se actualiza GUT sin verificar compatibilidad con la versión fijada de Godot.
