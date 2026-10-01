# 05 — Economía, objetos, crafteo y mercado

> Depende de: [01-lore.md](01-lore.md) §2 · Usa: [03-combat.md](03-combat.md) §2, [04-world.md](04-world.md) §6 · Afecta a: [06-progression.md](06-progression.md), [10-monetization.md](10-monetization.md)
> Implementación: catálogo en `src/data/items/*.tres`, recetas en `src/data/recipes/*.tres`, reglas puras en `src/domain/economy/`, transacciones en `src/net/` (ADR-002, 005).

## 1. Principios (pilar P4)

1. **Pocas monedas, usos separados y no intercambiables entre sí.**
2. **Todo sumidero es visible:** el jugador debe saber a dónde fue su cobre.
3. **Ningún sumidero destruye progreso de forma aleatoria** (sin refinar equipo con posibilidad de romperlo).
4. **El dinero real no compra poder**, ni directa ni indirectamente (ver [10-monetization.md](10-monetization.md)).
5. **Cada creación y destrucción de moneda u objeto se registra** en el log de economía del servidor, con el motivo.

## 2. Monedas

| Moneda | Icono | Fuente | Uso | Comerciable |
|--------|-------|--------|-----|-------------|
| **Cobre** | Moneda de cobre | Botín, misiones, eventos, venta a NPC, mercado | Compras, crafteo, viaje, reparación de rutas, listados del mercado | Sí (solo con otros jugadores, vía mercado) |
| **Nácar** (recurso, no moneda premium) | Cristal opalescente | Recolección, desmantelar equipo, jefes, ruinas | Encender rutas, afinar (encantar) equipo, recetas de alto nivel | Sí |
| **Sellos de Ruta** | Sello grabado | Misiones de facción, eventos públicos, temporada | Desbloquear waypoints, recetas de facción, cosméticos de facción | **No** (ligado a cuenta, intransferible) |
| **Lumbre** (premium) | Llama dorada | Compra con dinero real o **25–40/día** jugando eventos ([10-monetization.md](10-monetization.md) §5) | Cosméticos, pase de temporada, servicios de conveniencia | No |

Reglas de conversión: **no existe conversión entre Cobre, Sellos y Lumbre.** Lumbre no se puede comprar con Cobre, Nácar o Sellos. Esto evita el "mercado gris" de monetización y simplifica la auditoría.

### 2.1 Valores de referencia

| Referencia | Valor |
|-----------|-------|
| Enemigo común nivel 1 | 3–6 Cobre |
| Enemigo común nivel 10 | 12–20 Cobre |
| Enemigo común nivel 30 | 35–60 Cobre |
| Misión de zona (nivel medio) | 150–400 Cobre |
| Evento público de ruta | 200 Cobre + 1 Sello + 20 % de probabilidad de Nácar bruto |
| Poción de savia menor | 40 Cobre (compra) / 12 Cobre (venta a NPC) |
| Viaje por waypoint | 10–80 Cobre según distancia |

Los valores anteriores son de T1. La economía escala por tramo con un factor fijo para que el jugador sienta la subida de banda sin inflación descontrolada:

| Tramo | Niveles | Multiplicador de Cobre | Rango de botín por criatura común | Guía de precio de un consumible T |
|-------|---------|------------------------|-----------------------------------|------------------------------------|
| T1 | 1–15 | ×1 | 3–20 | 40 |
| T2 | 16–30 | ×4 | 20–80 | 120 |
| T3 | 31–45 | ×12 | 60–260 | 400 |
| T4 | 46–60 | ×30 | 150–700 | 1.200 |
| T5 | 61–75 | ×70 | 350–1.600 | 3.200 |
| T6 | 76–90 | ×150 | 750–3.600 | 8.000 |
| T7 | 91–105 | ×320 | 1.600–7.500 | 20.000 |
| T8 | 106–120 | ×650 | 3.200–15.000 | 48.000 |
| T9 | 121–135 | ×1.300 | 6.500–30.000 | 110.000 |
| T10 | 136–150 | ×2.600 | 13.000–62.000 | 260.000 |

El multiplicador aplica a botín, misiones, tarifas de crafteo y precios de NPC. **No aplica a los cosméticos ni a la Lumbre**, que mantienen precio plano (ver [13-shop.md](13-shop.md)).

## 3. Fuentes (fountains) y sumideros (sinks)

### 3.1 Fuentes

| Fuente | Cobre/día por jugador activo (estimado) | Notas |
|--------|------------------------------------------|-------|
| Botín de enemigos | 1.200 | Principal y estable; escala con nivel |
| Venta a NPC (fracción del precio) | 400 | El NPC compra al **35 %** del precio de compra |
| Misiones y encargos | 500 | 5–8 al día; se ralentizan con castigo por repetición |
| Eventos públicos | 300 | 4 eventos al día |
| Cofres de resonancia (rutas encendidas) | 200 | +50 % si la ruta está encendida |
| Venta en el mercado | variable | Solo redistribuye Cobre; no lo crea |
| **Total** | **~2.600 Cobre/día** | Techo suave, sin inflación de botín |

### 3.2 Sumideros

| Sumidero | Cobre/día por jugador activo | Tipo |
|----------|-------------------------------|------|
| Consumibles (pociones, comida, té) | 700 | Recurrente, proporcional al contenido |
| Crafteo (tarifa de estación) | 400 | Recurrente, escala con tier |
| Afinado (encantar) | 250 | Recurrente, mayor en endgame |
| Viaje por waypoint | 120 | Conveniencia |
| Reparación de ruta (donación de Nácar) | 100 en Cobre + Nácar | Colectivo, visible en el nodo |
| Tarifa de listado del mercado (5 %) + impuesto de venta (8 %) | 200 | Solo al comerciar |
| Reespecialización | 60 | Puntual |
| Cosmético con Cobre (colores básicos) | 150 | Puntual |
| **Total** | **~2.000–2.300 Cobre/día** | Déficit controlado: el jugador siente que ahorra |

**Diseño del balance:** las fuentes superan a los sumideros en ~15 % para que el jugador perciba progreso monetario, pero el excedente se absorbe con contenido de temporada (recetas caras, cosméticos de facción, mejoras de banco). La telemetría revisa esta relación cada temporada (ver `docs/07-testing.md`).

## 4. Catálogo base de T1 (28 objetos núcleo) y sets por tramo

Rarezas por color: `común` (blanco), `fino` (verde), `resonante` (azul), `raro` (violeta), `legendario` (dorado, solo artesanal/evento).

Los 28 objetos siguientes son los **núcleo de T1**: con ellos se cubre arma, armadura, consumible y material de las tres clases del MVP. Las piezas de **set** (6 por set) se suman a este catálogo: en el MVP hay 3 sets de clase (18 piezas) + 2 sets de crafteo (12 piezas) + equipo inicial, por lo que el inventario total de objetos del MVP ronda los **70** ([11-mvp-scope.md](11-mvp-scope.md) §1.1). Para v1.0, el catálogo completo es 28 núcleo + 50 sets × 6 piezas + alternativos ≈ **400 objetos**.

### 4.1 Armas (8)

| # | Nombre | Tipo | Niv. | Clase | Estadísticas | Fuente |
|---|--------|------|------|-------|--------------|--------|
| 1 | Cuchilla de aprendiz | Arma | 1 | Hiladora / Bastión | +3 POD, +1 AGI | Entrega inicial |
| 2 | Martillo de fragua | Arma | 5 | Bastión | +6 POD, +4 VIG, amenaza +10 % | Crafteo T1 / Oren |
| 3 | Filo de corriente | Arma | 8 | Hiladora | +7 POD, +3 AGI, +3 % celeridad | Crafteo T2 |
| 4 | Pluma de trazo | Arma | 8 | Lector | +6 POD, +4 RES | Crafteo T2 |
| 5 | Báculo de savia | Arma | 8 | Cantor | +4 POD, +6 RES, +5 % curación | Crafteo T2 |
| 6 | Lanzador de chispas | Arma | 8 | Forjador | +8 POD, +2 RES | Crafteo T2 |
| 7 | Aguja resonante | Arma | 20 | Todas | +12 POD, +6 RES (+8 RES si el nodo local está encendido) | Botín raro de la Mina de Aguja |
| 8 | Cuchilla de vidrio cantor | Arma | 34 | Hiladora / Bastión | +26 POD, +10 AGI, crítico +5 % | Crafteo T4 + Cóndor Rey |

### 4.2 Armaduras y accesorios (6)

| # | Nombre | Ranura | Niv. | Estadísticas | Fuente |
|---|--------|--------|------|--------------|--------|
| 9 | Peto de escoria | Pecho | 5 | +8 VIG, +6 DEF | Crafteo T1 |
| 10 | Yelmo de brasa | Cabeza | 8 | +5 VIG, +5 DEF, +3 % mitigación | Crafteo T2 |
| 11 | Capa de viento | Pecho | 10 | +6 AGI, +4 DEF, −5 % duración de `raiz` | Crafteo T2 / Bosque del Reverso |
| 12 | Botas de ruta | Pies | 6 | +3 AGI, +5 % velocidad | Crafteo T1 |
| 13 | Grebas de altura | Piernas | 28 | +14 VIG, +12 RES, +5 % tenacidad | Crafteo T3 / Cordillera |
| 14 | Anillo de nácar | Accesorio | 20 | +8 RES, +2 % curación, +3 % crítico | Misión de facción orteca |

### 4.3 Consumibles (6)

| # | Nombre | Efecto | Duración/CD | Fuente | ¿MVP? |
|---|--------|--------|-------------|--------|-------|
| 15 | Pan de brasa | Cura 15 % Vida máx (solo fuera de combate) | Instantáneo | Cocina T1 | Sí |
| 16 | Té de hierbas amargas | Limpia `quemadura` y `zumbido` | Instantáneo, CD 20 s | Cocina T1 | Sí |
| 17 | Poción de savia menor | Cura 30 % Vida máx | CD 30 s | Alquimia T1 | Sí |
| 18 | Poción de savia mayor | Cura 55 % Vida máx | CD 30 s | Alquimia T2 | No (v1.1) |
| 19 | Elixir de lumbre | +10 % daño y +5 % curación | 20 min | Alquimia T3 | No (v1.1) |
| 20 | Piedra de retorno | Viaja al último waypoint encendido | 10 min | Cantería T2 | Sí |

### 4.4 Materiales (8)

| # | Material | Zona principal | Uso |
|---|----------|----------------|-----|
| 21 | Madera clara | Prado, Bosque | Armas y mangos T1–T2 |
| 22 | Fibra | Prado, Pantano | Tela, capa, cuerdas |
| 23 | Hierbas | Prado, Bosque | Pociones y té |
| 24 | Cuero | Prado, Cordillera | Botas, correas, armaduras ligeras |
| 25 | Mineral resonante | Camino de las Agujas, Mina | Armas metálicas y afinado |
| 26 | Nácar bruto | Ruinas, Pantano, Cordillera | Afinado, encender rutas, recetas T3+ |
| 27 | Sal negra | Prado (raro), Puerto Salitre | Recetas de conservación, misiones de la Casa |
| 28 | Hilo de quipu | Ruinas de Quipu | Recetas de Lector, puzles, cosméticos de facción |

**Materiales por tramo (los 28 anteriores son el catálogo de T1; cada tramo añade su propio set):**

| Tramo | Materiales base | Material raro | Material de jefe |
|-------|-----------------|---------------|------------------|
| T1 | Madera clara, Fibra, Hierbas, Cuero | Sal negra | Nácar bruto |
| T2 | Barro, Junco, Cuero curtido | Hierba amarga | Campana de bronce |
| T3 | Mineral resonante, Piedra, Cobre | Chispa cristalizada | Núcleo de escoria |
| T4 | Sal negra, Tela, Pescado | Perla de umbral | Timón del Almirante |
| T5 | Hilo de quipu, Tinta antigua, Resina | Nácar tallado | Nudo del Archivista |
| T6 | Cristal vidriado, Hierba de altura, Cuero de cóndor | Flor de vidrio | Pluma del Rey |
| T7 | Sal blanca, Tinta de silencio, Hueso de sal | Semilla de silencio | Marca del Heraldo |
| T8 | Nácar puro, Cristal de eco, Cuarzo resonante | Núcleo resonante | Eco del Coro |
| T9 | Mineral primigenio, Sal de aurora, Ascua sólida | Perla de lumbre | Corazón de Ascua |
| T10 | Nácar primigenio, Cuarzo de alba, Reliquia | Semilla de terraza | Fragmento del Primer Canto |

### 4.5 Ranuras de equipamiento y presupuesto por tramo

Seis ranuras por personaje: **Arma, Cabeza, Pecho, Piernas, Pies, Accesorio**. Todo set de tramo cubre las seis.

| Tramo | Presupuesto ofensivo del set (POD total) | Presupuesto defensivo (DEF total) | Presupuesto de atributos (puntos) | Nivel de afinado máximo |
|-------|------------------------------------------|-----------------------------------|-----------------------------------|--------------------------|
| T1 | +40 | +35 | 30 | +1 |
| T2 | +90 | +80 | 60 | +1 |
| T3 | +180 | +160 | 100 | +2 |
| T4 | +330 | +300 | 160 | +2 |
| T5 | +560 | +520 | 230 | +2 |
| T6 | +900 | +840 | 320 | +3 |
| T7 | +1.400 | +1.300 | 440 | +3 |
| T8 | +2.100 | +2.000 | 580 | +3 |
| T9 | +3.000 | +2.900 | 740 | +3 |
| T10 | +4.200 | +4.100 | 920 | +3 |

El arma concentra el 40 % del presupuesto ofensivo; el pecho, el 30 % del defensivo; el accesorio aporta crítico, celeridad o tenacidad en lugar de poder bruto.

### 4.6 Sets completos por tramo (T1–T10)

Cada tramo tiene **5 sets de clase** (uno por clase), con la misma estructura:

**Convención de piezas (idéntica en todos los sets):**

```
[Arma] de [Set]        [Pecho] de [Set]
[Cabeza] de [Set]      [Piernas] de [Set]
[Pies] de [Set]        [Accesorio] de [Set]
```

Nombres de pieza por clase: Bastión → Martillo / Yelmo / Peto / Grebas / Botas / Sello · Hiladora → Filo / Capucha / Casaca / Calzas / Botines / Broche · Lector → Pluma / Capucha / Túnica / Faldón / Sandalias / Quipu · Cantor → Báculo / Corona / Manto / Faldón / Raíces / Semilla · Forjador → Lanzador / Gafas / Arnés / Perneras / Botas / Mecanismo.

Bonificaciones: **2 piezas** (ofensiva), **4 piezas** (defensiva/utilidad) y **6 piezas** (efecto firma). Las piezas se obtienen: 4 por crafteo del tramo, 1 por jefe de instancia y 1 (el arma) por el jefe de tramo.

| Tramo | Tema | Bastión | Hiladora | Lector | Cantor | Forjador | 2 piezas | 4 piezas | 6 piezas (firma) |
|-------|------|---------|----------|--------|--------|----------|----------|----------|------------------|
| T1 | Cobre | Yunque de Cobre | Ráfaga de Cobre | Trazo de Cobre | Raíz de Cobre | Chispa de Cobre | +4 % POD | +6 % VIG | **Escudo de cobre:** al usar una habilidad defensiva, +8 % escudo durante 4 s |
| T2 | Junco | Muro de Junco | Junco Veloz | Hilo de Junco | Savia de Junco | Pólvora de Junco | +4 % POD | +6 % RES | **Pantano vivo:** inmunidad a `ralentizacion` durante 3 s tras recibir un control |
| T3 | Aguja | Yunque de Aguja | Aguja Veloz | Trazo de Aguja | Raíz de Aguja | Chispa de Aguja | +5 % POD | +7 % VIG/RES | **Perforar:** el tercer golpe consecutivo ignora 15 % de mitigación |
| T4 | Salitre | Rompeolas | Sal marina | Carta náutica | Marea viva | Cañón de sal | +5 % POD | +8 % DEF | **Aguantar la marea:** al caer bajo 30 % de Vida, +20 % mitigación durante 5 s (CD 60 s) |
| T5 | Quipu | Nudo de Yunque | Nudo Veloz | Quipu Mayor | Nudo de Raíz | Nudo de Chispa | +6 % POD | +8 % RES | **Leer el patrón:** +12 % daño a enemigos que ya te golpearon en los últimos 6 s |
| T6 | Vidrio | Vidrio Negro | Vidrio Cortante | Vidrio Claro | Vidrio Verde | Vidrio Fundido | +7 % POD | +9 % VIG/RES | **Reflejo:** 10 % del daño recibido se devuelve como daño Resonante |
| T7 | Silencio | Muro Mudo | Paso Mudo | Trazo Mudo | Raíz Muda | Chispa Muda | +8 % POD | +10 % tenacidad | **No escucho:** inmunidad a `olvido` y `silencio`; al recibir uno, se convierte en +10 % daño por 6 s |
| T8 | Eco | Eco de Yunque | Eco Veloz | Eco Escrito | Eco Vivo | Eco Ardiente | +9 % POD | +11 % RES | **Reverberar:** cada 5.º golpe repite el 40 % del daño de la habilidad usada |
| T9 | Ascua | Ascua Fuerte | Ascua Rápida | Ascua Escrita | Ascua Verde | Ascua Viva | +10 % POD | +12 % VIG/RES | **Combustión:** al gastar toda la Reserva, +15 % daño y +10 % celeridad durante 6 s |
| T10 | Nácar Primigenio | Nácar de Yunque | Nácar Veloz | Nácar Escrito | Nácar Vivo | Nácar Ardiente | +12 % POD | +14 % VIG/RES | **Primer Canto:** la definitiva no consume Reserva y su CD se reduce 20 % |

**Ejemplo desarrollado — Set Yunque de Cobre (T1, Bastión):**

| Pieza | Estadísticas | Fuente |
|-------|--------------|--------|
| Martillo de Yunque | +10 POD, +4 VIG | Jefe de tramo (Mordeluz Resonante Alfa) |
| Yelmo de Yunque | +5 VIG, +2 DEF | Crafteo T1 (Forja) |
| Peto de Yunque | +7 VIG, +5 DEF | Crafteo T1 (Forja) |
| Grebas de Yunque | +4 VIG, +3 DEF | Crafteo T1 (Forja) |
| Botas de Yunque | +3 AGI, +3 DEF | Crafteo T1 (Telar) |
| Sello de Yunque | +3 RES, +2 % crítico | Instancia Cueva del Eco |
| **Bonos** | 2 piezas +4 % POD · 4 piezas +6 % VIG · 6 piezas Escudo de cobre | — |

### 4.7 Sets alternativos

Además del set de clase, cada tramo ofrece vías alternativas para que el crafteo y el PvP tengan sentido:

| Tipo | Cantidad | Cómo se obtiene | Diferencia frente al set de clase |
|------|----------|-----------------|-----------------------------------|
| **Set de crafteo ofensivo** | 1 por tramo | Forja + materiales raros | +15 % POD, −10 % DEF; ideal para subir nivel |
| **Set de crafteo defensivo** | 1 por tramo | Forja + materiales de zona | +20 % DEF, −5 % POD; ideal para jefes |
| **Set de facción** | 4 (uno por facción), 3 niveles de mejora | Sellos de Ruta | Efecto firma temático; sin ventaja de poder sobre el set de clase |
| **Set PvP** | 1 por tramo desde T4 | Arena y zonas PvP | +10 % tenacidad, +8 % daño a jugadores, −10 % daño a criaturas |
| **Set cosmético** | Continuo | Tienda y temporada | Sin estadísticas (ver [13-shop.md](13-shop.md)) |

### 4.8 Rareza, fuentes y reciclaje

| Rareza | Color | Cómo se obtiene | Estadísticas |
|--------|-------|-----------------|--------------|
| Común | blanco | Botín de criatura común | Base del tramo |
| Fino | verde | Crafteo (85 %) o botín de élite | +10 % |
| Resonante | azul | Crafteo con material de jefe o instancia | +22 %, 1 ranura de grabado extra |
| Raro | violeta | Jefe de tramo, instancia dificultad aumentada | +35 %, efecto de set mejorado |
| Legendario | dorado | Raid, temporada, logro | +50 %, efecto firma único y aspecto propio |

Toda pieza no legendaria se puede **desmantelar** (40 % de materiales) o **vender** a NPC (35 % del precio base). Las piezas legendarias se pueden desmantelar pero no vender a NPC.

## 5. Crafteo

### 5.1 Estructura

Un solo sistema de crafteo con **cinco ramas** (una por afinación), cada una con 5 tiers. Se sube de tier fabricando, no con puntos.

| Rama | Estación | Especialidad |
|------|----------|--------------|
| **Forja** | Fragua (Bastión, Mina) | Armas y armaduras metálicas |
| **Cocina** | Fogón (Bastión, Puerto) | Comida, té, buffs de zona |
| **Telar** | Telar (Bosque, Puerto) | Capa, fibra, cuero, cosméticos de tela |
| **Resonancia** | Altar de nácar (nodos) | Afinado, recetas de res (endgame) |
| **Cantería** | Banco de piedra (Ruinas, Cordillera) | Piedras de retorno, mejoras de banco, grabados |

### 5.2 Reglas

- **Tiempo de crafteo:** 2 s (T1) a 20 s (T5). El crafteo continúa si el jugador cierra el panel, pero se cancela si se mueve más de 3 casillas.
- **Nunca se pierden materiales por fallo.** Un crafteo fallido devuelve el 70 % de los materiales y consume la tarifa de Cobre. Decisión explícita por P5 y por el público móvil.
- **Calidad:** cada receta tiene 15 % de probabilidad de salir `fino` (+10 % estadísticas base). Con `Afinado` aplicado a la estación, sube a 25 %.
- **Descubrimiento:** las recetas se aprenden por misión, facción, exploración o compra. No hay recetas "drop aleatorio de 0,1 %".
- **Desmantelar:** todo objeto crafteable se puede desmantelar y devuelve 40 % de materiales (60 % si es `fino`), sin devolver Cobre.

### 5.3 Tarifas de estación

| Tier | Tarifa en Cobre | Materiales típicos |
|------|-----------------|--------------------|
| T1 | 10 | 3 base |
| T2 | 40 | 4 base + 1 raro |
| T3 | 120 | 5 base + 2 raros + Nácar bruto |
| T4 | 350 | 6 + 3 raros + Nácar bruto ×2 |
| T5 | 900 | 8 + 4 raros + Nácar puro |

## 6. Afinado (encantamiento)

El **Afinado** sintoniza un objeto con una afinación (Brasa, Viento, Trazo, Savia o Chispa) usando **Grabados**, que se obtienen desmantelando objetos raros, en ruinas, o en eventos de temporada.

| Regla | Valor |
|-------|-------|
| Ranuras | 1 a nivel 1–19, 2 a nivel 20–39, 3 a nivel 40+ |
| Coste | Nácar bruto ×2 + 60 Cobre por intento (T1); escala por ranura |
| Éxito | 100 % hasta +1, 75 % a +2, 55 % a +3 (con grabado de tier correspondiente) |
| Fallo | **No se destruye el objeto.** Se pierde el grabado y el 50 % del Nácar; el objeto queda con una **Estabilidad** reducida (−10 % a futuros intentos, se recupera con Cantería) |
| Efecto | Cada afinación da +6 % al tipo correspondiente y, en la ranura 3, un efecto de set (p. ej. Brasa: +8 % escudo) |
| Reemplazo | Un grabado nuevo reemplaza al anterior sin penalización de objeto |

Ejemplo: `Filo de corriente + Viento +2` = +12 % daño Viento-equivalente (Físico/Resonante según la habilidad) y −8 % CD de `Paso de Ráfaga` en la ranura 3.

## 7. Mercado entre jugadores

### 7.1 Tablón de Rutas (subasta asíncrona)

Disponible desde el nivel 10 y en los bastiones de Candela y Puerto Salitre. Es la vía principal y funciona como sumidero de Cobre.

| Regla | Valor |
|-------|-------|
| Listados por jugador | 5 (ampliable a 10 con Sello de Ruta) |
| Duración | 48 h; al expirar, el objeto vuelve por correo |
| Tarifa de listado | 5 % del precio pedido (se paga al publicar, no se devuelve) |
| Impuesto de venta | 8 % del precio final (se descuenta al vendedor) |
| Cobre de la venta | Se cobra al retirar, no al vender; si no se retira en 30 días, se recicla al banco |
| Precio sugerido | Mediana de las últimas 20 transacciones del mismo objeto en 7 días |
| Historial | Público: precio, cantidad y fecha (nunca nombre del comprador) |
| Prohibido | Sellos de Ruta, cosméticos comprados con Lumbre, objetos de misión, Lumbre |

### 7.2 Comercio directo (cara a cara)

- Requiere que ambos jugadores estén a ≤ 4 casillas y fuera de combate.
- Ventana de intercambio con confirmación doble (ofrecer → bloquear → aceptar) durante 5 s.
- Al aceptar, si alguno se mueve o entra en combate, se cancela sin pérdidas.
- Cada intercambio queda registrado con ID de transacción, ítems y Cobre; es auditable en caso de estafa o bug.
- Límite: 20 intercambios directos por día y cuenta (anti-RMT).

### 7.3 Anti-abuso

| Riesgo | Mitigación |
|--------|-----------|
| Lavado de Cobre vía mercado | Log completo + detección de patrones circulares (mismo par de cuentas, precios absurdos) |
| Venta de cuentas | Sellos y cosméticos de temporada ligados a cuenta; alerta si cambia la huella del dispositivo |
| Bots de farmeo | Límite de botín por hora, verificación de patrón de input, reportes (ver [07-social.md](07-social.md) §5) |
| Duplicación por bugs | Toda transacción es idempotente con ID; el servidor rechaza operaciones no confirmadas |

## 8. Economía y facciones

Las facciones no venden objetos exclusivos de poder, pero sí **acceso**:

| Facción | Lo que compra el jugador con Sellos de Ruta | Coste moral |
|---------|---------------------------------------------|-------------|
| Ortecas del Alba | Recetas de ruta, mejoras de waypoint, descuento de viaje | Sube reputación orteca; baja con Los Que Callan |
| Casa Salitre | Recetas de conservación y comercio, ampliación de listados, encargos lucrativos | Baja reputación con Cantores y Ortecas |
| Cantores de Raíz | Recetas de poción y crafteo orgánico, semillas de terraza | Baja reputación con Casa Salitre |
| Los Que Callan | Grabados de Umbrío, cosméticos de silencio, encargos de sabotaje (PvP de facción) | Bloquea contenido orteca y te marca en zonas PvP |

Detalle de reputación y topes en [06-progression.md](06-progression.md) §5.

## 9. Implementación

```gdscript
# src/domain/economy/currency_rules.gd  (extracto, puro, sin nodos)
class_name CurrencyRules

const TARIFA_LISTADO := 0.05
const IMPUESTO_VENTA := 0.08
const PRECIO_VENTA_NPC := 0.35

static func tarifa_listado(precio_pedido: int) -> int:
    return int(floor(precio_pedido * TARIFA_LISTADO))

static func ganancia_venta(precio_final: int) -> int:
    return precio_final - int(floor(precio_final * IMPUESTO_VENTA))

static func precio_npc(precio_base: int) -> int:
    return int(floor(precio_base * PRECIO_VENTA_NPC))
```

Reglas de servidor:

- Ninguna operación de economía se ejecuta en el cliente (ADR-002). El cliente solo envía intenciones (`comprar`, `vender`, `listar`, `intercambiar`).
- Cada operación devuelve un resultado con `transaction_id`; si el cliente no recibe confirmación en 5 s, muestra "pendiente" y **no** actualiza el inventario local.
- El log `economy_log` (JSONL por servidor) registra: timestamp, actor, tipo, objeto, cantidad, motivo y resultado.
- Los precios de NPC se definen en `data/items/*.tres` como `precio_base`; nunca se hardcodean en UI.
