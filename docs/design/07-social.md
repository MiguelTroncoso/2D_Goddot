# 07 — Sistemas sociales, party, gremios y PvP

> Depende de: [03-combat.md](03-combat.md) §6, [04-world.md](04-world.md) §2 · Afecta a: [08-ui-ux.md](08-ui-ux.md), [12-events.md](12-events.md), [13-shop.md](13-shop.md)
> Implementación: `src/net/chat_service.gd`, `src/systems/party_system.gd`, `src/systems/guild_system.gd`, `src/domain/social/`, UI en `src/ui/social/`.

## 1. Principios

1. **Cooperar debe ser más fácil que pelear** (pilar P2): eventos públicos sin grupo, party de un toque, botín por contribución.
2. **Todo canal tiene límite de frecuencia** y filtro: en móvil, el chat es la primera línea de abuso y de spam.
3. **Ningún sistema social otorga poder**: los gremios dan logística, cosméticos y guerras, no estadísticas.
4. **Moderación visible**: reportar tiene que ser un botón, no un formulario de 12 campos.

## 2. Chat

### 2.1 Canales

| Canal | Alcance | Comando | Límite | Notas |
|-------|---------|---------|--------|-------|
| **Zona** | Jugadores en la misma zona | `/z` | 5 mensajes / 15 s | Canal por defecto |
| **Global** | Todo el servidor | `/g` | 2 mensajes / 60 s | Solo nivel ≥ 10; cuesta 1 Cobre por mensaje (sumidero y anti-spam) |
| **Party** | Grupo (máx. 5) | `/p` | 10 / 15 s | También voz de texto rápido (pings) |
| **Gremio** | Gremio (máx. 40) | `/gr` | 10 / 15 s | Incluye canal de oficiales |
| **Whisper** | 1 jugador | `/w Nombre` | 10 / 15 s | Se abre con tap sobre el nombre en la lista |
| **Mercado** | Todo el servidor | `/m` | 1 / 60 s | Solo anuncios de venta/compra; con enlace al objeto |
| **Sistema** | Personal | — | — | Subidas de nivel, logros, eventos, recompensas |

### 2.2 Reglas y moderación

- Filtro de palabras en cliente (oculta) y servidor (bloquea), con lista mantenida en `data/moderation/`.
- Máximo 120 caracteres por mensaje (legible en 5") y 3 líneas en pantalla.
- Anti-flood: 3 mensajes idénticos en 30 s → silencio automático de 60 s y aviso.
- Bloqueo de enlaces externos y de datos personales detectables (teléfono, correo, coordenadas).
- **Reportar:** mantener pulsado el mensaje → Reportar → motivo en una lista de 5 (spam, insulto, acoso, estafa, otro). El reporte adjunta captura, canal, hora y últimos 20 mensajes del reportado (solo visible para moderación).
- **Ignorar:** por jugador; oculta chat, solicitudes de party, gremio y comercio. Límite de 100 ignorados.
- Apelaciones en el portal web (fuera del cliente) con ID de caso.

### 2.3 Chat rápido (mobile-first)

Como escribir en móvil es costoso, el juego ofrece un menú radial de **mensajes rápidos contextuales**: "Ayuda aquí", "Jefe a la vista", "Voy", "No puedo", "Buena caza", "Gracias". Un tap los envía al canal activo.

## 3. Party

### 3.1 Reglas

| Regla | Valor |
|-------|-------|
| Tamaño máximo | 5 jugadores (MVP: 3) |
| Creación | Un toque desde el menú social o por invitación cercana (≤ 10 casillas) |
| Liderazgo | Se transfiere si el líder se desconecta > 60 s |
| Experiencia | 100 % para cada miembro si hay ≥ 1 golpe de contribución; sin reparto proporcional |
| Rango | Sin restricción de nivel, pero con penalización de XP por diferencia > 5 niveles ([06-progression.md](06-progression.md) §1.3) |
| Instancias | Solo el líder elige dificultad y entrada |
| Salida | Voluntaria; expulsión con voto de 2/3 (evita abusos de líder) |

### 3.2 Herramientas de coordinación

- **Pings en el mapa** (4 tipos: peligro, jefe, ayuda, reunión), con cooldown de 10 s.
- Barra de aliados con Vida, Reserva y estados ([08-ui-ux.md](08-ui-ux.md) §3).
- Marcador de objetivo compartido: el líder puede marcar un enemigo y todos lo ven resaltado.
- Aviso automático de "aliado en peligro" cuando un miembro baja del 30 % de Vida.

### 3.3 Loot en party

| Modo | Descripción | Cuándo se usa |
|------|-------------|---------------|
| **Contribución** (por defecto) | Cada elegible (≥ 10 % de contribución) tira por el objeto raro según su contribución; el botín común va a quien lo recoge | Todo el juego |
| **Libre** | El primero que recoge se lo queda | Zonas de farmeo acordadas |
| **Asignación** | El líder asigna objetos raros | Mazmorras y raids |

Reglas anti-abuso: el líder no puede cambiar el modo en combate; los objetos de misión son personales e intransferibles; el Cobre siempre es personal.

## 4. Gremios

### 4.1 Creación y estructura

| Regla | Valor |
|-------|-------|
| Coste de creación | 100.000 Cobre (escala por tramo del servidor) + nivel 30 |
| Miembros | 40 máximo (10 en MVP/vertical slice) |
| Rango | Recluta, Miembro, Oficial, Tesorero, Líder |
| Permisos | Banco (ver/depositar/retirar), invitar/expulsar, declarar guerra, editar escudo |
| Nombre y escudo | 3–16 caracteres; escudo con formas, colores y símbolos propios (sin imágenes subidas en v1.0) |
| Disolución | Por el líder con confirmación doble; el banco se devuelve por correo a los últimos aportantes en 7 días |

### 4.2 Banco de gremio

- 100 ranuras iniciales, ampliables a 300 con Sellos de Ruta del gremio (no con Lumbre).
- Log completo de movimientos (quién, qué, cuándo); visible para todos los miembros.
- Los objetos depositados son del gremio, no del jugador. No se puede depositar equipo equipado.
- Saqueo del banco: solo Tesorero y Líder, con límite diario de 5 movimientos.

### 4.3 Niveles de gremio

| Nivel | Requisito | Beneficio (social/logístico) |
|-------|-----------|------------------------------|
| 1 | Creación | Chat de gremio, banco de 100 |
| 2 | 5.000 puntos de gremio | Punto de reunión propio (teletransporte del líder), +50 ranuras de banco |
| 3 | 20.000 puntos | Estación de crafteo portátil (uso 1/día por miembro), +50 ranuras |
| 4 | 60.000 puntos | Estandarte de gremio en zonas PvP (+5 % Sellos para el gremio) |
| 5 | 150.000 puntos | Salón de gremio instanciado (social, sin comercio) y escudo animado |

Los puntos de gremio se ganan con misiones de gremio (semanal), eventos públicos y guerras. **No dan estadísticas.**

### 4.4 Guerras de gremio

- Se declaran con 24 h de aviso, duran 48 h y solo en zonas PvP.
- Puntuación: eliminaciones, captura de estandartes y control de nodos.
- Máximo 1 guerra activa por gremio; no se puede declarar a un gremio con menos de la mitad de miembros activos.
- Al terminar: recompensa en Sellos, cosmético de estandarte y registro público del resultado.

## 5. PvP

| Modo | Dónde | Reglas |
|------|-------|--------|
| **Opt-in** | Cualquier zona marcada como PvP (T2+) | Se activa en el menú; advierte y muestra el icono sobre el personaje |
| **Zonas PvP** | Marismas de Sal (T4), Cordillera Vidriada (T6), Borde del Salar (T7), Costa de Aurora (T9) | PvP siempre activo; `olvido` y `corrosión` funcionan igual |
| **Arenas 1v1** | Puerto Salitre y Ciudad de Sal | Igualado por tramo (estadísticas normalizadas), 3 min por combate |
| **Arenas 3v3** | Desde nivel 45 | Igualado, 5 min, con reanimación por equipo |
| **Guerras de gremio** | Zonas PvP | Ver §4.4 |

Reglas compartidas (aplican a todos los modos):

- Multiplicador de daño ×0,6 entre jugadores, control ×0,5 y tolerancia a control escalonada ([03-combat.md](03-combat.md) §6).
- Anti-griefing: 3 muertes del mismo atacante sobre la misma víctima en 10 min → bloqueo de 30 min entre ambos.
- Protección de novato: nivel < 15 inmune en zonas PvP (puede atacar, pero no recibe daño de jugadores).
- Sin pérdida de equipo ni XP; solo % de Cobre y `mella` ([03-combat.md](03-combat.md) §8).
- El PvP **nunca** es requisito para progresar en PvE: las recompensas de PvP son alternativas, no superiores.

## 6. Amigos, ignore y report

| Función | Reglas |
|---------|--------|
| **Amigos** | Máximo 200; muestra estado (en línea, zona, nivel, última conexión); se puede invitar a party desde la lista |
| **Ignore** | Máximo 100; oculta chat, invitaciones, comercio y solicitudes de gremio |
| **Reporte** | Categorías: spam, lenguaje, acoso, estafa, trampa/bot, otro. Adjunta captura y últimos 20 mensajes |
| **Block de comercio** | Se puede bloquear el comercio directo con un jugador sin bloquearlo del chat |
| **Estado** | En línea, ausente, ocupado, invisible (invisible solo entre amigos) |

## 7. Antifraude social

| Riesgo | Mitigación |
|--------|-----------|
| Estafa en comercio directo | Ventana con doble confirmación, resumen final y registro auditable ([05-economy.md](05-economy.md) §7.2) |
| Suplantación de nombres | Nombres únicos, sin caracteres confundibles (se normaliza `l/I/1`, `O/0`) |
| Gremio estafa (banco) | Log público del banco, límites de retiro y roles claros |
| Acoso por whisper | Bloquear/ignorar; límite de 1 whisper por segundo entre el mismo par |
| Spam de mercado | Coste de 1 Cobre y límite de 1 mensaje por minuto |

## 8. Implementación

- El chat vive en `net/` como servicio de servidor (`chat_service.gd`), con validación y rate limit **en servidor**.
- La party es estado de servidor; el cliente solo muestra y solicita (`PartySystem.request_invite(target_id)`).
- Los gremios persisten en el backend (fase 5+); en MVP/vertical slice las party funcionan en memoria y se disuelven al desconectar el líder.
- Los mensajes rápidos son `@rpc` con un `enum` de 6 valores: ~2 bytes por mensaje, sin texto libre.
- Todo evento social relevante se registra con actor, objetivo, tipo y timestamp para moderación (retención 90 días).
