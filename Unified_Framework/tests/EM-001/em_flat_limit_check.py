"""EM-001 automation: confirm d_mu F^{mu nu} = J^nu, enforce the Bianchi identity, and sample numeric sweeps."""

from itertools import product
from pathlib import Path

import numpy as np
import sympy as sp


def build_field_tensor(potential, coords):
    """Compute F_{mu nu} from a gauge potential A_mu."""
    dim = len(coords)
    f_tensor = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            f_tensor[mu, nu] = sp.simplify(sp.diff(potential[nu], coords[mu]) - sp.diff(potential[mu], coords[nu]))
    return f_tensor


def raise_indices(f_tensor, metric):
    """Raise both indices on F_{mu nu} using the supplied metric."""
    dim = metric.shape[0]
    raised = sp.MutableDenseNDimArray.zeros(dim, dim)
    metric_inv = metric.inv()
    for mu in range(dim):
        for nu in range(dim):
            raised[mu, nu] = sp.simplify(
                sum(
                    metric_inv[mu, rho] * metric_inv[nu, sigma] * f_tensor[rho, sigma]
                    for rho in range(dim)
                    for sigma in range(dim)
                )
            )
    return raised


def divergence(f_tensor, coords):
    """Return d_mu F^{mu nu} for each nu."""
    dim = len(coords)
    div = [sp.Integer(0) for _ in range(dim)]
    for nu in range(dim):
        expr = 0
        for mu in range(dim):
            expr += sp.diff(f_tensor[mu, nu], coords[mu])
        div[nu] = sp.simplify(expr)
    return div


def check_bianchi(f_tensor, coords):
    """Confirm the homogeneous Maxwell equations."""
    dim = len(coords)
    for lam in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                bianchi = (
                    sp.diff(f_tensor[mu, nu], coords[lam])
                    + sp.diff(f_tensor[nu, lam], coords[mu])
                    + sp.diff(f_tensor[lam, mu], coords[nu])
                )
                assert sp.simplify(bianchi) == 0


def numeric_sweep(name, residuals, coords, param_subs, sample_points, tolerance=1e-9):
    """Evaluate residuals numerically across a grid of sample points."""
    max_residual = 0.0
    for point in sample_points:
        subs = dict(zip(coords, point))
        subs.update(param_subs)
        for expr in residuals:
            value = complex(sp.N(expr.subs(subs)))
            max_residual = max(max_residual, abs(value))
    assert max_residual < tolerance
    return f"{name}: numeric residual max = {max_residual:.2e}"


def verify_scenario(name, potential, coords, metric, expected_current):
    """Validate Maxwell equations for a given potential and expected current."""
    f_cov = build_field_tensor(potential, coords)
    f_contra = raise_indices(f_cov, metric)
    div = divergence(f_contra, coords)

    lines = []
    residuals = []
    for nu, expr in enumerate(div):
        simplified = sp.simplify(expr)
        target = sp.simplify(expected_current[nu])
        residual = sp.simplify(simplified - target)
        print(f"{name}: d_mu F^mu{nu} = {simplified}")
        assert residual == 0
        lines.append(f"{name}: d_mu F^mu{nu} = {simplified}")
        residuals.append(residual)

    check_bianchi(f_cov, coords)
    return lines, residuals


def ensure_artifact_dir():
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "EM-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def main():
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)
    minkowski = sp.diag(-1, 1, 1, 1)

    A0, k = sp.symbols("A0 k", real=True)
    phase = k * (z - t)
    plane_wave = sp.MutableDenseNDimArray.zeros(4)
    plane_wave[2] = A0 * sp.cos(phase)

    rho0 = sp.symbols("rho0", real=True)
    quadratic_potential = sp.MutableDenseNDimArray.zeros(4)
    quadratic_potential[0] = -rho0 * (x**2 + y**2 + z**2) / 6

    J0 = sp.symbols("J0", real=True)
    time_current_potential = sp.MutableDenseNDimArray.zeros(4)
    time_current_potential[3] = -J0 * t**2 / 2  # produces constant J^3

    scenarios = [
        ("vacuum_plane_wave", plane_wave, (0, 0, 0, 0)),
        ("uniform_charge", quadratic_potential, (rho0, 0, 0, 0)),
        ("time_current", time_current_potential, (0, 0, 0, J0)),
    ]

    numeric_configs = {
        "vacuum_plane_wave": {
            "params": {A0: 1.0, k: 2.0},
            "samples": list(product(np.linspace(-0.5, 0.5, 3), repeat=4)),
        },
        "uniform_charge": {
            "params": {rho0: 0.5},
            "samples": list(product(np.linspace(-0.3, 0.3, 3), repeat=4)),
        },
        "time_current": {
            "params": {J0: 1.25},
            "samples": list(product(np.linspace(-0.4, 0.4, 3), repeat=4)),
        },
    }

    artifact_dir = ensure_artifact_dir()
    outputs = []

    for name, potential, expected in scenarios:
        lines, residuals = verify_scenario(name, potential, coords, minkowski, expected)
        outputs.extend(lines)

        config = numeric_configs[name]
        summary = numeric_sweep(name, residuals, coords, config["params"], config["samples"])
        print(summary)
        outputs.append(summary)

    (artifact_dir / "em_flat_limit_check.txt").write_text("\n".join(outputs), encoding="utf-8")


if __name__ == "__main__":
    main()
