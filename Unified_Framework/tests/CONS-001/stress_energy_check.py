"""CONS-001 automation: verify ∇_μ T^{μν} = 0 for a simple homogeneous source."""

from pathlib import Path

import sympy as sp


def ensure_artifact_dir() -> Path:
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "CONS-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def homogeneous_perfect_fluid():
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)

    rho0, p0 = sp.symbols("rho0 p0", real=True, positive=True)
    T = sp.diag(rho0, p0, p0, p0)

    divergences = []
    for nu in range(4):
        term = 0
        for mu, coord in enumerate(coords):
            term += sp.diff(T[mu, nu], coord)
        divergences.append(sp.simplify(term))
    return divergences


def radiation_energy_momentum():
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)

    E0 = sp.symbols("E0", real=True)
    T = sp.Matrix(
        [
            [E0**2, E0**2, 0, 0],
            [E0**2, E0**2, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
        ]
    )

    divergences = []
    for nu in range(4):
        term = 0
        for mu, coord in enumerate(coords):
            term += sp.diff(T[mu, nu], coord)
        divergences.append(sp.simplify(term))
    return divergences


def main() -> int:
    artifact_dir = ensure_artifact_dir()
    lines = []

    fluid_div = homogeneous_perfect_fluid()
    lines.append("## Homogeneous perfect fluid")
    lines.extend(f"divergence[{i}] = {expr}" for i, expr in enumerate(fluid_div))

    radiation_div = radiation_energy_momentum()
    lines.append("## Plane-wave radiation")
    lines.extend(f"divergence[{i}] = {expr}" for i, expr in enumerate(radiation_div))

    (artifact_dir / "stress_energy_check.txt").write_text("\n".join(lines), encoding="utf-8")

    for expr in fluid_div + radiation_div:
        assert expr == 0

    print("CONS-001: stress-energy divergences vanish for the sampled sources.")
    print("Artifacts written to", artifact_dir / "stress_energy_check.txt")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
