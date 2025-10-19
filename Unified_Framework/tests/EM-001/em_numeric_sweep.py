"""EM-001 numeric sweep: integrate 1D Gauss law and compare against analytic field."""

import json
from pathlib import Path

import numpy as np


def ensure_artifact_dir() -> Path:
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "EM-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def integrate_gauss_law(rho0: float, epsilon0: float, domain: tuple[float, float], n_points: int):
    x = np.linspace(domain[0], domain[1], n_points)
    dx = x[1] - x[0]

    dE_dx = (rho0 / epsilon0) * np.ones_like(x)
    E_numeric = np.zeros_like(x)
    for i in range(1, n_points):
        E_numeric[i] = E_numeric[i - 1] + dE_dx[i - 1] * dx

    E_analytic = (rho0 / epsilon0) * (x - x[0])
    error = np.max(np.abs(E_numeric - E_analytic))
    return float(error), E_numeric.tolist(), E_analytic.tolist(), x.tolist()


def main() -> int:
    rho0 = 1.0
    epsilon0 = 1.0
    domain = (-0.5, 0.5)
    points = 101

    max_error, E_num, E_ana, grid = integrate_gauss_law(rho0, epsilon0, domain, points)

    artifact_dir = ensure_artifact_dir()
    payload = {
        "rho0": rho0,
        "epsilon0": epsilon0,
        "domain": domain,
        "points": points,
        "max_error": max_error,
    }
    (artifact_dir / "em_numeric_sweep.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")

    print("EM-001 numeric sweep max error:", max_error)
    print("Artifacts written to", artifact_dir / "em_numeric_sweep.json")
    assert max_error < 1e-6
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
