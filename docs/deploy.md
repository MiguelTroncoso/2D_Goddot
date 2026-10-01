# Deploy — Android

> Cubre la construcción, firma y publicación del APK. Para el detalle de configuración
> (SDK, plantillas, firma local) ver [08-android-development.md](08-android-development.md);
> para el historial de la regresión de input, [PHASE-1-REGRESSION.md](phase-reviews/PHASE-1-REGRESSION.md).

## 1. Builds disponibles

```sh
bash scripts/build_android.sh            # APK debug  → build/android/mmorpg-2d-debug.apk
bash scripts/build_android.sh --release  # APK release → build/android/mmorpg-2d-release.apk
```

Ambos comandos:

1. resuelven Godot 4.4 y exigen JDK 17+;
2. verifican el **contrato de input táctil** (`tools/check_input_contract.py`);
3. exportan con el preset correspondiente;
4. verifican que el APK contenga `assets/src/systems/` (regresión TASK-003.5) y que el
   overlay de diagnóstico **no** viaje en release;
5. firman, verifican con `apksigner` e imprimen tamaño y `sha256`.

## 2. Reproducibilidad

El APK es reproducible **en procedimiento**, no byte a byte.

| Aspecto | Estado |
|---------|--------|
| Mismo código + mismas herramientas → mismo contenido funcional | ✅ |
| Mismo tamaño aproximado entre builds | ✅ |
| `sha256` idéntico entre builds | ❌ **No**, Godot inserta timestamps en el empaquetado (ZIP) y genera `resources.arsc` con marca de tiempo |

Consecuencias prácticas:

- Para verificar que dos builds son equivalentes, compara **contenido** (`unzip -l`) y
  comportamiento, no el hash.
- El `sha256` se publica siempre junto al APK entregado para que el PO confirme que probó
  exactamente ese artefacto.
- Si en el futuro se necesita reproducibilidad bit a bit, exige fijar `SOURCE_DATE_EPOCH`
  en el empaquetador de Godot (hoy no expuesto para Android): queda como deuda técnica
  abierta, no como requisito de Fase 1.

## 3. Firma

| Tipo | Material | Dónde vive |
|------|----------|-----------|
| Debug | `~/.android/debug.keystore` (generado por el SDK) | Fuera del repositorio |
| Release (local) | `~/.android/mmorpg2d-release.keystore` + `~/.android/mmorpg2d-release.env` | Fuera del repositorio |
| Release (producción) | Keystore propio del PO | Fuera del repositorio (**nunca** en Git) |

`scripts/build_android.sh --release` lee estas variables desde
`~/.android/mmorpg2d-release.env`:

```sh
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/ruta/fuera/del/repo/keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=<alias>
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=<password>
```

El keystore local se generó para pruebas (`keytool -genkeypair`, validez 10.000 días).
**Antes de publicar en Google Play hay que sustituirlo por el keystore definitivo**: si se
pierde, la app no se puede actualizar en la tienda.

## 4. Diferencias debug vs release

| Aspecto | Debug | Release |
|---------|-------|---------|
| Overlay de diagnóstico | ✅ incluido y visible | ❌ excluido del paquete (`exclude_filter`) y nunca instanciado |
| Optimizaciones | Desactivadas | Activadas |
| Firma | Debug | Release |
| Uso | Pruebas del PO, desarrollo | Distribución, pruebas de rendimiento reales |

El overlay se activa con `OS.is_debug_build()` o con `game/debug_overlay=true` en
`project.godot`. En release la escena `src/ui/debug_overlay.tscn` no está en el paquete y
`tools/check_export_contract.py` falla si esa exclusión desaparece.

## 5. Checklist antes de entregar un APK

1. `python3 .github/scripts/validate_godot.py --godot <godot>` → import, parseo y 50 checks nativos.
2. Tests GUT (`domain`, `systems`, `presentation`) en verde.
3. `python3 tools/domain_coverage.py` ≥ 80 %.
4. `python3 tools/check_input_contract.py` y `python3 tools/check_export_contract.py` en verde.
5. `bash scripts/build_android.sh [--release]` sin errores.
6. Para features de UI/input/rendimiento: entregar APK + `sha256` + comandos `adb` + qué
   observar en pantalla, y dejar la tarea en `pending PO validation` (ADR-012).

## 6. Publicación futura (Fase 9–10)

Pendiente de definir: cuenta de desarrollador, keystore de producción, ficha de tienda,
política de privacidad, contenido clasificado, pruebas cerradas y plan de despliegue por
fases. No forma parte de Fase 1.
