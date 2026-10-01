#!/usr/bin/env python3
"""Contrato de exportación Android (regresión TASK-003.5).

El bug que rompió el input en dispositivo no fue de código de juego: el preset
`export_filter="scenes"` solo empaquetaba `src/main.tscn` y sus escenas hijas, así que
los `preload()` de `src/systems/` nunca llegaban al APK. En el teléfono, `main.gd` y
`virtual_joystick.gd` fallaban al cargar: HUD visible, joystick ausente, cero movimiento.

Este script falla si el preset vuelve a un modo que no garantiza incluir los scripts, o
si el filtro de exclusión tapa `src/`.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESET = ROOT / "export_presets.cfg"
RUTAS_CRITICAS = ("src/systems/", "src/domain/", "src/ui/", "src/entities/", "src/data/")
OVERLAY = "src/ui/debug_overlay"


def valor(texto: str, clave: str) -> str | None:
    coincidencia = re.search(rf'^{clave}="?([^"\n]*)"?$', texto, re.MULTILINE)
    return coincidencia.group(1) if coincidencia else None


def main() -> int:
    if not PRESET.is_file():
        print("FAIL: falta export_presets.cfg")
        return 1
    texto = PRESET.read_text(encoding="utf-8")
    filtro = valor(texto, "export_filter")
    exclusiones = (valor(texto, "exclude_filter") or "").split(",")
    exclusiones = [e.strip() for e in exclusiones if e.strip()]
    fallos: list[str] = []

    presets = _presets(texto)
    release = presets.get("Android Release")
    debug = presets.get("Android Debug")
    if release is None:
        fallos.append("falta el preset 'Android Release' (TASK-005)")
    else:
        exclusion_release = release.get("exclude_filter", "")
        if OVERLAY not in exclusion_release:
            fallos.append("el preset 'Android Release' debe excluir src/ui/debug_overlay* (no debe viajar a producción)")
    if debug is not None and "debug_overlay" in debug.get("exclude_filter", ""):
        fallos.append("el preset 'Android Debug' debe incluir el overlay de diagnóstico")

    if filtro != "all_resources":
        fallos.append(
            f"export_filter es '{filtro}': solo 'all_resources' garantiza incluir los scripts "
            "que los preload() necesitan (bug de input en dispositivo)"
        )
    for ruta in RUTAS_CRITICAS:
        for patron in exclusiones:
            base = patron.rstrip("*").rstrip("/")
            if base and (ruta == base or ruta.startswith(base + "/")):
                fallos.append(f"exclude_filter '{patron}' excluye código de runtime ({ruta})")
    if not any(patron.startswith("addons") for patron in exclusiones):
        fallos.append("exclude_filter debe excluir 'addons/*' (GUT no debe viajar en el APK)")

    if fallos:
        for fallo in fallos:
            print(f"FAIL: {fallo}")
        return 1
    print(f"PASS: contrato de exportación (filtro '{filtro}', exclusiones: {', '.join(exclusiones)})")
    return 0


def _presets(texto: str) -> dict[str, dict[str, str]]:
    """Separa export_presets.cfg por preset y devuelve un diccionario por nombre."""
    por_indice: dict[str, dict[str, str]] = {}
    indice_actual: str | None = None
    for linea in texto.splitlines():
        coincidencia = re.match(r"\[preset\.(\d+)(\.options)?\]", linea.strip())
        if coincidencia:
            indice_actual = coincidencia.group(1)
            por_indice.setdefault(indice_actual, {})
            continue
        if "=" not in linea or indice_actual is None:
            continue
        clave, valor = linea.split("=", 1)
        por_indice[indice_actual][clave.strip()] = valor.strip().strip('"')
    return {
        datos["name"]: datos
        for datos in por_indice.values()
        if datos.get("name")
    }


if __name__ == "__main__":
    sys.exit(main())
