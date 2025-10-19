# EM-001 - Flat-Space Maxwell Recovery

## Purpose
Validate that the unified gauge sector collapses to Maxwell's equations in the Minkowski, torsionless limit, consistent with `math/maxwell_recovery.md`.

## Planned Tooling
- SymPy for symbolic variation of the reduced gauge action.
- Julia or Python ODE solvers for optional numerical sanity checks of simple charge configurations.

## Inputs
- Gauge baseline conventions from `docs/phase0_foundations.md#12-standard-model-gauge-baseline`.
- Anomaly research references: `research_logs/2025-10-19_1309_standard-model-b-l-anomaly-cancellation.md`.

## Tasks
1. Build a SymPy notebook deriving \(\partial_\mu F^{\mu\nu} = J^\nu\) from the action and verify the Bianchi identity.
2. Implement a simple test case (e.g., static point charge) to confirm numerical agreement with known solutions.
3. Record outputs in `tests/artifacts/` and update verification tables when runs complete.

## Automation
- `em_flat_limit_check.py` validates vacuum plane waves, uniform static charge, and a time-dependent current pulse, confirming \( \partial_\mu F^{\mu\nu} = J^\nu\), running numeric sanity checks, and saving logs to `tests/artifacts/EM-001/`. Execute with `python tests/EM-001/em_flat_limit_check.py` or review `em_flat_limit_check.ipynb` for the notebook form.
- `em_numeric_sweep.py` integrates the 1D Gauss law using a finite-difference scheme and compares against the analytic solution; outputs land in `tests/artifacts/EM-001/em_numeric_sweep.json`. Execute with `python tests/EM-001/em_numeric_sweep.py`.


