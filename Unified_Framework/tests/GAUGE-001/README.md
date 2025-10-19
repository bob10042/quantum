# GAUGE-001 - Gauge-Covariant Current Conservation

## Purpose
Verify that conserved currents associated with each gauge generator satisfy \(D_\mu J^\mu{}_a = 0\) using the charge assignments and symmetry inventory documented in Phase 0.

## Planned Tooling
- Symbolic algebra in SymPy to evaluate covariant derivatives with structure constants.
- Optional matrix-based checks for anomaly-safe charge configurations.

## Inputs
- Charge tables from `docs/phase0_foundations.md#12-standard-model-gauge-baseline`.
- B-L anomaly references: `research_logs/2025-10-19_1309_standard-model-b-l-anomaly-cancellation.md`.

## Tasks
1. Encode the Standard Model representations and compute covariant divergences for each current.
2. Extend the calculation to candidate \(U(1)_{B-L}\) charges and document conditions that enforce conservation.
3. Save scripts/notebooks under this directory and update verification tracking once evaluations are completed.
