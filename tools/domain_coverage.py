#!/usr/bin/env python3
"""Cobertura de API del dominio (function coverage) para 2D_Goddot.

Qué mide
--------
Cuenta las funciones públicas declaradas en `src/domain/**/*.gd` y verifica que
cada una esté referenciada por al menos un test de `tests/domain/**/*.gd`.

Qué NO mide
-----------
No es cobertura de líneas ni de ramas: una referencia puede existir sin que se
ejerza el caso borde. La cobertura real de comportamiento la aporta la suite GUT
que corre en CI; este gate evita que una función pública quede sin ningún test.

Los nombres que empiezan con `_` se reportan aparte y no entran en el porcentaje,
porque son detalles internos del script.

Uso:
    python3 tools/domain_coverage.py [--min 0.80] [--verbose]
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIRS = [ROOT / "src" / "domain", ROOT / "src" / "systems"]
TESTS_DIRS = [ROOT / "tests" / "domain", ROOT / "tests" / "systems"]

FUNC_RE = re.compile(r"^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.MULTILINE)
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def funciones_por_archivo(directorios: list[Path]) -> dict[Path, list[str]]:
    resultado: dict[Path, list[str]] = {}
    for directorio in directorios:
        for archivo in sorted(directorio.rglob("*.gd")):
            resultado[archivo] = FUNC_RE.findall(archivo.read_text(encoding="utf-8"))
    return resultado


def identificadores_de_tests(directorios: list[Path]) -> set[str]:
    encontrados: set[str] = set()
    for directorio in directorios:
        for archivo in sorted(directorio.rglob("*.gd")):
            encontrados.update(IDENT_RE.findall(archivo.read_text(encoding="utf-8")))
    return encontrados


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--min", type=float, default=0.80, help="cobertura mínima exigida (0-1)")
    parser.add_argument("--verbose", action="store_true", help="lista cada función sin cobertura")
    args = parser.parse_args()

    for directorio in SOURCE_DIRS + TESTS_DIRS:
        if not directorio.is_dir():
            print(f"FAIL: no existe {directorio.relative_to(ROOT)}")
            return 1

    referencias = identificadores_de_tests(TESTS_DIRS)
    publicas_totales = 0
    publicas_cubiertas = 0
    privadas_totales = 0
    faltantes: list[str] = []

    print(f"{'archivo':<48}{'cubiertas':>10}{'total':>7}{'%':>8}")
    print("-" * 73)
    for archivo, funciones in funciones_por_archivo(SOURCE_DIRS).items():
        publicas = [f for f in funciones if not f.startswith("_")]
        privadas = [f for f in funciones if f.startswith("_")]
        cubiertas = [f for f in publicas if f in referencias]
        publicas_totales += len(publicas)
        publicas_cubiertas += len(cubiertas)
        privadas_totales += len(privadas)
        faltantes.extend(
            f"{archivo.relative_to(ROOT)}::{f}" for f in publicas if f not in referencias
        )
        porcentaje = (len(cubiertas) / len(publicas) * 100.0) if publicas else 100.0
        print(
            f"{str(archivo.relative_to(ROOT)):<48}{len(cubiertas):>10}{len(publicas):>7}{porcentaje:>7.1f}%"
        )

    print("-" * 73)
    if publicas_totales == 0:
        print("FAIL: no se encontraron funciones públicas en src/domain ni src/systems")
        return 1

    cobertura = publicas_cubiertas / publicas_totales
    print(
        f"API de dominio+sistemas: {publicas_cubiertas}/{publicas_totales} funciones públicas con test "
        f"({cobertura * 100:.1f} %) · {privadas_totales} funciones privadas fuera del cálculo"
    )
    if args.verbose and faltantes:
        print("\nSin ningún test que las referencie:")
        for faltante in faltantes:
            print(f"  - {faltante}")

    if cobertura + 1e-9 < args.min:
        print(f"FAIL: cobertura {cobertura * 100:.1f} % por debajo del mínimo {args.min * 100:.0f} %")
        return 1
    print(f"PASS: cobertura de API >= {args.min * 100:.0f} %")
    return 0


if __name__ == "__main__":
    sys.exit(main())
