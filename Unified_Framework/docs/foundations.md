# Foundational Assumptions

> Phase tracking: detailed task breakdown lives in `docs/phase0_foundations.md`.

## Symmetry Requirements
- **Lorentz invariance**: theory must respect local SO(1,3) symmetry.
- **Gauge symmetries**: baseline SU(3)×SU(2)×U(1); any extensions documented with representations and anomaly checks.
- **Diffeomorphism invariance**: coordinate independence through manifold mappings.

## Geometric Structure
- Base manifold \(M\) with metric signature (-,+,+,+).
- Principal bundles for gauge groups; connection forms \(\omega\), curvature two-forms \(R\), torsion two-forms \(T\) with explicit transformation rules.
- Tetrad fields \(e^a{}_{\mu}\) linking tangent spaces to local frames.

## Action Principles
- Unified action \(S = \int (\mathcal{L}_{\text{grav}} + \mathcal{L}_{\text{gauge}} + \mathcal{L}_{\text{matter}} + \mathcal{L}_{\text{int}}) \sqrt{-g}\, d^4x\).
- Variation rules recorded explicitly; boundary terms accounted for.

## Recovery Targets
- Einstein field equations in torsionless limit.
- Maxwell equations in flat limit with standard sources.
- Dirac equation for spin-1/2 matter in curved spacetime.
- Stress-energy conservation \(\nabla_\mu T^{\mu\nu} = 0\).

## Validation Criteria
- Each derivation must provide pathway to reproduce known experimental values within current uncertainties.
- Symbolic computations cross-checked by independent toolchains (e.g., Mathematica + SymPy).
- Numerical estimates benchmarked against CODATA and observational datasets.

Keep this file synchronized with roadmap milestones and update whenever foundational decisions evolve.
