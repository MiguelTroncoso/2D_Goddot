# 03 — Combate

> Depende de: [02-classes.md](02-classes.md) · Afecta a: [04-world.md](04-world.md), [06-progression.md](06-progression.md), [08-ui-ux.md](08-ui-ux.md)
> Implementación: reglas en `src/domain/combat/*.gd` (puro), orquestación en `src/systems/combat_system.gd`, replicación en `src/net/` (ADR-002, 005).

## 1. Modelo de combate

**Tiempo real con acción dirigida, no aim manual.** El jugador mueve con joystick y pulsa habilidades; el personaje ataca en la dirección del joystick o del objetivo más cercano válido. Es un modelo de *acción asistida*: rápido de entender en móvil, pero con decisiones reales (posición, coste de recurso, momento del CD).

| Decisión | Valor | Por qué |
|----------|-------|---------|
| Tick de simulación del servidor | 20 Hz | Coincide con el presupuesto de banda de `docs/02-networking.md` |
| Replicación de estado | 10 Hz + eventos puntuales | Menos tráfico; los eventos de combate van aparte |
| Ataque básico | Automático opcional (se activa cuando hay objetivo en rango) | P1: en móvil, el pulgar derecho está en las habilidades |
| Selección de objetivo | Tap sobre enemigo; si no hay objetivo, el más cercano dentro de 1,5 × rango | Evita "pelear con la cámara" |
| Movimiento durante la habilidad | Libre excepto en habilidades con tag `canalizado` | El jugador nunca pierde el control sin aviso |
| Interrupción | Daño fuerte (≥ 15 % de Vida máx en un golpe) interrumpe canalizaciones | Regla legible para PvE y PvP |
| Esquiva | No hay i-frames generales; el dash de Hiladora otorga inmunidad solo a `raiz` | Mantiene el dash valioso sin volverlo invulnerabilidad |
| Muerte | Fin de combate, respawn en checkpoint con **Mella** (ver §8) | Riesgo recuperable (P5, 00-vision §1) |

### 1.1 Formas de ataque (para hitboxes y telegraphs)

| Forma | Uso típico | Radio/largo |
|-------|-----------|-------------|
| `melee_cono` | Tajo, Corte | 1,5 casillas, 90° |
| `circulo` | Pulso de Escoria, Filo Circular | 2–3 casillas |
| `linea` | Cañón de Agujas, Cadena de Yunque | 4–8 casillas, ancho 0,6 |
| `proyectil` | Descarga, Trazo Menor, Pulso de Savia | 6–8 casillas, velocidad 12 casillas/s |
| `muro` | Reja de Geometría | 5 casillas de largo, 5 s |
| `despliegue` | Mina de Chispa, Batería Portátil | radio de detección 2 casillas |
| `propio` | Fragua Interna, Sobrecarga | solo el lanzador |

## 2. Fórmulas canónicas

### 2.1 Daño

```
daño_base   = (POD × coef_habilidad + plano_habilidad) × (1 + 0,02 × (nivel_lanzador − 1))
mitigación  = DEF_objetivo / (DEF_objetivo + K)
K           = 50 + 10 × nivel_objetivo
daño_final  = daño_base × (1 − mitigación) × (1 + bono_negativo) × mods_estado × mods_pvp
```

- `bono_negativo` = suma de reducciones de resistencia aplicadas al objetivo (Corrosión, marca de facción, etc.), cap **+40 %**.
- `mods_estado` = producto de buffs/debuffs aplicables (máx. 3 fuentes distintas; ver §5.3).
- `mods_pvp` = **0,6** si el objetivo es jugador (ver §6).

Ejemplo verificable: POD 30, coef 1,4, plano 12 (nivel 10 vs. nivel 10), DEF objetivo 80:

```
daño_base = (30 × 1,4 + 12) × 1,18 = 55,2 × 1,18 = 65,1
mitigación = 80 / (80 + 150) = 0,348
daño_final = 65,1 × 0,652 = 42,4 → 42
```

### 2.2 Mitigación por tipo

Solo existen tres tipos de daño (ver [01-lore.md](01-lore.md) §2.4). La mitigación por tipo usa la misma curva con otro valor de K, porque las resistencias escalan más lento que la defensa y deben sentirse como una decisión de equipo:

```
mitigación_tipo = RES_tipo / (RES_tipo + K_tipo)
K_físico    = 50 + 10 × nivel_objetivo
K_resonante = 75 + 15 × nivel_objetivo
K_umbrío    = 75 + 15 × nivel_objetivo
```

**Caps duros** (aplicados en `domain/combat/damage_calculator.gd`):

| Valor | Cap | Razón |
|-------|-----|-------|
| Mitigación por curva | 75 % | Que un tanque nunca sea inmune; el Bastión llega a ~65 % con equipo óptimo |
| Reducción adicional (`bono_negativo`) | +40 % | Evita que apilar shredders borre a un jefe |
| Chance de crítico | 50 % | El crítico es sabor, no la estadística dominante |
| Daño crítico total | 250 % | Techo de escalado |
| Celeridad (reducción de CD) | 40 % | Evita rotaciones sin huecos |
| Tenacidad (reducción de CC) | 50 % | PvP sostenible |
| Velocidad de movimiento | ±30 % sobre base | Legibilidad de la persecución en pantalla pequeña |

### 2.3 Crítico

```
es_crítico  = rng.randf() < min(0,5, crit_base + crit_equipo + crit_buff)
daño_crit   = daño_final × min(2,5, 1,5 + daño_crit_extra)
```

`crit_base` = 5 %. Los jefes y élites **no** pueden ser golpeados con crítico si el lanzador está a más de 8 casillas (limitación de daño a distancia gratuito) — se documenta en el tooltip del enemigo.

### 2.4 Curación y escudos

```
curación = (POD × coef_cura + plano_cura) × (1 + 0,02 × (nivel − 1)) × (1 + bono_curación) × mods_estado
```

- `Marchito` (−40 % curación recibida) es el único debuff de curación, y solo lo aplican élites y jefes.
- Los escudos absorben antes que la Vida y **no** se apilan entre sí: se toma el mayor valor vigente (evita el "apilado de escudos" del Cantor + Bastión).
- Los escudos **sí** se suman a la mitigación, en ese orden: golpe → mitigación → escudo → Vida.

### 2.5 Poder, plano escalado y presupuesto por nivel

`plano_habilidad` escala por tramo con una progresión por saltos, para que un mismo `SkillDefinition` sirva en todo el rango **1–150** sin reescribir recursos. Cada tramo arranca donde terminó el anterior:

| Tramo | Niveles | plano por coef unitario | Valor al final del tramo |
|-------|---------|--------------------------|---------------------------|
| T1 | 1–15 | 6 + 1,5 × (nivel − 1) | 27 |
| T2 | 16–30 | 27 + 2,6 × (nivel − 15) | 66 |
| T3 | 31–45 | 66 + 4,5 × (nivel − 30) | 133 |
| T4 | 46–60 | 133 + 7,5 × (nivel − 45) | 245 |
| T5 | 61–75 | 245 + 12 × (nivel − 60) | 425 |
| T6 | 76–90 | 425 + 19 × (nivel − 75) | 710 |
| T7 | 91–105 | 710 + 30 × (nivel − 90) | 1.160 |
| T8 | 106–120 | 1.160 + 47 × (nivel − 105) | 1.865 |
| T9 | 121–135 | 1.865 + 74 × (nivel − 120) | 2.975 |
| T10 | 136–150 | 2.975 + 116 × (nivel − 135) | 4.715 |

El crecimiento combinado (plano × POD × factor de nivel) da un multiplicador de daño de **×2,5 a ×3,0 por tramo**, alineado con la Vida y la Defensa de las criaturas del §7.1 (misma razón). Si una habilidad nueva no respeta esa razón, se corrige antes de añadirla.

El presupuesto de daño objetivo por nivel (ver [02-classes.md](02-classes.md) §3.3) se valida con un test de dominio que simula 60 s de rotación contra un objetivo de referencia.

## 3. Orden de resolución de un golpe

El servidor resuelve en este orden estricto. Cualquier cambio debe reflejarse en `domain/combat/resolution_order.gd` y en los tests.

1. Validar rango, línea de visión y que el lanzador no esté bajo `aturdimiento`, `silencio` o `miedo`.
2. Verificar coste y cooldown (el cliente pudo predecir el feedback, el servidor manda).
3. Aplicar modificadores del lanzador (buffs, `Sobrecarga`, `Lumbre`).
4. Calcular crítico (una sola tirada por golpe, no por objetivo).
5. Calcular daño base con la fórmula del §2.1.
6. Aplicar escudo del objetivo.
7. Aplicar mitigación por tipo.
8. Aplicar Vida; si llega a 0 → evento `entity_died` (loot, XP, contribución).
9. Aplicar estados (ver §5) y evaluar inmunidades/tolerancia.
10. Emitir eventos al cliente: `damage_dealt`, `status_applied`, `entity_died`.

## 4. Estados de combate: reglas generales

| Concepto | Regla |
|----------|-------|
| Duración | Se cuenta en segundos de servidor; se replica el `expires_at` para que la UI muestre el contador |
| Refresco | Un mismo estado de la misma fuente **refresca** duración y no acumula intensidad |
| Fuentes distintas | El mismo estado de fuentes distintas **sí** acumula, hasta 3 intensidades (excepto DoT: hasta 5) |
| Limpieza | `Coro de Raíces` limpia 2; `Viento Compartido` limpia solo `ralentizacion` |
| Tolerancia a control (PvP) | 1.º CC al 100 % de duración, 2.º 50 %, 3.º 25 %, 4.º inmune 8 s |
| Tenacidad | Reduce duración de CC: `duración × (1 − tenacidad)`, cap 50 % |
| Umbral de interrupción | Un golpe ≥ 15 % de Vida máx interrumpe `canalizado` y aplica 1 s de bloqueo de la habilidad interrumpida |
| Máximo de estados activos | 12 por entidad con prioridad definida; al exceder, se elimina el de menor prioridad |

## 5. Tabla de estados

### 5.1 Buffs

| ID | Nombre | Tipo | Duración | Acumulación | Efecto | Fuente |
|----|--------|------|----------|-------------|--------|--------|
| `lumbre` | Lumbre | Buff | 20 s | 3 × 10 % | +10 % daño por intensidad | Nodos encendidos, consumibles |
| `piel_nacar` | Piel de Nácar | Escudo | 8 s | No acumula (mayor) | Escudo 10–15 % Vida máx | Bastión (definitiva), Cantor, pociones |
| `impulso` | Impulso | Buff | 5 s | 2 × 15 % | +15 % velocidad e inmunidad a `ralentizacion` | Hiladora |
| `afinado` | Afinado | Buff | 10 s | 2 × 8 % | +8 % crítico | Lector, consumibles |
| `coral_savia` | Coral de Savia | HoT | 6 s | 2 fuentes | Cura 2,5 % Vida máx cada 1 s | Cantor |
| `guia` | Guía | Buff | 12 s | No acumula | +20 % daño contra objetivos marcados | Lector (definitiva) |
| `foco` | Foco | Buff | 8 s | No acumula | +15 % celeridad | Ingeniería, nodos |
| `mella` | Mella | Debuff propio | 180 s | No acumula | −10 % a todos los atributos; se limpia al recuperar el cuerpo | Muerte (ver §8) |

### 5.2 Debuffs

| ID | Nombre | Tipo | Duración | Acumulación | Efecto | Fuente |
|----|--------|------|----------|-------------|--------|--------|
| `quemadura` | Quemadura | DoT Resonante | 6 s | 5 intensidades | 4 % del daño del golpe inicial por segundo | Bastión, brasas ambientales |
| `zumbido` | Zumbido | DoT Resonante | 5 s | 5 intensidades | 3 % daño/s y −10 % celeridad por intensidad (máx. 30 %) | Forjador, tormentas |
| `marchito` | Marchito | Debuff | 8 s | No acumula | −40 % curación recibida | Élites umbríos, jefes |
| `raiz` | Raíz | Control | 2–3 s | Tolerancia PvP | No puede moverse (sí atacar y usar habilidades) | Bastión, Cantor, plantas |
| `ralentizacion` | Ralentización | Control | 4 s | 3 × 25 % | −25 % velocidad por intensidad | Hiladora, pantano |
| `aturdimiento` | Aturdimiento | Control duro | 1–1,5 s | Tolerancia PvP | No puede moverse ni actuar | Hiladora, Forjador |
| `silencio` | Silencio | Control duro | 2 s | Tolerancia PvP | No puede usar habilidades (sí ataque básico) | Élites de la Quiebra, PvP |
| `corrosion` | Corrosión | Shred | 6 s | 2 × 25 % | −25 % mitigación por intensidad | Lector, ácido |
| `umbral_de_miedo` | Umbral de Miedo | Control | 2 s | Inmune si el objetivo es umbrío | Huye del lanzador | Jefes del Salar |
| `olvido` | Olvido | Debuff | 10 s | No acumula | Elimina **un** buff aleatorio al aplicarse y bloquea su refresco | Enemigos umbríos (Ley L3) |
| `marca_silencio` | Marca del Silencio | Debuff | 15 s | No acumula | +12 % daño recibido; acumulable con `guia` | Los Que Callan |

### 5.3 Reglas de apilado entre categorías

- Máximo **3 modificadores positivos** y **3 negativos** afectan un cálculo simultáneamente; el resto se muestra pero no aplica.
- `olvido` y `mella` no pueden multiplicarse entre sí: se aplica el peor.
- Un enemigo con `inmune_control = true` (jefes de fase 3) ignora `raiz`, `aturdimiento`, `silencio` y `umbral_de_miedo`, pero **sí** recibe `corrosion`, DoT y `marchito`.

## 6. PvP

| Regla | Valor |
|-------|-------|
| Multiplicador de daño entre jugadores | ×0,6 |
| Duración de control entre jugadores | ×0,5 (además de la tolerancia) |
| Curación en PvP | Sin penalización, pero `marchito` es más frecuente |
| Zonas | Solo en zonas marcadas (`Cordillera Vidriada`, `Salar del Silencio`) o en arenas (ver [07-social.md](07-social.md) §4) |
| Protección de novato | Nivel < 15 inmune en zonas PvP |
| Anti-griefing | 3 muertes del mismo atacante sobre la misma víctima en 10 min → el atacante queda marcado y no puede volver a golpearla por 30 min |
| Pérdida al morir en PvP | Igual que PvE (§8): 5 % de cobre y Mella; no se pierde equipo ni XP |

## 7. Ritmo de combate (presupuesto de diseño)

| Encuentro | Duración objetivo | Golpes recibidos por el jugador | Notas |
|-----------|-------------------|--------------------------------|-------|
| Enemigo común (nivel equivalente) | 6–10 s | 2–4 | Debe morir en una rotación corta |
| Enemigo de manada (×4) | 15–25 s | 6–10 | Enseña control de área y kiting |
| Élite | 25–40 s | 8–14 | Al menos un telegraph evitable |
| Mini-jefe | 60–90 s | 15–25 | Un cambio de patrón |
| Jefe de mazmorra | 3–5 min | 30–60 | Dos o tres fases |
| Jefe de raid | 6–10 min | 60–120 | Mecánicas asignadas por rol |

TTK de un jugador contra otro en PvP equivalente: **12–20 s** y nunca menos de 8 s.

### 7.1 Tabla de referencia de Vida y Defensa por tramo

Valores objetivo para criaturas comunes y jefes, alineados con el daño por golpe esperado del §2 y con las bandas de [02-classes.md](02-classes.md) §3.4. Son la referencia que usan los `EnemyDefinition` de cada zona.

| Tramo | Niv. medio | Vida común | Vida élite (×4) | Vida jefe de tramo (×25) | DEF común | Mitigación esperada (DPS / tanque) |
|-------|-----------|-----------|-----------------|---------------------------|-----------|-------------------------------------|
| T1 | 8 | 260 | 1.040 | 6.500 | 60 | 40 % / 55 % |
| T2 | 23 | 800 | 3.200 | 20.000 | 150 | 42 % / 57 % |
| T3 | 38 | 1.800 | 7.200 | 45.000 | 260 | 43 % / 58 % |
| T4 | 53 | 3.600 | 14.400 | 90.000 | 400 | 44 % / 58 % |
| T5 | 68 | 6.500 | 26.000 | 162.500 | 560 | 45 % / 59 % |
| T6 | 83 | 11.000 | 44.000 | 275.000 | 760 | 45 % / 59 % |
| T7 | 98 | 19.000 | 76.000 | 475.000 | 1.000 | 46 % / 59 % |
| T8 | 113 | 33.000 | 132.000 | 825.000 | 1.280 | 46 % / 60 % |
| T9 | 128 | 55.000 | 220.000 | 1.375.000 | 1.600 | 46 % / 60 % |
| T10 | 143 | 91.000 | 364.000 | 2.275.000 | 1.950 | 46 % / 60 % |

Jefes de instancia = ×12 la Vida común del tramo. Jefes de raid = ×60 y jefes mundiales = ×60 repartidos entre 20–60 jugadores. Un cambio en esta tabla exige actualizar los tests de balance del tramo correspondiente.

## 8. Muerte, derrota y recuperación

1. Al morir, el jugador aparece como **Eco** durante 5 s (puede ver, no actuar).
2. Respawn en el checkpoint del nodo más cercano.
3. Penalización: **5 % del cobre total** (nunca por debajo de 0) y la Mella (−10 % atributos, 180 s).
4. El cuerpo queda en el lugar de la muerte con el cobre perdido visible como **Brasa caída** durante 10 min.
5. Recuperar la Brasa limpia la Mella inmediatamente; si expira, la Mella termina sola.
6. **No se pierde XP, no se pierde equipo, no se puede perder el objeto equipado.** Es una decisión deliberada de P5 y del público objetivo (00-vision §3).

## 9. Inteligencia artificial de enemigos

### 9.1 Parámetros por enemigo (`data/enemies/*.tres`)

| Parámetro | Descripción | Rango típico |
|-----------|-------------|--------------|
| `arquetipo_ia` | Uno de los nueve patrones del §9.2 | — |
| `radio_deteccion` | Casillas a las que reacciona | 3–9 |
| `radio_agarre` | Leash: se rinde y vuelve a casa | 8–16 |
| `radio_ataque` | Alcance de su ataque | 1–7 |
| `velocidad` | Casillas/s | 2,0–5,0 (jugador base: 4,0) |
| `cooldown_ataque` | Segundos entre ataques | 1,0–4,0 |
| `tiempo_telegraph` | Aviso visual antes del golpe | 0,4–1,5 s |
| `comportamiento_al_dano` | `persigue`, `huye`, `llama`, `inmune` | — |
| `resistencia_control` | Inmune o no a CC duros | jefes: sí |
| `botín`, `xp`, `contribucion_minima` | Ver [05-economy.md](05-economy.md) y [06-progression.md](06-progression.md) | — |

### 9.2 Patrones

| Patrón | Descripción | Ejemplo en el mundo | Contramedida esperada |
|--------|------------|---------------------|------------------------|
| **Pasivo** | No ataca salvo que lo golpeen; huye a 20 % de Vida | Guanaco de terraza, ave de sal | No gastar habilidades; matar solo si se necesita material |
| **Errante** | Deambula sin rumbo; ataca si el jugador entra en su radio | Mordeluz de prado | Aprender el radio de detección |
| **Patrulla** | Recorre una ruta fija con puntos de pausa | Guardia de ruina, centinela de la Casa | Leer el patrón para pasar sin combatir |
| **Territorial** | Se queda en un área; ataca a quien entre y no persigue fuera | Nido de chispas, enredadera | Atacar desde el borde del territorio |
| **Agresivo** | Detecta a 8+ casillas y persigue hasta el leash | Jauría umbría, saqueador | Pelear en retirada hacia aliados |
| **Manada** | Se activa en grupo (3–6); uno llama y el resto converge | Mordeluz resonante, cuervos de campana | Control de área, no 1v1 |
| **Emboscada** | Invisible/inactivo hasta que el jugador pisa el gatillo | Reptil del pantano, araña de la mina | Detección con Lector; caminar por el centro de la ruta |
| **Guardián** | No persigue; protege un punto y tiene un ataque de área con CD | Gólem de la Mina, guardián del Templo | Forzar el ataque de área y entrar en el hueco |
| **Jefe** | Fases con mecánicas anunciadas y cambio de patrón | Mordeluz Resonante (mini), Kallpa (mundo) | Aprender fases; reparto de roles |

### 9.3 Máquina de estados común

```
IDLE ──(jugador en radio_deteccion)──► ALERTA (0,3–0,8 s de animación)
ALERTA ──(objetivo válido)──► PERSEGUIR
PERSEGUIR ──(en radio_ataque)──► TELEGRAPH ──► ATACAR ──► ENFRIAR ──► PERSEGUIR
PERSEGUIR ──(fuera de radio_agarre o sin línea de visión 3 s)──► VOLVER
VOLVER ──(llega a casa)──► IDLE          VOLVER ──(recibe daño)──► PERSEGUIR
VIDA ≤ 20 % ──(comportamiento_al_dano = huye)──► HUIR ──(fuera de radio)──► VOLVER
VIDA = 0 ──► MUERTO (loot, XP, respawn según zona)
```

Reglas de servidor:

- El pathfinding se resuelve con `AStarGrid2D` sobre el grid de la zona (ver [04-world.md](04-world.md) §8).
- La IA corre **solo en servidor** (ADR-002); el cliente interpola posiciones y muestra animaciones.
- Máximo 40 enemigos activos simulando IA por zona; el resto queda "congelado" en su spawn hasta que un jugador entra en 20 casillas (presupuesto de CPU y banda).
- Los enemigos no atraviesan transiciones de zona; los jefes tienen leash explícito y aviso visual antes de resetear.

### 9.4 Jefes: estructura de fases

Todo jefe usa la misma estructura de datos para que sea barato de implementar:

```
Jefe: fases = [F1 (100–66 % Vida), F2 (66–33 %), F3 (33–0 %)]
Por fase: 2–3 ataques con CD, 1 mecánica de posición, 1 ventana de vulnerabilidad (10–15 s)
Transición: invulnerable 3 s con aviso en pantalla y cambio de música
```

**Ejemplo — Mordeluz Resonante (mini-jefe, nivel 12, MVP):**

| Fase | Ataque | Telegraph | Contramedida |
|------|--------|-----------|--------------|
| F1 (100–66 %) | Onda de eco en cono | 1,2 s de círculo rojo | Salir del cono |
| F2 (66–33 %) | Invoca 4 mordeluces | 0,8 s de zumbido | Control de área |
| F2 | Doble carga | 1,0 s de línea | Esquivar lateral |
| F3 (33–0 %) | Pulso circular + Zumbido | 1,5 s de círculo grande | Usar la pausa entre pulsos |
| Ventana | Tras el pulso, 12 s con −20 % mitigación | aura azul | Concentrar daño |

### 9.5 Cómo se reparte el botín por contribución

El servidor acumula **contribución** por jugador en cada enemigo (daño efectivo + curación efectiva a quien lo golpeó + control aplicado en el momento del golpe). Al morir:

- Contribución ≥ 10 % → elegible para botín y XP.
- El botín raro se reparte por tirada de contribución, no por "último golpe".
- Ver reglas completas en [05-economy.md](05-economy.md) §4 y loot de grupo en [07-social.md](07-social.md) §3.3.
