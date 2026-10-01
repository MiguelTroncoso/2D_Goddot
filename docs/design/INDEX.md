# Índice del diseño y checklist de coherencia

> Carpeta: `docs/design/` · Proyecto: **Lumbre de Nácar** (MMORPG 2D top-down, Godot 4.4, Android)
> Moneda de verdad de estos documentos: si dos documentos se contradicen, gana el que define el número (indicado en la tabla de coherencia) y el otro se corrige en el mismo commit.

## 1. Índice

| # | Archivo | Qué contiene | Depende de |
|---|---------|--------------|------------|
| 00 | [00-vision.md](00-vision.md) | Pitch, 5 pilares, público, diferenciadores, alcance por etapa, restricciones técnicas | — |
| 01 | [01-lore.md](01-lore.md) | Mundo Astreva, 4 eras, cosmología de la resonancia, 4 facciones, 8 NPCs clave, guía de tono | 00 |
| 02 | [02-classes.md](02-classes.md) | 5 clases, 7 habilidades cada una, curva 1–150, sinergias, datos en `data/` | 00, 01, 03 |
| 03 | [03-combat.md](03-combat.md) | Modelo de combate, fórmulas de daño/crítico/mitigación, 19 estados, IA (9 patrones), ritmo y jefes | 01, 02 |
| 04 | [04-world.md](04-world.md) | 30 zonas persistentes, 10 instancias, 4 raids, 10 jefes de tramo, 16 familias de criaturas, spawn, rutas | 01, 03 |
| 05 | [05-economy.md](05-economy.md) | Monedas, fuentes/sumideros, catálogo base, **10 tramos de sets completos**, crafteo, afinado, mercado | 01, 03, 04 |
| 06 | [06-progression.md](06-progression.md) | Curva de XP 1–150, atributos, 3 ramas de talento por clase, reputación, endgame y Resonancia | 02, 03, 04 |
| 07 | [07-social.md](07-social.md) | Chat, party, gremios, PvP, amigos/ignore/report, antifraude social | 03, 04 |
| 08 | [08-ui-ux.md](08-ui-ux.md) | Orientación horizontal, wireframes (HUD, inventario, party, chat, talentos, mapa), controles táctiles, onboarding de 5 min | 00, 02, 07 |
| 09 | [09-art-audio.md](09-art-audio.md) | Paleta, resoluciones, animaciones, assets CC0 por fase, dirección musical y SFX | 01, 04 |
| 10 | [10-monetization.md](10-monetization.md) | F2P cosmético, 8 principios, gratis vs pago, roadmap de contenido, protecciones al jugador | 00, 05 |
| 11 | [11-mvp-scope.md](11-mvp-scope.md) | Qué entra en 3 meses, plan semanal, 12 criterios de "MVP listo", riesgos, gates de CI | todos |
| 12 | [12-events.md](12-events.md) | Eventos diarios, semanales, mensuales y de temporada; horarios UTC; contribución; calendario | 04, 06, 10 |
| 13 | [13-shop.md](13-shop.md) | Paquetes de Lumbre y precios, catálogo, Pase de Ruta, suscripción, conveniencia, rotaciones, reembolsos | 05, 10, 12 |
| — | [INDEX.md](INDEX.md) | Este archivo: índice, glosario y checklist de coherencia | — |

### 1.1 Glosario mínimo

| Término | Significado |
|---------|-------------|
| **Tramo** | Banda de 15 niveles con 3 zonas, 1 instancia, 1 jefe y 1 set por clase (T1 = 1–15 … T10 = 136–150) |
| **Resonancia** | Fuerza cosmológica que sostiene la realidad; también nombre del atributo de recurso |
| **Reserva** | Recurso de clase (Calor, Impulso, Trazos, Savia, Carga) |
| **Nodo / ruta** | Punto y conexión que cambian el estado del mundo (`encendida`, `tenue`, `apagada`, `corrompida`) |
| **Contribución** | Aporte medido (daño, curación, control, entregas) que habilita botín y recompensas de evento |
| **Cobre / Sellos / Lumbre** | Moneda blanda / moneda de facción intransferible / moneda premium cosmética |
| **Mella** | Penalización temporal tras morir (−10 % atributos, 180 s) |

## 2. Checklist de coherencia

Cada punto debe poder verificarse abriendo los documentos citados. Se revisa antes de cada entrega de contenido.

### 2.1 Números canónicos

| # | Verificación | Dónde se define | Dónde se usa |
|---|--------------|-----------------|--------------|
| C1 | Nivel máximo **150**, en 10 tramos de 15 niveles | [06-progression.md](06-progression.md) §1, [04-world.md](04-world.md) §3 | [02-classes.md](02-classes.md) §3, [12-events.md](12-events.md) |
| C2 | XP: `40 × L² + 25 × L`; total ≈ 44,83 M hasta 150 | [06-progression.md](06-progression.md) §1.1 | [12-events.md](12-events.md) (recompensas de XP), [11-mvp-scope.md](11-mvp-scope.md) §3 |
| C3 | 3 atributos primarios + Agilidad con los mismos nombres en todos los documentos | [06-progression.md](06-progression.md) §3, [03-combat.md](03-combat.md) §2 | [02-classes.md](02-classes.md) §1.1, [05-economy.md](05-economy.md) §4.5 |
| C4 | Tres tipos de daño: Físico, Resonante, Umbrío | [01-lore.md](01-lore.md) §2.4 | [03-combat.md](03-combat.md) §2.2, [04-world.md](04-world.md) §5 |
| C5 | Vida base `120 + 26×(n−1) + 0,09×(n−1)²` y POD `10 + 1,9×(n−1) + 0,006×(n−1)²` | [02-classes.md](02-classes.md) §3.1 | [03-combat.md](03-combat.md) §7.1, [06-progression.md](06-progression.md) §3.2 |
| C6 | Presupuesto de daño por tramo (T1–T10) alineado entre clases y jefes | [02-classes.md](02-classes.md) §3.4, [03-combat.md](03-combat.md) §7.1 | [11-mvp-scope.md](11-mvp-scope.md) §6 |
| C7 | 30 zonas persistentes, 10 instancias, 10 jefes de tramo, 4 raids, 1 jefe mundial | [04-world.md](04-world.md) §1–§3, §6 | [00-vision.md](00-vision.md) §6, [11-mvp-scope.md](11-mvp-scope.md) §4 |
| C8 | 16 familias de criaturas × 4 variantes = 64 criaturas | [04-world.md](04-world.md) §5 | [03-combat.md](03-combat.md) §9.1, [09-art-audio.md](09-art-audio.md) §2 |
| C9 | 5 clases con 7 habilidades (básico + 5 + definitiva) y desbloqueos 1/5/15/30/60/90 | [02-classes.md](02-classes.md) §1 | [11-mvp-scope.md](11-mvp-scope.md) §1.1, [08-ui-ux.md](08-ui-ux.md) §3.4 |
| C10 | 10 tramos × 5 sets de clase = 50 sets, 6 piezas cada uno, con bonos 2/4/6 | [05-economy.md](05-economy.md) §4.5–4.7 | [09-art-audio.md](09-art-audio.md) §2.1, [11-mvp-scope.md](11-mvp-scope.md) §1.1 |
| C11 | Monedas: Cobre, Nácar (recurso), Sellos de Ruta, Lumbre; sin conversión entre ellas | [05-economy.md](05-economy.md) §2 | [10-monetization.md](10-monetization.md) §2, [13-shop.md](13-shop.md) §2 |
| C12 | Lumbre gratis ≈ 25–40/día | [10-monetization.md](10-monetization.md) §5 | [12-events.md](12-events.md) §2–§4, [13-shop.md](13-shop.md) §2.1 |

### 2.2 Coherencia entre sistemas

| # | Verificación | Estado |
|---|--------------|--------|
| K1 | **Cada clase usa estados definidos en `03-combat.md`**: Bastión → `quemadura`, `raiz`, Provocar; Hiladora → `ralentizacion`, `aturdimiento`; Lector → `corrosion`, `guia`, `raiz`; Cantor → `coral_savia`, `raiz`, limpieza; Forjador → `zumbido`, `aturdimiento`, `corrosion` | ✔ Todos los estados existen en la tabla de §5 de [03-combat.md](03-combat.md) |
| K2 | **Toda habilidad respeta la fórmula de daño canónica** y el plano por tramo | ✔ [02-classes.md](02-classes.md) §1, [03-combat.md](03-combat.md) §2.5 |
| K3 | **Cada tramo tiene jefe, instancia, set y 3 zonas** | ✔ [04-world.md](04-world.md) §4, [05-economy.md](05-economy.md) §4.6 |
| K4 | **Cada zona tiene al menos 1 razón para volver** (recurso, encargo, evento o jefe) | ✔ [04-world.md](04-world.md) §10 |
| K5 | **Todo evento entrega recompensas de economía/cosmética, nunca poder exclusivo** | ✔ [12-events.md](12-events.md) §1, [10-monetization.md](10-monetization.md) §1 |
| K6 | **La tienda no vende nada que afecte combate, XP, botín o acceso**, con test en CI | ✔ [13-shop.md](13-shop.md) §8, [10-monetization.md](10-monetization.md) §3.3 |
| K7 | **La conveniencia de pago tiene tope y alternativa jugable** | ✔ [13-shop.md](13-shop.md) §5, [10-monetization.md](10-monetization.md) §3.2 |
| K8 | **El móvil limita a 4 botones de acción + básico + definitiva** | ✔ [08-ui-ux.md](08-ui-ux.md) §2, [02-classes.md](02-classes.md) §1 |
| K9 | **La orientación es horizontal y coincide con `project.godot` (1280×720)** | ✔ [08-ui-ux.md](08-ui-ux.md) §1, ADR-004 |
| K10 | **Todo cálculo de daño, XP, loot y economía ocurre en servidor** | ✔ ADR-002, [03-combat.md](03-combat.md) §3, [06-progression.md](06-progression.md) §8, [05-economy.md](05-economy.md) §9 |
| K11 | **Los assets del MVP son CC0 o tienen licencia verificada y registro en `CREDITS.md`** | ✔ ADR-008, [09-art-audio.md](09-art-audio.md) §2 |
| K12 | **El lore explica cada sistema**: rutas ↔ P3, Ley L2 ↔ Reserva, Ley L3 ↔ inmunidad a miedo, cinco afinaciones ↔ cinco clases, cuatro facciones ↔ reputación | ✔ [01-lore.md](01-lore.md) §9 |
| K13 | **Cada documento cita a los otros** y ninguno introduce sistemas fuera de los 5 pilares | ✔ Revisar encabezados "Depende de" de los 14 archivos |
| K14 | **El MVP es alcanzable en 3 meses** con la lista cerrada de §1.1 y el recorte definido en §2 | ✔ [11-mvp-scope.md](11-mvp-scope.md) |
| K15 | **Ningún contenido requiere PvP para progresar en PvE** | ✔ [07-social.md](07-social.md) §5 |

### 2.3 Lista de verificación rápida antes de publicar contenido nuevo

1. ¿A qué tramo pertenece y respeta las bandas de Vida/daño de [03-combat.md](03-combat.md) §7.1?
2. ¿Qué set de tramo afecta o requiere ([05-economy.md](05-economy.md) §4.6)?
3. ¿Usa estados existentes o introduce uno nuevo? Si introduce, ¿está en la tabla de [03-combat.md](03-combat.md) §5 con duración, stacking y fuente?
4. ¿Qué eventos y encargos lo acompañan ([12-events.md](12-events.md))?
5. ¿Tiene algo que se pueda comprar con dinero real? Si sí, ¿está en [13-shop.md](13-shop.md) y pasa el test anti-poder?
6. ¿Cómo se implementa en `domain/`, `systems/`, `net/`, `data/` según ADR-005?
7. ¿Cuánto pesa en el presupuesto de red y de CPU ([11-mvp-scope.md](11-mvp-scope.md) §3, [04-world.md](04-world.md) §11)?
8. ¿Está escrito en menos de 120 caracteres por caja de diálogo y cabe en una pantalla de 5" ([08-ui-ux.md](08-ui-ux.md) §1.1)?
