"""Solve the Einstein–Cartan axial torsion equation for homogeneous spin density."""

import sympy as sp


def main():
    kappa = sp.symbols("kappa", positive=True)
    J0 = sp.symbols("J0", real=True)
    sigma = sp.symbols("sigma", real=True)

    equation = sp.Eq(sigma, (kappa / 2) * J0)
    solution = sp.solve(equation, sigma)[0]
    print(f"sigma_solution = {solution}")

    a = sp.Function("a")
    t = sp.symbols("t", real=True)
    divergence = sp.simplify(3 * sigma * sp.diff(sigma, t) / 2)
    divergence_frw = sp.simplify(
        3 * (a(t) * sp.diff(sigma, t) - 3 * sigma * sp.diff(a(t), t)) * sigma / (2 * a(t) ** 7)
    )
    print(f"divergence_minkowski = {divergence}")
    print(f"divergence_frw = {divergence_frw}")


if __name__ == "__main__":
    main()
