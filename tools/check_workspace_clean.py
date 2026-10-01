#!/usr/bin/env python3
"""Detecta copias de conflicto del gestor de archivos (iCloud Drive / Finder).
macOS duplica archivos y carpetas como `crit_roller 2.gd` o `fonts 3/`. Godot escanea
el proyecto, los duplicados declaran el mismo `class_name` y la compilación falla con
"hides a global script class", colgando GUT sin mensaje claro. CI clona desde git y
nunca los tiene; este chequeo sirve para builds y pruebas locales.
Uso: python3 tools/check_workspace_clean.py [--mover]
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATRON = re.compile(r"^(.*) \d+(\.[A-Za-z0-9_]+)*$")
IGNORAR = {".git"}


def duplicados() -> list[Path]:
    encontrados: list[Path] = []
    for ruta in ROOT.rglob("*"):
        if any(parte in IGNORAR for parte in ruta.parts):
            continue
        if PATRON.match(ruta.name):
            encontrados.append(ruta)
    return encontrados


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mover", action="store_true", help="mueve los duplicados a /tmp")
    args = parser.parse_args()
    copias = duplicados()
    if not copias:
        print("PASS: no hay copias de conflicto en el proyecto")
        return 0
    if args.mover:
        destino = Path("/tmp/duplicados_icloud")
        for copia in copias:
            final = destino / copia.relative_to(ROOT)
            final.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(copia), str(final))
        print(f"OK: {len(copias)} copias movidas a {destino}")
        return 0
    print(f"FAIL: {len(copias)} copias de conflicto detectadas (iCloud/Finder). Ejemplos:")
    for copia in copias[:10]:
        print(f"  - {copia.relative_to(ROOT)}")
    print("Rompen GDScript ('hides a global script class') y cuelgan GUT.")
    print("Solución: python3 tools/check_workspace_clean.py --mover")
    return 1


if __name__ == "__main__":
    sys.exit(main())
