# Phase 0 - Foundations Kickoff

> Time window: Weeks 0-2

This document tracks the concrete deliverables for the foundational phase described in `docs/roadmap.md`. Keep it synchronized with `docs/foundations.md` as decisions evolve.

## 1. Symmetry Inventory

| Task | Details | Status | Owner | References |
|------|---------|--------|-------|------------|
| Define Lorentz sector | Confirm local SO(1,3) representation choices and spin connection conventions. | [x] (2025-10-19, see Section 1.1) | Codex Agent | docs/foundations.md#symmetry-requirements, docs/phase0_foundations.md#11-lorentz-sector-notes |
| Verify SM gauge baseline | Document SU(3) x SU(2) x U(1) fiber structure, coupling normalization, and charge assignments. | [x] (2025-10-19, see Section 1.2) | Codex Agent | docs/foundations.md#symmetry-requirements, docs/phase0_foundations.md#12-standard-model-gauge-baseline |
| Identify candidate extensions | Catalogue optional symmetry enlargements with justification. | [x] (2025-10-19, see Section 1.3) | Codex Agent | docs/phase0_foundations.md#13-extension-candidates |
| Cross-check anomaly considerations | List triangle anomalies and cancellation conditions for baseline and extensions. | [x] (2025-10-19, see Section 1.4) | Codex Agent | docs/phase0_foundations.md#14-anomaly-check-summary |

### 1.1 Lorentz sector notes
- Local Lorentz symmetry is implemented as SO(1,3) acting on orthonormal frames; the metric signature (-,+,+,+) matches the convention in `docs/foundations.md`.
- Tetrads `e^a_mu` provide the soldering form between tangent indices (Greek letters) and local Lorentz indices (Latin letters). The determinant `e = det(e^a_mu)` normalizes the volume element.
- Spin-connection components `omega_mu^{ab}` are antisymmetric in `(a,b)` and transform as gauge connections under local Lorentz rotations. The convention `omega_mu^{ab} = -omega_mu^{ba}` keeps compatibility with the Cartan structure equations.
- Matter fields use the standard double-cover representation via SL(2,C), ensuring Dirac spinors acquire covariant derivatives `D_mu psi = (partial_mu + 1/4 omega_mu^{ab} gamma_ab) psi`.

### 1.2 Standard Model gauge baseline
- Gauge group `G_SM = SU(3)_c x SU(2)_L x U(1)_Y` is realized via principal bundles over the base manifold `M`. Each factor has a connection `A_mu^I T_I` valued in the corresponding Lie algebra.
- Coupling normalization follows the GUT-motivated convention `Tr(T^a T^b) = 1/2 delta^{ab}` for SU(N) generators in the fundamental representation. Hypercharge normalization is chosen so that `Q = T_3 + Y` reproduces observed electric charges.
- One generation of fermions carries representations: left-handed quark doublet `(3,2)_{1/6}`, right-handed up `(3,1)_{2/3}`, right-handed down `(3,1)_{-1/3}`, left-handed lepton doublet `(1,2)_{-1/2}`, right-handed electron `(1,1)_{-1}`, optional right-handed neutrino `(1,1)_0` retained for anomaly bookkeeping.
- Fiber structure is summarized in `docs/foundations.md`; diagrammatic details will live under `math/` as derivations are drafted.

### 1.3 Extension candidates
- Conformal extension: promote global scale invariance to local Weyl symmetry with a compensator field. Assess whether gauging dilatations reintroduces anomalies (analysis pending in `math/`).
- Supersymmetry: consider `N=1` super-Poincare algebra with minimal field content, constrained by torsion conditions from standard supergravity literature. Track compatibility with the tetrad formalism.
  - Research sweep `research_logs/2025-10-19_1309_cartan-geometry-supersymmetry-torsion.md` summarizes Newton-Cartan supersymmetric constructions for follow-up.
- Grand unification ideas: SU(5) and SO(10) embeddings recorded with decomposition to Standard Model multiplets. Maintain anomaly-free representations and note proton-decay constraints for Phase 4 phenomenology.
- Additional U(1) factors such as `U(1)_{B-L}` are listed with charge assignments that cancel mixed anomalies when right-handed neutrinos are included.
  - Supporting references captured in `research_logs/2025-10-19_1309_standard-model-b-l-anomaly-cancellation.md`; extract anomaly-free charge patterns before implementation.

### 1.4 Anomaly check summary
| Anomaly | Condition | Baseline status | Notes |
|---------|-----------|-----------------|-------|
| `[SU(3)]^2 U(1)_Y` | Sum of `Y T(R)` over chiral fermions vanishes | Satisfied per generation | Quark triplets cancel when left- and right-handed fields are included. |
| `[SU(2)]^2 U(1)_Y` | Sum of `Y T(R)` over doublets vanishes | Satisfied per generation | Quark and lepton doublets offset. |
| `[U(1)_Y]^3` | Sum of `Y^3` over chiral fermions vanishes | Satisfied per generation | Standard Model assignment gives zero. |
| Gravitational `U(1)_Y` | Sum of `Y` over chiral fermions vanishes | Satisfied per generation | Verified with optional right-handed neutrino neutral. |
| Mixed `U(1)` (extensions) | Each added U(1) obeys analogous sums | Pending | Evaluate once extension charges are finalized; see `research_logs/2025-10-19_1309_standard-model-b-l-anomaly-cancellation.md` for recent context. |

Document any deviations from the baseline anomaly conditions in `research_logs/` and record remediation strategies before advancing to Phase 1.

## 2. Geometric Object Definitions

| Object | Deliverable | Status | Owner | Notes |
|--------|------------|--------|-------|-------|
| Connection forms `omega` | Specify representation, components, and gauge transformation properties. | [x] (2025-10-19, Section 2.1) | Codex Agent | Aligned with Cartan formalism and Section 1.1 notes. |
| Torsion two-forms `T` | State when torsion is permitted, relevant identities, and constraints for recovery limits. | [x] (2025-10-19, Section 2.2) | Codex Agent | Requires symbolic check plan for torsionless limit. |
| Curvature `R` | Document Bianchi identities and sign conventions. | [x] (2025-10-19, Section 2.3) | Codex Agent | Prep for automated validation in `tests/`. |
| Tetrads `e^a_mu` | Clarify index conventions, determinant normalization, and metric reconstruction. | [x] (2025-10-19, Section 2.4) | Codex Agent | Cross-linked with Lorentz sector section. |

### 2.1 Connection forms
- Levi-Civita connection appears when torsion is constrained to zero, defined by `omega_mu^{ab}(e) = e^{a nu} (partial_mu e^b_nu - Gamma^rho_{mu nu} e^b_rho)`.
- General affine connections may include contorsion `K_mu^{ab}` so that `omega_mu^{ab} = omega_mu^{ab}(e) + K_mu^{ab}`. Track `K` contributions explicitly to control torsion effects.
- Gauge transformations act as `omega_mu -> Lambda omega_mu Lambda^{-1} + Lambda partial_mu Lambda^{-1}` for `Lambda(x)` in SO(1,3). Preserve this formula within derivation templates.

### 2.2 Torsion two-forms
- Torsion is defined by the first Cartan structure equation `T^a = d e^a + omega^a_b wedge e^b`. Components read `T^a_{mu nu} = 2 partial_[mu e^a_{nu]} + 2 omega_[mu^{ab} e_{nu]b}`.
- Recovery requirement: torsion must vanish (or be algebraically constrained) when matching Einstein gravity. Imposing `T^a = 0` implies the Levi-Civita connection.
- For extensions allowing torsion (Einstein-Cartan, supersymmetric cases), record the algebraic relation between torsion and spin density in `math/` derivations.
- Literature snapshot: `research_logs/2025-10-19_1308_cartan-geometry-unification-torsion.md` consolidates recent Cartan-torsion studies relevant to this section.

### 2.3 Curvature
- Curvature two-form `R^a_b = d omega^a_b + omega^a_c wedge omega^c_b` yields components `R^a_{b mu nu}` used in field equations.
- Sign convention adopted so that the Riemann tensor satisfies `R^rho_{sigma mu nu} = partial_mu Gamma^rho_{nu sigma} - partial_nu Gamma^rho_{mu sigma} + ...`, matching Wald (1984).
- Bianchi identities monitored: `D T^a = R^a_b wedge e^b` and `D R^a_b = 0`. Automated checks via SymPy or xAct are scheduled under `tests/`.

### 2.4 Tetrads
- Tetrads satisfy `g_{mu nu} = eta_{ab} e^a_mu e^b_nu` with `eta = diag(-1, 1, 1, 1)`. Orientation is fixed so that `det(e^a_mu) > 0`.
- Index conventions: Latin indices `(a,b,...)` denote local Lorentz frames, Greek indices `(mu,nu,...)` denote spacetime coordinates. Raising and lowering use `eta_{ab}` and `g_{mu nu}`.
- Volume form normalization: `epsilon_{abcd} e^a wedge e^b wedge e^c wedge e^d = 4! e d^4 x`, required for action integrals.

## 3. Recovery Target Checklist

Use this checklist to ensure reduction to established physics before advancing to Phase 1. Each item references preparatory notes or planned derivations.

- [ ] Einstein field equations recovered in torsionless, vacuum, and matter-coupled limits. (Planned derivation: `math/einstein_recovery.md`, tests via SymPy notebook.)
- [ ] Maxwell equations recovered in flat spacetime with conserved sources. (Requires gauge-sector reduction script in `tests/`.)
- [ ] Dirac equation recovered for spin-1/2 matter on curved background with minimal coupling. (Derivation to cite Section 1.1 and tetrad notes.)
- [ ] Stress-energy conservation `nabla_mu T^{mu nu} = 0` verified from field equations. (Depends on completion of Einstein recovery derivation.)
- [ ] Gauge-covariant conservation laws checked for each symmetry generator. (Needs charge assignment table from Section 1.2 embedded into derivations.)

## 4. Dependencies and Inputs

- Literature review tasks should reference outputs under `Unified_Framework/research_logs/` (see new sweeps dated 2025-10-19 for Cartan torsion, supersymmetry, and B-L anomaly topics).
- All derivations use `math/derivation_template.md` with citations back to this checklist.
- Corresponding test plans now live in `tests/verification_plan.md` with Phase 0 coverage.
- Coordinate with tooling owners before introducing Mathematica workflows; document reproducible steps for SymPy equivalents.

## 5. Immediate Next Actions

1. Populate `math/` with draft derivations for Einstein and Maxwell recoveries using the template, citing Sections 2.1-2.4.
2. Stand up symbolic check scripts for the torsionless reduction (prefer SymPy) and register them under `tests/`.
3. Launch a literature sweep via `Automation_Agents/unification_research_agent.ps1` focused on Cartan-based unification and anomaly-free extensions; deposit report in `research_logs/`.
4. Prepare charge and representation tables for candidate extensions (Section 1.3) to support anomaly verification once new symmetries are adopted.

Update this file as tasks reach completion. Add commit or log references in the Status column (for example `[x] (Commit abc123)` once applicable).
