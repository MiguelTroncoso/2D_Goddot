# Esquemas de datos del dominio

> Referencia para `src/domain/` y para los recursos `data/*.tres` que los alimentan.
> Regla: el dominio recibe y devuelve diccionarios/DTO tipados; nunca lee `.tres` directamente
> (eso es trabajo de `data/` + `systems/`, ADR-005).

## 1. `StatBlock` (`src/domain/entities/stat_block.gd`)

Diccionario aceptado por `StatBlock.desde_diccionario()` y devuelto por `a_diccionario()`:

| Campo | Tipo | Rango | Descripción |
|-------|------|-------|-------------|
| `nivel` | int | 1–150 | Se limita en los bordes |
| `vigor` | int | ≥ 0 | +8 Vida por punto, +2 DEF sobre 20 |
| `poder` | int | ≥ 0 | +1 POD por punto |
| `resonancia` | int | ≥ 0 | +2 Reserva máx, +0,05 regen, penetración |
| `agilidad` | int | ≥ 0 | Celeridad y velocidad |
| `critico_extra` | float | 0–0,45 útil | Suma a la base 5 %; tope final 50 % |
| `dano_critico_extra` | float | 0–1,0 útil | Suma a 150 %; tope final 250 % |
| `celeridad_extra` | float | 0–0,40 | Tope 40 % |
| `tenacidad_extra` | float | 0–0,50 | Tope 50 % |
| `penetracion_extra` | float | 0–0,35 | Tope 35 % (junto con la Resonancia) |
| `velocidad_extra` | float | −0,30–0,30 | Desvío sobre 4,0 casillas/s |

Derivados (solo lectura, no se guardan): `vida_base`, `vida_max`, `pod_base`, `pod_total`,
`def_base`, `def_total`, `reserva_max`, `regeneracion_combate`, `regeneracion_fuera_combate`,
`critico`, `multiplicador_critico`, `celeridad`, `tenacidad`, `penetracion`, `velocidad_casillas`.

## 2. `EnemyArchetype` (`src/domain/entities/enemy_archetype.gd`)

Entrada de `EnemyArchetype.crear(datos)`:

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `id` | StringName | sí | Identificador estable, `append-only` |
| `nombre` | String | no | Nombre visible |
| `familia` | StringName | no | Una de las 16 familias de `docs/design/04-world.md` §5 |
| `variante` | StringName | sí | `joven`, `adulto`, `ancestral`, `primigenio`, `umbrio`, `elite` |
| `nivel` | int | sí | 1–150 |
| `tipo_dano` | StringName | no | `fisico`, `resonante`, `umbrio`; la variante umbría lo fuerza |
| `vida_base` | float | sí | Vida de la variante `joven` (base del tramo) |
| `defensa_base` | float | sí | DEF del objetivo para la fórmula de mitigación |
| `velocidad` | float | sí | Casillas/s |
| `patron_ia` | StringName | sí | Uno de los 9 patrones de `docs/design/03-combat.md` §9.2 |
| `radio_deteccion` | float | sí | Casillas |
| `radio_agarre` | float | sí | Debe ser ≥ `radio_deteccion` |
| `radio_ataque` | float | sí | Casillas |
| `tipo_mob` | StringName | sí | `comun`, `elite`, `minijefe`, `jefe_tramo`, `jefe_instancia`, `jefe_raid`, `jefe_mundial` |
| `contribucion_minima` | float | no | Por defecto 0,10 |

Multiplicadores de variante aplicados por el dominio:

| Variante | Vida | Daño | Habilidades extra | Inmune a control | Notas |
|----------|------|------|-------------------|------------------|-------|
| `joven` | ×1,0 | ×1,0 | 0 | No | Base |
| `adulto` | ×1,6 | ×1,3 | 0 | No | — |
| `ancestral` | ×2,6 | ×1,7 | 1 | No | — |
| `primigenio` | ×4,0 | ×2,2 | 2 | Sí | Endgame |
| `umbrio` | ×1,0 | ×1,25 | 0 | No | Fuerza tipo Umbrío y aplica `olvido` |
| `elite` | ×3,2 | ×1,8 | 1 | No | Alfa / Menor / Mayor / Rey |

## 3. Golpe de combate (`DamageCalculator.resolver`)

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `pod` | float | sí | Poder efectivo del lanzador |
| `coef` | float | sí | Coeficiente de la habilidad |
| `nivel_lanzador` | int | sí | Se limita a 1–150 |
| `plano` | float | no | Si falta, se calcula con la tabla de tramo (`§2.5` de `03-combat.md`) |
| `defensa_objetivo` | float | sí | DEF del objetivo |
| `nivel_objetivo` | int | sí | Define la constante K |
| `tipo` | StringName | sí | `fisico` / `resonante` / `umbrio` |
| `bono_negativo` | float | no | Reducción de resistencia; se limita al 40 % |
| `penetracion` | float | no | Se limita al 35 % |
| `mods_estado` | float | no | Producto de buffs/debuffs; por defecto 1,0 |
| `mods_pvp` | float | no | 0,6 entre jugadores |
| `tirada_critico` | float | no | Si falta, el golpe no puede ser crítico |
| `critico_base` / `critico_equipo` / `critico_buff` | float | no | Se suman y se topan al 50 % |
| `dano_critico_extra` | float | no | Se suma a 150 % con tope 250 % |

Salida: `pod`, `coef`, `plano`, `nivel_lanzador`, `nivel_objetivo`, `tipo`, `factor_nivel`,
`dano_base`, `defensa_efectiva`, `mitigacion`, `bono_negativo`, `mods_estado`, `mods_pvp`,
`es_critico`, `multiplicador_critico`, `dano_final` (float) y `dano_final_entero` (int).

## 4. Recursos `data/*.tres` (planificados)

Los `.tres` son contenedores de los diccionarios anteriores; el dominio nunca los abre.

| Recurso | Ruta prevista | Contenido |
|---------|---------------|-----------|
| `EnemyDefinition` | `src/data/enemies/<familia>_<variante>.tres` | Campos del §2 |
| `ClassDefinition` | `src/data/classes/<clase>.tres` | Id, afinación, recurso, primario, secundario, silueta, acento |
| `SkillDefinition` | `src/data/skills/<clase>_<habilidad>.tres` | Coste, CD, rango, forma, coef, plano, estados aplicados, tags |
| `ItemDefinition` | `src/data/items/<tramo>_<slot>.tres` | Ranura, nivel, rareza, estadísticas, precio base, fuente |
| `SetDefinition` | `src/data/sets/<tramo>_<clase>.tres` | 6 piezas + bonos 2/4/6 |
| `EventDefinition` | `src/data/events/<id>.tres` | Cadencia, formato, franjas UTC, recompensas, límite diario |

## 5. `CombatResult` (`CombatSystem.atacar`)

Salida de un ataque resuelto. Todos los campos del desglose son obligatorios
(los tests verifican la lista completa):

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `exito` | bool | `false` si el ataque se rechazó; en ese caso solo hay `razon` |
| `razon` | String | `self_target`, `atacante_no_disponible`, `objetivo_no_disponible`, `en_enfriamiento` |
| `atacante` / `objetivo` | StringName | Identificadores de los actores |
| `habilidad` | StringName | Identificador usado para el cooldown |
| `dano` | float | Daño efectivo aplicado |
| `dano_entero` | int | Daño redondeado para UI y telemetría |
| `tipo` | StringName | `fisico`, `resonante`, `umbrio` |
| `es_critico` | bool | Resultado de la tirada |
| `mitigacion` | float | Mitigación efectiva aplicada (0–0,75) |
| `vida_antes` / `vida_restante` | float | Estado del objetivo antes y después |
| `objetivo_derrotado` | bool | `true` si la Vida llegó a 0 |
| `desglose` | Dictionary | Salida completa de `DamageCalculator.resolver` |

`desglose` contiene: `pod`, `coef`, `plano`, `nivel_lanzador`, `nivel_objetivo`, `tipo`,
`factor_nivel`, `dano_base`, `defensa_efectiva`, `mitigacion`, `bono_negativo`, `mods_estado`,
`mods_pvp`, `es_critico`, `multiplicador_critico`, `dano_final`, `dano_final_entero`.

## 6. `MobData` (`data/mobs/*.tres` → `MobDefinition`)

| Campo | Tipo | Rango/valores | Notas |
|-------|------|---------------|-------|
| `id` | StringName | único | Estable y append-only |
| `nombre` | String | — | Se muestra en el HUD de combate |
| `familia` | StringName | 16 familias del GDD | Define la tabla de botín por respaldo |
| `variante` | String | `joven`, `adulto`, `ancestral`, `primigenio`, `umbrio`, `elite` | Multiplica Vida y daño |
| `nivel` | int | 1–150 | Define tramo, cobre y XP |
| `tipo_dano` | String | `fisico`, `resonante`, `umbrio` | La variante umbría lo fuerza |
| `vida_base` | float | > 0 | Vida de la variante `joven` (base del tramo) |
| `defensa_base` | float | ≥ 0 | Se mapea a `StatBlock.defensa_extra` |
| `velocidad` | float | > 0 | Casillas/s |
| `patron_ia` | String | 12 valores; **solo 3 implementados** | Ver `AiPatterns` |
| `radio_deteccion` / `radio_agarre` / `radio_ataque` | float | > 0 | Radios en casillas |
| `tipo_mob` | String | 7 tipos | Multiplicador de XP y cobre |
| `coef_ataque` / `cooldown_ataque` | float | > 0 | Ataque básico de la criatura |
| `botin` | Array[Dictionary] | — | `{item_id, probabilidad, cantidad_min, cantidad_max}` |
| `color_placeholder` / `escala` | Color / float | — | Presentación provisional |

### `ItemData` (`data/items/*.tres` → `ItemDefinition`)

| Campo | Tipo | Notas |
|-------|------|-------|
| `id`, `nombre`, `tipo`, `rareza`, `nivel`, `precio_base`, `stack_max`, `descripcion` | — | Datos base |
| `efecto` | Dictionary | Consumibles: `curacion_pct`, `limpia`, `duracion_s`, `bonus`, `teleporte`, `cooldown_s` |

Validación: cada recurso expone `validar() -> Array[String]` en su tipo de dominio asociado
(`StatBlock.validar()`, `EnemyArchetype.validar()`), y los tests de datos deben exigir lista vacía.
