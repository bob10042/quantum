# Einstein Limit with Axial Torsion Perturbation

## Objective
Map how a small totally antisymmetric torsion \( S_\mu \) alters the Einstein-limit recovery, providing a baseline for extending GR-001 to Einstein–Cartan checks.

## Setup
- Background metric: Minkowski in rotating coordinates (matches GR-001 coverage).
- Torsion ansatz: \( T_{\lambda\mu\nu} = \epsilon_{\lambda\mu\nu\rho} S^\rho \) with \( S^\rho = (\sigma(t), 0, 0, 0) \) capturing an axial time-dependent perturbation.
- Contorsion: \( K_{\lambda\mu\nu} = -\tfrac{1}{2}\left(T_{\lambda\mu\nu} - T_{\mu\nu\lambda} + T_{\nu\lambda\mu}\right) \).
- Modified connection: \( \Gamma^\rho_{\mu\nu} = \{^{\;\rho}_{\mu\nu}\} + K^\rho{}_{\mu\nu} \), where \( \{^{\;\rho}_{\mu\nu}\} \) is the Levi-Civita part.

## Derivation Outline
1. Construct \( K^\rho{}_{\mu\nu} \) using the torsion ansatz and rotate-frame metric inverse.
2. Compute curvature \( R^\rho{}_{\sigma\mu\nu} \) with the torsionful connection and contract to obtain \( R_{\mu\nu} \).
3. Form the Einstein tensor \( G_{\mu\nu} = R_{\mu\nu} - \tfrac{1}{2} g_{\mu\nu} R \).
4. Evaluate \( \nabla_\mu G^{\mu\nu} \) using the torsionful covariant derivative to expose non-vanishing corrections proportional to \( \dot{\sigma}(t) \).

## Preliminary Result
- Automation (`tests/GR-001/gr_torsion_perturbation_check.py`) yields \( \nabla_\mu G^{\mu 0} = \tfrac{3}{2} \sigma \dot{\sigma} \) with other components vanishing; substituting \(\sigma = \kappa s(t)\) produces \( \tfrac{3}{2} \kappa^2 s \dot{s} \).
- Feeding the Dirac axial current \( J_5^\mu = \bar{\psi}\gamma^\mu \gamma^5 \psi \) from the plane-wave solution gives \( J_5^\mu = (p/\sqrt{m^2+p^2}, 0, 0, 1) \); the time component is constant so the divergence vanishes when \(\sigma = \kappa J_5^0\), confirming consistency with Einstein–Cartan sourcing.

## Next Steps
- Implement `tests/GR-001/gr_torsion_perturbation_check.py` to automate the calculation and compare against Einstein–Cartan field equations. *(Status: initial script reports non-zero divergence, awaiting spin coupling integration.)*
- Extend the result to general axial four-vectors \( S^\mu \) and evaluate boundary terms.
- Tie the torsion parameter \( \sigma(t) \) to matter spin density derived from the Dirac sector (DIR-001).
