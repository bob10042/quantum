# CONS-001 - Stress-Energy Conservation

## Purpose
Demonstrate that the torsionless Einstein limit implies \(\nabla_\mu T^{\mu\nu} = 0\) for matter sources consistent with the unified framework, building on GR-001 outputs.

## Planned Tooling
- SymPy for symbolic divergence calculations.
- Reuse tensors computed in the GR-001 notebook where possible.

## Inputs
- Results from `tests/GR-001`.
- Matter sector details in `math/einstein_recovery.md` and `math/dirac_recovery.md`.

## Tasks
1. Import metric/tetrad solutions used in GR-001 and compute the covariant divergence of \(T^{\mu\nu}\).
2. Verify conservation for representative sources (perfect fluid, electromagnetic stress tensor).
3. Store evaluation logs under `tests/artifacts/` and update `tests/verification_plan.md` once the check passes.
