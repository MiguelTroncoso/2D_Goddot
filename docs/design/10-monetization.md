# 10 — Monetización

> Depende de: [00-vision.md](00-vision.md) §3, [05-economy.md](05-economy.md) §2 · Catálogo y precios en [13-shop.md](13-shop.md) · Eventos y Lumbre gratis en [12-events.md](12-events.md)
> Implementación: validación de compras en servidor (`src/net/iap_service.gd`) + recibo firmado del store; la entrega de cosméticos va por `systems/cosmetic_system.gd`. Nunca se confía en el cliente.

## 1. Principios no negociables

1. **Nada de poder comprable.** Ningún objeto de la tienda modifica daño, Vida, mitigación, curación, XP, botín, velocidad ni acceso a contenido.
2. **Nada de azar pagado.** Sin loot boxes con dinero real, sin gacha, sin "sobres" con probabilidad. Todo lo pagado se ve antes de comprar.
3. **Sin anuncios.** No hay publicidad de terceros, ni recompensada, ni intersticial.
4. **Sin energía ni bloqueos.** No hay vidas, energía, cooldown de partida ni "espera o paga".
5. **Todo lo de conveniencia se puede ganar jugando**, más lento, pero sin muro de pago (ver §3).
6. **Los cosméticos vuelven.** Todo cosmético de pago reaparece en rotación cada 6–12 meses; nada es "solo una vez" para siempre.
7. **Transparencia.** Precio claro en moneda local, historial de compras visible en la cuenta y sin renovación automática oculta.
8. **Un menor no puede gastar sin control.** Ver §6.

Si una propuesta de monetización rompe cualquiera de estos 8 puntos, no entra.

## 2. Modelo

**F2P con cuatro líneas de ingreso, ordenadas por importancia prevista:**

| Línea | Qué es | % de ingreso estimado | Riesgo ético |
|-------|--------|------------------------|--------------|
| **Cosméticos directos** | Conjuntos, piezas, monturas, mascotas, efectos, títulos | 55 % | Bajo |
| **Pase de Ruta** (temporada de 8 semanas) | Pista de recompensas con cosméticos y monedas de conveniencia | 25 % | Bajo si la pista gratis da la misma cantidad de economía |
| **Conveniencia acotada** | Banco, listados de mercado, cambio de nombre/apariencia, ranuras de personaje | 15 % | Medio (se mitiga con topes y alternativa jugable) |
| **Suscripción "Orteca de Honor"** | Cosmético mensual + comodidades, canjeable por Lumbre | 5 % | Bajo |

**Moneda premium: Lumbre.**

- Se compra con dinero real (paquetes en [13-shop.md](13-shop.md) §2) o se gana jugando entre **20 y 40 por día** con actividades normales (eventos diarios, primer objetivo del día, logros, temporada).
- **No se puede cambiar por Cobre** ni el Cobre por Lumbre.
- Los precios de la tienda están fijos en Lumbre; el tipo de cambio no fluctúa.
- Lumbre no caduca ni se consume por inactividad.

Tiempo de referencia: un cosmético de 800 Lumbre equivale a ~25–40 días de juego activo sin gastar, o a USD 7,99.

## 3. Qué es gratis y qué es pago

### 3.1 Gratis (100 % del juego)

| Contenido | Detalle |
|-----------|---------|
| Todo el mundo | Las 30 zonas, 10 instancias, 4 raids, arenas y jefes mundiales |
| Todo el poder | Niveles 1–150, sets de equipo, grabados, talentos, consumibles |
| Toda la economía | Cobre, Nácar, Sellos de Ruta, mercado entre jugadores, crafteo |
| Todo el social | Chat, party, gremios de 40, guerras, PvP |
| Progresión horizontal | Bestiario, colecciones, logros, títulos ganados jugando |
| Lumbre gratis | 20–40/día + 100 al llegar a nivel 15 + recompensas de temporada |
| Aspectos base | 6 paletas de color por clase + cosméticos de facción y de jefe |

### 3.2 Pago (sin ventaja)

| Categoría | Ejemplos | Límite |
|-----------|----------|--------|
| Conjuntos cosméticos | Atuendos de temporada, temáticos de zona, de facción | Sin límite de compra |
| Piezas sueltas | Cascos, armas, capas, efectos de arma | Sin límite |
| Monturas y mascotas | Visuales; velocidad idéntica al caminar base (0 ventaja) | Sin límite |
| Efectos y animaciones | Aura de nivel, estela, montura voladora cosmética | Sin límite |
| Títulos | Texto bajo el nombre | Sin límite |
| Conveniencia de banco | +20 ranuras | Máx. 5 compras (100 ranuras extra); +100 adicionales por Sellos |
| Conveniencia de mercado | +2 listados | Máx. 2 compras; alternativa por Sellos |
| Cambio de nombre / apariencia | Servicio puntual | 1 por mes por cuenta |
| Ranura de personaje | +1 personaje | Máx. 6 compras (7 personajes) |
| Token de reespecialización | Reespecialización sin coste de Cobre | Sin límite (también gratis hasta nivel 30) |
| Pase de Ruta | Pista premium de temporada | 1 por temporada |
| Suscripción | Cosmético mensual + comodidades | 1 activa |

### 3.3 Comparación explícita con lo que NO se venderá

| Tentación típica del género | Decisión |
|-----------------------------|----------|
| Pociones de Vida en tienda | No. Solo con Cobre y crafteo |
| Boost de XP | No. Existe la Lumbre de Descanso, gratis y con tope |
| Equipo con estadísticas | No, nunca |
| Venta de oro | No |
| Cofres con probabilidad | No |
| Entradas de mazmorra | No |
| Renacimiento instantáneo pagado | No |
| Ventaja de inventario ilimitado | No: tope alto, pero tope |

## 4. Roadmap de contenido post-lanzamiento

| Versión | Cuándo | Contenido | Monetización asociada |
|---------|--------|-----------|-----------------------|
| **1.0** | Lanzamiento | T1–T7 (niveles 1–105), 21 zonas, 7 instancias, 7 jefes de tramo, arenas 1v1/3v3, temporada 1 | Cosmético base + Pase de Ruta 1 |
| **1.0.x** | Semanal | Correcciones, ajustes de balance, rotación de tienda | Sin novedad de pago |
| **1.1** | +2 meses | T8 (106–120), instancia de 5, mazmorras aumentadas +1/+2 | Conjunto de temporada 2, montura |
| **1.2** | +4 meses | T9 (121–135), raid de 5, arenas 3v3 clasificatorias, 6.ª clase en evaluación | Pase 2, cosméticos de raid |
| **1.3** | +6 meses | T10 (136–150), raid de 10, jefe mundial rotativo | Pase 3, legendario cosmético |
| **2.0** | +12 meses | Mar de Nácar (nuevo continente, 5 zonas, nivel 150–200 en evaluación) | Expansión de contenido gratis + cosméticos |

Cada temporada de 8 semanas añade: 1 pase, 1 conjunto de temporada, 1 montura, 1 mascota, 3–5 cosméticos sueltos, 1 variante de zona y 1 jefe mundial rotativo.

## 5. Economía de la Lumbre

| Fuente gratuita | Lumbre | Frecuencia |
|-----------------|--------|-----------|
| Primer objetivo del día (encargo) | 10 | Diaria |
| Evento diario completo | 10 | Diaria |
| Evento semanal completo | 40 | Semanal |
| Subir de nivel (cada 10 niveles) | 20 | 15 veces hasta 150 |
| Logros (120 iniciales) | 5–25 cada uno | Puntual |
| Pista gratis del Pase de Ruta | 120 por temporada | 8 semanas |
| Recompensa de temporada (Voz/honores) | 100 | 8 semanas |
| **Total estimado** | **≈ 25–40/día** | — |

**Sumidero de Lumbre:** solo cosméticos y conveniencia. No hay conversión ni apuestas. El saldo se muestra en la tienda y en la cuenta; el historial de compras es exportable.

## 6. Protecciones al jugador

| Riesgo | Medida |
|--------|--------|
| Gasto por menores | Declaración de edad en la cuenta; si es menor, la tienda queda bloqueada salvo autorización con PIN adulto |
| Gasto impulsivo | Límite de gasto configurable (diario/semanal/mensual) por el propio jugador o por el tutor |
| FOMO agresivo | Los cosméticos rotan y vuelven; nunca hay "última oportunidad" en menos de 6 meses |
| Suscripciones olvidadas | Recordatorio 3 días antes de renovar y cancelación en 2 toques desde el juego |
| Compras duplicadas | Bloqueo de recompra automática de lo ya poseído |
| Fallo de entrega | Reintento automático + entrega diferida por correo; botón "Reclamar" en la cuenta |
| Reembolsos | Política alineada con Google Play; nunca se reembolsa lo ya consumido (p. ej. cambio de nombre) |
| Cuentas robadas | 2FA opcional, historial de dispositivos, bloqueo de compras desde un dispositivo nuevo por 24 h |

## 7. Indicadores de salud (no de extracción)

| Métrica | Objetivo | Señal de alarma |
|---------|----------|-----------------|
| Conversión de jugadores activos | 2–5 % | > 8 % (presión excesiva) |
| Gasto del 1 % que más gasta | < 12 % del ingreso total | > 25 % (dependencia de ballenas) |
| Ingreso por jugador activo mensual | USD 0,35–0,80 | > 1,50 |
| % de ingreso por cosméticos | ≥ 55 % | < 35 % (conveniencia dominante) |
| Quejas por monetización | < 1 % de tickets | > 3 % |
| Retención D7 / D30 | ≥ 25 % / ≥ 8 % | < 15 % / < 4 % |

## 8. Implementación

- La tienda **no** se renderiza con precios hardcodeados: el catálogo viene de `data/shop/catalog.tres` + configuración del servidor (precio regional, rotación).
- Toda compra se valida en el servidor contra el recibo firmado del store antes de entregar el cosmético (ADR-002). Si el recibo no se puede verificar, se entrega en modo "pendiente" y se resuelve por correo.
- Los cosméticos son **datos de apariencia** (IDs en `CosmeticDefinition`), no objetos de inventario con estadísticas: no entran al mercado ni al comercio entre jugadores.
- Los tests deben verificar que ningún `ShopItemDefinition` tenga campos de combate (`poder`, `vida`, `defensa`, `xp_bonus`) — gate de CI (ver [11-mvp-scope.md](11-mvp-scope.md) §6).
