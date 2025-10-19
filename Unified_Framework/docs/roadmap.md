# Development Roadmap

> Status: Phase 0 in progress (kickoff 2025-10-19). Track deliverables in `docs/phase0_foundations.md`.

## Phase 0 — Foundations (Weeks 0-2)
- Finalize symmetry set: Lorentz invariance, gauge groups (SU(3)×SU(2)×U(1) baseline), diffeomorphism invariance.
- Define geometric objects: connection, torsion, curvature, tetrads, fiber structure.
- Produce checklist of recovery targets (Einstein field equations, Maxwell equations, Dirac equation) with acceptable tolerances.

## Phase 1 — Core Field Equations (Weeks 2-6)
- Derive unified action functional using Cartan geometry or alternative candidate.
- Show reduction to Einstein-Hilbert + Maxwell in torsionless and weak-field limits.
- Symbolically verify Bianchi identities, conservation laws.
- Milestone review: independent derivation replication and automated algebra checks in `tests/`.

## Phase 2 — Matter Coupling (Weeks 6-10)
- Introduce fermionic and bosonic matter representations respecting Standard Model charges.
- Recover Dirac equation, Yukawa interactions, and gauge covariant derivatives in appropriate limits.
- Validate anomaly cancellation; document in verification log.

## Phase 3 — Quantization and Effective Theories (Weeks 10-16)
- Develop linearized quantization around Minkowski background.
- Compare propagators and interaction vertices with QED/QCD where applicable.
- Identify effective-field-theory regime and estimate cutoff scales.

## Phase 4 — Phenomenology and Predictions (Weeks 16-24)
- Compute precision observables: anomalous magnetic moments, Lamb shift, gravitational lensing corrections, cosmological parameters.
- Populate prediction matrix with testable deviations and required experimental sensitivity.

## Phase 5 — Review and Publication (Weeks 24-28)
- Conduct full red-team audit; record responses in verification log.
- Prepare preprints, documentation, and data releases.
- Plan external peer engagement and replication packages.

## Ongoing Tasks
- Maintain `docs/verification_log.md` after every milestone.
- Update `tests/` suite whenever new derivations are added.
- Schedule periodic roadmap reviews (every four weeks) to adjust timelines and scope.
