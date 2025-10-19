# Dirac Minimal Coupling Derivation

## Objective
Show that fermionic matter in the unified framework reduces to the standard Dirac equation on a curved background with minimal coupling to gauge fields, as required by the Phase 0 recovery checklist.

## Inputs
- Lorentz and spin-connection conventions in `docs/phase0_foundations.md#11-lorentz-sector-notes` and `#21-connection-forms`.
- Tetrad relationships from Section 2.4 of the same document.
- Supersymmetry-related references for torsion handling: `research_logs/2025-10-19_1309_cartan-geometry-supersymmetry-torsion.md`.

## Steps
1. Start with the fermionic portion of the unified action, writing the kinetic term using tetrads \(e^a{}_\mu\) and spin connection \(\omega_\mu^{ab}\).
2. Derive the covariant derivative \(D_\mu \psi = (\partial_\mu + \tfrac{1}{4}\omega_\mu^{ab}\gamma_{ab} - i g A_\mu) \psi\) given the conventions in Phase 0 docs.
3. Perform the variation with respect to \(\bar{\psi}\) to obtain the curved-space Dirac equation.
4. Take the flat limit \(e^a{}_\mu \rightarrow \delta^a_\mu\), \(\omega_\mu^{ab} \rightarrow 0\) to recover the standard Minkowski Dirac equation.
5. Outline symbolic calculations for `tests/DIR-001`, including gamma-matrix algebra checks.

## Checks
- Confirm Clifford algebra conventions with the chosen metric signature.
- Verify that the covariant derivative reduces to the minimal-coupling form in the flat limit.
- Ensure torsion contributions enter only through antisymmetric combinations consistent with references in the supersymmetry sweep.

## Results
- Starting from \(S_\psi = \int d^4x\, e\, \bar{\psi}\big(i\gamma^a e_a{}^\mu D_\mu - m\big)\psi\) with \(D_\mu = \partial_\mu + \tfrac{1}{4}\omega_\mu{}^{ab}\gamma_{ab} - ig A_\mu\), variation with respect to \(\bar{\psi}\) yields the curved-space Dirac equation \(i\gamma^a e_a{}^\mu D_\mu \psi - m\psi = 0\).
- The adjoint variation produces \(i D_\mu\bar{\psi}\, e_a{}^\mu \gamma^a + m\bar{\psi} = 0\), confirming Hermitian consistency and providing the conserved vector current \(J^\mu = e\, \bar{\psi}\gamma^a e_a{}^\mu \psi\) for `tests/DIR-001`.
- Imposing the torsionless solution for \(\omega_\mu{}^{ab}\) collapses the spin connection to the Levi-Civita form and eliminates the axial torsion term \(\tfrac{3i}{4}S_\mu\gamma^5\gamma^\mu\); any remaining gauge interaction appears solely through the minimal coupling \(gA_\mu\).
- In the flat limit \(e_a{}^\mu \rightarrow \delta_a^\mu\) and \(\omega_\mu{}^{ab} \rightarrow 0\), the equation reduces to \((i\gamma^\mu \partial_\mu - m)\psi = 0\), matching the Phase 0 recovery requirement and setting the normalization for the fermion kinetic term.
- The axial current for the plane-wave spinor used in DIR-001 evaluates to \(J_5^\mu = \big(p/\sqrt{m^2+p^2}, 0, 0, 1\big)\), providing the spin density needed by the torsion probe in `tests/GR-001/gr_torsion_perturbation_check.py`.
- Automated checks (`tests/DIR-001/dirac_minimal_coupling_check.py`) verify Minkowski plane waves (including arbitrary spatial momentum) and the homogeneous flat-FRW solution with Hubble friction term \( \tfrac{3}{2}H \), archiving logs in `tests/artifacts/DIR-001/`.

## Open Questions
- Quantify how torsion reintroduction modifies the axial current and identify anomaly-cancellation constraints linking those corrections to the `B-L` charge assignments.
- Work out Yukawa/Dirac mass terms for right-handed neutrinos so that minimal coupling persists while accommodating seesaw scenarios noted in the anomaly sweep.
- Provide an explicit spin-density map \(S^\mu \propto \bar{\psi}\gamma^\mu \gamma^5 \psi\) to feed the torsion sourcing required by `math/gr_torsion_perturbation.md` and `tests/GR-001/gr_torsion_perturbation_check.py`.
