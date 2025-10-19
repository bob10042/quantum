# Verification Plan Template

## Target
Specify the derivation or model component under test.

## Test Categories
- Symbolic consistency checks
- Numerical simulations
- Limit recoveries (e.g., GR, QFT)
- Dimensional analysis

## Tooling
- Scripts/notebooks to run
- Required data/configuration

## Procedure
1. Setup steps (environment, parameters).
2. Execution steps.
3. Expected outputs and tolerance levels.

## Results Log
| Date | Test | Outcome | Notes |
|------|------|---------|-------|

## Follow-ups
Document issues, retests, and review assignments.

---

## Phase 0 Verification Plan

| Test ID | Scope | Inputs | Tooling | Status | Notes |
|---------|-------|--------|---------|--------|-------|
| GR-001 | Torsionless Einstein recovery | `math/einstein_recovery.md` draft, tetrad definitions (Phase 0 Section 2.4) | SymPy script `tests/GR-001/gr_torsionless_check.py`, EinsteinPy audit `tests/GR-001/gr_torsionless_check_einsteinpy.py`, torsion probes `tests/GR-001/gr_torsion_perturbation_check.py` + `tests/GR-001/gr_einstein_cartan_solution.py`, optional xAct cross-check | Scripts passing | Schwarzschild, flat-FRW, and rotating-frame Minkowski tetrads pass; torsion probe shows expected Einstein-Cartan sourcing requirementâ€”extend to full spin-coupled automation. |
| EM-001 | Flat-space Maxwell equations | Gauge baseline notes (Phase 0 Section 1.2), Minkowski limit | SymPy script `tests/EM-001/em_flat_limit_check.py`, numeric sweep `tests/EM-001/em_numeric_sweep.py` | Scripts passing | Vacuum plane wave, uniform charge, time-dependent current, and finite-difference Gauss-law sweeps validated; extend to mixed-source cases and full ODE solvers. |
| DIR-001 | Dirac minimal coupling | Lorentz sector notes (Phase 0 Section 1.1), spin connection definition | SymPy script `tests/DIR-001/dirac_minimal_coupling_check.py`, Clifford algebra checks | Script passing | Flat-space plane waves (arbitrary momentum) and homogeneous FRW solutions pass; incorporate torsionful couplings next. |
| CONS-001 | Stress-energy conservation | Outputs of GR-001 | Placeholder script `tests/CONS-001/stress_energy_check.py` | Pending | Scaffold added; implement `?_µ T^{µ?} = 0` checks using GR-001 data and representative sources. |
| GAUGE-001 | Gauge-covariant current conservation | Charge assignments from Phase 0 Section 1.2 | Symbolic algebra, tabulated charges | Planned | Demonstrate `D_mu J^{mu}_a = 0` for each generator. |

### Execution roadmap
- Promote the current SymPy scripts for GR-001, EM-001, and DIR-001 into reproducible notebooks with logging under 	ests/artifacts/.
- Use 	ests/run_all.py for quick regressions; capture runtimes and parameters for future CI.
- Execute the scripts under controlled parameter sweeps; export .html or .md reports into 	ests/ for review and reference. Record hashes for reproducibility.
- When xAct validation is required, document the Mathematica workflow so reviewers without Mathematica can replicate via SymPy where feasible.

### Data capture and reporting
- Append results to the table above and register detailed outcomes in the Results Log once runs complete.
- Archive raw outputs under `tests/artifacts/` (create as needed) and note paths in the Notes column.
- Log verification activities in `docs/verification_log.md`, referencing both this plan and the corresponding derivations.






