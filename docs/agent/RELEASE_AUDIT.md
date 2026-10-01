# AUDITORÍA FINAL DE RELEASE v1.0

## Parte 1 — Criterios "GAME READY"
Verifica cada criterio del PROMPT_MASTER. Por cada uno:
- ✅/❌ Estado
- Evidencia (archivo, test, comando, captura)
- Si ❌ → plan de remediación + estimación

## Parte 2 — Auditorías específicas
1. **Seguridad API**: rate limiting, validación de inputs, autenticación,
   inyección SQL/command, replay attacks.
2. **Rendimiento Android**: APK en 3 dispositivos (gama baja/media/alta) con
   perfil de CPU, memoria, batería, FPS mínimo 30 sostenido.
3. **Licencias**: `CREDITS.md` — todos los assets con autor, licencia,
   permiso de uso comercial.
4. **Carga**: script de load testing con 20 concurrentes, latencia <150 ms,
   sin desync ni caídas.
5. **IAP**: validación de recibos Google Play, restauración de compras,
   tabla regional USD/CLP/MXN/BRL/EUR.
6. **Anti-cheat**: server-authoritative en daño, loot, XP, movimiento,
   cooldowns y economía.
7. **Anti-AFK**: detección de inactividad, recompensas solo con actividad real.
8. **Coherencia GDD**: verificar checklist de `INDEX.md` (12 numéricas + 15 sistemas).
9. **Recompensas**: curvas XP 1–150, drops, precios de tienda,
   balance de sets.
10. **Onboarding**: primeros 5 minutos funcionales según `docs/design/08-ui-ux.md`.

## Parte 3 — Entregables
- `docs/release-notes-v1.0.md`
- Checklist de subida a Google Play
- Informe final con semáforo por área (🟢/🟡/🔴) y bloqueantes

## Formato de respuesta
Tabla con criterio | estado | evidencia | bloqueante sí/no.
Al final: lista priorizada de bloqueantes para release.
