"""Unified test runner for the Unified Framework automation suites."""

from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

TEST_SCRIPTS = [
    Path("GR-001/gr_torsionless_check.py"),
    Path("GR-001/gr_torsionless_check_einsteinpy.py"),
    Path("GR-001/gr_torsion_perturbation_check.py"),
    Path("EM-001/em_flat_limit_check.py"),
    Path("DIR-001/dirac_minimal_coupling_check.py"),
    Path("EM-001/em_numeric_sweep.py"),
    Path("CONS-001/stress_energy_check.py"),
]


ARTIFACT_PATH = Path("artifacts/test_run_summary.json")


def run_script(script: Path) -> tuple[bool, str, float]:
    cmd = [sys.executable, str(script)]
    start = time.perf_counter()
    try:
        completed = subprocess.run(
            cmd,
            cwd=Path(__file__).parent,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )
        duration = time.perf_counter() - start
        return True, completed.stdout, duration
    except subprocess.CalledProcessError as exc:
        duration = time.perf_counter() - start
        return False, exc.stdout or "", duration


def main() -> int:
    root = Path(__file__).parent
    results = []
    for script in TEST_SCRIPTS:
        ok, output, duration = run_script(script)
        results.append((script, ok, output, duration))
        status = "PASS" if ok else "FAIL"
        print(f"[{status}] {script} ({duration:.2f}s)")
        if output:
            print(output.strip())
            print("-" * 60)

    summary = [
        {
            "script": str(script),
            "status": "PASS" if ok else "FAIL",
            "duration_seconds": round(duration, 3),
        }
        for script, ok, _, duration in results
    ]
    artifact = root / ARTIFACT_PATH
    artifact.parent.mkdir(parents=True, exist_ok=True)
    artifact.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    failed = [script for script, ok, _, _ in results if not ok]
    if failed:
        print("Failures detected:")
        for script in failed:
            print(f" - {script}")
        return 1

    print("All scripted tests completed successfully. Summary written to", artifact)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
