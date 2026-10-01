# 13 — Tienda premium: Lumbre, catálogo, precios y rotaciones

> Depende de: [10-monetization.md](10-monetization.md) (principios), [05-economy.md](05-economy.md) §2, [12-events.md](12-events.md) §4
> Implementación: catálogo en `src/data/shop/*.tres`, UI en `src/ui/shop/`, validación y entrega en `src/net/iap_service.gd` (servidor). Compra nativa vía **Google Play Billing** (Android) y **StoreKit** (iOS, futuro).

## 1. Estructura de la tienda

Seis pestañas, siempre en el mismo orden y sin ventanas emergentes de venta:

| Pestaña | Contenido | Moneda |
|---------|-----------|--------|
| **Destacados** | 3–6 artículos de la rotación + Pase de Ruta de temporada | Lumbre |
| **Atuendos** | Conjuntos y piezas por clase, zona, facción y temporada | Lumbre |
| **Monturas y mascotas** | Monturas, mascotas, efectos de movimiento | Lumbre |
| **Efectos y títulos** | Auras, estelas, efectos de arma, títulos, emotes | Lumbre |
| **Conveniencia** | Banco, mercado, cambios de nombre/apariencia, ranuras | Lumbre (copias, nunca estadísticas) |
| **Lumbre** | Paquetes de moneda (única pestaña con precio en dinero real) | Dinero real |

**Reglas de la tienda:**

- Nunca hay cuenta atrás de presión ("solo hoy") salvo descuentos de rotación, que se avisan con antelación y vuelven.
- Nada se vende en combate, ni durante una muerte, ni después de una derrota.
- El botón de compra muestra siempre: qué incluye, qué moneda, cuánto queda después y si ya lo tienes.
- Si el jugador ya posee el artículo, se muestra "En tu colección" y no se puede volver a comprar.

## 2. Paquetes de Lumbre (dinero real)

Referencia base en USD; los precios regionales los fija la tienda (tabla de equivalencias en §2.2).

| Paquete | Lumbre | Bono | Precio USD | Precio por 100 Lumbre |
|---------|--------|------|-----------|----------------------|
| Bolsa de brasas | 100 | — | $0,99 | $0,99 |
| Cofre pequeño | 550 | +10 % | $4,99 | $0,91 |
| Cofre mediano | 1.200 | +20 % | $9,99 | $0,83 |
| Cofre grande | 2.500 | +25 % | $19,99 | $0,80 |
| Cofre del Coro | 6.500 | +30 % | $49,99 | $0,77 |
| Cofre del Primer Canto | 14.000 | +40 % | $99,99 | $0,71 |

Reglas:

- **Sin compras repetibles automáticas**, sin suscripción obligatoria ni "pase de batalla" obligatorio.
- El primer paquete de cada cuenta tiene **+50 % de bono único** (oferta de bienvenida visible y sin urgencia artificial).
- No hay anuncios de vídeo para ganar Lumbre; la Lumbre gratis viene de eventos ([12-events.md](12-events.md) §4 y [10-monetization.md](10-monetization.md) §5).

### 2.1 Cómo se gasta la Lumbre (referencia de precios)

| Artículo | Precio en Lumbre | Equivalente USD aproximado |
|----------|------------------|----------------------------|
| Conjunto cosmético completo (6 piezas visuales) | 1.200 | $9,99 |
| Conjunto de temporada (con arma y efecto) | 1.500 | $12,49 |
| Pieza suelta (casco, capa, arma) | 300–450 | $2,49–3,99 |
| Montura | 1.200–2.500 | $9,99–19,99 |
| Mascota | 600–1.200 | $4,99–9,99 |
| Efecto de arma | 350–700 | $2,99–5,99 |
| Aura o estela | 300–600 | $2,49–4,99 |
| Título | 150–300 | $1,49–2,49 |
| Emote | 200 | $1,99 |
| Pase de Ruta (temporada de 8 semanas) | 900 | $8,99 |
| Pase de Ruta + 10 niveles | 1.600 | $12,99 |
| Suscripción Orteca de Honor (mensual) | 450 | $4,99 |

### 2.2 Precios regionales (referencia)

Los precios exactos los aplica la tienda de cada país; esta tabla es la guía de producto y de comunicación.

| País | Moneda | Bolsa | Cofre pequeño | Cofre mediano | Cofre grande |
|------|--------|-------|---------------|---------------|--------------|
| Estados Unidos | USD | $0,99 | $4,99 | $9,99 | $19,99 |
| Chile | CLP | $990 | $4.990 | $9.990 | $19.990 |
| México | MXN | $19 | $99 | $199 | $399 |
| Brasil | BRL | R$ 4,99 | R$ 24,90 | R$ 49,90 | R$ 99,90 |
| España | EUR | €0,99 | €4,99 | €9,99 | €19,99 |
| Argentina | ARS | ajustado por tienda | — | — | — |

## 3. Pase de Ruta

Duración: 8 semanas (una temporada). Dos pistas: **gratis** y **premium**.

| Nivel del pase | Pista gratis | Pista premium (900 Lumbre) |
|----------------|--------------|----------------------------|
| 1–10 | Cobre escalado, 30 Lumbre, 1 cosmético básico | Conjunto de temporada (6 piezas) |
| 11–20 | Grabado común, 30 Lumbre, emotes | Montura de temporada |
| 21–30 | Nácar, 30 Lumbre, título | Efecto de arma + 150 Lumbre de vuelta |
| 31–40 | Cobre, 30 Lumbre, cosmético de pase | Mascota + 150 Lumbre de vuelta + variante de color del conjunto |
| **Total** | **120 Lumbre + 4 cosméticos** | **300 Lumbre + 6 cosméticos + montura** |

Reglas:

- El pase **no vende niveles con dinero** más allá del paquete "+10 niveles" (que solo acelera, no otorga nada exclusivo).
- Se puede completar la pista con ~4 h de juego por semana (objetivos semanales) o ~8 h sin objetivos.
- Todo lo del pase premium es cosmético. La pista gratis da la misma cantidad de economía (Cobre/Nácar) que la premium.
- Los cosméticos de temporada vuelven a la tienda 12 meses después, a precio de catálogo.

## 4. Suscripción "Orteca de Honor"

| Aspecto | Detalle |
|---------|---------|
| Precio | 450 Lumbre/mes o **USD 4,99/mes** directo (más barato con Lumbre) |
| Beneficios | Cosmético mensual exclusivo (se conserva si cancelas), +2 listados de mercado, +20 ranuras de banco mientras esté activa, 1 teletransporte gratis al día, +30 min de tope de Lumbre de Descanso |
| Lo que NO da | Nada de combate, XP extra, botín extra, acceso a zonas ni ventajas de poder |
| Renovación | Aviso 3 días antes; cancelación en 2 toques; sin penalización |
| Acumulación | Los cosméticos mensuales no se pierden al cancelar |

## 5. Conveniencia (con topes)

| Artículo | Precio | Tope | Alternativa jugable |
|----------|--------|------|---------------------|
| +20 ranuras de banco | 300 Lumbre | 5 compras (100 ranuras) | +100 ranuras con Sellos de Ruta |
| +2 listados de mercado | 250 Lumbre | 2 compras (4 listados) | +3 listados con Sellos de Ruta |
| Cambio de nombre | 400 Lumbre | 1 por mes | — |
| Cambio de apariencia completo | 250 Lumbre | Ilimitado (por personaje) | — |
| Ranura de personaje extra | 600 Lumbre | 6 compras (hasta 7 personajes) | — |
| Token de reespecialización | 150 Lumbre | Ilimitado | Gratis hasta nivel 30; luego con Cobre |
| Pase de Ruta +10 niveles | 700 Lumbre | 1 por temporada | Se completa jugando |

## 6. Rotaciones y descuentos

| Rotación | Cadencia | Contenido | Descuento |
|----------|----------|-----------|-----------|
| **Vitrina diaria** | Cada 24 h (04:00 UTC) | 3 cosméticos + 1 artículo de conveniencia | −15 % |
| **Destacado semanal** | Lunes 04:00 UTC | 1 conjunto + 1 montura o mascota | −25 % |
| **Temporada** | 8 semanas | Conjunto, montura, mascota, efectos nuevos | Precio de catálogo |
| **Feria de Yatiri** (en el juego, con Cobre) | Viernes a domingo | Stock raro, no premium | — |
| **Aniversario** | 1 vez al año | Regreso de cosméticos históricos | −30 % |

Reglas de rotación:

- La vitrina diaria **nunca** incluye nada que se pueda terminar para siempre: todo vuelve.
- No hay "ofertas relámpago" de menos de 24 h.
- Los descuentos se anuncian en el calendario de eventos y en el canal de sistema, no con ventanas emergentes.

## 7. Pagos, impuestos y reembolsos

| Aspecto | Decisión |
|---------|----------|
| Pasarela | Google Play Billing en Android (obligatorio); StoreKit en iOS (futuro) |
| Precios | Con impuestos incluidos según lo que exija la tienda; el precio mostrado es el final |
| Métodos | Los que ofrezca la tienda (tarjeta, saldo, operadores locales) |
| Reembolsos | Política de la tienda: ventana de 48 h en compras no consumidas; en el juego, "Historial de compras" con botón de solicitud |
| Reembolso de Lumbre gastada | No reembolsable una vez gastada en un cosmético (se informa antes de confirmar) |
| Entrega fallida | Reintento automático; si falla, botón "Reclamar" y entrega por correo |
| Fraude | Verificación de recibo en servidor; bloqueo temporal de compras si el recibo es inválido o duplicado |
| Datos personales | No se almacenan datos de tarjeta; solo identificador de transacción y recibo firmado |

## 8. Garantías anti-P2W verificadas en CI

El catálogo premium se valida automáticamente antes de cada release:

```gdscript
# tests/domain/test_shop_no_power.gd (extracto)
func test_no_shop_item_grants_power() -> void:
    for item in ShopCatalog.all():
        assert_false(item.has_stat_bonus(), "%s otorga estadísticas" % item.id)
        assert_false(item.grants_xp_bonus(), "%s otorga XP" % item.id)
        assert_false(item.grants_loot_bonus(), "%s otorga botín" % item.id)
        assert_false(item.is_random(), "%s tiene azar pagado" % item.id)
        if item.category == "conveniencia":
            assert_true(item.has_earnable_alternative(), "%s no tiene alternativa jugable" % item.id)
```

Si un artículo nuevo rompe cualquiera de estas condiciones, el pipeline de CI falla y no se publica.

## 9. Implementación

- `ShopCatalog` (datos) define: id, categoría, precio en Lumbre, moneda alternativa si existe, tope, cosmético asociado y si es de rotación.
- La tienda **lee** el catálogo del servidor; nunca confía en el cliente para el precio ni para el saldo.
- Flujo de compra con Lumbre: solicitud del cliente → validación de saldo en servidor → descuento → entrega → evento `purchase_completed`. Cada paso es idempotente con `transaction_id`.
- Flujo con dinero real: Google Play → recibo firmado → servidor valida con la API → acredita Lumbre → evento `currency_granted`.
- Modo prueba (`sandbox`) en servidor de desarrollo con recibos simulados; nunca se activa en producción (`OS.has_feature("production")` es el gate).
- Auditoría: cada compra y gasto queda en `shop_log` (JSONL) con id, cuenta, artículo, moneda, importe y resultado, retenido 5 años para contabilidad.
