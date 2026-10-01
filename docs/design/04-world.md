# 04 — Mundo, zonas y progresión de niveles 1–150

> Depende de: [01-lore.md](01-lore.md) §4 · Usa: [03-combat.md](03-combat.md) §9 · Afecta a: [05-economy.md](05-economy.md), [06-progression.md](06-progression.md), [12-events.md](12-events.md)
> Implementación: definiciones en `src/data/zones/*.tres`, criaturas en `src/data/enemies/*.tres`, escenas en `src/world/`, spawn y transiciones en `src/systems/` (ADR-005).

## 1. Estructura del mundo

Astreva se divide en **10 tramos de 15 niveles**. Cada tramo tiene **3 zonas persistentes** (una de ellas puede ser hub), **1 instancia** y **1 jefe de tramo**. Total del mundo v1.0:

| Contenido | Cantidad |
|-----------|----------|
| Zonas persistentes | 30 |
| Instancias (1 por tramo) | 10 |
| Raids (endgame) | 4 |
| Arenas (1v1 / 3v3) | 2 |
| Jefes de tramo | 10 |
| Jefes de instancia | 10 |
| Jefes de raid | 4 |
| Jefes mundiales | 1 + 1 rotativo por temporada |
| Familias de criaturas | 16 (con 4 variantes cada una = 64 criaturas) |

Regla de construcción: cada tramo es **autocontenido y jugable de punta a punta** — se puede publicar, probar y balancear un tramo sin que exista el siguiente. Esto permite lanzar por etapas (ver [11-mvp-scope.md](11-mvp-scope.md)) sin rehacer nada.

## 2. Grafo macro

```
 T1 Cuenca de Candela     T2 Reverso Húmedo      T3 Las Agujas        T4 Costa de Umbral
 [1] Bastión Candela  ──► [4] Pantano Campanas ─► [7] Camino Agujas ─► [10] Puerto Salitre
 [2] Prado de Senda       [5] Río Turbio          [8] Mina de Aguja    [11] Marismas de Sal
 [3] Bosque del Reverso   [6] Ruinas de Tierra    [9] Cumbres Escoria [12] Farallones Hundidos
        1–15                   16–30                   31–45                 46–60

 T5 Tierras Quipu         T6 Cordillera Vidriada  T7 El Salar          T8 Profundidades
 [13] Ruinas de Quipu ──► [16] Cordillera Vidriada►[19] Borde del Salar►[22] Descenso Resonante
 [14] Biblioteca de Hilo  [17] Ventisquero         [20] Duna Blanca     [23] Catedral del Eco
 [15] Terrazas Colgantes  [18] Jardín de Vidrio    [21] Ciudad de Sal   [24] Vientre de Nácar
        61–75                   76–90                   91–105                106–120

 T9 Aurora Quemada        T10 Nácar Primigenio
 [25] Costa de Aurora ──► [28] Anillo de Nácar
 [26] Fiordo de Ascua     [29] Cámara del Primer Canto
 [27] Mirador del Alba    [30] Templo de Nácar
        121–135                 136–150
```

## 3. Resumen de tramos

| Tramo | Niveles | Región | Hub | PvP | Jefe de tramo | Instancia |
|-------|---------|--------|-----|-----|---------------|-----------|
| T1 | 1–15 | Cuenca de Candela | Bastión de Candela | No | Mordeluz Resonante Alfa (nv 15) | Cueva del Eco (8–15) |
| T2 | 16–30 | Reverso Húmedo | Bastión de Candela (puerta sur) | Opt-in | Campanero Mayor (nv 30) | Cripta de Barro (16–30) |
| T3 | 31–45 | Las Agujas | Campamento de Aguja | Opt-in | Gólem Corazón (nv 45) | Galería Profunda (31–45) |
| T4 | 46–60 | Costa de Umbral | Puerto Salitre | Sí (marismas) | Almirante Hundido (nv 60) | Naufragio del Faro (46–60) |
| T5 | 61–75 | Tierras Quipu | Puerto Salitre (barca) | Opt-in | El Olvidado Mayor (nv 75) | Archivo Prohibido (61–75) |
| T6 | 76–90 | Cordillera Vidriada | Torre de Vigilia | Sí | Cóndor Rey (nv 90) | Ventisquero Alto (76–90) |
| T7 | 91–105 | El Salar | Ciudad de Sal | Sí | Heraldo de Kallpa (nv 105) | Tumba de Sal (91–105) |
| T8 | 106–120 | Profundidades Resonantes | Campamento del Eco | No | Coro Quebrado (nv 120) | Catedral del Eco (106–120) |
| T9 | 121–135 | Aurora Quemada | Mirador del Alba | Sí | Ascua Viva (nv 135) | Cámara de Ascua (121–135) |
| T10 | 136–150 | Nácar Primigenio | Anillo de Nácar | No (raid) | Coro Primero (nv 150) | Templo de Nácar (136–150) |

## 4. Fichas por tramo

Cada zona lista: nivel recomendado, criaturas (ver §5 para familias y variantes), recursos propios, NPCs con función y número de misiones (M). El detalle de recompensas y encargos repetibles está en [12-events.md](12-events.md).

### T1 — Cuenca de Candela (1–15)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[1] Bastión de Candela** | 1–6 | Mordeluz (joven) en el anillo | Madera clara, Fibra | Nara Velaquieta (misiones, onboarding), Oren Martillo Claro (forja), Mira Tres Llaves (banco), Sio Páramo (curación), Yatiri (errante) | 6 | — |
| **[2] Prado de Senda** | 3–10 | Mordeluz (joven/adulto), Cuervo de campana (joven), Nido de chispas (territorial) | Fibra, Hierbas, Sal negra | Sio Páramo (puesto), Yatiri | 4 | Mordeluz Alfa (élite nv 10) |
| **[3] Bosque del Reverso** | 9–15 | Reptil de raíz, Enredadera emboscada, Cuervo de campana (adulto) | Madera clara, Resina, Savia viva, Hierbas raras | Coro de las Tres Voces (puzle), Cantor Anciano (talentos) | 5 | Enredadera Madre (élite nv 15) |

**Instancia T1 — Cueva del Eco (8–15, 1–3 jugadores):** enseña ondas de sonido, esquiva de telegraphs y puzle de eco. **Jefe:** Mordeluz Resonante (3 fases, tabla en [03-combat.md](03-combat.md) §9.4). **Botín de tramo:** set T1 completo (§6), receta de poción menor.

**Cadena narrativa del tramo:** "La ruta que no vuelve" — Nara envía al jugador a encender el Nodo de Senda y descubre que la ruta que su hermano encendió fue la que se corrompió. Termina con la primera decisión de facción (Ortecas vs. Los Que Callan).

### T2 — Reverso Húmedo (16–30)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[4] Pantano de las Campanas** | 16–24 | Sapo de campana, Ahogado, Serpiente de limo | Barro raro, Hierbas amargas, Metal oxidado | Pescador sin nombre (lore), Yatiri | 5 | Campanero errante (élite nv 24, aparece de noche) |
| **[5] Río Turbio** | 20–27 | Ahogado (adulto), Reptil de raíz (ancestral), Bandido de ruta | Fibra, Cuero, Sal negra | Balsero Tuli (transporte), Mercader de la Casa | 4 | Bandido Capitán (élite nv 27) |
| **[6] Ruinas de Tierra Baja** | 24–30 | Escriba sin nombre (joven), Centinela de la Casa, Enredadera (ancestral) | Hilo de quipu, Nácar bruto, Tinta antigua | Arqueóloga Quilla (misiones), Yatiri | 5 | Campanero Mayor (jefe nv 30) |

**Instancia T2 — Cripta de Barro (16–30, 3 jugadores):** DoT ambiental, antorchas que se apagan, primer combate que exige limpieza de estados. **Jefe:** El Ahogado Primero.

**Tramo narrativo:** la Casa Salitre empieza a comprar nácar robado; el jugador elige denunciar o participar.

### T3 — Las Agujas (31–45)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[7] Camino de las Agujas** | 31–38 | Centinela de la Casa, Bandido de ruta (ancestral), Jauría umbría | Mineral resonante, Piedra, Cristal de aguja | Tarek del Umbral (waypoint), Caravana de la Casa (comercio móvil) | 5 | Guardián de la Aguja (élite nv 38, solo si la ruta está corrompida) |
| **[8] Mina de Aguja** | 34–41 | Gólem de escoria, Rata de túnel (manada), Excavador ciego | Cobre, Mineral resonante, Chispa cristalizada | Capataz Rumi (encargos), Oren Martillo Claro (semanal) | 5 | Gólem de Veta (élite nv 41) |
| **[9] Cumbres de Escoria** | 39–45 | Gólem de escoria (ancestral), Cóndor de vidrio (joven), Umbrío de altitud | Mineral resonante puro, Nácar bruto | Ermitaño de la cumbre (recetas raras) | 4 | Gólem Corazón (jefe nv 45) |

**Instancia T3 — Galería Profunda (31–45, 3 jugadores):** terreno con luz (visión reducida fuera de las lámparas), gólems que se apagan y encienden. **Jefe:** Excavador Rey.

**Tramo narrativo:** la mina despierta algo; Oren admite que el nácar no es solo una piedra.

### T4 — Costa de Umbral (46–60)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[10] Puerto Salitre** (hub) | 46–54 | Contrabandista (anillo), Rata de muelle | Pescado, Sal negra, Tela | Ivo Salitre (comercio), Aduanera Pelao (facción), Capitán Vera (transporte) | 6 | — |
| **[11] Marismas de Sal** (PvP) | 50–57 | Ahogado (ancestral), Sapo de sal, Bandido (ancestral) | Sal negra (abundante), Cuero, Nácar bruto | Farero Ciego (misión de faro), Yatiri | 4 | Farero Caído (élite PvP nv 57) |
| **[12] Farallones Hundidos** | 54–60 | Cóndor de vidrio (adulto), Escalador helado, Silente (joven) | Cristal vidriado, Nácar bruto, Perla de umbral | Cartógrafa Nima (mapas), Yatiri | 5 | Almirante Hundido (jefe nv 60) |

**Instancia T4 — Naufragio del Faro (46–60, 3 jugadores):** interior de un faro volcado, agua que sube por fases. **Jefe:** Farero del Umbral.

**Tramo narrativo:** la Casa Salitre vende nácar a Los Que Callan. Ivo Salitre pide ayuda al jugador para detenerlo desde dentro.

### T5 — Tierras Quipu (61–75)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[13] Ruinas de Quipu** | 61–68 | Escriba sin nombre (adulto), Guardián de hilo, Olvidado (joven) | Hilo de quipu, Nácar tallado, Tinta antigua | Wara Quipucamayoc (lore), el Fabricante (recetas) | 6 | El Olvidado Menor (élite nv 68) |
| **[14] Biblioteca de Hilo** | 65–72 | Guardián de hilo (ancestral), Escriba Mayor, Espectro de nácar | Tinta antigua (abundante), Nácar tallado, Quipu completo | Bibliotecaria Sisa (puzles, misiones de historia) | 5 | Escriba Mayor (élite nv 72) |
| **[15] Terrazas Colgantes** | 69–75 | Olvidado, Enredadera (ancestral), Silente (adulto) | Hierbas raras, Semilla de terraza, Nácar puro | Cantor Anciano (talentos de soporte), Yatiri | 5 | El Olvidado Mayor (jefe nv 75) |

**Instancia T5 — Archivo Prohibido (61–75, 3 jugadores):** puzles de quipu donde hay que "leer" el orden correcto de las salas; los errores invocan Olvidados. **Jefe:** El Archivista.

**Tramo narrativo:** Wara revela que rehacer la ruta madre exigiría sacrificar una zona habitada. El jugador decide si ayudarla o frenarla.

### T6 — Cordillera Vidriada (76–90)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[16] Cordillera Vidriada** (PvP) | 76–83 | Cóndor de vidrio (ancestral), Escalador helado, Umbrío de altitud | Cristal vidriado, Nácar bruto, Hierba de altura | Torre de Vigilia (checkpoint PvP), Ermitaño de la cumbre | 6 | Cóndor Rey (élite/jefe nv 83) |
| **[17] Ventisquero** | 80–87 | Escalador helado (ancestral), Silente (ancestral), Gólem de hielo | Cristal vidriado (abundante), Nácar puro | Guardiana Puka (misiones de rescate), Yatiri | 4 | Ventisca Viva (élite nv 87) |
| **[18] Jardín de Vidrio** | 84–90 | Espectro de nácar, Cóndor de vidrio (ancestral), Guardián de hilo (ancestral) | Nácar puro, Flor de vidrio, Semilla rara | Jardinero Ciego (recetas T6), Wara (visita) | 5 | Cóndor Rey (jefe nv 90, 8 jugadores) |

**Instancia T6 — Ventisquero Alto (76–90, 3–5 jugadores):** ventisca que reduce la visión y obliga a moverse entre refugios. **Jefe:** El Que Sopla.

**Tramo narrativo:** el Cóndor Rey era un guardián, no una bestia; algo lo corrompió desde el Salar.

### T7 — El Salar (91–105)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[19] Borde del Salar** (PvP) | 91–98 | Caminante de sal, Silente (ancestral), Heraldo (joven) | Sal blanca, Nácar puro | Campamento de las Ortecas (checkpoint móvil), Tarek | 5 | Heraldo Menor (élite PvP nv 98) |
| **[20] Duna Blanca** | 95–102 | Caminante de sal (ancestral), Espectro de nácar, Silente Mayor | Sal blanca (abundante), Semilla de silencio | Eremita del Silencio (lore de Kallpa) | 5 | Espectro de Sal (élite nv 102) |
| **[21] Ciudad de Sal** (hub secundario) | 99–105 | Heraldo, Silente Mayor (anillo) | Nácar puro, Sal blanca, Tinta de silencio | Kallpa el Que Calla (NPC antagonista, interactuable), Comerciante mudo, Yatiri (última aparición) | 6 | Heraldo de Kallpa (jefe nv 105) |

**Instancia T7 — Tumba de Sal (91–105, 5 jugadores):** sala donde el sonido no viaja: los jugadores no escuchan ni ven los telegraphs hasta estar cerca. **Jefe:** El Silencio Primero.

**Tramo narrativo:** Kallpa habla por primera vez. No amenaza: ofrece descanso. El jugador puede aceptar su marca (reputación con Los Que Callan).

### T8 — Profundidades Resonantes (106–120)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[22] Descenso Resonante** | 106–113 | Espectro de nácar (ancestral), Guardián de hilo (ancestral), Olvidado Mayor | Nácar puro, Cristal de eco | Campamento del Eco (checkpoint), Ingeniera Mala (equipo T8) | 5 | Guardián del Descenso (élite nv 113) |
| **[23] Catedral del Eco** | 110–117 | Coro Menor, Espectro de nácar, Escriba sin nombre (ancestral) | Cristal de eco (abundante), Nácar puro, Quipu completo | Coro de las Tres Voces (variante profunda), Historiadora Wara | 5 | Coro Menor (élite nv 117) |
| **[24] Vientre de Nácar** | 114–120 | Coro Menor (ancestral), Tarek corrompido (evento), Espectro de primer canto | Nácar puro (máximo), Semilla de silencio, Núcleo resonante | Tarek del Umbral (cadena personal) | 5 | Coro Quebrado (jefe nv 120) |

**Instancia T8 — Catedral del Eco (106–120, 5 jugadores):** cuatro coros que deben silenciarse en orden; el orden cambia cada semana. **Jefe:** Coro Quebrado.

**Tramo narrativo:** Tarek descubre que fue creado por la Quiebra. Su cadena define si se convierte en aliado de facción o en jefe de temporada.

### T9 — Aurora Quemada (121–135)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[25] Costa de Aurora** (PvP) | 121–128 | Ascua errante, Caminante de sal (ancestral), Silente Mayor | Nácar puro, Sal de aurora, Perla de lumbre | Vigía Sol (misiones PvP), Tarek (si aliado) | 5 | Ascua Menor (élite PvP nv 128) |
| **[26] Fiordo de Ascua** | 125–132 | Ascua errante (ancestral), Gólem de escoria (primigenio), Espectro de primer canto | Mineral primigenio, Núcleo resonante | Forjadora Iren (sets T9), Oren (cameo final) | 5 | Forja Viva (élite nv 132) |
| **[27] Mirador del Alba** | 129–135 | Ascua Viva (élite), Coro Menor (ancestral), Guardián de hilo (primigenio) | Nácar primigenio, Semilla de terraza, Cuarzo de alba | Wara Quipucamayoc (final de cadena) | 6 | Ascua Viva (jefe nv 135) |

**Instancia T9 — Cámara de Ascua (121–135, 5 jugadores):** plataforma con calor creciente (DoT acumulativo) y fases de enfriamiento. **Jefe:** Corazón de Ascua.

**Tramo narrativo:** la ruta madre se puede rehacer, pero exige el sacrificio de una zona. La decisión se guarda por servidor y afecta la temporada siguiente.

### T10 — Nácar Primigenio (136–150)

| Zona | Niv. | Criaturas | Recursos | NPCs | M | Jefe / élite |
|------|------|-----------|----------|------|---|--------------|
| **[28] Anillo de Nácar** | 136–143 | Guardián primigenio, Coro Menor (primigenio), Espectro de primer canto | Nácar primigenio (abundante), Núcleo resonante | Custodios del Anillo (vendedores de endgame) | 5 | Guardián Primero (élite nv 143) |
| **[29] Cámara del Primer Canto** | 140–147 | Ecos del Primer Coro, Olvidado Primigenio, Silente Arquetípico | Nácar primigenio, Quipu completo, Semilla de silencio | Wara, Tarek (según decisión), Kallpa (diálogo final) | 6 | Coro Primero (jefe nv 147) |
| **[30] Templo de Nácar** (raid) | 145–150 | Heraldos, Ecos, Coro Primero | Nácar primigenio, reliquias de temporada | Custodios, NPCs de facción | 4 | **Coro Primero** (raid 5–10, 4 fases) |

**Instancia T10 / raid — Templo de Nácar (145–150, 5–10 jugadores):** 4 fases con mecánicas por rol, requiere reputación ≥ Honrado con 2 facciones y el set T9 completo o superior. **Jefe final:** Coro Primero, con variante **Aumentada** que añade una quinta fase de temporada.

**Raid de temporada — Coro del Silencio (150, 10 jugadores):** raid rotativa que cambia cada temporada; su resultado decide el estado inicial de las rutas del mundo al reiniciar el ciclo (ver §8 y [12-events.md](12-events.md)).

## 5. Familias de criaturas

16 familias × 4 variantes. La variante define estadísticas y comportamiento; la familia define silueta, sonido y resistencias (barato de reutilizar en arte y datos).

| # | Familia | Variantes | Hábitat | Tipo de daño | IA base | Nota de diseño |
|---|---------|-----------|---------|--------------|---------|----------------|
| 1 | **Mordeluz** | Joven / Adulto / Alfa / Umbrío | Prado, bosque | Físico | Errante → Manada | Enseña detección y kiting |
| 2 | **Cuervo de campana** | Joven / Adulto / Ancestral / Umbrío | Bosque, pantano | Físico | Patrulla → Agresivo | Roba objetos y huye |
| 3 | **Reptil de raíz** | Joven / Adulto / Ancestral / Umbrío | Bosque, río | Físico + veneno | Emboscada | Enseña antídotos |
| 4 | **Enredadera emboscada** | Joven / Adulto / Ancestral / Umbrío | Bosque, terrazas | Resonante | Emboscada fija | No persigue; castiga la prisa |
| 5 | **Sapo de campana** | Joven / Adulto / Ancestral / Umbrío | Pantano, marismas | Resonante + `zumbido` | Territorial | Ataque de área con CD largo |
| 6 | **Ahogado** | Joven / Adulto / Ancestral / Umbrío | Río, marismas, naufragio | Umbrío | Agresivo | Inmune a `umbral_de_miedo` |
| 7 | **Bandido de ruta** | Joven / Adulto / Ancestral / Umbrío | Caminos, costa | Físico | Patrulla → Manada | Primer humanoide con habilidades |
| 8 | **Gólem de escoria** | Joven / Adulto / Ancestral / Primigenio | Mina, cumbres, fiordo | Físico | Guardián | Ventana de vulnerabilidad tras su área |
| 9 | **Rata de túnel** | Joven / Adulto / Ancestral / Umbrío | Mina, túneles | Físico | Manada | 6+ a la vez; enseña área |
| 10 | **Centinela de la Casa** | Joven / Adulto / Ancestral / Umbrío | Caminos, ruinas | Físico + `silencio` | Patrulla | Aplica `silencio` en el golpe 3 |
| 11 | **Escriba sin nombre** | Joven / Adulto / Mayor / Ancestral | Ruinas, bibliotecas | Resonante + `olvido` | Errante → Guardián | Borra buffs; prioridad alta en grupo |
| 12 | **Guardián de hilo** | Joven / Adulto / Ancestral / Primigenio | Ruinas, catedral | Resonante | Guardián | Se enlaza con otros y comparte daño |
| 13 | **Cóndor de vidrio** | Joven / Adulto / Ancestral / Rey | Cordillera, jardín | Físico + `raiz` | Agresivo aéreo | Vuela 3 s tras golpearlo de cerca |
| 14 | **Escalador helado** | Joven / Adulto / Ancestral / Umbrío | Cordillera, ventisquero | Físico | Emboscada | Aparece de la nieve |
| 15 | **Silente** | Joven / Adulto / Mayor / Arquetípico | Salar y profundidades | Umbrío | Agresivo | `olvido` + inmunidad a miedo; el enemigo central del endgame |
| 16 | **Caminante de sal** | Joven / Adulto / Ancestral / Primigenio | Salar, aurora | Umbrío + `corrosion` | Patrulla | Deja charcos que ralentizan |

**Variantes y multiplicadores:** Joven ×1,0 · Adulto ×1,6 Vida / ×1,3 daño · Ancestral ×2,6 Vida / ×1,7 daño / +1 habilidad · Primigenio ×4,0 Vida / ×2,2 daño / 2 habilidades / inmune a control · Umbrío = variante con `olvido` y +25 % daño Umbrío. Alfa/Menor/Mayor/Rey son élites con ×3,2 Vida, ×1,8 daño y tabla de botín propia.

## 6. Catálogo de jefes

| Categoría | Jefe | Nivel | Jugadores | Fases | Mecánica firma |
|-----------|------|-------|-----------|-------|----------------|
| Tramo T1 | Mordeluz Resonante Alfa | 15 | 1–3 | 3 | Ondas de eco en cono |
| Tramo T2 | Campanero Mayor | 30 | 1–3 | 3 | Campanas que aplican `zumbido` en área |
| Tramo T3 | Gólem Corazón | 45 | 3 | 3 | Núcleo expuesto 12 s tras área |
| Tramo T4 | Almirante Hundido | 60 | 3 | 3 | Agua que sube y ahoga zonas seguras |
| Tramo T5 | El Olvidado Mayor | 75 | 3 | 4 | Borra un buff por fase y bloquea su refresco |
| Tramo T6 | Cóndor Rey | 90 | 8 | 3 | Vuelo + ventisca que reduce visión |
| Tramo T7 | Heraldo de Kallpa | 105 | 5 | 4 | Marca del Silencio sobre un jugador; el grupo debe cubrirlo |
| Tramo T8 | Coro Quebrado | 120 | 5 | 4 | Cuatro coros, orden semanal secreto |
| Tramo T9 | Ascua Viva | 135 | 5 | 4 | Calor acumulativo en toda la arena |
| Tramo T10 | **Coro Primero** | 150 | 5–10 | 4 (+1 Aumentada) | Fase final de temporada; requiere sets T9/T10 |
| Instancia | 10 jefes de instancia | por tramo | 1–5 | 2–3 | Ver la tabla de cada tramo |
| Raid | Coro del Silencio | 150 | 10 | 5 | Rotativa por temporada; altera el mundo al cerrar |
| Mundial | **Kallpa el Que Calla** | 120/150 | 40–60 | 3 oleadas | Jefe mundial: aportación por contribución, sin necesidad de grupo |

## 7. Directorio de NPCs por función

| Función | NPCs | Ubicación |
|---------|------|-----------|
| Onboarding y trama principal | Nara Velaquieta, Sio Páramo, Wara Quipucamayoc, Tarek del Umbral | T1 → T10 |
| Crafteo y recetas | Oren Martillo Claro, Cantor Anciano, el Fabricante, Forjadora Iren, Jardinero Ciego | T1, T3, T5, T9 |
| Comercio y banco | Mira Tres Llaves, Ivo Salitre, Comerciante mudo, Caravana de la Casa | T1, T4, T7 |
| Facción | Aduanera Pelao, Pelotón Orteca, Enviado de los Cantores, Heraldos de Kallpa | Todos los hubs |
| Misión repetible / tablón | Nara (T1), Capataz Rumi (T3), Farero Ciego (T4), Bibliotecaria Sisa (T5) | 1 por región |
| Errante | Yatiri (aparece en todas las zonas con precios distintos; cambia stock cada 6 h) | Todas |
| Antagonista | Kallpa el Que Calla (interactuable, no hostil fuera del Salar) | T7, T10 |

## 8. Rutas de resonancia, temporadas y eventos de mundo

Cada zona persistente tiene un **nodo** y una **ruta** a su vecina principal; el estado lo decide el servidor a partir de la actividad de los jugadores.

| Estado | Cómo se llega | Efectos |
|--------|---------------|---------|
| **Encendida** | Por defecto o tras completar "Encender ruta" | Viaje rápido, set de enemigos normal, precios base, +10 % XP en la zona |
| **Tenue** | 24 h sin mantenimiento | −20 % velocidad en el camino, más enemigos, precios +10 % |
| **Apagada** | 72 h sin mantenimiento o fallo del evento | Sin viaje rápido, umbríos, +25 % recursos raros, −10 % XP |
| **Corrompida** | Agotar el nácar o sabotaje de Los Que Callan | Élites errantes, DoT ambiental, precios +25 %, recompensa alta |

**Ciclo de temporada (8 semanas):** semanas 1–3 degradación acelerada y eventos de ruta; semanas 4–5 jefe mundial y raid rotativa; semana 6 "Eco de temporada" (variante de zona + cosméticos); semanas 7–8 cierre, archivo del estado del servidor y reinicio con las rutas legibles. El detalle de eventos diarios, semanales y de temporada está en [12-events.md](12-events.md).

## 9. Transiciones, spawn y respawn

### 9.1 Transiciones

| Aspecto | Decisión | Razón |
|---------|----------|-------|
| Modelo | Zonas persistentes conectadas por puertas; instancias por copia | El mundo compartido es el punto del MMORPG |
| Transición | Portal visible + fundido de 0,8 s | P1: el jugador debe entender que cambió de lugar |
| Persistencia | La zona se mantiene cargada mientras haya jugadores; al vaciarse 120 s, se serializa y se libera | Memoria del servidor |
| Combate | No se puede cruzar en combate (bloqueo hasta 3 s tras el último golpe) | Evita huir de un jefe |
| Estado | El estado de zona es global del servidor | Pilar P3 |
| Nivel | Se avisa si la zona está 10+ niveles por encima del jugador (sin bloquear el paso) | Libertad con advertencia |

### 9.2 Tipos de spawn

| Tipo | Descripción | Respawn |
|------|-------------|---------|
| **Fijo** | Punto autoral con radio de 1 casilla | 60–180 s según nivel |
| **Zona** | Área de 3×3 a 6×6 con 2–5 posibles criaturas del set local | 90–240 s |
| **Dinámico** | Cantidad y variante ajustadas por presión de jugadores y estado de ruta | 30–300 s con límite por zona |
| **De evento** | Solo durante evento público o temporada | Al terminar el evento |
| **Único** | Élite o jefe de zona con ventana anunciada | 20–120 min, anunciado en el mapa |

```
densidad_objetivo = base_zona
                  × (1 + 0,15 × jugadores_activos)     # cap ×1,6
                  × modificador_estado_ruta            # encendida 1,0 · tenue 1,15 · apagada 1,30 · corrompida 1,45
                  × modificador_hora_mundo             # día 0,85 · noche 1,15
```

- Máximo de criaturas simultáneas: **60** por zona persistente, **90** en El Salar (T7+) y **40** con IA activa (el resto congelado hasta que un jugador entra en 20 casillas).
- Ninguna criatura aparece a menos de 8 casillas de un jugador ni dentro de su cono de visión.
- Una criatura que mata a un jugador gana "saciedad": 90 s sin perseguir a ese jugador (anti-camping).
- Instancias: sin respawn de criaturas; el jefe reinicia si el grupo muere completo o nadie lo golpea 45 s.

### 9.3 Muerte y recuperación

Sin pérdida de XP ni de equipo. Al morir: 5 % del cobre, estado `mella` (−10 % atributos, 180 s) y una **Brasa caída** recuperable durante 10 min en el punto de muerte (ver [03-combat.md](03-combat.md) §8). En zonas PvP, si la Brasa es recogida por otro jugador, el 50 % del cobre pasa a él y el 50 % se destruye (sumidero intencional).

## 10. Presupuesto de contenido por tramo

Un tramo se considera **entregable** cuando cumple:

- 3 zonas persistentes con identidad visual, paleta secundaria y tema musical propios.
- 16–20 criaturas activas (familias con variantes, no 20 diseños distintos).
- 1 jefe de tramo + 1 instancia con jefe + 2 élites de zona.
- 15 misiones (5 por zona) + 3 encargos repetibles + 1 cadena de facción.
- 1 set completo de equipo por clase y tramo (5 piezas, ver §6 de [05-economy.md](05-economy.md)) + sets alternativos de crafteo.
- 8–12 materiales y 10–14 recetas nuevas.
- 3 eventos de zona (1 diario, 1 semanal, 1 de temporada).
- 12–18 NPCs con función clara, de los cuales 3 con diálogo ramificado.

## 11. Implementación técnica del mundo

| Necesidad | Solución Godot 4.4 | Capa |
|-----------|--------------------|------|
| Grid de navegación | `AStarGrid2D` desde el `TileMapLayer` de colisión | `world/` |
| Colisiones | `TileMapLayer` con física + `CollisionShape2D` para props | `world/`, `entities/` |
| Transiciones | `Area2D` + `SceneLoader` (autoload) con fundido | `world/`, `autoload/` |
| Spawn autoritativo | `MultiplayerSpawner` con `spawn_function` determinista (semilla por zona) | `net/` |
| Estado de zona | `ZoneState` en servidor, replicado como 4 bytes | `net/`, `domain/` |
| Densidad dinámica | `ZoneDirector` en `systems/`, evaluación cada 5 s | `systems/` |
| Definición de tramo | `ZoneSetDefinition` en `data/zones/` que agrupa 3 zonas + instancia + jefe | `data/` |
| Nivel de criatura | `EnemyDefinition.nivel_base` + variante multiplicadora | `data/` |

Presupuesto por tramo: máx. 90 entidades replicadas, 40 con IA activa, 220 KB/s de ancho de banda por zona con 20 jugadores (ver `docs/02-networking.md` y `tests/performance/zone_budget_test.gd`).
