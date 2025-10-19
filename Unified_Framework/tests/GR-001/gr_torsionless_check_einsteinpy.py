"""GR-001 auxiliary check: compare EinsteinPy results with in-house tensors."""

import sys
from pathlib import Path

import sympy as sp
from einsteinpy.symbolic import EinsteinTensor, MetricTensor

CURRENT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(CURRENT_DIR))

from gr_torsionless_check import christoffel_symbols, divergence_g, einstein_tensor, ricci_tensor  # noqa: E402


def ensure_artifact_dir():
    artifact_dir = CURRENT_DIR.parents[0] / "artifacts" / "GR-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def compare_tensors(name, metric_matrix, coords):
    metric_array = sp.Array(sp.Matrix(metric_matrix).tolist())
    metric = MetricTensor(metric_array, coords)
    einstein_py = sp.Matrix(EinsteinTensor.from_metric(metric).tensor())

    g_inv = sp.Matrix(metric_matrix).inv()
    gamma = christoffel_symbols(metric_matrix, g_inv, coords)
    ricci = ricci_tensor(gamma, coords)
    einstein_manual = sp.Matrix(einstein_tensor(metric_matrix, g_inv, ricci))

    lines = []
    for mu in range(len(coords)):
        for nu in range(len(coords)):
            diff = sp.simplify(einstein_manual[mu, nu] - einstein_py[mu, nu])
            print(f"{name}: deltaG[{mu}{nu}] = {diff}")
            assert diff == 0
            lines.append(f"{name}: deltaG[{mu}{nu}] = {diff}")

    einstein_array = sp.MutableDenseNDimArray(einstein_py.tolist())
    divergences = divergence_g(einstein_array, g_inv, gamma, coords)
    for idx, expr in enumerate(divergences):
        simplified = sp.simplify(expr)
        print(f"{name}: divergence_component[{idx}] = {simplified}")
        assert simplified == 0
        lines.append(f"{name}: divergence_component[{idx}] = {simplified}")
    return lines


def main():
    t, r, theta, phi = sp.symbols("t r theta phi", real=True)
    coords = (t, r, theta, phi)

    M = sp.symbols("M", positive=True, finite=True)
    f = 1 - 2 * M / r
    schwarzschild = sp.diag(-f, 1 / f, r**2, r**2 * sp.sin(theta) ** 2)

    a = sp.Function("a")
    frw_flat = sp.diag(
        -1,
        a(t) ** 2,
        a(t) ** 2 * r**2,
        a(t) ** 2 * r**2 * sp.sin(theta) ** 2,
    )

    Omega = sp.symbols("Omega", real=True)
    rotating_minkowski = sp.Matrix([
        [
            -(1 - (Omega**2) * r**2 * sp.sin(theta) ** 2),
            0,
            0,
            Omega * r**2 * sp.sin(theta) ** 2,
        ],
        [0, 1, 0, 0],
        [0, 0, r**2, 0],
        [
            Omega * r**2 * sp.sin(theta) ** 2,
            0,
            0,
            r**2 * sp.sin(theta) ** 2,
        ],
    ])

    metrics = {
        "schwarzschild": schwarzschild,
        "frw_flat": frw_flat,
        "rotating_minkowski": rotating_minkowski,
    }

    artifact_dir = ensure_artifact_dir()
    outputs = []

    for name, metric_matrix in metrics.items():
        outputs.extend(compare_tensors(name, metric_matrix, coords))

    (artifact_dir / "gr_torsionless_check_einsteinpy.txt").write_text("\n".join(outputs), encoding="utf-8")


if __name__ == "__main__":
    main()
