# Core Equations Reference

This guide consolidates the primary equations used in the Unified Framework notebooks and tests, together with short explanations and source pointers.

## Gravitation (Einstein Limit)

- \( S_{\text{grav}} = \dfrac{1}{16\pi G}\int d^4x\, e\, e_a{}^\mu e_b{}^\nu R_{\mu\nu}{}^{ab} \)  
  *Einstein–Hilbert action written in tetrad form.*  
  Source: `math/einstein_recovery.md`

- \( G_{\mu\nu} + \Lambda g_{\mu\nu} = 8\pi G\, T_{\mu\nu} \)  
  *Einstein field equations relating curvature to stress-energy.*  
  Source: `math/einstein_recovery.md`

- \( \nabla_\mu G^{\mu\nu} = 0 \)  
  *Contracted Bianchi identity guaranteeing stress-energy conservation.*  
  Source: `math/einstein_recovery.md`

## Electromagnetism (Maxwell Limit)

- \( S_{\text{em}} = -\tfrac{1}{4}\int d^4x\, F_{\mu\nu}F^{\mu\nu} + \int d^4x\, J^\mu A_\mu \)  
  *Electromagnetic action with external current.*  
  Source: `math/maxwell_recovery.md`

- \( \partial_\mu F^{\mu\nu} = J^\nu \)  
  *Sourced Maxwell equations obtained by varying the action.*  
  Source: `math/maxwell_recovery.md`

- \( \partial_{[\lambda}F_{\mu\nu]} = 0 \)  
  *Homogeneous Maxwell equations (Bianchi identity for the gauge field).*  
  Source: `math/maxwell_recovery.md`

## Fermions (Dirac Sector)

- \( S_\psi = \int d^4x\, e\, \bar{\psi}\big(i\gamma^a e_a{}^\mu D_\mu - m\big)\psi \)  
  *Dirac action on a curved background.*  
  Source: `math/dirac_recovery.md`

- \( D_\mu = \partial_\mu + \tfrac{1}{4}\omega_\mu{}^{ab}\gamma_{ab} - igA_\mu \)  
  *Covariant derivative including spin connection and minimal gauge coupling.*  
  Source: `math/dirac_recovery.md`

- \( J_5^\mu = \bar{\psi}\gamma^\mu\gamma^5\psi \)  
  *Axial (chiral) current used for torsion sourcing.*  
  Source: `math/dirac_recovery.md`

## Torsion & Einstein–Cartan

- \( T_{\lambda\mu\nu} = \epsilon_{\lambda\mu\nu\rho} S^\rho \)  
  *Totally antisymmetric torsion constructed from an axial vector \(S^\rho\).*  
  Source: `math/gr_torsion_perturbation.md`

- \( \nabla_\mu G^{\mu 0} = \tfrac{3}{2}\,\sigma\,\dot{\sigma} \)  
  *Divergence of the Einstein tensor in the presence of axial torsion.*  
  Source: `math/gr_torsion_perturbation.md`

- \( S_\mu = \frac{\kappa}{2} J_\mu^{(5)} \)  
  *Einstein–Cartan relation equating torsion to spin current.*  
  Source: `math/gr_torsion_perturbation.md`

- \( \sigma(t) = \frac{\kappa}{2} J_0^{(5)} \)  
  *Homogeneous solution for the temporal torsion component.*  
  Source: `math/einstein_cartan_axial.md`

- \( J_0^{(5)} = \frac{p}{\sqrt{m^2 + p^2}} \)  
  *Axial charge density for the plane-wave Dirac solution used in tests.*  
  Source: `math/einstein_cartan_axial.md`

---

For interactive verification of these formulas, run `python tests/run_all.py`; the command regenerates all artifacts and writes a timing summary to `tests/artifacts/test_run_summary.json`.
