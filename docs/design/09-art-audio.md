# 09 — Dirección de arte y audio

> Depende de: [01-lore.md](01-lore.md), [04-world.md](04-world.md) · Afecta a: [08-ui-ux.md](08-ui-ux.md), [11-mvp-scope.md](11-mvp-scope.md)
> Cumple: ADR-008 (política de assets) y `docs/05-assets-licenses.md`. Todo asset nuevo se registra en `CREDITS.md`.

## 1. Identidad visual

Pixel art top-down con lectura inmediata en pantalla de 5–7": formas grandes, contraste alto entre personaje/entorno/peligro y detalles que solo aparecen al acercar la mirada. La fantasía es luminosa de raíz andina: sal, cobre, jade, cielo nocturno, brasa y nácar opalescente.

**Los tres colores que el jugador debe reconocer siempre, en cualquier bioma:**

| Rol | Color | Hex | Uso |
|-----|-------|-----|-----|
| Interacción / recompensa | Lumbre | `#F6C65B` | Objetos recogibles, NPC relevante, ruta encendida, recompensa |
| Peligro | Coral | `#D95A4F` | Telegraphs de daño, enemigo agresivo, Vida baja |
| Aliado / apoyo | Cian mineral | `#4FA8C7` | Jugadores de party, curación, escudo |

### 1.1 Resoluciones

| Elemento | Resolución lógica | Escala de pantalla | Notas |
|----------|-------------------|--------------------|-------|
| Tile de terreno | 32×32 px | ×2 (64 px en pantalla) | Master a 2× para nitidez; filtro `nearest` |
| Props | 32×32 a 64×64 | ×2 | Sin rotaciones no enteras |
| Personaje jugable | 32×48 px | ×2 | Pivote en los pies (16, 44) |
| Criatura común | 24×24 a 48×48 | ×2 | Silueta única por familia |
| Jefe | 64×64 a 128×128 | ×2 | Puede ocupar 2×2 o 4×4 celdas |
| Icono de objeto/habilidad | 24×24 px | ×2 | Legible a 48 px, sin texto dentro |
| Retrato de NPC | 64×64 px | ×2 | Solo en diálogo |
| UI (9-slice) | 8×8 px de borde | ×1–2 | Escala `nine_patch_stretch` |
| Fuente | 8×12 px base | ×2 | Bitmap o `Label` con fuente pixel y escalado entero |

**Regla de nitidez:** nunca escalar a factores no enteros. Si el dispositivo exige un factor raro, se prefiere el entero más cercano y se acepta un borde muerto.

### 1.2 Animaciones por actor

| Animación | Frames | FPS | Notas |
|-----------|--------|-----|-------|
| Idle | 4 | 6 | Respiración sutil, obligatoria |
| Caminar | 6 | 10 | 4 direcciones (arriba, abajo, izquierda, derecha); diagonales reutilizan |
| Atacar | 5 | 12 | Anticipación 2, impacto 1, recuperación 2 (lee bien en móvil) |
| Habilidad | 6–8 | 12 | Reutilizable entre habilidades de la misma clase |
| Recibir daño | 2 | 12 | Flash blanco + retroceso 2 px |
| Morir | 6 | 8 | Sin gore; se disuelve en partículas de lumbre |
| Recolectar | 4 | 8 | Se reutiliza para crafteo y entrega |

Los **5 arquetipos** se distinguen por silueta y por color de acento: Bastión `#D9622B` · Hiladora `#6FD3C7` · Lector `#7C6BE0` · Cantor `#63B36A` · Forjador `#E8C34A`.

### 1.3 Paleta general

| Uso | Color guía | Intención |
|-----|-----------|-----------|
| Lumbre principal | `#F6C65B` | Energía, recompensa, navegación |
| Cielo / bruma | `#22304A` | Profundidad, interfaz nocturna |
| Azul mineral | `#3F7EA6` | Agua, rutas, información |
| Verde musgo | `#5E8A62` | Bosque, recursos naturales |
| Coral de peligro | `#D95A4F` | Daño, amenaza, alertas |
| Marfil de lectura | `#F5EBDD` | Texto principal, brillos |
| Tinta | `#151A24` | Contornos, paneles, sombras |
| Nácar | `#E8D8F0` | Material mágico, templos, endgame |

### 1.4 Paletas por tramo

Cada tramo tiene una paleta secundaria propia; el color de interacción siempre es Lumbre `#F6C65B` y el de peligro siempre Coral `#D95A4F`, sin importar el bioma (regla de P1).

| Tramo | Tema | Colores dominantes | Material de set |
|-------|------|--------------------|-----------------|
| T1 | Cobre y terraza | `#B87333`, `#5E8A62`, `#F5EBDD` | Cobre mate con cuero claro |
| T2 | Junco y barro | `#6B7A4A`, `#4A3B2A`, `#8FA36B` | Junco trenzado, bronce |
| T3 | Aguja y escoria | `#7A8794`, `#D9622B`, `#2E3B4A` | Acero picado con vetas naranjas |
| T4 | Sal y marisma | `#B9C7C6`, `#3F7EA6`, `#6E5A3E` | Tela encerada, sal cristalizada |
| T5 | Quipu y archivo | `#C9A227`, `#7C6BE0`, `#3E3A44` | Hilo dorado, tinta violeta |
| T6 | Vidrio y nieve | `#A8E6E2`, `#FFFFFF`, `#4C5B7A` | Cristal translúcido, piel de cóndor |
| T7 | Sal blanca y silencio | `#EDEDE6`, `#9AA0A6`, `#22304A` | Sal pulida, tela sin color |
| T8 | Eco y nácar | `#E8D8F0`, `#6B4E8A`, `#2A2F45` | Nácar, cuarzo resonante |
| T9 | Ascua y aurora | `#FF8A3D`, `#8B2E45`, `#2C1B33` | Ascua sólida, metal al rojo |
| T10 | Nácar primigenio | `#F2E6FF`, `#C9A227`, `#1B1430` | Nácar iridiscente, oro antiguo |

## 2. Assets necesarios por fase

Solo CC0 al inicio, con la excepción documentada de LPC (CC-BY-SA/GPL) si se acepta su licencia. Nada de arte propietario de terceros.

### Fase 1 (MVP, T1) — objetivo: 0 $ y 0 dependencias externas

| Categoría | Cantidad | Fuente sugerida (licencia) | Nota |
|-----------|----------|----------------------------|------|
| Terreno T1 (hierba, tierra, agua, piedra, camino) | 40–60 tiles 32×32 | **Kenney** *Tiny Town / Roguelike* (CC0) o arte geométrico propio (ADR-009) | Ya hay placeholders propios en uso |
| Props T1 (árboles, rocas, vallas, faroles, cofres) | 25–35 | Kenney *Roguelike/RPG Pack* (CC0) | Se reemplazan por arte propio después |
| Personaje (3 clases) | 3 × 7 animaciones | Kenney *Tiny Dungeon* (CC0) o LPC (CC-BY-SA 3.0) | LPC requiere crédito y share-alike por asset |
| Criaturas T1 | 5 familias × 4 variantes | Kenney *Roguelike* (CC0), OpenGameArt (verificar cada una) | Variante = recolor + escala |
| Jefe T1 | 1 (2×2) | Kenney *Roguelike* boss o propio | Debe leerse a 128 px |
| Iconos de objeto/habilidad | 60–80 (24×24) | **Kenney** *Game Icons* (CC0) + **game-icons.net** (CC-BY 3.0, requiere crédito) | Registrar autoría en `CREDITS.md` |
| UI (paneles, botones, barras) | 1 tema completo | Kenney *UI Pack* (CC0) | 9-slice |
| VFX | 12 (golpe, curación, escudo, quemadura, raíz, eco, nivel) | Kenney *Particle Pack* (CC0) o partículas propias | Formas simples, sin texturas grandes |
| Sonido | 30 SFX + 3 pistas | Kenney *Audio* (CC0), **OpenGameArt** (verificar), itch.io (verificar) | Ver §4 |

### Fase 2 (vertical slice, T1–T2)

- Tiles y props de T2 (jungle/río/ruinas): +80 assets.
- 4.ª clase y su set de animaciones.
- 11 familias de criaturas restantes (variantes incluidas).
- Bestiario, retratos de 8 NPCs y escudos de facción.
- Set de UI de mercado, gremio y eventos.
- 8 pistas musicales (una por zona/hub).

### Fase 3 (v1.0, T1–T7)

- Tiles y props de T3–T7: +350 assets.
- 5.ª clase, monturas (3), mascotas (3).
- 10 jefes de tramo con animaciones propias.
- Ilustraciones de carga por tramo (7) y arte de tienda.
- 14 pistas musicales + 90 SFX.

### Fase 4 (v1.1–v1.3, T8–T10)

- Tiles de T8–T10: +250 assets.
- Sets de armadura con variantes visuales por tramo (6 ranuras × 10 tramos × 5 clases, reutilizando base + cambios de material/color).
- 4 jefes de raid, 1 mundial de temporada, 2 arenas.
- 10 pistas + 60 SFX adicionales.

**Presupuesto de reemplazo:** en cada fase se sustituye primero lo que más se ve (suelo, personaje, criaturas comunes) y se deja para el final lo que menos se ve (props raros, iconos secundarios). El juego debe seguir siendo legible si el 100 % del arte es placeholder.

### 2.1 Cómo se ven los sets de equipo

- Cada pieza cambia un **bloque de color grande** del sprite (hombros, torso, piernas, arma), no píxeles sueltos.
- Material del tramo (tinte) + silueta de clase (forma): se pueden combinar 10 tintes × 5 siluetas con el mismo set de animaciones.
- El set completo (6 piezas) añade un detalle distintivo: aura sutil, brillo del arma o borde del hombro.
- Los cosméticos de tienda reutilizan la misma base con materiales, patrones y accesorios nuevos; nunca cambian la lectura del rol (P1).

## 3. Estilo de UI

- Paneles con borde de 2 px y esquina biselada; superficie tinta `#151A24` al 92 % de opacidad.
- Tipografía pixel de 8×12 con escalado entero; jerarquía por tamaño y color, no por negrita.
- Estados siempre con forma + color (nunca solo color): escudo (línea punteada), Quemadura (llama), Raíz (raíz), Silencio (círculo tachado).
- Iconos simples, sin texto incrustado, legibles a 48 px.
- Animaciones de UI: 0,12–0,25 s, curva `ease-out`; ningún destello por encima de 3 Hz.

## 4. Dirección de sonido

### 4.1 Música (una pista por zona, 60–90 s en loop)

| Tramo | Instrumentación | Sensación |
|-------|-----------------|-----------|
| T1 Cuenca de Candela | Quena, charango, percusión suave | Hogar, calidez, primera aventura |
| T2 Reverso Húmedo | Flautas graves, cuerdas pulsadas, agua | Inquietud, naturaleza densa |
| T3 Las Agujas | Percusión metálica, cuerdas tensas | Trabajo, presión, profundidad |
| T4 Costa de Umbral | Cuerdas largas, tambores lentos, gaviotas | Melancolía, comercio, niebla |
| T5 Tierras Quipu | Campanas suaves, coros lejanos | Memoria, misterio, respeto |
| T6 Cordillera Vidriada | Vientos agudos, cristales percutidos | Frío, altitud, riesgo |
| T7 El Salar | Silencio con drones graves y latidos | Soledad, amenaza, escala |
| T8 Profundidades | Coros procesados, ecos reversos | Descenso, revelación |
| T9 Aurora Quemada | Cuerdas ardientes, percusión rápida | Crisis, decisión, clímax |
| T10 Nácar Primigenio | Coro completo, tema principal en modo mayor | Resolución épica |
| Combate | Capa percusiva sobre la pista de zona | Se mezcla por capas sin cortar |
| Jefe | Tema propio de 90 s con transición por fase | Cambia de fase en el mismo tono |

### 4.2 SFX (mínimos)

| Grupo | Cantidad | Ejemplos |
|-------|----------|----------|
| Combate | 20 | Golpe físico, golpe resonante, crítico, golpe bloqueado, muerte de criatura, muerte de jefe |
| Habilidades | 25 | 5 por clase (una por habilidad) |
| Estados | 10 | Aplicar/expirar Quemadura, Raíz, Escudo, Silencio, Olvido |
| UI | 12 | Toque, abrir/cerrar panel, error, compra, subir de nivel, logro |
| Mundo | 15 | Recoger, craftear, puerta, ruta encendida, campana, agua |
| Ambiente | 10 | Bucle por bioma (viento, agua, bosque, mina) |

**Reglas de audio:**

- El combate es la prioridad: máximo 3 capas simultáneas por evento (evita saturación en el altavoz del teléfono).
- Nada de SFX más largo de 1,5 s salvo jingles de nivel/logro (máx. 2,5 s).
- Frecuencia de muestreo 44,1 kHz mono para SFX, estéreo solo en música; formato OGG (Vorbis) para música y WAV corto para SFX.
- Mezcla: música −12 dB por defecto bajo SFX; opciones separadas para música, SFX, ambiente y vibración.
- Todos los assets CC0 o con licencia verificada; se registran autor, URL, licencia y fecha en `CREDITS.md` (ADR-008).

## 5. Pipeline

| Etapa | Herramienta | Regla |
|-------|-------------|-------|
| Pixel art | Aseprite (licencia del dev) o alternativa libre | Exportar PNG con escala 1×, sin antialias |
| Importación | Godot | Filtro `nearest`, sin compresión destructiva, `2d_pixel_snap` cuando aplique |
| Animación | `AnimatedSprite2D` o `AnimationPlayer` | Un `SpriteFrames` por actor, nombrado por animación |
| Tilemaps | `TileMapLayer` | Un layer por tipo (suelo, prop, colisión) |
| Atlas | `TexturePacker`/manual | Máx. 2048×2048 para gama media; no fragmentar en cientos de texturas |
| Revisión | Captura en dispositivo real | Se valida legibilidad a 5" antes de aprobar un asset |

**Criterio de aceptación de asset:** legible a 5", paleta dentro del tramo, sin violar ADR-008, registrado en `CREDITS.md` y medido en el presupuesto de memoria de texturas (≤ 64 MB en gama media).
