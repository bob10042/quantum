# Unified Framework Initiative

Research program to construct a rigorously testable geometric unification of gravity, electromagnetism, and quantum fields. Every derivation, assumption, and prediction recorded here must trace back to reproducible mathematics and measurable consequences.

## Directory Layout

- `docs/` — planning notes, foundations, verification logs, prediction matrix.
- `math/` — symbolic derivations, recovery proofs, and supporting notebooks.
- `tests/` — automated consistency checks, numerical experiments, and cached artifacts (`tests/artifacts/`). Run `python tests/run_all.py` to execute the full verification suite locally.
- `research_logs/` — literature sweeps with raw payloads mirrored under `raw/`.
- `Automation_Agents/` — PowerShell utilities for research ingestion and repo maintenance.

## Operating Principles

1. **Fidelity** – Recover every validated result of GR + SM within stated limits before proposing extensions.
2. **Transparency** – Cite sources and assumptions so reviewers can trace each equation quickly.
3. **Falsifiability** – Tie new claims to observable signatures and maintain status tables.
4. **Tooling** – Prefer reproducible scripts (SymPy, EinsteinPy, xAct, Julia) with versioned outputs.

## Current Status

- Phase 0 foundations, roadmap, and verification scaffolding are published (`docs/phase0_foundations.md`, `docs/verification_log.md`).
- Core recoveries (Einstein, Maxwell, Dirac) are derived in `math/` and validated by SymPy automation; logs live in `tests/artifacts/GR-001`, `EM-001`, and `DIR-001`.
- EinsteinPy parity checks, numerical residual sweeps, and FRW reductions backstop the SymPy scripts; notebook companions (`*.ipynb`) exist beside each test for interactive reruns.
- Research agents populate `research_logs/` with anomaly, torsion, and supersymmetry sweeps to inform upcoming extensions.

## Immediate Goals

- Extend GR-001 to include torsion perturbations and document parity with external toolchains (xAct).
- Enrich EM-001 with mixed-source scenarios and ODE spot-checks; generalize DIR-001 to torsionful couplings.
- Standardize artifact metadata (hashes, runtime, parameters) and surface summaries in `docs/verification_log.md`.

## Contribution Workflow

1. Open a planning issue describing scope, dependencies, success criteria.
2. Draft in a feature branch; keep derivations in literate form (Markdown + code blocks/notebooks).
3. Run automated tests in `tests/` and attach artifact paths or hashes to the PR description.
4. Submit for review and log outcomes in `docs/verification_log.md`.

Stay disciplined: no speculative claims without derivation and prediction status updates.
