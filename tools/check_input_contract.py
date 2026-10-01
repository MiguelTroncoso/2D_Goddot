#!/usr/bin/env python3
"""Contrato de input táctil (regresión TASK-003.5).

Verifica que las piezas que hicieron fallar el input en dispositivo siguen en su
sitio. Falla con código != 0 si alguna desaparece.

Comprueba:
1. `project.godot`: orientación horizontal y emulación táctil para pruebas en escritorio.
2. `src/ui/virtual_joystick.tscn`: existe, es Control y ocupa toda la pantalla.
3. `src/ui/hud.tscn`: instancia el joystick.
4. `src/main.tscn`: instancia el HUD.
5. `src/systems/movement_input.gd`: expone el mapeo relativo y la zona de activación.
6. `src/ui/virtual_joystick.gd`: usa el mapeo relativo, no un hit test por transformaciones.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PROJECT = ROOT / "project.godot"
JOYSTICK_SCENE = ROOT / "src" / "ui" / "virtual_joystick.tscn"
JOYSTICK_SCRIPT = ROOT / "src" / "ui" / "virtual_joystick.gd"
HUD_SCENE = ROOT / "src" / "ui" / "hud.tscn"
MAIN_SCENE = ROOT / "src" / "main.tscn"
MOVEMENT_SYSTEM = ROOT / "src" / "systems" / "movement_input.gd"


def leer(ruta: Path) -> str:
    if not ruta.is_file():
        print(f"FAIL: falta {ruta.relative_to(ROOT)}")
        sys.exit(1)
    return ruta.read_text(encoding="utf-8")


def main() -> int:
    fallos: list[str] = []

    project = leer(PROJECT)
    if "window/handheld/orientation=0" not in project:
        fallos.append("project.godot: falta la orientación horizontal (window/handheld/orientation=0)")
    if "pointing/emulate_touch_from_mouse=true" not in project:
        fallos.append("project.godot: falta emulate_touch_from_mouse=true (pruebas táctiles en escritorio)")
    if "pointing/emulate_mouse_from_touch=false" not in project:
        fallos.append("project.godot: se espera emulate_mouse_from_touch=false (tacto puro en Android)")

    joystick_scene = leer(JOYSTICK_SCENE)
    if 'type="Control"' not in joystick_scene:
        fallos.append("virtual_joystick.tscn: la raíz debe ser un Control")
    for requerido in ("anchor_right = 1.0", "anchor_bottom = 1.0", "mouse_filter = 2"):
        if requerido not in joystick_scene:
            fallos.append(f"virtual_joystick.tscn: falta '{requerido}' (joystick de pantalla completa)")

    hud = leer(HUD_SCENE)
    if "src/ui/virtual_joystick.tscn" not in hud:
        fallos.append("hud.tscn: no instancia src/ui/virtual_joystick.tscn")
    if "script = ExtResource" not in hud:
        fallos.append("hud.tscn: falta el script del HUD (safe area y diagnóstico)")

    main_scene = leer(MAIN_SCENE)
    if "src/ui/hud.tscn" not in main_scene:
        fallos.append("main.tscn: no instancia src/ui/hud.tscn")

    movement = leer(MOVEMENT_SYSTEM)
    for requerido in ("func vector_desde_origen", "func en_zona_activacion", "func delta_desde_origen"):
        if requerido not in movement:
            fallos.append(f"movement_input.gd: falta {requerido}")

    joystick_script = leer(JOYSTICK_SCRIPT)
    if "MovementInput.vector_desde_origen" not in joystick_script:
        fallos.append("virtual_joystick.gd: no usa el mapeo relativo (regresión del bug de input)")
    if "MovementInput.en_zona_activacion" not in joystick_script:
        fallos.append("virtual_joystick.gd: no usa la zona de activación táctil")

    if fallos:
        for fallo in fallos:
            print(f"FAIL: {fallo}")
        print(f"FAIL: contrato de input táctil incompleto ({len(fallos)} problema(s))")
        return 1
    print("PASS: contrato de input táctil (escena, flags y mapeo relativo) verificado")
    return 0


if __name__ == "__main__":
    sys.exit(main())
