# Maxwell Limit Derivation

## Objective
Demonstrate that the unified gauge sector reduces to Maxwell's equations in the flat-space, torsionless limit with conserved sources, aligning with Phase 0 recovery targets.

## Inputs
- Gauge structure baseline from `docs/phase0_foundations.md#12-standard-model-gauge-baseline`.
- Bundle and connection conventions in `docs/foundations.md`.
- Literature on torsion and gauge interplay: `research_logs/2025-10-19_1308_cartan-geometry-unification-torsion.md`.

## Steps
1. Restrict the unified action to the \(U(1)_Y\) sector and identify the effective electromagnetic field strength \(F_{\mu\nu}\) under symmetry breaking \(SU(2)_L \times U(1)_Y \rightarrow U(1)_{\text{em}}\).
2. Impose Minkowski background \(g_{\mu\nu} = \eta_{\mu\nu}\) and torsionless limit \(T^a = 0\).
3. Vary the reduced action with respect to the gauge potential to obtain \(\partial_\mu F^{\mu\nu} = J^\nu\).
4. Confirm the Bianchi identity \(\partial_{[\lambda} F_{\mu\nu]} = 0\) follows from the bundle curvature definition.
5. Prepare symbolic steps for automation under `tests/EM-001`, including charge normalization checks.

## Checks
- Ensure coupling normalization matches \(Q = T_3 + Y\) conventions.
- Validate that the conserved current \(J^\mu\) satisfies \(\partial_\mu J^\mu = 0\).
- Compare with anomaly insights from `research_logs/2025-10-19_1309_standard-model-b-l-anomaly-cancellation.md` to flag potential extensions.

## Results
- Electromagnetic covariance emerges after electroweak symmetry breaking with \(A_\mu = \sin\theta_W\, W_\mu^3 + \cos\theta_W\, B_\mu\) and field strength \(F_{\mu\nu} = \partial_\mu A_\nu - \partial_\nu A_\mu\). In the torsionless, Minkowski limit the bundle curvature reduces to the usual antisymmetric tensor without spin-connection corrections.
- Varying the gauge action \(S_{\text{em}} = -\tfrac{1}{4}\int d^4x\, F_{\mu\nu}F^{\mu\nu} + \int d^4x\, J^\mu A_\mu\) gives \(\partial_\mu F^{\mu\nu} = J^\nu\), establishing the sourced Maxwell equations used as acceptance criteria in `tests/EM-001`.
- The geometric Bianchi identity \(D F = 0\) collapses to \(\partial_{[\lambda}F_{\mu\nu]} = 0\), guaranteeing the homogeneous Maxwell equations and enabling the vector-potential formulation targeted for automation.
- Evaluating the static point-charge ansatz with \(J^0 = q\delta^{(3)}(\mathbf{r})\) reproduces \(E_r = q/(4\pi r^2)\) and vanishing magnetic field, verifying normalization of the electric coupling inherited from the gauge baseline.
- Scripted verification (`tests/EM-001/em_flat_limit_check.py`) confirms vacuum plane waves, uniform charge densities, and a time-dependent current profile satisfy \(\partial_\mu F^{\mu\nu} = J^\nu\) and the Bianchi identity; residual sweeps are archived under `tests/artifacts/EM-001/`.

## Open Questions
- Track kinetic mixing terms when additional \(U(1)\) factors such as \(B-L\) are present, and document how diagonalization impacts the normalization of the electromagnetic current.
- Catalogue boundary terms (e.g., \(\int_{\partial M} F\wedge *A\)) required for a well-posed variational principle in manifolds with boundary, especially for future numerical implementations.
