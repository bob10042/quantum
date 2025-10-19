# DIR-001 - Dirac Minimal Coupling Check

## Purpose
Confirm that the fermionic sector yields the curved-space Dirac equation with minimal coupling and reduces to the Minkowski result, following `math/dirac_recovery.md`.

## Planned Tooling
- SymPy with `sympy.physics.matrices` or `clifford` for gamma algebra.
- Optional Mathematica/xAct verification for spin-connection handling.

## Inputs
- Lorentz, tetrad, and spin-connection conventions from `docs/phase0_foundations.md`.
- Supersymmetry-torsion references: `research_logs/2025-10-19_1309_cartan-geometry-supersymmetry-torsion.md`.

## Tasks
1. Symbolically compute the Euler-Lagrange equations for the fermionic action to reproduce the Dirac equation.
2. Check the flat limit explicitly and ensure gauge couplings align with the charge assignments used in EM-001.
3. Archive resulting notebooks/logs under `tests/artifacts/` and cross-reference in the verification plan and log.

## Automation
- `dirac_minimal_coupling_check.py` verifies flat-space plane waves (axial and arbitrary momentum) and a homogeneous flat-FRW solution satisfy the Dirac equation with conserved current, archiving outputs in `tests/artifacts/DIR-001/`. Execute with `python tests/DIR-001/dirac_minimal_coupling_check.py` or open `dirac_minimal_coupling_check.ipynb` for the notebook workflow.
