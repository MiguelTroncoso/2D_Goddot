# 02 — Clases jugables

> Depende de: [01-lore.md](01-lore.md) §6 · Usa: [03-combat.md](03-combat.md) (fórmulas y estados) · Afecta a: [06-progression.md](06-progression.md), [08-ui-ux.md](08-ui-ux.md), [11-mvp-scope.md](11-mvp-scope.md)
> Datos en `src/data/classes/*.tres` y `src/data/skills/*.tres` (ADR-005, capa `data/`). Reglas en `src/domain/class_rules.gd`.

## 1. Reglas comunes

| Regla | Valor |
|-------|-------|
| Nivel máximo | **150** (MVP: 15) |
| Habilidades por clase | 1 ataque básico (sin coste) + 5 habilidades + 1 definitiva = 7 ranuras |
| Desbloqueo de habilidades | básico y H1 en 1 · H2 en 5 · H3 en 15 · H4 en 30 · H5 en 60 · definitiva en 90 |
| Rangos de habilidad | Cada habilidad sube 4 rangos automáticos al nivel 15 / 45 / 75 / 120 (+12 % potencia por rango, sin puntos que gastar) |
| Poder de afinación | Cada 15 niveles la clase gana una pasiva de tramo (+3 % al recurso y +2 % al atributo primario) |
| Ranuras activas visibles en móvil | 4 botones + 1 básico + 1 definitiva (P1, ver [08-ui-ux.md](08-ui-ux.md) §4) |
| **Reserva** (recurso de clase) | Máx = 100 + 2 × Resonancia. Regen: 6,0/s fuera de combate, 2,0/s + 0,05 × Resonancia en combate |
| Generación de Reserva | Ataque básico +8; recibir daño +5 si el personaje es tanque; golpe crítico +4 |
| Coste de reespecialización | Gratis hasta nivel 10; luego 250 cobre + 5 min de enfriamiento |
| Cambio de clase | Permitido desde nivel 20, conserva nivel y progreso de facción, reinicia talentos |

Todos los valores de habilidad escalan con la fórmula canónica de daño de [03-combat.md](03-combat.md) §2:

```
daño = (POD × coef + plano) × (1 + 0,02 × (nivel − 1)) × (1 − mitigación) × mods_estado
curación = (POD × coef_cura + plano_cura) × (1 + 0,02 × (nivel − 1)) × mods_estado
```

`coef` es la fracción del Poder del personaje; `plano` se resuelve con la tabla de nivel del §3. Los números siguientes están calibrados para que un combate común dure **6–10 s** y un élite **25–40 s** (ver [03-combat.md](03-combat.md) §7).

### 1.1 Distribución de atributos al subir de nivel

Cada clase tiene un **primario** (+2 por nivel, automático), un **secundario** (+1 por nivel, automático) y **1 punto libre** por nivel para repartir entre los cuatro atributos (ver [06-progression.md](06-progression.md) §3).

## 2. Las cinco clases

### 2.1 Bastión de Brasa — Tanque

*"Lo que golpea la brasa, alimenta la brasa."*

- **Afinación:** Brasa · **Recurso:** Calor · **Primario:** Vigor · **Secundario:** Poder
- **Silueta:** ancho de hombros, martillo/escudo, yelmo con cresta baja. **Acento:** `#D9622B` naranja fragua.
- **Rol:** primera línea, control de espacio, protección de aliados frágiles.
- **Fuerte en:** PvE sostenido, mazmorras, jefes con daño físico. **Débil en:** movilidad, daño a distancia, persecución.
- **Rotación base (PvE):** Tajo → Pulso de Escoria ×2 → Muro de Brasa cuando el aliado baja de 50 % → Fragua Interna al recibir burst.

| # | Habilidad | Coste | CD | Alcance | Efecto | Escalado |
|---|-----------|-------|----|---------|--------|----------|
| 0 | **Tajo de Fragua** (básico) | 0 | 1,0 s | 1,5 casillas, cono 90° | Daño Físico + genera 8 Calor | coef 1,0 |
| 1 | **Muro de Brasa** | 20 Calor | 10 s | 3 casillas, grupo | Escudo = 15 % de Vida máx durante 6 s + Provocar 3 s a enemigos golpeados por el escudo | escudo escala con Vigor: `0,15 × Vida_max` |
| 2 | **Fragua Interna** | 0 | 25 s | propio | 4 s: +30 % mitigación, convierte 25 % del daño recibido en Calor, no puede moverse a más de 2 casillas/s | mitigación fija |
| 3 | **Pulso de Escoria** | 30 Calor | 8 s | radio 3 | Daño Resonante en área + aplica **Quemadura** 6 s (ver [03-combat.md](03-combat.md) §5) | coef 0,8 |
| 4 | **Cadena de Yunque** | 25 Calor | 14 s | 4 casillas, línea | Arrastra 1 casilla hacia el Bastión + **Raíz** 2 s; interrumpe canalizaciones | coef 0,5 |
| 5 | **Estallido de Candela** (definitiva) | 100 Calor | 90 s | radio 4 | Daño Resonante en área + aplica **Piel de Nácar** al grupo (escudo 10 % Vida 8 s) | coef 2,2 |

**Talentos (3 ramas):** *Yunque* (más escudo y Provocar), *Escoria* (más daño y Quemadura), *Corazón de Fragua* (regeneración y reducción del CD de la definitiva).

### 2.2 Hiladora de Viento — DPS móvil / soporte de reposicionamiento

*"El viento no bloquea: mueve."*

- **Afinación:** Viento · **Recurso:** Impulso · **Primario:** Agilidad · **Secundario:** Poder
- **Silueta:** delgada, doble filo curvo, capa corta. **Acento:** `#6FD3C7` turquesa claro.
- **Rol:** DPS cuerpo a cuerpo rápido, reposicionamiento de aliados, limpieza de enjambres.
- **Fuerte en:** movilidad, mapas abiertos, huir de zonas. **Débil en:** aguantar daño, objetivos con mucha mitigación.
- **Rotación base:** Filo Circular en enjambre → Paso de Ráfaga para entrar/salir → Vórtice Ascendente para agrupar → Vendaval al jefe.

| # | Habilidad | Coste | CD | Alcance | Efecto | Escalado |
|---|-----------|-------|----|---------|--------|----------|
| 0 | **Corte de Corriente** (básico) | 0 | 0,6 s | 1,5 casillas | Daño Físico rápido + genera 8 Impulso | coef 0,7 |
| 1 | **Paso de Ráfaga** | 15 Impulso | 6 s | 4 casillas | Dash; daña a los enemigos atravesados; inmune a Raíz durante el desplazamiento | coef 0,6 |
| 2 | **Viento Compartido** | 25 Impulso | 18 s | 5 casillas, grupo | +25 % velocidad de movimiento a aliados por 5 s; limpia **Ralentización** | utilidad |
| 3 | **Filo Circular** | 30 Impulso | 9 s | radio 2,5 | Daño Físico en círculo + **Ralentización** 25 % por 4 s | coef 1,1 |
| 4 | **Vórtice Ascendente** | 35 Impulso | 20 s | radio 3 | Atrae enemigos hacia el centro + **Aturdimiento** 1,5 s | coef 1,0 |
| 5 | **Vendaval de Cola** (definitiva) | 100 Impulso | 80 s | cono 5, canalizado 3 s | 5 golpes de daño Físico; cada golpe da +10 % Impulso al grupo | coef 0,9 × 5 |

**Talentos:** *Ráfaga* (dash más corto en CD, daño de paso), *Ciclo* (Filo Circular y Vórtice), *Custodia* (Viento Compartido escuda aliados).

### 2.3 Lector de Umbrales — Control / utilidad a distancia

*"Todo problema es un mapa mal dibujado."*

- **Afinación:** Trazo · **Recurso:** Trazos · **Primario:** Resonancia · **Secundario:** Agilidad
- **Silueta:** alto, capucha, bastón-pluma, quipu colgando. **Acento:** `#7C6BE0` violeta tinta.
- **Rol:** DPS a distancia con marcas, control de terreno y utilidad de grupo (revelar, bloquear, abrir atajos).
- **Fuerte en:** grupos, jefes con fases, emboscadas. **Débil en:** 1v1 sostenido, cuando queda aislado (P5: frágil).
- **Rotación base:** Trazo Menor → Marca de Umbral → Lectura de Fallas → Reja para cortar la huida.

| # | Habilidad | Coste | CD | Alcance | Efecto | Escalado |
|---|-----------|-------|----|---------|--------|----------|
| 0 | **Trazo Menor** (básico) | 0 | 0,9 s | 7 casillas | Daño Resonante a distancia + genera 8 Trazos | coef 0,8 |
| 1 | **Marca de Umbral** | 15 Trazos | 5 s | 8 casillas | Marca 8 s: el objetivo recibe +12 % daño y queda revelado (anti-invisibilidad) | utilidad |
| 2 | **Atajo de Tinta** | 20 Trazos | 15 s | 6 casillas | Teletransporte corto; atraviesa obstáculos bajos y sirve de escape | utilidad |
| 3 | **Reja de Geometría** | 30 Trazos | 16 s | línea de 5 | Muro invisible de 5 s que bloquea movimiento (no proyectiles) | utilidad |
| 4 | **Lectura de Fallas** | 20 Trazos | 12 s | radio 4 | Daño Resonante leve + **Corrosión** (−25 % mitigación) 6 s | coef 0,6 |
| 5 | **Trazado Mayor** (definitiva) | 100 Trazos | 100 s | mapa 12 casillas, 12 s | Revela y etiqueta enemigos en la zona; aliados hacen +20 % daño a objetivos marcados; daño 1,6 a marcados al lanzar | coef 1,6 |

**Talentos:** *Cartografía* (alcance, revelar, duración de marca), *Geometría* (Reja y atajos), *Anotación* (daño a marcados y CD).

### 2.4 Cantor de Raíces — Soporte / sanador

*"Las heridas se cierran si el mundo recuerda cómo estaba entero."*

- **Afinación:** Savia · **Recurso:** Savia · **Primario:** Resonancia · **Secundario:** Poder
- **Silueta:** bajo y sólido, ramas en la espalda, morral de semillas. **Acento:** `#63B36A` verde savia.
- **Rol:** curación, escudos, limpieza y resurrección en combate. Es el pegamento del grupo.
- **Fuerte en:** mazmorras, jefes, PvP de grupo. **Débil en:** daño propio, duelos, solitario (el MVP lo compensa con curación al propio personaje al 70 %).
- **Rotación base:** Brote Sanador cuando el aliado baja del 70 % → Corteza Viva antes del burst enemigo → Enraizar al que persigue → Semilla de Rebrote si cae alguien.

| # | Habilidad | Coste | CD | Alcance | Efecto | Escalado |
|---|-----------|-------|----|---------|--------|----------|
| 0 | **Pulso de Savia** (básico) | 0 | 1,0 s | 6 casillas | Daño Resonante a enemigos **o** cura a un aliado; genera 8 Savia | coef 0,7 daño / 0,7 cura |
| 1 | **Brote Sanador** | 20 Savia | 4 s | 7 casillas | Cura directa a un aliado; sobre 60 % de Vida se convierte en **Coral de Savia** (regen 2,5 s × 6 s) | cura coef 1,6 |
| 2 | **Corteza Viva** | 25 Savia | 12 s | 6 casillas | Escudo = 12 % Vida máx por 8 s; absorbe daño antes que la Vida | `0,12 × Vida_max` + 0,3 × POD |
| 3 | **Semilla de Rebrote** | 35 Savia | 30 s | 4 casillas | Revive en combate a un aliado con 40 % Vida; no puede usarse sobre sí mismo | utilidad |
| 4 | **Enraizar** | 25 Savia | 14 s | radio 3 | Daño Resonante leve + **Raíz** 3 s a enemigos en área | coef 0,8 |
| 5 | **Coro de Raíces** (definitiva) | 100 Savia | 90 s | radio 6, grupo | Cura 1,2 × POD/s durante 6 s y limpia 2 efectos negativos de cada aliado | cura coef 1,2/s |

**Talentos:** *Verde Nuevo* (cura y regen), *Corteza* (escudos y mitigación a aliados), *Ciclo* (limpieza, resurrección y definitiva).

### 2.5 Forjador de Chispas — DPS a distancia / área

*"Un problema bien medido explota una sola vez."*

- **Afinación:** Chispa · **Recurso:** Carga · **Primario:** Poder · **Secundario:** Resonancia
- **Silueta:** gafas de soldadura, mochila de cobre, martillo-lanzador. **Acento:** `#E8C34A` amarillo chispa.
- **Rol:** daño a distancia, trampas, control de zonas y objetivos múltiples.
- **Fuerte en:** PvE en grupo, oleadas, jefes estáticos. **Débil en:** presión cuerpo a cuerpo (P5); si lo alcanzan, cae rápido.
- **Rotación base:** Cañón de Agujas en línea → Mina de Chispa en el suelo → Batería Portátil → Sobrecarga antes de la definitiva.

| # | Habilidad | Coste | CD | Alcance | Efecto | Escalado |
|---|-----------|-------|----|---------|--------|----------|
| 0 | **Descarga** (básico) | 0 | 0,8 s | 6 casillas | Proyectil Resonante + genera 8 Carga | coef 0,9 |
| 1 | **Mina de Chispa** | 20 Carga | 8 s | lanzada a 6 | Trampa: detona en radio 2, aplica **Aturdimiento** 1 s y **Zumbido** 5 s | coef 2,0 |
| 2 | **Cañón de Agujas** | 30 Carga | 10 s | línea de 8 | Atraviesa enemigos; ignora 20 % de mitigación | coef 1,4 |
| 3 | **Batería Portátil** | 25 Carga | 20 s | despliegue a 2 | Torreta 10 s que dispara 0,5 × POD cada 1 s al enemigo más cercano marcado | coef 0,5 por disparo |
| 4 | **Sobrecarga** | 20 Carga | 18 s | propio | 6 s: +25 % daño propio, −15 % mitigación propia; el siguiente golpe no falla | buff/debuff propio |
| 5 | **Tormenta de Chispas** (definitiva) | 100 Carga | 95 s | radio 5 | 6 impactos Resonantes aleatorios que aplican **Zumbido**; prioriza objetivos con Marca de Umbral | coef 1,0 × 6 |

**Talentos:** *Ingeniería* (torreta y minas), *Balística* (cañón, penetración y crítico), *Reactor* (Carga, Sobrecarga, definitiva).

## 3. Curva de progresión 1–150

### 3.1 Fórmulas de crecimiento

```
Vida_max  = 120 + 26,0 × (nivel − 1) + 0,090 × (nivel − 1)²   # nv 15: 502 · nv 75: 2.535 · nv 150: 5.992
POD_base  =  10 +  1,9 × (nivel − 1) + 0,006 × (nivel − 1)²   # nv 15:  38 · nv 75:   184 · nv 150:   426
DEF_base  =  15 +  2,4 × (nivel − 1) + 0,010 × (nivel − 1)²   # nv 15:  51 · nv 75:   247 · nv 150:   595
Reserva_max = 100 + 2 × Resonancia (atributo, no nivel)
```

Los atributos primarios son Vigor, Poder, Resonancia y Agilidad (ver [06-progression.md](06-progression.md) §3). La clase decide el reparto automático: +2 al primario y +1 al secundario por nivel; el resto sale de 1 punto libre por nivel y del equipo.

### 3.2 Hitos compartidos (por tramo)

| Tramo | Nivel | Desbloqueo | Vida base | Poder base | Notas |
|-------|-------|-----------|-----------|------------|-------|
| T1 | 1 | Básico + H1 | 120 | 10 | Onboarding, primera zona, primer crafteo |
| T1 | 5 | H2 | 225 | 18 | Cueva del Eco, primer set completo |
| T1 | 10 | Árbol de talentos (1 punto/nivel) | 361 | 28 | Primera decisión de talento |
| T1 | 15 | H3, fin de tramo | 502 | 38 | Jefe de tramo |
| T2 | 30 | H4 | 950 | 70 | PvP opt-in, mercado entre jugadores |
| T3 | 45 | Cambio de clase, montura cosmética | 1.438 | 105 | Instancia de dificultad aumentada |
| T4 | 60 | H5 | 1.967 | 143 | Hub secundario, encargos de facción |
| T5 | 75 | — | 2.535 | 184 | Talento de rama 2 |
| T6 | 90 | Definitiva | 3.147 | 227 | Zona PvP de riesgo alto |
| T7 | 105 | — | 3.797 | 272 | Jefe mundial de temporada |
| T8 | 120 | Talento final de rama 2 | 4.489 | 321 | Instancias de 5 jugadores |
| T9 | 135 | — | 5.220 | 372 | Sets T9, raid de 5 |
| T10 | 150 | Tope: título, cosmético, raid de 10 | 5.992 | 426 | Endgame de temporada |

*(Vida y Poder son base de clase sin equipo ni puntos libres; todo lo demás proviene de atributos, sets, grabados y talentos.)*

### 3.3 Hitos por clase (nivel en que el kit "se siente")

| Clase | 1 | 15 | 30 | 60 | 90 | 150 |
|-------|---|----|----|----|----|-----|
| Bastión de Brasa | Tajo de Fragua | Pulso de Escoria | Cadena de Yunque | Muro reforzado | Estallido de Candela | Mitigación 65 % con set T10 |
| Hiladora de Viento | Corte de Corriente | Filo Circular | Vórtice Ascendente | Vendaval encadenado | Vendaval de Cola | Mantiene 100 % Impulso en grupo |
| Lector de Umbrales | Trazo Menor | Reja de Geometría | Lectura de Fallas | Trazado de mazmorra | Trazado Mayor | Marca permanente a jefes de raid |
| Cantor de Raíces | Pulso de Savia | Corteza Viva | Semilla de Rebrote | Cura en área cada 4 s | Coro de Raíces | Resurrección sin CD extra |
| Forjador de Chispas | Descarga | Batería Portátil | Sobrecarga | Torreta doble | Tormenta de Chispas | Área sostenida sin coste neto |

### 3.4 Poder relativo esperado por tramo

Con equipo del tramo y sin consumibles, el daño por segundo de referencia debe quedar en estas bandas (objetivo de balance, no ley):

| Tramo | Bastión | Hiladora | Lector | Cantor | Forjador |
|-------|---------|----------|--------|--------|----------|
| T1 (1–15) | 60 % | 100 % | 85 % | 45 % (cura 100 %) | 105 % |
| T2 (16–30) | 68 % | 100 % | 92 % | 48 % | 105 % |
| T3 (31–45) | 72 % | 100 % | 96 % | 52 % | 108 % |
| T4 (46–60) | 75 % | 100 % | 100 % | 55 % | 110 % |
| T5 (61–75) | 78 % | 100 % | 102 % | 57 % | 110 % |
| T6 (76–90) | 80 % | 98 % | 104 % | 58 % | 112 % |
| T7 (91–105) | 82 % | 97 % | 105 % | 60 % | 113 % |
| T8 (106–120) | 84 % | 96 % | 106 % | 61 % | 114 % |
| T9 (121–135) | 86 % | 95 % | 107 % | 62 % | 115 % |
| T10 (136–150) | 88 % | 94 % | 108 % | 63 % | 116 % |

El Bastión compensa con mitigación y control; el Cantor, con curación y supervivencia del grupo. Se revisa con la telemetría de `docs/07-testing.md` y un test de dominio por tramo (`tests/domain/test_balance_bands.gd`, ver [11-mvp-scope.md](11-mvp-scope.md) §6).

### 3.5 Clase futura (post-1.0)

En v1.2 se evalúa una sexta clase, **Tejedor de Umbral** (híbrido Umbrío/Resonante, control de sombras y robo de recursos), reservada para cuando el sistema de estados Umbríos tenga telemetría suficiente. No entra en MVP, vertical slice ni v1.0.

## 4. Sinergias entre clases

La cooperación debe leerse sin explicación (P2). Cada par tiene al menos una combinación evidente.

| Combinación | Combo | Efecto combinado |
|-------------|-------|------------------|
| Bastión + Forjador | *Trampa sobre yunque* | El Bastión agrupa con Cadena de Yunque; la Mina de Chispa del Forjador golpea a todos los agrupados |
| Bastión + Lector | *Arena cerrada* | Reja de Geometría corta la huida y el Bastión Provoca dentro de la reja |
| Bastión + Cantor | *Muro vivo* | Corteza Viva sobre el Bastión duplica el valor efectivo del escudo por su mitigación |
| Hiladora + Forjador | *Kiting cooperativo* | Filo Circular ralentiza; el Forjador mantiene distancia con Cañón y Torreta |
| Hiladora + Cantor | *Rescate* | Semilla de Rebrote + Viento Compartido permiten revivir y salir de una zona de jefe |
| Lector + Forjador | *Fuego guiado* | Marca de Umbral (+12 % daño recibido) multiplica los 6 impactos de Tormenta de Chispas |
| Lector + Cantor | *Sala segura* | Reja + Coro de Raíces estabilizan un punto para curar en mazmorra |
| Cualquiera + Cantor | *Sinergia universal* | El Cantor es la única fuente de limpieza de 2 debuffs en área (Coro de Raíces) |

### 4.1 Regla de solitario

Todo contenido del MVP debe poder completarse **solo** con al menos una clase, excepto las instancias de grupo, que indican explícitamente "3+ jugadores" en su descripción (ver [04-world.md](04-world.md) §7). Ningún contenido de zona persistente exige un rol específico.

## 5. Implementación en Godot

Estructura de datos (`data/`, sin lógica):

```
src/data/classes/bastion_de_brasa.tres      # ClassDefinition: id, nombre, afinacion, recurso, primario, secundario, silueta, acento
src/data/skills/baston_muro_de_brasa.tres   # SkillDefinition: id, clase, coste, cd, rango, forma, coef, plano, estados_aplicados, tags
src/data/talents/baston_yunque.tres         # TalentDefinition: id, rama, nivel_requerido, modificadores
```

Reglas puras (`domain/`, sin nodos):

```gdscript
# src/domain/class_rules.gd  (extracto)
class_name ClassRules

const RECURSO_BASE := 100
const REGEN_COMBATE := 2.0
const REGEN_FUERA := 6.0

static func reserva_max(resonancia: int) -> int:
    return RECURSO_BASE + 2 * resonancia

static func regen_por_segundo(resonancia: int, en_combate: bool) -> float:
    if en_combate:
        return REGEN_COMBATE + 0.05 * resonancia
    return REGEN_FUERA

static func puede_usar(reserva: float, coste: int) -> bool:
    return reserva >= float(coste)
```

El servidor es la única autoridad sobre coste, cooldown y resolución de efectos (ADR-002). El cliente solo predice el *feedback* visual, nunca el gasto de Reserva.
