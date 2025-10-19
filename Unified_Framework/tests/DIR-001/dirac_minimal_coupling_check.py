"""DIR-001 automation: verify Dirac minimal coupling in flat and curved backgrounds."""

from pathlib import Path

import sympy as sp
from sympy.physics.matrices import mgamma


def minkowski_spinor_checks():
    """Check a plane-wave solution in flat spacetime."""
    t, x, y, z = sp.symbols("t x y z", real=True)
    mass, momentum = sp.symbols("m p", positive=True)
    energy = sp.sqrt(momentum**2 + mass**2)

    spinor = dirac_spinor_z_axis(energy, momentum, mass)
    phase = -energy * t + momentum * z
    psi = spinor * sp.exp(sp.I * phase)

    residual = flat_dirac_residual(psi, (t, x, y, z), mass)
    lines = []
    for idx, value in enumerate(residual):
        simplified = sp.simplify(value)
        print(f"minkowski: Dirac residual component {idx} = {simplified}")
        assert simplified == 0
        lines.append(f"minkowski: Dirac residual component {idx} = {simplified}")

    current = conserved_current(psi)
    divergence = sp.simplify(
        sp.diff(current[0], t) + sp.diff(current[1], x) + sp.diff(current[2], y) + sp.diff(current[3], z)
    )
    print(f"minkowski: divergence = {divergence}")
    assert sp.simplify(divergence) == 0
    lines.append(f"minkowski: divergence = {divergence}")
    return lines


def dirac_spinor_z_axis(energy, momentum, mass):
    """Return a positive-energy spinor with momentum along the z-axis."""
    norm = sp.sqrt((energy + mass) / (2 * energy))
    upper = sp.Matrix([1, 0])
    lower = sp.Matrix([momentum / (energy + mass), 0])
    return norm * sp.Matrix.vstack(upper, lower)


def flat_dirac_residual(psi, coords, mass):
    """Compute (i gamma^mu d_mu - m) psi in flat spacetime."""
    result = sp.zeros(4, 1)
    for mu, coord in enumerate(coords):
        result += mgamma(mu) * sp.diff(psi, coord)
    result = sp.I * result - mass * psi
    return sp.Matrix([sp.simplify(component) for component in result])


def conserved_current(psi):
    """Construct the Dirac vector current J^mu."""
    gamma0 = mgamma(0)
    psi_dag = sp.conjugate(psi.T)
    psi_bar = psi_dag * gamma0
    components = []
    for mu in range(4):
        current_mu = (psi_bar * mgamma(mu) * psi)[0]
        components.append(sp.simplify(current_mu))
    return components


def spatial_plane_wave_checks():
    """Check a plane-wave solution with arbitrary spatial momentum."""
    t, x, y, z = sp.symbols("t x y z", real=True)
    mass = sp.symbols("m", positive=True)
    px, py, pz = sp.symbols("p_x p_y p_z", real=True)
    energy = sp.sqrt(px**2 + py**2 + pz**2 + mass**2)

    chi = sp.Matrix([1, 0])
    sigma_x = sp.Matrix([[0, 1], [1, 0]])
    sigma_y = sp.Matrix([[0, -sp.I], [sp.I, 0]])
    sigma_z = sp.Matrix([[1, 0], [0, -1]])
    sigma_dot_p = px * sigma_x + py * sigma_y + pz * sigma_z
    lower = sigma_dot_p * chi / (energy + mass)
    norm = sp.sqrt((energy + mass) / (2 * energy))
    spinor = norm * sp.Matrix.vstack(chi, lower)

    phase = -energy * t + px * x + py * y + pz * z
    psi = spinor * sp.exp(sp.I * phase)

    residual = flat_dirac_residual(psi, (t, x, y, z), mass)
    lines = []
    for idx, value in enumerate(residual):
        simplified = sp.simplify(value)
        print(f"spatial_plane_wave: Dirac residual component {idx} = {simplified}")
        assert simplified == 0
        lines.append(f"spatial_plane_wave: Dirac residual component {idx} = {simplified}")

    current = conserved_current(psi)
    divergence = sp.simplify(
        sp.diff(current[0], t) + sp.diff(current[1], x) + sp.diff(current[2], y) + sp.diff(current[3], z)
    )
    print(f"spatial_plane_wave: divergence = {divergence}")
    assert sp.simplify(divergence) == 0
    lines.append(f"spatial_plane_wave: divergence = {divergence}")
    return lines


def frw_spinor_check():
    """Verify the homogeneous FRW Dirac equation with scale factor a(t)."""
    t, x, y, z = sp.symbols("t x y z", real=True)
    a = sp.Function("a")
    adot = sp.diff(a(t), t)
    H = sp.simplify(adot / a(t))

    mass = sp.symbols("m", positive=True)
    base_spinor = sp.Matrix([1, 0, 0, 0])
    psi = a(t) ** (-sp.Rational(3, 2)) * sp.exp(-sp.I * mass * t) * base_spinor

    operator = sp.I * mgamma(0) * (sp.diff(psi, t) + sp.Rational(3, 2) * H * psi) - mass * psi
    lines = []
    for idx, value in enumerate(operator):
        simplified = sp.simplify(value.expand())
        simplified = sp.simplify(simplified.subs(sp.diff(a(t), t), a(t) * H))
        print(f"frw_flat: Dirac residual component {idx} = {simplified}")
        assert simplified == 0
        lines.append(f"frw_flat: Dirac residual component {idx} = {simplified}")
    return lines


def ensure_artifact_dir():
    artifact_dir = Path(__file__).resolve().parents[1] / "artifacts" / "DIR-001"
    artifact_dir.mkdir(parents=True, exist_ok=True)
    return artifact_dir


def main():
    artifact_dir = ensure_artifact_dir()
    outputs = []
    outputs.extend(minkowski_spinor_checks())
    outputs.extend(spatial_plane_wave_checks())
    outputs.extend(frw_spinor_check())
    (artifact_dir / "dirac_minimal_coupling_check.txt").write_text("\n".join(outputs), encoding="utf-8")


if __name__ == "__main__":
    main()
