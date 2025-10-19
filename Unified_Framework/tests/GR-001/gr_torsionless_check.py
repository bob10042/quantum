"""GR-001 automation: verify nabla_mu G^{mu}{}_nu = 0 for representative torsionless tetrads."""

from pathlib import Path

import sympy as sp


def christoffel_symbols(metric, g_inv, coords):
    """Compute Christoffel symbols of the second kind for a given metric."""
    dim = len(coords)
    gamma = [[[sp.Integer(0) for _ in range(dim)] for _ in range(dim)] for _ in range(dim)]
    for lam in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                term = 0
                for rho in range(dim):
                    d_mu = sp.diff(metric[rho, nu], coords[mu])
                    d_nu = sp.diff(metric[rho, mu], coords[nu])
                    d_rho = sp.diff(metric[mu, nu], coords[rho])
                    term += g_inv[lam, rho] * (d_mu + d_nu - d_rho)
                gamma[lam][mu][nu] = sp.simplify(sp.Rational(1, 2) * term)
    return gamma


def ricci_tensor(gamma, coords):
    """Return the Ricci tensor given the Christoffel symbols."""
    dim = len(coords)
    ricci = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            term = 0
            for lam in range(dim):
                term += sp.diff(gamma[lam][mu][nu], coords[lam])
                term -= sp.diff(gamma[lam][mu][lam], coords[nu])
                for rho in range(dim):
                    term += gamma[lam][mu][nu] * gamma[rho][lam][rho]
                    term -= gamma[rho][mu][lam] * gamma[lam][nu][rho]
            ricci[mu, nu] = sp.simplify(term)
    return ricci


def einstein_tensor(metric, g_inv, ricci):
    """Construct the Einstein tensor from metric and Ricci data."""
    dim = metric.shape[0]
    ricci_scalar = sp.simplify(sum(g_inv[i, j] * ricci[i, j] for i in range(dim) for j in range(dim)))
    einstein = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            einstein[mu, nu] = sp.simplify(ricci[mu, nu] - sp.Rational(1, 2) * metric[mu, nu] * ricci_scalar)
    return einstein


def divergence_g(einstein, g_inv, gamma, coords):
    """Compute the covariant divergence of the Einstein tensor."""
    dim = len(coords)
    g_mixed = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            g_mixed[mu, nu] = sp.simplify(sum(g_inv[mu, rho] * einstein[rho, nu] for rho in range(dim)))

    divergences = []
    for nu in range(dim):
        term = 0
        for mu in range(dim):
            term += sp.diff(g_mixed[mu, nu], coords[mu])
            for lam in range(dim):
                term += gamma[mu][mu][lam] * g_mixed[lam, nu]
                term -= gamma[lam][mu][nu] * g_mixed[mu, lam]
        divergences.append(sp.simplify(term))
    return divergences


def verify_metric(name, metric, coords):
    """Verify Bianchi identity for a supplied metric and return formatted results."""
    g_inv = metric.inv()
    gamma = christoffel_symbols(metric, g_inv, coords)
    ricci = ricci_tensor(gamma, coords)
    einstein = einstein_tensor(metric, g_inv, ricci)
    divergences = divergence_g(einstein, g_inv, gamma, coords)

    lines = []
    for idx, expr in enumerate(divergences):
        simplified = sp.simplify(expr)
        print(f"{name}: divergence_component[{idx}] = {simplified}")
        assert simplified == 0
        lines.append(f"{name}: divergence_component[{idx}] = {simplified}")
    return lines


def ensure_artifact_dir():
    """Create the artifact directory if it does not yet exist."""
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "GR-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


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

    scenarios = {
        "schwarzschild": schwarzschild,
        "frw_flat": frw_flat,
        "rotating_minkowski": rotating_minkowski,
    }

    artifact_dir = ensure_artifact_dir()
    outputs = []

    for name, metric in scenarios.items():
        outputs.extend(verify_metric(name, metric, coords))

    (artifact_dir / "gr_torsionless_check.txt").write_text("\n".join(outputs), encoding="utf-8")


if __name__ == "__main__":
    main()
