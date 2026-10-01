# TASK-003 — Dominio puro: combate, entidades y progresión (arranque de Fase 2)

- **Rama:** `feat/TASK-003-dominio-combate-progresion`
- **Fase:** 2 — Combate PvE (primer PR: núcleo de dominio)
- **Objetivo:** implementar en `src/domain/` las reglas puras de daño, crítico, mitigación, estadísticas, arquetipos de criatura y curva de XP, con suite GUT y cobertura ≥80 %.

## Archivos

| Acción | Ruta | Contenido |
|--------|------|-----------|
| Crear | `src/domain/combat/damage_types.gd` | Los tres tipos de daño canónicos |
| Crear | `src/domain/combat/mitigation_resolver.gd` | Curva DEF/(DEF+K), tope 75 %, penetración |
| Crear | `src/domain/combat/crit_roller.gd` | Probabilidad (cap 50 %), multiplicador (cap 250 %), tirada determinista |
| Crear | `src/domain/combat/damage_calculator.gd` | Fórmula canónica + tabla de plano por tramo + desglose auditable |
| Crear | `src/domain/entities/stat_block.gd` | Atributos, derivados, topes y validación |
| Crear | `src/domain/entities/enemy_archetype.gd` | Familia, variante, IA, radios, XP y validación |
| Crear | `src/domain/progression/xp_curve.gd` | Curva 40·L²+25·L, acumulados, XP por tipo y diferencia de nivel |
| Crear | `tests/domain/*.gd` | 8 suites GUT, casos borde incluidos |
| Crear | `tools/domain_coverage.py` | Gate de cobertura de API ≥80 % |
| Editar | `.github/workflows/ci.yml` | Steps de GUT y cobertura |
| Editar | `docs/07-testing.md` | GUT instalado, comandos y alcance de la cobertura |
| Editar | `docs/03-roadmap.md` | Fase 2 en curso |
| Crear | `docs/agent/SCHEMAS.md` | Esquema de datos de dominio y futuros `.tres` |
| Crear | `docs/decisions/010-*.md`, `011-*.md` | Excepción de Fase 1 y adopción de GUT |

## Tests

- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/domain -ginclude_subdirs -gexit`
- `python3 tools/domain_coverage.py --min 0.80`
- `python3 .github/scripts/validate_godot.py --godot <godot>` (regresiones de Fase 1 intactas)

Casos borde obligatorios: nivel 0/1/150/151/9999, defensa ≤ 0, mitigación máxima, crítico en el
límite de la tirada, penetración y bono negativo topados, atributos negativos, variante y patrón
de IA inválidos, y round-trip de diccionarios.

## DoD

1. `src/domain/` contiene solo lógica pura: cero imports de `ui/`, `net/`, `entities/` (escenas) ni `world/`.
2. Suite GUT en verde (52 tests, 378 asserts) y regresiones nativas de Fase 1 intactas (50 checks).
3. Cobertura de API del dominio ≥ 80 % (obtenida: 100 %).
4. CI ejecuta GUT y el gate de cobertura además de la validación existente.
5. Valores verificados contra el GDD: ejemplo canónico 42 de daño, XP total 44.830.375, tramos 1–10.
6. Documentación actualizada: ADR-010, ADR-011, TASK-002, TASK-003, SCHEMAS, testing y roadmap.

## Riesgos

| Riesgo | Mitigación |
|--------|------------|
| GUT 9.6.1 no soporta Godot 4.4 | Se fija 9.4.0 y se verifica en CI (ADR-011) |
| El ejemplo del GDD tenía un error aritmético intermedio | Se corrige el documento y el test verifica el resultado final (42) |
| Deriva entre `docs/design` y código | Los números canónicos viven en constantes + tests que los fijan |
| Cobertura de API confundida con cobertura de líneas | Se declara explícitamente en ADR-011 y en `docs/07-testing.md` |
