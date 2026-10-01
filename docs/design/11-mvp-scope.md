# 11 — Alcance del MVP

> Depende de: todo `docs/design/`, en especial [04-world.md](04-world.md) §4 T1 y [06-progression.md](06-progression.md) §2
> Restricción base: **1 desarrollador, 3 meses reales, $0 en assets, Android real, servidor autoritativo ENet**.

## 1. Definición del MVP

**El MVP es el Tramo T1 completo, jugable en línea con otras personas.**

No es una demo técnica ni un vertical slice de una sola zona: es el primer tramo íntegro del juego (niveles 1–15), con principio, final de tramo, economía cerrada y cooperación real. Se elige el tramo en vez de "un poco de todo" porque el juego vende tramos completos ([04-world.md](04-world.md) §1) y porque permite publicar y medir antes de construir el resto.

### 1.1 Qué entra en el MVP

| Área | Incluido | Cantidad |
|------|----------|----------|
| Zonas persistentes | Bastión de Candela, Prado de Senda, Bosque del Reverso | 3 |
| Instancia | Cueva del Eco (1–3 jugadores) | 1 |
| Niveles | 1 a 15 | — |
| Clases | Bastión de Brasa (tanque), Forjador de Chispas (DPS), Cantor de Raíces (soporte) | 3 |
| Habilidades | 7 por clase (básico + 5 + definitiva) | 21 |
| Talentos | 1 rama completa por clase (10 nodos) + 2 ramas parciales (4 nodos) | 3 × ~18 |
| Criaturas | 5 familias × 4 variantes | 20 |
| Jefes | Mordeluz Resonante Alfa (tramo) + Mordeluz Resonante (instancia) | 2 |
| Equipo | Sets T1 de las 3 clases + set de crafteo ofensivo/defensivo + armas iniciales | ~45 objetos |
| Objetos totales | Equipo, consumibles, materiales | ~70 |
| Crafteo | Forja, Cocina, Telar (T1–T2) | 3 ramas, 24 recetas |
| Economía | Cobre, Nácar bruto, Sellos de Ruta, Lumbre (solo cosmética) | — |
| NPCs | Nara, Oren, Mira, Sio, Yatiri + 2 secundarios | 7 |
| Misiones | Cadena principal (6) + 5 por zona + 3 encargos repetibles | 14 |
| Eventos | Encender ruta (cada 6 h), Defensa del bastión (diario), Cacería del día, encargos diarios | 4 |
| Social | Chat (zona, party, global, susurro), party de 3, amigos/ignorar/reportar | — |
| Networking | Servidor dedicado headless + cliente, ENet autoritativo, 8 jugadores por zona | — |
| Android | APK ARM64/OpenGLES3 en dispositivo real, 60 FPS objetivo, 30 FPS mínimo | — |
| Tienda | Catálogo de 12 cosméticos + paquetes de Lumbre (compra desactivada hasta la build pública) | 12 |
| Guardado | Progreso por cuenta en servidor + caché local | — |

### 1.2 Qué NO entra en el MVP

| Excluido | Cuándo entra | Por qué se corta |
|----------|--------------|------------------|
| Zonas T2–T10 | v1.1–v1.3 | Cada tramo es una entrega completa por sí misma |
| Clases Hiladora y Lector | v1.1 | 3 clases cubren tanque/DPS/soporte; las otras dos llegan con su animación y balance |
| PvP (zonas, arenas, guerras) | vertical slice | Requiere servidor estable, telemetría y anti-griefing probado |
| Gremios | vertical slice | Party de 3 primero; gremio necesita backend |
| Mercado entre jugadores | vertical slice | Necesita auditoría de transacciones y volumen |
| Raids | v1.1+ | Nivel 135+ no existe en MVP |
| Mazmorras aumentadas | v1.1 | Requiere instancias estables |
| Monturas y mascotas | v1.1 | Cosmético, no crítico |
| Estación de temporada completa | v1.1 | El MVP tiene eventos rotativos, no temporada global |
| Nivel de Resonancia (post-150) | v1.3 | No aplica sin nivel 150 |
| 6.ª clase | v1.2 en evaluación | Sin telemetría de estados Umbríos |
| iOS | v2.0 | Android primero (ADR-004) |
| Backend Node/PostgreSQL | fase 5+ (ADR-007) | El MVP persiste en servidor Godot con archivos |

## 2. Presupuesto de tiempo (12 semanas, 1 dev)

| Semanas | Foco | Entregable verificable |
|---------|------|------------------------|
| 1 | Cimientos de dominio | `domain/` con combate, XP, economía, estados y tests en verde |
| 2 | Movimiento y cámara en servidor | Jugador autoritativo moviéndose con predicción básica |
| 3 | Combate PvE | Golpe, daño, muerte, respawn, UI de Vida |
| 4 | Criaturas e IA | 5 familias × variantes, patrullas, manadas, emboscadas |
| 5 | Zona 1 y 2 | Bastión y Prado jugables con tiles, colisiones y NPCs |
| 6 | Habilidades y clases | 3 clases con 7 habilidades cada una |
| 7 | Loot, inventario y equipo | 70 objetos, sets T1, equipamiento con comparación |
| 8 | Crafteo y economía | 3 ramas, 24 recetas, tiendas NPC, Cobre/Nácar/Sellos |
| 9 | Misiones y NPCs | 14 misiones, diálogos, tablón de encargos |
| 10 | Instancia + jefes | Cueva del Eco, 2 jefes con fases |
| 11 | Multiplayer y social | 8 jugadores por zona, party de 3, chat, 4 eventos |
| 12 | Android, tienda y pulido | APK en dispositivo, tienda de cosméticos, ajustes, balance, telemetría |

Regla de las 12 semanas: **si una semana se atrasa, se recorta contenido del tramo, no calidad ni pruebas.** El recorte preferente es: tercer set de crafteo → 3 recetas → 1 secundario de zona → 1 encargo repetible.

## 3. Criterio de "MVP listo"

El MVP está listo cuando **las 12 condiciones** se cumplen y son verificables:

1. Un jugador nuevo instala el APK, crea personaje y completa el onboarding en menos de 5 minutos ([08-ui-ux.md](08-ui-ux.md) §5).
2. Sube de nivel 1 a 15 en 4–6 h de juego real.
3. Enciende una ruta de resonancia y ve el cambio de estado del mundo.
4. Completa la Cueva del Eco con otras dos personas sin usar chat externo.
5. Mata al jefe de tramo y recibe el arma del set T1.
6. Craftea y equipa un set completo de 6 piezas.
7. Vende y compra en una tienda NPC con Cobre obtenido jugando.
8. Dos jugadores se encuentran en la misma zona, se ven moverse y luchan juntos contra la misma criatura (servidor autoritativo).
9. La sesión de 30 minutos no tiene caídas ni bugs bloqueantes.
10. 60 FPS en un gama media y ≥ 30 FPS en el mínimo soportado, con ≤ 220 KB/s de ancho de banda por zona con 8 jugadores.
11. La suite de tests pasa: dominio (GUT), integración de red con 8 clientes simulados, y CI en verde.
12. Ningún objeto de tienda otorga poder (test `test_shop_no_power.gd` en verde) y el catálogo de Lumbre funciona en modo sandbox.

## 4. Qué se posterga y cuándo

| Versión | Contenido | Niveles | Cuándo |
|---------|-----------|---------|--------|
| **MVP** | T1: 3 zonas, 1 instancia, 1 jefe de tramo, 3 clases | 1–15 | Mes 3 |
| **v1.1 (vertical slice)** | T2 completo, 4.ª clase (Hiladora), party de 5, gremios (10), mercado entre jugadores, PvP opt-in, eventos semanales | 16–30 | Mes 6 |
| **v1.2** | T3–T4, 5.ª clase (Lector), arenas 3v3, sets alternativos, mazmorras aumentadas +1/+2, temporada 1 | 31–60 | Mes 9 |
| **v1.3** | T5–T7, jefe mundial, endgame temprano, tienda completa, temporadas 2–3 | 61–105 | Mes 12 |
| **v2.0** | T8–T10, raids de 5 y 10, Nivel de Resonancia, 6.ª clase, iOS, mar de Nácar | 106–150 | Mes 18–24 |

## 5. Riesgos del MVP y mitigación

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| El multiplayer autoritativo come más tiempo que el gameplay | Alta | Alto | Sincronizar solo lo esencial (posición, Vida, estados, eventos) y usar `MultiplayerSynchronizer`; el resto por `@rpc` |
| El arte CC0 no alcanza la identidad visual | Media | Medio | Paleta y siluetas propias desde el día 1 (ADR-009); reemplazo por fases ([09-art-audio.md](09-art-audio.md) §2) |
| Balance entre 3 clases y 20 criaturas | Media | Medio | Tests de balance por tramo y tabla de referencia de Vida/Defensa ([03-combat.md](03-combat.md) §7.1) |
| Rendimiento en Android de gama baja | Media | Alto | Presupuesto de 40 IA activas, atlas ≤ 2048, UI ≤ 40 draw calls, perfilado semanal |
| Alcance del tramo T1 se infla | Alta | Alto | Lista cerrada de §1.1; recorte por orden definido en §2 |
| Tienda percibida como P2W | Baja | Alto | CI anti-poder ([13-shop.md](13-shop.md) §8) y comunicación clara |

## 6. Gates técnicos antes de cerrar el MVP

```bash
# Gates de CI (ver docs/07-testing.md)
godot --headless --script tests/run_tests.gd                    # dominio y reglas puras
godot --headless --script tests/net/run_net_tests.gd --clients 8  # 8 clientes simulados
godot --headless --script tests/perf/zone_budget_test.gd         # 40 IA, 90 entidades, 220 KB/s
godot --headless --script tests/domain/test_balance_bands.gd     # bandas de daño por clase y tramo
godot --headless --script tests/domain/test_shop_no_power.gd     # tienda sin poder
godot --headless --script tests/domain/test_events_reset.gd      # reinicio diario/semanal en UTC
```

Cada gate debe pasar en verde en CI y en local antes de publicar la build del MVP. Un gate en rojo bloquea el release, sin excepción.
