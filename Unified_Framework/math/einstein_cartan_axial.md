# Einstein–Cartan Axial Torsion Solution

## Goal
Solve the algebraic Einstein–Cartan torsion equation for a homogeneous axial spin density using the FRW-compatible ansatz introduced in `math/gr_torsion_perturbation.md`.

## Field Equations
For Einstein–Cartan gravity with axial torsion \(S_\mu\) sourced by spin current \(J_\mu^{(5)}\):
\[
S_\mu = \frac{\kappa}{2} J_\mu^{(5)}, \qquad
T_{\lambda\mu\nu} = \epsilon_{\lambda\mu\nu\rho} S^\rho,
\]
where \(\kappa = 8\pi G\) in standard conventions.

In a spatially flat FRW background with tetrad \(e^a{}_\mu = \text{diag}(1, a(t), a(t), a(t))\) and the Dirac plane-wave solution used in DIR-001, the axial current is constant in time:
\[
J_0^{(5)} = \frac{p}{\sqrt{m^2 + p^2}}, \qquad J_i^{(5)} = \delta_{i3}.
\]
Hence the torsion is algebraically fixed:
\[
\sigma(t) = S_0 = \frac{\kappa}{2} J_0^{(5)}, \qquad \partial_t \sigma = 0.
\]

## SymPy Verification
- The script `tests/GR-001/gr_torsion_perturbation_check.py` substitutes \( \sigma = \kappa J_0^{(5)} \) (with \(J_0^{(5)}\) constant) and obtains zero divergence for Minkowski space.
- In FRW, the divergence reduces to \( \tfrac{3}{2} \kappa^2 J_0^{(5)} J_i^{(5)} \dot{a}/a^7 \), signalling that a purely temporal torsion cannot balance the expansion without incorporating the spatial spin components or solving the full Einstein–Cartan system.

## Next Steps
1. Extend the ansatz to include spatial torsion components proportional to \(J_i^{(5)}\) and re-evaluate the divergence.
2. Couple the result to the Dirac equations in a time-dependent spinor background to track \(J_\mu^{(5)}(t)\).
3. Embed the symbolic solution into `gr_torsion_perturbation_check.py` once the full Einstein–Cartan equations are solved, replacing hand substitutions.
