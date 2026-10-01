# 06 — Progresión, talentos, reputación y endgame (niveles 1–150)

> Depende de: [02-classes.md](02-classes.md) §3, [03-combat.md](03-combat.md) §2, [04-world.md](04-world.md) §4 · Afecta a: [05-economy.md](05-economy.md), [07-social.md](07-social.md), [12-events.md](12-events.md)
> Implementación: curvas y reglas en `src/domain/progression/`, orquestación en `src/systems/progression_system.gd`, datos en `src/data/talents/*.tres` y `src/data/progression/*.tres`.

## 1. Curva de XP

### 1.1 Fórmula

```
XP_para_subir(L)      = round(40 × L² + 25 × L)
XP_total_hasta(150)   ≈ 44.830.000
```

| Nivel | XP para subir | XP acumulada al llegar | Nivel | XP para subir | XP acumulada al llegar |
|-------|---------------|------------------------|-------|---------------|------------------------|
| 1 | 65 | 0 | 80 | 258.000 | 6.778.200 |
| 10 | 4.250 | 12.525 | 100 | 402.500 | 13.257.750 |
| 25 | 25.625 | 203.500 | 120 | 579.000 | 22.931.300 |
| 50 | 101.250 | 1.647.625 | 135 | 732.375 | 32.667.525 |
| 75 | 226.875 | 5.582.375 | 149 | 891.765 | 43.938.610 |
| — | — | — | 150 | 903.750 | 44.830.375 |

Comprobación rápida: para llegar al nivel 10 hacen falta **12.525 XP** (suma de los niveles 1 a 9) y para llegar al 150, **44.830.375 XP**. La función de test `test_xp_curve_total()` verifica ambos valores.

### 1.2 Cuánto tarda

| Tramo | Niveles | Horas de juego previstas (jugador promedio) | Ritmo |
|-------|---------|---------------------------------------------|-------|
| T1 | 1–15 | 4–6 h | Tutorial y primera identidad de clase |
| T2 | 16–30 | 8–10 h | Primera decisión de talento y facción |
| T3 | 31–45 | 12–15 h | Primer set completo |
| T4 | 46–60 | 16–20 h | Primer contacto PvP y hubs secundarios |
| T5 | 61–75 | 20–24 h | Crafteo serio y encargos |
| T6 | 76–90 | 26–32 h | Zonas PvP y recetas raras |
| T7 | 91–105 | 32–40 h | Jefe mundial y endgame temprano |
| T8 | 106–120 | 40–48 h | Instancias de 5 y raids de 5 |
| T9 | 121–135 | 48–56 h | Sets legendarios y temporadas |
| T10 | 136–150 | 55–70 h | Raid de 10 y progresión horizontal |
| **Total** | **1–150** | **≈ 260–320 h** | Con Lumbre de Descanso puede bajar a ~200 h |

Objetivo de diseño: **el jugador nunca sube menos de un nivel por sesión de 40 minutos** en la primera mitad. Si la telemetría muestra lo contrario, se ajusta la XP por criatura del tramo antes de tocar la curva global.

### 1.3 XP por criatura

```
XP_criatura(nivel) = round(0,012 × XP_para_subir(nivel))        # criatura común
                   = 0,48 × nivel² + 0,3 × nivel
élite   = ×3,0        mini-jefe = ×8       jefe de tramo = ×25
jefe de instancia = ×18                     jefe de raid = ×60 (repartido)
```

| Diferencia de nivel (criatura − jugador) | Multiplicador de XP |
|-------------------------------------------|---------------------|
| +8 o más | ×1,15 (riesgo) |
| −3 a +7 | ×1,00 |
| −4 a −8 | ×0,60 |
| −9 a −14 | ×0,25 |
| −15 o menos | 0 (no vale la pena farmear zonas viejas) |

### 1.4 Lumbre de Descanso (progreso offline)

- Se acumula mientras el jugador está desconectado en un hub, a razón de **1 hora de juego = 15 minutos de acumulación**, máximo 10 h reales (2,5 h de juego acumuladas).
- Genera un pozo de XP extra igual al 25 % de un nivel de su tramo, máximo 1,5 niveles.
- Mientras el pozo esté activo, toda la XP ganada aumenta un **50 %** hasta consumirlo.
- No acumula en zonas PvP ni con `mella` activa. Es la única forma de progreso pasivo y está acotada para no volverse un idle game (00-vision §7).

### 1.5 Muerte y XP

**No se pierde XP al morir** (ver [03-combat.md](03-combat.md) §8). La penalización es cobre + `mella` + el tiempo de volver.

## 2. Desbloqueo por nivel

| Nivel | Desbloqueo |
|-------|-----------|
| 1 | Clase, ataque básico, H1, inventario, primer hub |
| 5 | H2, primer crafteo, instancia Cueva del Eco |
| 10 | Árbol de talentos (1 punto por nivel), mercado entre jugadores, encargos diarios |
| 15 | H3, fin de T1, primer jefe de tramo, montura cosmética de facción |
| 20 | Sellos de Ruta, reputación de facción, primera mejora de banco |
| 30 | H4, PvP opt-in, arenas 1v1, fin de T2 |
| 45 | Cambio de clase (desde nivel 20), instancia aumentada, arenas 3v3 |
| 60 | H5, segundo hub, encargos de facción |
| 75 | Talentos de rama 2, jefes de zona con tabla aumentada |
| 90 | Definitiva, zonas PvP de riesgo alto |
| 105 | Jefe mundial de temporada, comercio de grabados |
| 120 | Instancias de 5 jugadores, mazmorras aumentadas +1 a +5 |
| 135 | Raid de 5 (Templo de Nácar), sets T9 |
| 150 | Raid de 10, Nivel de Resonancia, título de temporada |

## 3. Atributos

### 3.1 Primarios

| Atributo | Aporte principal | Aporte secundario |
|----------|------------------|-------------------|
| **Vigor** | +8 Vida por punto, +2 DEF por punto (desde 20 puntos) | +1 % mitigación por cada 25 |
| **Poder** | +1 POD por punto, +0,4 % daño de habilidad por cada 10 | +0,5 % curación por cada 10 |
| **Resonancia** | +2 Reserva máx por punto, +0,05 regeneración en combate | +1 % penetración por cada 30 |
| **Agilidad** | +0,15 % celeridad por punto (cap 40 %) | +0,1 % velocidad por cada 10 (cap ±30 %) |

Reparto automático por clase: **+2 al primario, +1 al secundario, +1 punto libre** por nivel. A nivel 150 hay 150 puntos libres (≈ 30 % del total), suficiente para una identidad propia sin volver el juego inescrutable.

### 3.2 Secundarios

| Estadística | Fórmula / fuente | Cap |
|-------------|------------------|-----|
| POD efectivo | `POD_base + atributos + equipo + buffs` | — |
| DEF | `DEF_base + Vigor + equipo` | — |
| Mitigación | `DEF / (DEF + 50 + 10 × nivel)` | 75 % |
| Crítico | 5 % base + equipo + talentos + buffs | 50 % |
| Daño crítico | 150 % base + equipo | 250 % |
| Celeridad | Agilidad + equipo | 40 % |
| Tenacidad | Equipo + talentos | 50 % |
| Penetración | Resonancia + grabados | 35 % |
| Poder de curación | POD + talentos + equipo | — |
| Velocidad de movimiento | 4,0 casillas/s base ± 30 % | ±30 % |

## 4. Talentos

### 4.1 Estructura

- **3 ramas por clase, 10 nodos cada una** (30 nodos).
- 1 punto de talento por nivel desde el 10 (141 puntos a nivel 150).
- Los nodos 1–4 cuestan 1 punto, los nodos 5–7 cuestan 2, los nodos 8–9 cuestan 3 y el capstone (nodo 10) cuesta 5.
- Para desbloquear el capstone hay que haber invertido al menos 20 puntos en esa rama.
- **Reespecialización:** gratis hasta nivel 30; después cuesta `1.000 × tramo` de Cobre y se puede hacer en cualquier hub. No hay límite de reespecializaciones.
- Las ramas son **identidad**, no potencia bruta: ninguna combinación debe superar en más de 12 % a otra en daño puro (test de dominio por clase y tramo).

### 4.2 Ramas por clase

| Clase | Rama 1 | Rama 2 | Rama 3 |
|-------|--------|--------|--------|
| Bastión de Brasa | **Yunque** (escudo, Provocar, defensa de grupo) | **Escoria** (daño, Quemadura, área) | **Corazón de Fragua** (regeneración, CD de definitiva, supervivencia) |
| Hiladora de Viento | **Ráfaga** (dash, movilidad, daño de paso) | **Ciclo** (Filo Circular, Vórtice, área) | **Custodia** (apoyo a aliados, limpieza, escudos) |
| Lector de Umbrales | **Cartografía** (alcance, revelar, marca) | **Geometría** (Reja, atajos, control) | **Anotación** (daño a marcados, CD, crítico) |
| Cantor de Raíces | **Verde Nuevo** (curación y regeneración) | **Corteza** (escudos y mitigación a aliados) | **Ciclo** (limpieza, resurrección, definitiva) |
| Forjador de Chispas | **Ingeniería** (torreta, minas, trampas) | **Balística** (cañón, penetración, crítico) | **Reactor** (Carga, Sobrecarga, definitiva) |

### 4.3 Ejemplo completo — árbol del Bastión de Brasa (rama Yunque)

| # | Nodo | Coste | Efecto |
|---|------|-------|--------|
| 1 | Piel de escoria | 1 | +5 % Vida máx |
| 2 | Postura firme | 1 | +10 % resistencia a `raiz` y `ralentizacion` |
| 3 | Eco del golpe | 1 | Recibir daño genera +1 Calor adicional |
| 4 | Guardia baja | 1 | +5 % mitigación mientras no te muevas |
| 5 | Provocación mayor | 2 | `Muro de Brasa` provoca 4 s y alcanza 4 casillas |
| 6 | Yunque compartido | 2 | `Estallido de Candela` da escudo al grupo un 25 % mayor |
| 7 | Brasa paciente | 2 | `Fragua Interna` dura 6 s y devuelve 40 % del daño |
| 8 | Muro doble | 3 | El escudo de `Muro de Brasa` se aplica dos veces (una al lanzar, otra a los 3 s) |
| 9 | Voluntad de fragua | 3 | Al caer bajo 25 % de Vida, +20 % mitigación 5 s (CD 90 s) |
| 10 | **Corazón de Yunque** (capstone) | 5 | Mientras tienes escudo activo, tus habilidades cuestan 20 % menos Calor y el grupo recibe el 30 % de tu mitigación |

Las otras 14 ramas siguen la misma estructura (4 nodos de identidad, 3 de especialización, 2 de potencia, 1 capstone) y se documentan en `src/data/talents/<clase>_<rama>.tres`.

## 5. Reputación con facciones

### 5.1 Rangos

| Rango | Puntos | Recompensa |
|-------|--------|-----------|
| Neutral | 0 | Nada |
| Conocido | 1.000 | Descuento de 5 % en servicios de facción |
| Respetado | 3.000 | Receta exclusiva de la facción (sin poder superior) |
| Honrado | 8.000 | Cosmético de facción + acceso a encargos semanales de alto valor |
| Voz | 20.000 | Montura cosmética, título y una decisión de trama |

### 5.2 Reglas

- La suma de reputación **positiva** entre las cuatro facciones está topada en **35.000 puntos**: no se puede ser Voz en todas.
- Ganar reputación con una facción puede restar con su opuesta: Ortecas ↔ Los Que Callan (−50 % del valor ganado) y Casa Salitre ↔ Cantores de Raíz (−25 %).
- La reputación **nunca** otorga estadísticas ni equipo de poder; otorga acceso, recetas cosméticas, precio y trama.
- Perder reputación por debajo de Neutral no bloquea contenido ya desbloqueado; solo cierra nuevas compras.
- Los sellos de Ruta son la moneda de facción y son intransferibles.

## 6. Endgame

El endgame comienza de forma real en T7 (nivel 91) y se estructura en cuatro ejes. Todos los ejes usan sistemas ya definidos, sin añadir capas nuevas.

| Eje | Contenido | Recompensa | Frecuencia |
|-----|-----------|------------|-----------|
| **PvE de grupo** | Instancias T7–T10 normal y aumentada (+1 a +5) | Grabados, piezas raras, Nácar puro | Diaria y semanal |
| **Raids** | Templo de Nácar (5 jugadores, nv 135–150) y Coro del Silencio (10 jugadores, nv 150) | Piezas legendarias, cosméticos, monturas | Semanal con reinicio el lunes |
| **PvP** | Arenas 1v1 y 3v3, zonas PvP, guerras de gremio | Set PvP, títulos, cosméticos | Diaria (arenas) y semanal (guerras) |
| **Mundo vivo** | Jefe mundial Kallpa, eventos de ruta, temporadas | Sellos, cosméticos de temporada, estado del mundo | Semanal y por temporada |

### 6.1 Nivel de Resonancia (post-150)

Al llegar a 150 se desbloquea el **Nivel de Resonancia** (RS):

- RS 1–50, se sube con XP de endgame (no con XP de criaturas comunes).
- Cada RS otorga 1 punto para una de cuatro pistas: Poder, Defensa, Utilidad o Fortuna.
- **No desbloquea habilidades nuevas**; solo ajusta estadísticas y comodidad (velocidad de recolección, tamaño de bolsa de botín).
- Se reinicia parcialmente cada temporada (se conserva el 50 %), para que la brecha entre veteranos y nuevos no crezca sin límite.

### 6.2 Mazmorras aumentadas

| Nivel | Modificador | Recompensa |
|-------|-------------|------------|
| +1 | +10 % Vida enemiga | +10 % Cobre |
| +2 | +20 % Vida y daño | +20 % y 1 grabado garantizado |
| +3 | Enemigos con un estado extra (Quemadura, Corrosión o Zumbido) | +35 % y 2 grabados |
| +4 | Sin checkpoints intermedios | +55 % y pieza rara garantizada |
| +5 | Límite de tiempo 20 min | +80 %, pieza rara y probabilidad de legendario |

Las cinco dificultades se desbloquean por tramo y se reinician cada semana (ver [12-events.md](12-events.md) §4).

## 7. Progresión horizontal

Además del nivel, cinco pistas que no otorgan poder directo:

| Pista | Qué es | Recompensa |
|-------|--------|-----------|
| **Colección de atuendos** | Sets cosméticos por zona, facción y temporada | Títulos y variantes de color |
| **Bestiario** | Registrar cada familia y variante derrotada | Datos visibles, 1 % de daño extra contra esa familia (acumulativo por tramo, cap 3 %) |
| **Cazador de jefes** | Derrotar cada jefe de tramo en dificultad aumentada | Montura cosmética |
| **Crafteo legendario** | Cadena larga por tramo, con materiales de temporada | Pieza legendaria artesanal |
| **Logros** | 120 logros iniciales (movimiento, social, economía, exploración) | Sello y cosméticos |

## 8. Implementación

```gdscript
# src/domain/progression/xp_curve.gd  (extracto, puro, sin nodos)
class_name XpCurve

const NIVEL_MAX := 150

static func xp_para_subir(nivel: int) -> int:
    return int(round(40.0 * nivel * nivel + 25.0 * nivel))

static func xp_acumulada(hasta_nivel: int) -> int:
    var total := 0
    for nivel in range(1, hasta_nivel):
        total += xp_para_subir(nivel)
    return total

static func xp_criatura(nivel_criatura: int, tipo: String) -> int:
    var base := 0.012 * float(xp_para_subir(nivel_criatura))
    match tipo:
        "comun":    return int(round(base))
        "elite":    return int(round(base * 3.0))
        "minijefe": return int(round(base * 8.0))
        "jefe":     return int(round(base * 25.0))
    return int(round(base))
```

Reglas de servidor:

- La XP la otorga **solo el servidor**, a partir de la contribución registrada ([03-combat.md](03-combat.md) §9.5).
- El cliente nunca calcula el nivel: recibe `level_up` con el total y muestra la animación.
- `progression_save` guarda: nivel, XP acumulada, puntos libres, talentos, reputación y pozo de Lumbre de Descanso. Los tests de dominio verifican que la XP acumulada nunca exceda la curva y que el total a 150 sea el documentado.
