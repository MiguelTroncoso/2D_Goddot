# 08 — UI, UX y controles táctiles

> Depende de: [00-vision.md](00-vision.md) P1, [02-classes.md](02-classes.md) §1, [07-social.md](07-social.md) · Afecta a: [09-art-audio.md](09-art-audio.md), [11-mvp-scope.md](11-mvp-scope.md)
> Implementación: `src/ui/` (nodos `Control`), tema en `src/ui/theme/`, autoload `UIManager`. La UI nunca modifica estado de juego: solo emite intenciones (ADR-005).

## 1. Decisión de orientación: **horizontal (landscape)**

Se elige horizontal, no vertical, por cinco razones concretas:

1. **El juego es top-down y necesita conciencia lateral**: ver 360° alrededor del personaje en un área amplia evita emboscadas injustas, que en vertical serían la norma.
2. **Ya está configurado**: `project.godot` fija 1280×720 con `handheld/orientation = 0` (ADR-004) y la Fase 1 valida joystick + HUD en esa proporción.
3. **El pulgar izquierdo y el derecho no compiten**: joystick a la izquierda, acciones a la derecha; en vertical los botones quedan al alcance del pulgar que también controla la cámara.
4. **Los MMORPG de referencia son horizontales** (Tibia, Ragnarok, Albion): el jugador objetivo ya tiene ese músculo y espera ese layout.
5. **Rendimiento y batería**: un viewport apaisado permite canvas de UI más bajos (menos fill rate) que una columna vertical con el mismo contenido visible.

En consecuencia: **no se diseña un modo retrato**. Las pantallas de carga y los menús de cuenta sí se adaptan a ambos ejes (portada, login, ajustes), pero el juego es horizontal.

### 1.1 Resoluciones y escalado

| Aspecto | Valor |
|---------|-------|
| Resolución base | 1280×720 (`canvas_items`, `expand`) |
| Relación soportada | 16:9 a 21:9 (sin recortar contenido crítico) |
| Escala de UI | 0,85 / 1,00 / 1,15 (automática por tamaño de pantalla + ajuste manual) |
| Objetivo táctil mínimo | 48 dp (≈ 96 px a 2×) |
| Safe area | Todos los controles dentro de `DisplayServer.get_display_safe_area()`, con margen extra de 8 px |
| Fuente base | 16 px del tema (≈ 24 px renderizado), mínimo 14 px en etiquetas secundarias |
| Texto máximo por línea | 24–28 caracteres en etiquetas de botón |

## 2. HUD (wireframe)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ [avatar][Vida 1.240/1.240 ██████████░][Reserva 118/150 ████░░]   [⛃ 12.480]  │  ← barra superior
│ [buffs: 3 iconos 16×16]                    [minimapa 120×120] [☰] [🎒] [👥]   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   [OBJETIVO: Mordeluz resonante · Nv 12 · Vida ████░░]                       │
│                          ·  mundo  ·                                         │
│             ▲[nombre aliado][Vida ████░]                                     │
│                                                  ╭──────────────────────╮    │
│                                                  │        ⚔ BÁSICO      │    │
│                                                  │  H1   H2   H3        │    │
│                                                  │  H4   ULT (carga)    │    │
│                                                  ╰──────────────────────╯    │
│  ╭─────────────╮                                                             │
│  │ ⋯ joystick  │      [💬 chat 3 líneas]                                    │
│  ╰─────────────╯                                                             │
└──────────────────────────────────────────────────────────────────────────────┘
```

Reglas del HUD:

- **Arriba:** Vida, Reserva, Cobre, buffs/debuffs (máx. 8 iconos visibles), minimapa, menú.
- **Abajo izquierda:** joystick dinámico (aparece donde toques) con zona muerta de 0,2 y radio de 120 px.
- **Abajo derecha:** 4 botones de acción en arco + básico (acción automática opcional) + definitiva con anillo de carga.
- **Centro:** objetivo actual con barra de Vida y 2 líneas de debuffs; nombres solo de jugadores, NPC relevantes y objetivo.
- **Abajo centro:** 3 líneas de chat con autoscroll y desvanecido a los 8 s.
- Todo elemento del HUD es **ocultable** desde ajustes (modo limpio para capturas y para dispositivos pequeños).

## 3. Pantallas (wireframes textuales)

### 3.1 Inventario y equipamiento

```
┌ INVENTARIO   [Equipo] [Mochila] [Banco] ─────────── [⛃ 12.480] [🔷 42] ──────┐
│ ┌─── Personaje ───┐  ┌─── Mochila 6×5 = 30 ────────────────────────────┐    │
│ │ (silueta)       │  │ [Pan de brasa ×12] [Poción savia ×5] [Nácar ×8] │    │
│ │ Arma: Martillo  │  │ [Fibra ×20] [Cuero ×6] [Mineral ×14] ...        │    │
│ │ Cabeza: Yelmo   │  │                                                  │    │
│ │ Pecho: Peto     │  │                                                  │    │
│ │ Piernas: Grebas │  └──────────────────────────────────────────────────┘    │
│ │ Pies: Botas     │  ┌── Ficha del objeto seleccionado ────────────────┐     │
│ │ Accesorio: Sello│  │ Peto de Yunque · fino · nv 5                   │     │
│ └─────────────────┘  │ +8 VIG · +6 DEF                                │     │
│ [Oro] [Peso 42/120]  │ Set: Yunque de Cobre (4/6)                     │     │
│                      │ [Equipar] [Comparar] [Desmantelar] [Vender]     │     │
└────────────────────────────────────────────────────────────────────────────┘
```

- Comparación automática con lo equipado (`+2 DEF, −1 VIG` en verde/rojo).
- Toque largo = tooltip con la descripción completa y la fuente.
- Acciones por objeto: equipar, comparar, desmantelar, vender, marcar como favorito (bloquea venta).
- Filtros por tipo, rareza y nivel; buscador con teclado nativo.

### 3.2 Party

```
┌ PARTY (3/5) ─────────────────────────────── [Invitar] [Pings] [Salir] ──────┐
│ ● Nara        Lv 14  Bastión   Vida ████████░░  120/140   [🔊][📍]          │
│ ● Tarek       Lv 12  Cantor    Vida █████░░░░░   78/120   [🔊][📍]          │
│ ○ Yatiri      Lv 13  Forjador  Vida ████████░░  110/130   (desconectado)    │
│ Modo de botín: (•) Contribución  ( ) Libre  ( ) Asignación                  │
│ Objetivo marcado: Mordeluz resonante alfa                                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Chat

```
┌ CHAT ───────────────────────────────────────────────────────────────────────┐
│ [Zona][Global][Party][Gremio][Susurro][Mercado]           [🔍][⚙][✕]        │
│ 12:04 Nara: ¿Alguien para el eco?                                          │
│ 12:04 Tarek: Voy, dame 2 min                                               │
│ 12:05 [Sistema] Evento: Encender ruta (Prado de Senda) en 3 min             │
│ ─────────────────────────────────────────────────────────────────────────── │
│ [ Mensaje rápido ▾ ]  [ escribir... ]                            [Enviar]   │
└─────────────────────────────────────────────────────────────────────────────┘
```

- Máximo 3 líneas visibles en el HUD; 12 en la ventana completa.
- Mensajes rápidos como chips (Ayuda, Jefe, Voy, No puedo, Gracias, Buena caza).
- Toque largo en un mensaje: responder en susurro, ignorar, reportar.

### 3.4 Árbol de talentos

```
┌ TALENTOS · Bastión de Brasa · puntos 12/12 ────── [Reespecializar: 500⛃] ───┐
│   YUNQUE (7 gastados)      ESCORIA (5)          CORAZÓN DE FRAGUA (0)       │
│   [1 Piel de escoria ✓]    [1 Brasa viva ✓]     [1 Pulso lento]             │
│   [2 Postura firme ✓]      [2 Escoria densa ✓]  [2 Aliento]                 │
│   [3 Eco del golpe ✓]      [3 Pulso amplio ✓]   [3 Foco]                    │
│   [4 Guardia baja ✓]       [4 Quemar fuerte]    [4 Recuperar]               │
│   [5 Provocación ▸]        [5 Onda doble]       [5 Corazón]                 │
│   [6][7][8][9][★ Capstone]                                                  │
│ ── Resumen: +10 % Vida · +18 % escudo · Provocar 3 s                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

- Vista de 3 columnas; nodos bloqueados en gris con su requisito.
- Se puede tocar un nodo para ver el detalle y previsualizar el total resultante.
- Botón de reespecialización con confirmación y precio visible.

### 3.5 Mapa

```
┌ MAPA · Cuenca de Candela ──────────────────────────── [Tramo: T1 (1–15)] ───┐
│  ⛺ Bastión de Candela (hub)   ███████████████████  [Nivel 1–6]             │
│  🌾 Prado de Senda             ████████████████     [Nivel 3–10]  Nodo ◉   │
│  🌳 Bosque del Reverso         ███████████████      [Nivel 9–15]  Nodo ◍   │
│  🕳 Cueva del Eco              ███████              [Nivel 8–15]  (3/3)    │
│ ── Leyenda: ◉ ruta encendida · ◍ tenue · ○ apagada · ✖ corrompida          │
│ ── Marcadores de party: [📍 jefe] [📍 reunión] [📍 ayuda]                   │
│ ── Leyenda de criaturas registradas (Bestiario)                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

- El mapa muestra el estado de las rutas en tiempo real (P3) y marca los eventos activos con un icono pulsante.
- Zoom por pellizco (2 niveles: región y tramo) y desplazamiento con arrastre.
- Al tocar una zona se ve: nivel recomendado, nivel de ruta, jefe, recursos y si hay jugadores de la party allí.

### 3.6 Otras pantallas (resumen)

| Pantalla | Contenido | Nota de diseño |
|----------|-----------|----------------|
| **Habilidades** | 7 ranuras, coste, CD, rango y estados aplicados | Cada habilidad muestra su interacción con estados ([03-combat.md](03-combat.md) §5) |
| **Crafteo** | Recetas por rama y tier, materiales, tarifa y resultado | Botón "repetir" para tandas |
| **Mercado** | Buscador, filtros, precio sugerido, historial, listados propios | Requiere nivel 10 |
| **Banco** | 60 ranuras iniciales (ampliables), búsqueda, ordenar | Compartido por cuenta (no por personaje) |
| **Gremio** | Miembros, roles, banco, log, guerras, estandarte | Estandarte dibujado por el jugador con piezas |
| **Eventos** | Calendario diario/semanal, hora local del servidor, recompensas | Ver [12-events.md](12-events.md) |
| **Tienda** | Pestañas: destacados, cosméticos, monturas, mascotas, consumibles de conveniencia, Lumbre | Nunca muestra nada de poder (ver [13-shop.md](13-shop.md)) |
| **Ajustes** | Gráficos, audio, controles, escala de UI, chat, accesibilidad | Presets: batería / equilibrado / calidad |

## 4. Controles táctiles

| Control | Zona | Comportamiento |
|---------|------|----------------|
| **Joystick** | Mitad izquierda | Dinámico (aparece bajo el pulgar), zona muerta 0,2, radio 120 px; deslizar fuera cancela |
| **Ataque básico** | Botón principal derecho (110 px) | Mantener = ataque continuo; doble toque = fijar objetivo |
| **Habilidades** | 4 botones en arco (88 px) | Arrastrar sobre un botón = apuntar manualmente hacia esa dirección |
| **Definitiva** | Botón superior derecho (110 px) | Anillo de carga; se ilumina cuando está lista |
| **Tap en el mundo** | Centro | Fijar objetivo; tap en NPC = interactuar; tap en el suelo = mover (opcional, desactivado por defecto) |
| **Toque largo** | Cualquier objeto | Tooltip / menú contextual |
| **Pellizco** | Mapa y mundo | Zoom (2 niveles en el mundo: 1× y 1,25×) |
| **Deslizar desde el borde izquierdo** | Borde | Menú rápido (personaje, inventario, habilidades, ajustes) |
| **Botón de chat rápido** | Bajo el chat | Chips de mensajes rápidos y pings |

### 4.1 Asistencia de apuntado

Como el aim manual es costoso en móvil:

- Las habilidades direccionales apuntan al objetivo fijado si está dentro de rango y cono.
- Si no hay objetivo, apuntan a la dirección del joystick en el momento del toque.
- El asistente **nunca** cambia el objetivo elegido por el jugador ni añade daño; no hay aimbot sobre jugadores (en PvP el apuntado asistido se limita a un cono de 45° y se desactiva a más de 6 casillas).

### 4.2 Accesibilidad y ergonomía

- Modo zurdo (joystick a la derecha, acciones a la izquierda).
- Escala de UI, tamaño de fuente (3 niveles), alto contraste y modo daltónico (formas + color en estados, nunca solo color).
- Sin *flash* a más de 3 Hz (riesgo fotosensible); los telegraphs usan forma además de color.
- Vibración opcional 3 niveles; por defecto solo en golpes fuertes y nivel alcanzado.
- Botones con área de toque ≥ 48 dp aunque el icono sea menor.
- Modo "una mano" para desplazamiento y combate básico (habilidades deshabilitadas con aviso, no ocultas).

## 5. Onboarding: los primeros 5 minutos

| Minuto | Qué pasa | Objetivo de diseño |
|--------|----------|--------------------|
| 0:00–0:30 | Pantalla de creación: cara, paleta, clase (3 en MVP) con un GIF de 3 s del kit y su rol | Elegir sin leer párrafos |
| 0:30–1:00 | Apareces en el Bastión de Candela; Nara te saluda y te pide seguirla | Enseñar movimiento con el joystick sin tutorial de texto |
| 1:00–1:45 | Recorrido guiado por el bastión: se recoge una Fibra, se pasa por la forja y el banco | Enseñar recolección e interacción con 3 puntos brillantes |
| 1:45–2:30 | Primer combate contra 1 Mordeluz joven; aparece la barra de Vida y el objetivo | Enseñar ataque básico y objetivo |
| 2:30–3:15 | Combate contra 3 Mordeluces jóvenes; Nara cura y explica el grupo | Enseñar la H2 recién desbloqueada (nivel 1 tiene H1; H2 a los 2 min por quest) |
| 3:15–4:00 | Se entrega la Fibra a Oren; se craftea la primera pieza y se equipa | Cerrar el bucle crafteo → equipo → poder |
| 4:00–4:45 | Se enciende el Faro de Candela con la primera entrega de Nácar | Presentar el pilar P3 (el mundo cambia) |
| 4:45–5:00 | Aparece el mapa con la ruta encendida y el Tablón de Rutas con 2 encargos | Dar el primer objetivo autónomo |

**Reglas del onboarding:**

- Ningún texto de más de 120 caracteres; sin tutorial de 20 pasos.
- Cada mecánica se enseña **usándola**, no leyéndola.
- Al minuto 5 el jugador ya tiene: 1 habilidad usada, 1 objeto crafteado, 1 enemigo derrotado y 1 ruta encendida.
- El tutorial completo se puede saltar y se puede repetir desde ajustes.
- El primer jefe de tramo está a ~4–6 h; el primer set completo, a ~3 h.

## 6. Rendimiento de UI

| Presupuesto | Valor |
|-------------|-------|
| Draw calls de UI | ≤ 40 en combate, ≤ 60 con panel abierto |
| Nodos `Control` activos | ≤ 220 en HUD de combate |
| Actualizaciones por frame | Solo Vida/Reserva/objetivo; el resto por señal (EventBus) |
| Paneles | Uno a la vez; los demás se descargan salvo caché de 1 |
| Texto | Sin `RichTextLabel` en HUD (usa `Label`); tooltips con formato simple |
| Animaciones de UI | `Tween` de 0,12–0,25 s; nada bloquea input más de 0,3 s |

Regla dura: **ningún panel de UI puede costar más de 1 ms de CPU por frame en gama media**; se mide con el perfilador en dispositivo real (ver `docs/08-android-development.md`).
