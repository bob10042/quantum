"""GR-001 torsion perturbation check: evaluate axial torsion impact on Einstein tensor divergence."""

from pathlib import Path

import sympy as sp
from sympy.physics.matrices import mgamma


def ensure_artifact_dir():
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "GR-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def axial_current_plane_wave():
    t, z = sp.symbols("t z", real=True)
    m, p = sp.symbols("m p", positive=True)
    energy = sp.sqrt(p**2 + m**2)

    chi = sp.Matrix([1, 0])
    lower = sp.Matrix([p / (energy + m), 0])
    norm = sp.sqrt((energy + m) / (2 * energy))
    spinor = norm * sp.Matrix.vstack(chi, lower)

    phase = -energy * t + p * z
    psi = spinor * sp.exp(sp.I * phase)

    gamma0 = mgamma(0)
    gamma5 = mgamma(5)
    psi_bar = sp.conjugate(psi.T) * gamma0

    axial = []
    for mu in range(4):
        current_mu = (psi_bar * mgamma(mu) * gamma5 * psi)[0]
        axial.append(sp.simplify(current_mu))
    return axial, {m: sp.symbols("m_dirac", positive=True), p: sp.symbols("p_dirac", real=True)}


def torsion_tensor(g, g_inv, s_contra, coords):
    dim = len(coords)
    torsion_lower = sp.MutableDenseNDimArray.zeros(dim, dim, dim)
    for lam in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                term = 0
                for rho in range(dim):
                    term += sp.LeviCivita(lam, mu, nu, rho) * s_contra[rho]
                torsion_lower[lam, mu, nu] = sp.simplify(term)
    torsion_up = sp.MutableDenseNDimArray.zeros(dim, dim, dim)
    for rho in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                term = 0
                for lam in range(dim):
                    term += g_inv[rho, lam] * torsion_lower[lam, mu, nu]
                torsion_up[rho, mu, nu] = sp.simplify(term)
    return torsion_lower, torsion_up


def contorsion(torsion_lower, torsion_up, g, g_inv):
    dim = g.shape[0]
    cont = sp.MutableDenseNDimArray.zeros(dim, dim, dim)
    for lam in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                term = torsion_lower[nu, lam, mu] + torsion_lower[mu, nu, lam] - torsion_lower[lam, mu, nu]
                cont[lam, mu, nu] = sp.simplify(sp.Rational(1, 2) * term)
    cont_up = sp.MutableDenseNDimArray.zeros(dim, dim, dim)
    for rho in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                term = 0
                for lam in range(dim):
                    term += g_inv[rho, lam] * cont[lam, mu, nu]
                cont_up[rho, mu, nu] = sp.simplify(term)
    return cont_up


def curvature_and_einstein(connection, coords, g, g_inv):
    dim = len(coords)
    riemann = sp.MutableDenseNDimArray.zeros(dim, dim, dim, dim)
    for rho in range(dim):
        for sigma in range(dim):
            for mu in range(dim):
                for nu in range(dim):
                    term = sp.diff(connection[rho, nu, sigma], coords[mu]) - sp.diff(
                        connection[rho, mu, sigma], coords[nu]
                    )
                    for lam in range(dim):
                        term += connection[rho, mu, lam] * connection[lam, nu, sigma]
                        term -= connection[rho, nu, lam] * connection[lam, mu, sigma]
                    riemann[rho, sigma, mu, nu] = sp.simplify(term)

    ricci = sp.MutableDenseNDimArray.zeros(dim, dim)
    for sigma in range(dim):
        for nu in range(dim):
            term = 0
            for rho in range(dim):
                term += riemann[rho, sigma, rho, nu]
            ricci[sigma, nu] = sp.simplify(term)

    ricci_scalar = sp.simplify(sum(g_inv[mu, nu] * ricci[mu, nu] for mu in range(dim) for nu in range(dim)))
    einstein = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            einstein[mu, nu] = sp.simplify(ricci[mu, nu] - sp.Rational(1, 2) * g[mu, nu] * ricci_scalar)
    return einstein


def raise_indices(tensor, g_inv):
    dim = tensor.shape[0]
    raised = sp.MutableDenseNDimArray.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            raised[mu, nu] = sp.simplify(sum(g_inv[mu, rho] * tensor[rho, nu] for rho in range(dim)))
    return raised


def divergence(einstein_up, connection, coords, g_inv):
    dim = len(coords)
    divergences = []
    for nu in range(dim):
        term = 0
        for mu in range(dim):
            term += sp.diff(einstein_up[mu, nu], coords[mu])
            for lam in range(dim):
                term += connection[mu, mu, lam] * einstein_up[lam, nu]
                term -= connection[lam, mu, nu] * einstein_up[mu, lam]
        divergences.append(sp.simplify(term))
    return divergences


def main():
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)

    a = sp.Function("a")

    scenarios = {
        "minkowski": sp.diag(-1, 1, 1, 1),
        "frw_flat": sp.diag(-1, a(t) ** 2, a(t) ** 2, a(t) ** 2),
    }

    kappa = sp.symbols("kappa")
    spin_density = sp.Function("s")(t)
    axial_current, subs_map = axial_current_plane_wave()
    axial_current = [sp.simplify(comp.subs(subs_map)) for comp in axial_current]

    artifact_dir = ensure_artifact_dir()
    lines = []

    for name, g in scenarios.items():
        g_inv = sp.simplify(sp.Matrix(g).inv())

        sigma = sp.Function("sigma")(t)
        tau = sp.Function("tau")(t)
        s_contra = sp.Matrix([sigma, 0, 0, tau])

        torsion_lower, torsion_up = torsion_tensor(g, g_inv, s_contra, coords)
        connection = contorsion(torsion_lower, torsion_up, g, g_inv)
        einstein = curvature_and_einstein(connection, coords, g, g_inv)
        einstein_up = raise_indices(einstein, g_inv)
        divergences = divergence(einstein_up, connection, coords, g_inv)

        lines.append(f"## {name}")
        for idx, expr in enumerate(divergences):
            simplified = sp.simplify(expr)
            print(f"{name}: torsion_divergence[{idx}] = {simplified}")
            lines.append(f"{name}: torsion_divergence[{idx}] = {simplified}")

        sigma_prime = sp.diff(sigma, t)
        lines.append(f"{name}: sigma_prime = {sigma_prime}")

        divergence_with_spin = sp.simplify(divergences[0].subs(sigma, kappa * spin_density))
        lines.append(f"{name}: divergence_with_sigma_eq_kappa_s = {divergence_with_spin}")

        sigma_dirac = sp.simplify(kappa * axial_current[0])
        tau_dirac = sp.simplify(kappa * axial_current[3])
        subs_dirac = {
            sigma: sigma_dirac,
            sp.diff(sigma, t): 0,
        }

        if name == "minkowski":
            subs_dirac.update({tau: tau_dirac, sp.diff(tau, t): 0})
            tau_profile = tau_dirac
        else:
            tau_symbol = sp.symbols("tau_symbol")
            expr_frw = sp.simplify(
                divergences[0]
                .subs({sigma: sigma_dirac, sp.diff(sigma, t): 0, tau: tau_symbol, sp.diff(tau, t): 0})
            )
            solutions = sp.solve(sp.Eq(expr_frw, 0), tau_symbol)
            tau_profile = sp.simplify(solutions[0])
            tau_profile = sp.simplify(tau_profile.subs({sigma_dirac: sigma_dirac}))
            tau_derivative = sp.diff(tau_profile, t)
            subs_dirac.update({tau: tau_profile, sp.diff(tau, t): tau_derivative})

        divergence_with_dirac = sp.simplify(divergences[0].subs(subs_dirac))
        lines.append(f"{name}: divergence_with_dirac_axial = {divergence_with_dirac}")
        lines.append(f"{name}: tau_profile = {sp.simplify(tau_profile)}")

    lines.append(f"axial_current_components = {axial_current}")
    lines.append("Note: Spatial torsion profile τ must track σ and a(t) to cancel FRW divergence.")
    (artifact_dir / "gr_torsion_perturbation_check.txt").write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
