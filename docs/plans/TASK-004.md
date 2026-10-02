# TASK-004 — Bucle de combate offline (núcleo de Fase 2)

- **Rama:** `feat/TASK-004-combate-offline` · **PR:** #5
- **Estado:** implementado; **pending PO validation** en dispositivo (ADR-012)

## Alcance entregado

| # | Entregable | Estado |
|---|-----------|--------|
| 1 | `systems/combat_system.gd` — orquesta daño, mitigación y crítico con RNG inyectable y desglose auditable | ✅ |
| 2 | `domain/ai/ai_patterns.gd` — **3 patrones**: pasivo, agresivo, patrulla (los otros 6 declarados como pendientes) | ✅ |
| 3 | `systems/ai_system.gd` — estado por criatura y transiciones | ✅ |
| 4 | `entities/enemy.gd` + `enemy.tscn` — consume `EnemyArchetype`, aplica la decisión, sin lógica propia | ✅ |
| 5 | `entities/player.gd` — ataque con cooldown, hitbox `Area2D` y flash | ✅ |
| 6 | `ui/combat_hud.tscn` — vida del objetivo, cooldown y daño flotante | ✅ |
| 7 | `systems/loot_system.gd` — botín por familia/variante, cobre y XP con `XpCurve` | ✅ |
| 8 | `data/mobs/` — 5 `.tres` T1 (joven + adulto) | ✅ |
| 9 | `data/items/` — 5 consumibles + 3 materiales | ✅ |
| 10 | Tests GUT de combate, botín e IA | ✅ 101 tests / 638 asserts |

## Decisiones de diseño

1. **Auto-daño bloqueado**: `atacar()` devuelve `razon = "self_target"`; el daño propio (DoT,
   entorno) entra por `aplicar_dano()`.
2. **Tirada de crítico inyectable** (`datos.tirada_critico`): permite tests deterministas y
   repetición de combates en el servidor.
3. **Vida máxima explícita** en `registrar_actor()`: la Vida de una criatura sale de su
   arquetipo (variante incluida), no de la fórmula base del `StatBlock`.
4. **Patrones no implementados** devuelven `estado = "no_implementado"` con el flag
   `no_implementado = true`, en lugar de fallar o devolver `null`.

## DoD

- [x] Capas respetadas: `systems/` importa `domain/` y `data/`; `entities/` y `ui/` solo presentan.
- [x] 101 tests GUT en verde (638 asserts) y 50 checks nativos intactos.
- [x] Cobertura de API **109/110 (99,1 %)** en `domain/` + `systems/` (gate ≥80 %).
- [x] Casos borde: crítico en el límite (0,499 vs 0,50), mitigación al tope (75 %), daño 0,
      RNG extremos (0.0 y 1.0), auto-daño, drop garantizado/imposible, RNG determinista, XP por tipo.
- [ ] Validación física del bucle en dispositivo (ADR-012) — ver §Validación.

## Validación en dispositivo

1. Matar un mob con el botón **ATACAR** (o clic derecho en escritorio).
2. Ver los números de daño flotantes y la barra de vida del objetivo.
3. Confirmar botín + XP al morir (el número amarillo sobre el cadáver es la XP).
4. Confirmar que el **mordeluz adulto** (agresivo) ataca al acercarse.
5. Confirmar que el **mordeluz joven** (pasivo) solo reacciona al ser golpeado.

## Pendiente para TASK-004.1

- 6 patrones restantes: errante, territorial, manada, emboscada, guardián, jefe.
- Más mobs T1 por familia y variantes élite.
- Inventario real y persistencia del botín (hoy solo se genera y se reporta en HUD).
