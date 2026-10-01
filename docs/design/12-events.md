# 12 — Eventos diarios, semanales, mensuales y de temporada

> Depende de: [04-world.md](04-world.md) §8, [06-progression.md](06-progression.md), [10-monetization.md](10-monetization.md) · Afecta a: [08-ui-ux.md](08-ui-ux.md) §3.6
> Implementación: `src/data/events/*.tres` (definiciones), `src/systems/event_scheduler.gd` (servidor), `src/ui/events/` (calendario). El horario se calcula **solo en el servidor**; el cliente solo muestra.

## 1. Principios

1. **El evento es el motor de la sesión corta**: entrar 15 min debe alcanzar para completar al menos un evento.
2. **Nada de "si no entras, perdiste para siempre"**: las recompensas únicas rotan cada 6–12 meses; lo demás es progreso normal.
3. **Todo evento es cooperativo por defecto** (P2): se participa sin grupo y se cobra por contribución.
4. **Los horarios son predecibles**: el jugador planifica su día; nada de eventos sorpresa aleatorios.
5. **Las recompensas son cosméticas, de economía o de progresión**, nunca poder exclusivo.

### 1.1 Horarios y husos

| Regla | Valor |
|-------|-------|
| Zona horaria del servidor | UTC |
| Reinicio diario | 04:00 UTC (00:00 en Chile continental, 21:00 del día anterior en CDMX) |
| Reinicio semanal | Lunes 04:00 UTC |
| Reinicio de temporada | Cada 8 semanas, lunes 04:00 UTC |
| Visualización | El cliente convierte a la hora local del dispositivo y muestra "en 2 h 15 min" |
| Franjas de eventos mundiales | 3 franjas fijas: 16:00, 21:00 y 01:00 UTC (cubren Europa tarde, Latinoamérica tarde y Asia) |

## 2. Eventos diarios

| Evento | Horario | Formato | Duración | Qué se hace | Recompensa |
|--------|---------|---------|----------|-------------|-----------|
| **Encargos diarios** (3) | Desde el reinicio | Individual | ~15 min c/u | Misiones del Tablón en la zona activa del jugador | Cobre ×3, Sellos de Ruta, 1 objeto | 
| **Primer objetivo del día** | Cualquiera | Individual | 1 acción | Completar 1 encargo o 1 evento público | 10 Lumbre + 100 % XP durante 30 min |
| **Cacería del día** | Todo el día | Individual/grupo | 20 min | Derrotar 5 criaturas de una familia rotativa (+1 élite) | Cobre ×2, 1 material raro, probabilidad de grabado |
| **Veta de Lumbre** | Todo el día | Público | 20 min | Recolectar en un nodo rotativo de la zona del tramo | Nácar bruto, 10 Lumbre al completar 5 nodos, +50 % recolección |
| **Hora oscura** | 20:00–23:00 local | Mundo | 3 h | Noche alta: +15 % spawns, +10 % recursos raros, +25 % Umbríos | Botín mejorado, riesgo mayor |
| **Arena diaria** | Desde el reinicio | PvP | ~10 min | 3 combates 1v1 o 3v3 | Sellos, Cobre, cosmético de temporada a los 15 días acumulados |
| **Encender ruta** | Cada 6 h por zona | Público | 10 min | Entregar Nácar bruto en 3 puntos y defender oleadas | Cobre, Sellos, 20 % de Nácar bruto, estado de ruta (`encendida` 24 h) |
| **Defensa del bastión** | 1 vez al día en el hub del tramo | Público | 12 min | Oleadas de criaturas de la zona contra el bastión | Cobre, Sellos, reputación con la facción local |

Los eventos públicos diarios usan un **calendario visible** en la pantalla de eventos y un aviso 3 minutos antes en el chat de zona.

## 3. Eventos semanales

| Evento | Cuándo | Formato | Contenido | Recompensa |
|--------|--------|---------|-----------|-----------|
| **Raid semanal** | Reinicio del lunes | Party 5 o 10 | Templo de Nácar (5) o Coro del Silencio (10) | Piezas legendarias, cosmético, 40 Lumbre |
| **Asedio del Salar** | Miércoles, sábado y domingo en las 3 franjas | Mundo (20–60) | Jefe mundial **Kallpa el Que Calla** en oleadas | Sellos, Nácar puro, cosmético de temporada, estado del mundo |
| **Cordillera abierta** | Lunes a jueves | Público PvP | Cordillera Vidriada con +50 % mineral y PvP siempre activo en el anillo alto | Materiales T6, títulos PvP |
| **Feria de Yatiri** | Viernes a domingo | Público | Yatiri aparece en 3 hubs con stock raro (recetas, grabados, cosméticos de temporada) a precio variable | Compras con Cobre y Sellos (nunca Lumbre) |
| **Semana de facción** | Rotativa semanal | Individual | Reputación ×1,5 con una facción y sellos ×1,5 en sus encargos | Sellos, recetas de facción |
| **Cacería de élites** | Sábado y domingo | Público | Élites reaparecen 40 % más rápido y dan +25 % botín | Materiales raros, grabados |
| **Guerras de gremio** | Ventana de 48 h, sábado 20:00 UTC | Gremio | Declaración con 24 h de aviso, control de nodos en zonas PvP | Sellos de gremio, estandarte, puntos de gremio |
| **Mazmorras aumentadas destacadas** | Rotativa semanal (2 instancias) | Party 3–5 | +100 % de recompensa en 2 instancias concretas (dificultad +1 a +5) | Grabados, piezas raras, Cobre |

## 4. Eventos mensuales y de temporada

| Evento | Frecuencia | Contenido | Recompensa |
|--------|-----------|-----------|-----------|
| **Temporada de ruta** | Cada 8 semanas | Estado global del mundo, progresión de rutas, cosméticos de temporada | Pase de Ruta (gratis y premium), 100 Lumbre por hitos |
| **Eco de temporada** | Última semana de temporada | Variante de una zona (clima, enemigos, recetas) | Cosmético exclusivo de temporada (vuelve cada 12 meses) |
| **Raid rotativa** | Cada temporada | Coro del Silencio con mecánicas nuevas | Legendario y montura |
| **Doble Lumbre** | 1 fin de semana al mes | +100 % Lumbre gratuita de eventos diarios | Lumbre |
| **Aniversario / festival** | 1 vez al año | Zona decorada, eventos cada 2 h, cosméticos de aniversario | Cosmético conmemorativo (vuelve cada año) |

## 5. Formatos de evento y reglas de contribución

| Formato | Participación | Cobro de recompensa |
|---------|---------------|---------------------|
| **Individual** | Cualquiera | Al completar el objetivo |
| **Público** | Cualquiera en la zona; sin grupo | Por contribución ≥ 10 % ([03-combat.md](03-combat.md) §9.5) |
| **Party** | Grupo de hasta 5 | Reparto según modo de loot de la party |
| **Gremio** | Miembros del gremio | Puntos de gremio + recompensa personal |
| **Mundo** | Todos los del servidor en la zona | Contribución escalonada por umbrales (bronce/plata/oro) |
| **Facción** | Reputación con la facción convocante | Sellos y reputación |

**Anti-abuso:**

- La contribución caduca si el jugador no realiza ninguna acción válida en 90 s (expulsa al AFK).
- Los eventos públicos tienen un tope de recompensa por cuenta y día (evita cadenas infinitas de bots).
- Los eventos de facción no otorgan reputación por acciones repetidas por encima de 3 veces al día.
- Los jefes mundiales usan ventana de contribución: si el jugador se une con el jefe por debajo del 20 % de Vida, cobra recompensa reducida (30 %).

## 6. Calendario en el cliente

La pantalla de eventos (ver [08-ui-ux.md](08-ui-ux.md) §3.6) muestra:

```
┌ EVENTOS · Hoy (hora local) ────────────────────────────── [Filtrar: Todos ▾] ┐
│ AHORA  ● Encender ruta · Prado de Senda · 6 min restantes     [Ir]           │
│ 12:00  ○ Defensa del bastión · Bastión de Candela · en 1 h 20 m              │
│ 18:00  ○ Cacería de élites · Bosque del Reverso · en 7 h 20 m                │
│ DÍA    ○ Cacería del día (2/5) · Veta de Lumbre (1/5)                        │
│ SEMANA ○ Raid semanal (0/1) · Asedio del Salar (1/3) · Feria de Yatiri       │
│ TEMPORADA ▸ Pase de Ruta · nivel 14 · 3 semanas restantes                    │
└──────────────────────────────────────────────────────────────────────────────┘
```

- Botón "Recordarme" con notificación local (opt-in) 10 min antes del evento elegido.
- Los eventos futuros muestran la recompensa principal sin ambigüedad.
- Si el jugador no puede asistir a una franja, la mayoría de los eventos tiene 2–3 franjas alternas a la semana (excepto jefes mundiales, que tienen 3).

## 7. Implementación

```gdscript
# src/data/events/event_definition.gd  (recurso, datos sin lógica)
@tool
class_name EventDefinition
extends Resource

@export var id: StringName
@export var nombre: String
@export_enum("diario", "semanal", "mensual", "temporada") var cadencia: String = "diario"
@export var formato: StringName          # individual | publico | party | gremio | mundo | faccion
@export var zona_id: StringName          # vacío = rotativa
@export var hora_utc: PackedInt32Array   # franjas en las que abre
@export var duracion_min: int = 15
@export var contribucion_minima: float = 0.10
@export var recompensas: Array[RewardDefinition]
@export var limite_diario_por_cuenta: int = 3
```

Reglas de servidor:

- El `EventScheduler` corre en el servidor autoritativo, no en el cliente; el cliente nunca decide si un evento está activo.
- El estado de los eventos se replica compacto (máx. 32 eventos activos × 8 bytes) y se actualiza cada 5 s.
- Cada evento guarda progreso por jugador (`event_progress` en el save): contador diario, semanal y de temporada.
- Los eventos de temporada escriben un registro al cerrar (`season_archive`), que es la entrada del siguiente ciclo ([04-world.md](04-world.md) §8).
- Los tests deben cubrir: reinicio diario/semanal, cambio de horario de verano (el servidor trabaja en UTC, el cliente solo convierte), y que un evento no otorgue recompensa dos veces por el mismo `event_id` + periodo.
