# Repository Guidelines

## Project Structure & Module Organization
- `Unified_Framework/` holds the unification program: `docs/` for planning and verification logs, `math/` for derivations, and `tests/` for automation scripts plus artifacts.
- `Automation_Agents/` provides PowerShell utilities (`list_agents.ps1`, `unification_research_agent.ps1`) that ingest research or scaffold workflows.
- Historical resources live under `Theory_Papers/`, `Documentation/`, and related top-level folders; treat them as read-only context unless a task says otherwise.

## Build, Test & Automation Commands
- `python Unified_Framework/tests/GR-001/gr_torsionless_check.py`: validates torsionless Einstein recoveries (outputs in `tests/artifacts/GR-001/`).
- `python Unified_Framework/tests/EM-001/em_flat_limit_check.py`: checks Maxwell limits for vacuum and sourced cases.
- `python Unified_Framework/tests/DIR-001/dirac_minimal_coupling_check.py`: exercises flat and FRW Dirac reductions.
- `powershell -File Automation_Agents/list_agents.ps1 -Detailed`: inventories available automation agents with size and timestamp metadata.

## Coding Style & Naming Conventions
- Python: prefer `black`-compatible 4-space indentation, lowercase module names, and descriptive snake_case for functions (`verify_metric`, `build_field_tensor`). Keep scripts self-validating with assertions rather than print-heavy logs.
- Markdown: use ATX headings, ordered lists for stepwise procedures, and backticks for commands/paths. Keep derivation files under 120-character lines for diff clarity.
- PowerShell agents follow PascalCase functions and align parameter blocks; include `Set-StrictMode -Version Latest` when scripting.

## Testing Guidelines
- SymPy-based checks live in `Unified_Framework/tests/`; mirror new physics claims with executable scripts or notebooks saved to `tests/artifacts/ID/`.
- Name new verification directories using the test identifier (e.g., `GAUGE-001`). Include README.md describing purpose, tooling, and run command.
- When extending checks, assert symbolic identities and persist outputs for reviewers; avoid silent failures.

## Commit & Pull Request Guidelines
- Follow present-tense, imperative commits (`Add FRW Dirac check`, `Update Maxwell verification notes`). Group related file updates together; do not bundle documentation-only tweaks with heavy code changes.
- Pull requests should summarize scope, list verification commands executed, link to relevant research logs or issues, and flag any follow-up TODOs. Include screenshots or artifact paths when visual outputs are produced.

## Agent Ops Tips
- Run agents from repository root so relative paths resolve (e.g., `powershell -File Automation_Agents/unification_research_agent.ps1 -Query "Cartan torsion"`).
- When saving raw payloads or logs, place them under the existing `research_logs/raw/` or `tests/artifacts/` hierarchies to keep the COMPLETE_INDEX accurate.
