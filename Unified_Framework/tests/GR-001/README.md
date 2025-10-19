# GR-001 - Torsionless Einstein Recovery

## Purpose
Automate the symbolic reduction outlined in `math/einstein_recovery.md`, verifying that the torsionless limit reproduces the Einstein field equations using shared conventions from Phase 0 documentation.

## Planned Tooling
- SymPy (einsteinpy) for curvature and Einstein-tensor calculations.
- Optional cross-check with xAct (document workflow if executed).

## Inputs
- Tetrad and connection definitions from `docs/phase0_foundations.md`.
- Research references: `research_logs/2025-10-19_1308_cartan-geometry-unification-torsion.md`.

## Tasks
1. Implement a SymPy script/notebook computing \(R_{\mu\nu}\) and \(G_{\mu\nu}\) for a generic tetrad with imposed torsionless constraint.
2. Validate \(\nabla_\mu G^{\mu\nu} = 0\) numerically on representative metrics (e.g., Schwarzschild in tetrad form).
3. Store outputs (plots/logs) under `tests/artifacts/` once available and reference them in `tests/verification_plan.md` and `docs/verification_log.md`.

## Automation
- `gr_torsionless_check.py` runs SymPy-based verifications that Schwarzschild, flat-FRW, and rotating-frame Minkowski tetrads satisfy \(\nabla_\mu G^{\mu\nu} = 0\) in the torsionless limit while archiving outputs under `tests/artifacts/GR-001/`. Execute with `python tests/GR-001/gr_torsionless_check.py` or open `gr_torsionless_check.ipynb` for the notebook workflow.
- `gr_torsionless_check_einsteinpy.py` cross-validates the Einstein tensor against EinsteinPy and confirms the Bianchi identity using the same metrics. Execute with `python tests/GR-001/gr_torsionless_check_einsteinpy.py`.
- `gr_torsion_perturbation_check.py` introduces an axial torsion ansatz on Minkowski and flat-FRW backgrounds, reporting the resulting divergence and substitutions for generic spin densities and the Dirac axial current. Execute with `python tests/GR-001/gr_torsion_perturbation_check.py`.
- `gr_einstein_cartan_solution.py` solves the algebraic Einstein–Cartan torsion equation and reports residual divergences for Minkowski/FRW backgrounds. Execute with `python tests/GR-001/gr_einstein_cartan_solution.py`.
