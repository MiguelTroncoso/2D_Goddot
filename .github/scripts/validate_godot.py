#!/usr/bin/env python3
"""Run Godot itself; reject script/runtime errors even when Godot returns zero."""

import argparse
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ANSI = re.compile(r"\x1b\[[0-9;]*m")
# Godot 4.4-stable upstream bug #103398. Only these exact editor-import
# message/location pairs are tolerated; they remain visible in the output.
IMPORT_BUG = {
    ("ERROR: Do not use progress dialog (task) while flushing the message queue or using call_deferred()!",
     "at: add_task (editor/progress_dialog.cpp:183)"),
    ('ERROR: Condition "!tasks.has(p_task)" is true. Returning: canceled',
     "at: task_step (editor/progress_dialog.cpp:217)"),
    ('ERROR: Condition "!tasks.has(p_task)" is true.',
     "at: end_task (editor/progress_dialog.cpp:240)"),
}


def run(engine, arguments, *, importing=False, test_run=False):
    command = [engine, "--headless", "--path", str(ROOT), *arguments]
    print("RUN:", " ".join(arguments), flush=True)
    result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=120)
    output = ANSI.sub("", result.stdout)
    print(output, end="", flush=True)
    lines = output.splitlines()
    failures = []
    known = 0
    for index, line in enumerate(lines):
        if "ERROR:" not in line and "SCRIPT ERROR:" not in line:
            continue
        location = lines[index + 1].strip() if index + 1 < len(lines) else ""
        if importing and (line.strip(), location) in IMPORT_BUG:
            known += 1
        else:
            failures.append(line)
    if known:
        print("WARNING: Godot 4.4 upstream editor import bug #103398 observed.")
    if result.returncode or failures:
        raise SystemExit(f"FAIL: {arguments}; exit={result.returncode}; errors={len(failures)}")
    if test_run and not re.search(r"PHASE1_TEST_RESULT: [1-9][0-9]* checks, 0 failures", output):
        raise SystemExit("FAIL: test runner did not report successful completion")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", default="godot", help="Godot 4.4-stable executable")
    args = parser.parse_args()
    version = subprocess.check_output([args.godot, "--version"], text=True, timeout=15).strip()
    if version != "4.4.stable.official.4c311cbee":
        raise SystemExit(f"FAIL: expected official Godot 4.4-stable, got {version}")
    run(args.godot, ["--import"], importing=True)
    for directory in ("src", "server", "tests"):
        for script in sorted((ROOT / directory).rglob("*.gd")):
            run(args.godot, ["--check-only", "--script", str(script.relative_to(ROOT))])
    run(args.godot, ["--quit-after", "60"])
    run(args.godot, ["--script", "tests/run_tests.gd"], test_run=True)
    print("PASS: Godot import, all GDScript parsers, main scene startup and automated tests")


if __name__ == "__main__":
    main()
