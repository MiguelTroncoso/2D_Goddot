# 00 — Visión, pilares y alcance

> Proyecto: MMORPG 2D top-down para Android · Godot 4.4 · GDScript · servidor autoritativo ENet
> Estado: propuesta de preproducción · Documento raíz de `docs/design/`
> Depende de: `docs/01-architecture.md`, `docs/decisions/002`, `004`, `005`, `006`, `008`

## 1. Pitch

**Lumbre de Nácar** es un MMORPG 2D top-down de fantasía luminosa de raíz andina, diseñado primero para Android, donde el mundo no es un fondo decorativo sino una red de **rutas de resonancia** que los jugadores encienden, reparan y desvían en conjunto. Cada sesión de 15 minutos cabe en una mano: salir de un bastión iluminado, recorrer un bioma con silueta y sonido propios, combatir con un kit corto y legible, recolectar, cooperar en un evento público sin necesidad de formar grupo antes, volver a vender, fabricar y abrir una ruta nueva. El juego es generoso con el tiempo del jugador: derrotas recuperables, economía trazable, cero venta de poder y una progresión de **nivel 1 a 150** repartida en 10 tramos de 15 niveles que se entiende sin planillas externas.

## 2. Pilares de diseño

Cada decisión posterior en `docs/design/` debe poder rastrearse hasta uno de estos cinco pilares. Si un sistema no sirve a ninguno, no entra en el MVP.

| # | Pilar | Qué significa en concreto | Cómo se verifica |
|---|-------|---------------------------|------------------|
| P1 | **Legibilidad móvil** | Todo lo que importa se distingue en una pantalla de 5–7" a un brazo de distancia: silueta, color de peligro, telegraph, icono y texto mínimo | Prueba física: identificar amenaza, aliado, NPC interactuable y objetivo en < 1 s |
| P2 | **Cooperación de baja fricción** | Se puede cooperar sin invitar, sin chat y sin grupo: los eventos públicos y el loot por contribución premian estar ahí | Un jugador solo + dos desconocidos resuelven un evento sin hablar |
| P3 | **Mundo con consecuencia** | Las rutas de resonancia cambian accesos, recursos y amenazas por temporadas cortas; la economía reacciona a lo que la comunidad hace | Antes/después de un evento de ruta: qué cambió y quién se benefició |
| P4 | **Economía comprensible y justa** | Pocos recursos base, sumideros visibles, precios explicables, nada de poder comprable con dinero real | Un jugador nuevo explica por qué un objeto vale lo que vale |
| P5 | **Progresión legible y corta** | Pocos números, pocas capas, reespecialización barata, sesiones que terminan en un hito concreto | El jugador sabe qué desbloqueó hoy y qué hará mañana |

## 3. Público objetivo

**Núcleo (núcleo de lanzamiento):**
- 16–35 años, Android de gama media (Snapdragon 6xx/7xx, 4 GB RAM, 60 Hz), sesiones de 10–30 minutos, 1–3 veces al día.
- Nostálgicos de MMORPG 2D de los 2000 (Tibia, Graal, Ragnarok, Realm of the Mad God) que ahora tienen poco tiempo y quieren esa sensación sin grind infinito ni interfaz de escritorio.
- Jugadores cooperativos casuales: entran solos, ayudan en eventos públicos, salen.

**Secundario:**
- Jugadores de idle/auto-battler que buscan progreso pasivo moderado (Lumbre de Descanso) sin que sea el centro.
- Comunidades hispanohablantes de rol ligero y creadores de contenido móvil.

**Fuera de objetivo durante el MVP:**
- Hardcore PvP competitivo, gremios de 200 personas, simulador de economía especulativa, speedrun de mazmorras, mercado con arbitraje de alta frecuencia.

## 4. Diferenciadores frente a Tibia / Graal / RO Mobile

| Referencia | Lo que hace bien | Nuestra diferencia deliberada |
|-----------|------------------|-------------------------------|
| **Tibia** | Mundo enorme, riesgo real, economía de jugadores | Mundo más denso y navegable en móvil; rutas con estado global; pérdida de XP al morir limitada y recuperable |
| **Graal Online** | Sociabilidad inmediata, entrada sin fricción | Cooperación estructurada por eventos públicos y contribución, no solo por chat |
| **Ragnarok Mobile** | Curva cosmética, clases con identidad | Cero venta de poder, sin gacha, sin refinar equipo con dinero; resonancia como recurso de mundo, no como sesión de casino |
| **Realm of the Mad God** | Acción rápida, riesgo alto | Cámara y combate más pausados, top-down clásico, control táctil con un solo pulgar |

**Diferenciador central:** el jugador no solo sube de nivel, **cambia el estado del mapa para todos**. Encender una ruta de resonancia abre un atajo, cambia el set de enemigos de la zona y altera precios de una región hasta el próximo ciclo. Es worldbuilding y diseño de sistemas al mismo tiempo, y es exponible con los sistemas que el servidor autoritativo ya necesita (ADRs 002 y 006).

## 5. Tono y fantasía

Fantasía luminosa de raíz andina: un mundo de salares, terrazas, minas de cobre y cordilleras donde la memoria de lo cantado se cristaliza en **nácar**, una sustancia que brilla y que sostiene la realidad local. No es grimdark: hay humor, hospitalidad, mercados ruidosos y cocina. Pero hay un problema real — **el Silencio avanza**, y hay quien cree que debería avanzar.

Se elige este tono (en vez de fantasía europea genérica o post-apocalipsis) por tres razones de diseño:

1. **Identidad visual inmediata** en tienda y capturas: paleta de sal, cobre, brasa, jade y cielo nocturno, sin orcos ni castillos.
2. **Coherencia con el recurso mágico**: "resonancia" es un sistema mecánico y a la vez la cosmología; una sola idea explica el mundo, las clases y los eventos.
3. **Originalidad legal y cultural**: todo el vocabulario es propio, no derivado de IP ajena (ADR-008), y el material de referencia de la región es de dominio público.

Detalle en [01-lore.md](01-lore.md).

## 6. Alcance realista por etapa

Un dev, tres meses de MVP. Estos números son presupuesto, no deseo.

| Etapa | Duración objetivo | Contenido | Criterio de salida |
|-------|-------------------|-----------|--------------------|
| **MVP (demo multi)** | 3 meses | T1 completo: 3 zonas + 1 instancia, niveles 1–15, 3 clases, 16 criaturas (familias × variantes), 1 jefe de tramo, sets T1, 15 misiones, 1 evento público, servidor autoritativo con 8 jugadores por zona, Android real | Ver [11-mvp-scope.md](11-mvp-scope.md) |
| **Vertical slice** | 3 meses siguientes | T1–T2, niveles 1–30, 4 clases, party de 5, gremio básico, mercado entre jugadores, PvP opt-in, 2 sets por clase, eventos diarios y semanales, tienda de cosméticos activa | Un jugador externo juega 5 horas sin guía y no se traba |
| **v1.0 (lanzamiento)** | +12 meses | T1–T7, niveles 1–105, 5 clases, 4 facciones, 21 zonas + 7 instancias, endgame intermedio (T6–T7), temporadas de ruta, calendario completo de eventos | 2.000 cuentas beta, retención D7 ≥ 25 %, 0 crashes críticos por sesión |
| **v1.1 – v1.3** | +6 meses | T8–T10, niveles 106–150, raids de 5 y 10, segunda ronda de sets, jefes mundiales rotativos | El 5 % de los jugadores alcanza nivel 150 y el endgame se sostiene 8 semanas |

Cada tramo es jugable y publicable de forma independiente (§1 de [04-world.md](04-world.md)); el nivel máximo 150 se alcanza por expansión de tramos, no rehaciendo lo anterior.

Regla de recorte: si una función no entra en MVP **ni** deja preparado un dato que la v1.0 necesite, se corta. El MVP no incluye PvP abierto, gremios, ni mercado entre jugadores.

## 7. Qué NO es este juego

- No es un idle game, aunque tenga progreso de descanso acotado.
- No es PvP-first; el PvP es opt-in y señalizado.
- No es un sandbox de construcción de casas.
- No es pay-to-win, ni gacha, ni loot boxes con dinero real (ver [10-monetization.md](10-monetization.md)).
- No es cross-platform con PC en el MVP: el cliente objetivo es Android (ADR-004), el headless server es el mismo proyecto Godot.

## 8. Restricciones técnicas que condicionan el diseño

| Restricción | Consecuencia de diseño |
|-------------|------------------------|
| Godot 4.4 + GDScript, un solo proyecto con feature tags | Todo dato vive en `data/*.tres`; la lógica en `domain/` no toca nodos (ADR-001, 003, 005) |
| Servidor autoritativo ENet, 10–20 jugadores por zona (ADR-006) | Nada de cálculos en cliente; telegraphs y predicción deben ser baratos; sin física client-side para daño |
| Assets CC0 en MVP, $0 (ADR-008) | Estilo soportado por tiles 32×32 y placeholders geométricos (ADR-009); nada de arte que dependa de un pack propietario |
| Pantalla 5–7" horizontal, 1280×720 base | Máximo 4 botones de acción + joystick; textos ≤ 24 caracteres por etiqueta; un panel abierto a la vez |
| Presupuesto de banda por zona (docs/02-networking.md) | Estados y buffs se replican como bitmask; efectos visuales derivados deterministamente de datos |

## 9. Documentos relacionados

- [01-lore.md](01-lore.md) — mundo, eras, cosmología, NPCs
- [02-classes.md](02-classes.md) — 5 clases y sus kits
- [03-combat.md](03-combat.md) — fórmulas, estados, IA
- [04-world.md](04-world.md) — 30 zonas, 10 instancias, 10 tramos de nivel
- [05-economy.md](05-economy.md) — monedas, objetos, sets de equipo, crafteo, mercado
- [06-progression.md](06-progression.md) — XP 1–150, stats, talentos, reputación, endgame
- [07-social.md](07-social.md) — chat, party, gremios, PvP
- [08-ui-ux.md](08-ui-ux.md) — wireframes, onboarding, controles táctiles
- [09-art-audio.md](09-art-audio.md) — dirección visual y sonora
- [10-monetization.md](10-monetization.md) — F2P cosmético, principios y ética
- [11-mvp-scope.md](11-mvp-scope.md) — qué entra en 3 meses
- [12-events.md](12-events.md) — eventos diarios, semanales y de temporada
- [13-shop.md](13-shop.md) — tienda premium: coins, packs, precios y rotaciones
- [INDEX.md](INDEX.md) — índice y checklist de coherencia
