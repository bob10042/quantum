# Einstein Limit Derivation

## Objective
Recover the Einstein field equations from the unified framework in the torsionless limit, validating that the geometric conventions in `docs/phase0_foundations.md` yield the standard form \(G_{\mu\nu} = 8\pi G\, T_{\mu\nu}\).

## Inputs
- Lorentz/tetrad conventions from `docs/phase0_foundations.md#11-lorentz-sector-notes` and Section 2.4.
- Connection and torsion definitions in `docs/phase0_foundations.md#21-connection-forms` and `#22-torsion-two-forms`.
- Research context on Cartan torsion behavior: `research_logs/2025-10-19_1308_cartan-geometry-unification-torsion.md`.

## Steps
1. Start from the unified action restricted to the gravitational sector and impose \(T^a = 0\) using the Cartan structure equation.
2. Express the curvature two-form \(R^a{}_b\) in terms of the Levi-Civita connection and translate into coordinate components \(R^\rho{}_{\sigma\mu\nu}\).
3. Derive the Einstein tensor via \(G_{\mu\nu} = R_{\mu\nu} - \tfrac{1}{2} g_{\mu\nu} R\) and verify signature consistency.
4. Match matter coupling terms to \(T_{\mu\nu}\) while ensuring conservation \(\nabla_\mu T^{\mu\nu} = 0\).
5. Prepare symbolic steps for automation (target `tests/GR-001` workflow).

## Checks
- Confirm torsionless condition reproduces Levi-Civita connection (compare with Cartan torsion references).
- Verify Bianchi identity \(D R^a{}_b = 0\) leads to \(\nabla_\mu G^{\mu\nu} = 0\).
- Cross-check numerical factors and sign conventions against Wald (1984) references noted in Phase 0 docs.

## Results
- Solving the torsion constraint \(T^a = 0\) with the first Cartan structure equation fixes the spin connection to the Levi-Civita form \(\omega_\mu{}^{ab}(e) = e^{a\nu}(\partial_\mu e^b{}_\nu - \Gamma^\rho_{\mu\nu} e^b{}_\rho)\), ensuring compatibility \(D_\mu e^a{}_\nu = 0\).
- Variation of the Einstein-Hilbert sector \(S_{\text{grav}} = \frac{1}{16\pi G}\int d^4x\, e\, e_a{}^\mu e_b{}^\nu R_{\mu\nu}{}^{ab}\) yields \(\delta S_{\text{grav}} = \frac{1}{16\pi G}\int d^4x\, e\, (G_{\mu\nu} + \Lambda g_{\mu\nu})\, \delta g^{\mu\nu}\) up to the tetrad-compatible Gibbons-Hawking-York boundary term.
- Including matter contributions gives \(\delta S_{\text{matter}} = -\tfrac{1}{2}\int d^4x\, e\, T_{\mu\nu}\, \delta g^{\mu\nu}\), producing the field equations \(G_{\mu\nu} + \Lambda g_{\mu\nu} = 8\pi G\, T_{\mu\nu}\) in the torsionless limit.
- The covariant Bianchi identity \(D R^a{}_b = 0\) implies \(\nabla_\mu G^{\mu\nu} = 0\), guaranteeing stress-energy conservation for any matter sector satisfying its equations of motion. This identity matches the verification target for `tests/GR-001`.
- Automated checks (`tests/GR-001/gr_torsionless_check.py`) confirm the divergence-free condition for Schwarzschild, spatially flat FRW, and rotating-frame Minkowski tetrads, with logs stored under `tests/artifacts/GR-001/`, and EinsteinPy cross-validation (`tests/GR-001/gr_torsionless_check_einsteinpy.py`) reproduces the same tensor components.

## Open Questions
- Quantify how reinstating torsion reintroduces the Nieh-Yan density and whether compensating boundary terms are required before extending beyond the torsionless sector.
- Fix the normalization and sign conventions for the tetrad-form Gibbons-Hawking-York term when stitching regions with different frame choices.
- Leverage the axial torsion perturbation study (`math/gr_torsion_perturbation.md`) to align GR-001 automation with Einstein–Cartan source terms.
