# TASK-002 — Prueba física del APK en dispositivo Android

> **Estado: `deferred, no bloquea Fase 2`** (ver [ADR-010](../decisions/010-phase1-closure-exception.md)).
> Responsable de ejecución: Product Owner (requiere hardware). Duración estimada: 45–60 min.

## Objetivo

Verificar en un dispositivo Android real que el APK de Fase 1 arranca, se controla
con el joystick táctil, respeta la safe area y sostiene el rendimiento mínimo.

## Entradas

- APK: `build/android/mmorpg-2d-debug.apk` (regenerable con `bash scripts/build_android.sh`).
- Dispositivo: Android 10+ con depuración USB habilitada y `adb` disponible.
- Opcional: un segundo dispositivo de gama distinta para comparar.

## Comandos

```sh
# 1. Verificar que el dispositivo responde
adb devices -l

# 2. Instalar (reemplazando versiones anteriores)
adb install -r build/android/mmorpg-2d-debug.apk

# 3. Lanzar y observar
adb shell am start -n org.mmorpg2d.prototype/com.godot.game.GodotApp

# 4. Métricas objetivas durante 3 minutos de juego
adb shell dumpsys gfxinfo org.mmorpg2d.prototype framestats > build/android/gfxinfo.txt
adb shell dumpsys battery | sed -n '1,25p'                > build/android/battery-before.txt
adb logcat -d | grep -iE "godot|fatal|exception"          > build/android/logcat.txt

# 5. Captura de evidencia
adb exec-out screencap -p > build/android/device-screenshot.png
```

## Criterios de aceptación

| # | Criterio | Cómo se comprueba | Resultado |
|---|----------|-------------------|-----------|
| 1 | Instala y arranca sin crash | `adb install -r` + pantalla de juego visible | [ ] |
| 2 | Orientación horizontal fija, sin rotación accidental | Girar el dispositivo durante el juego | [ ] |
| 3 | Joystick responde en las 8 direcciones y libera al soltar | Recorrido completo del mapa de prueba | [ ] |
| 4 | Colisiones correctas en los 8 bordes/obstáculos | Chocar contra cada muro y bloque | [ ] |
| 5 | Cámara sigue sin tirones perceptibles | Recorrido diagonal de 30 s | [ ] |
| 6 | HUD legible a 5–7" y dentro de la safe area | Captura + inspección visual | [ ] |
| 7 | Sin corte de contenido en notch/cutout | Captura en dispositivo con notch | [ ] |
| 8 | **FPS ≥ 30 sostenido** en gama media (objetivo 60) | `dumpsys gfxinfo` + overlay de FPS | [ ] |
| 9 | Consumo de batería razonable (< 12 % en 20 min) | `dumpsys battery` antes/después | [ ] |
| 10 | Suspender y reanudar sin drift ni input atascado | Botón de bloqueo y regreso | [ ] |
| 11 | Sustituir el APK por uno nuevo reinstalando sin perder configuración local | `adb install -r` de una build posterior | [ ] |

## Evidencia a adjuntar

- `build/android/device-screenshot.png` (HUD y safe area).
- `build/android/gfxinfo.txt` (percentiles de frame time).
- `build/android/logcat.txt` (sin `FATAL` ni `Exception`).
- `build/android/battery-before.txt` y medición final.
- Dispositivo, versión de Android y densidad de pantalla usados.

## Criterios para reabrir Fase 1

Cualquiera de estos hechos reabre la fase y congela contenido nuevo
([ADR-010](../decisions/010-phase1-closure-exception.md)):

1. Fallo de instalación o crash en los primeros 5 minutos.
2. FPS < 30 sostenido en un dispositivo de gama media.
3. Contenido crítico fuera de la safe area o ilegible a 5".
4. Joystick con drift, input atascado o pérdida de control al suspender.

## Riesgos

| Riesgo | Mitigación |
|--------|------------|
| No hay dispositivo disponible | Es exactamente el motivo de la excepción; la Fase 2 no depende de esto |
| El APK debug pesa 51,7 MB (plantillas sin optimizar) | Se revisará en la fase de pulido móvil (optimización de APK) |
| `adb` no está en PATH | Está en `~/Library/Android/sdk/platform-tools/adb` |
