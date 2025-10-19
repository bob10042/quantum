#!/usr/bin/env python3
"""
Donald Hoffman's conscious-agent mathematics translated into executable form.

This module provides three ingredients:
1. A faithful implementation of finite conscious agents as stochastic kernels
   acting on probability simplices (Hoffman and Prakash, 2014).
2. Exact calculations of Fisher-Rao, Fubini-Study, and commute-time metrics
   that Hoffman interprets as emergent geometric observables.
3. Simulation routines that generate sample trajectories and hitting times so
   the empirical behaviour of the model can be compared against Hoffman's
   published claims (for example, Minkowski-like structure from n-cycle agents).

Run this module directly to execute a demonstration with an n-cycle conscious
agent and to print key geometric diagnostics.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple

import numpy as np


def _validate_stochastic(matrix: np.ndarray, axis: int = 0, atol: float = 1e-9) -> None:
    """Ensure a matrix is stochastic (non-negative, columns or rows sum to one)."""
    if np.any(matrix < -atol):
        raise ValueError("Stochastic matrix contains negative entries.")
    sums = matrix.sum(axis=axis)
    if not np.allclose(sums, 1.0, atol=atol):
        raise ValueError(f"Matrix is not stochastic along axis {axis}.")


@dataclass
class ConsciousAgent:
    """Finite conscious agent in the Hoffman-Prakash formalism."""

    perception: np.ndarray  # columns indexed by actions
    decision: np.ndarray  # columns indexed by experiences

    def __post_init__(self) -> None:
        self.perception = np.asarray(self.perception, dtype=float)
        self.decision = np.asarray(self.decision, dtype=float)
        if self.perception.ndim != 2 or self.decision.ndim != 2:
            raise ValueError("Perception and decision matrices must be two-dimensional.")
        if self.perception.shape[1] != self.decision.shape[0]:
            raise ValueError(
                "Perception columns (actions) must match decision rows (actions)."
            )
        _validate_stochastic(self.decision, axis=0)
        _validate_stochastic(self.perception, axis=0)
        self.kernel = self.perception @ self.decision  # experience-to-experience map
        _validate_stochastic(self.kernel, axis=0)
        self.n_experiences = self.kernel.shape[0]

    # ------------------------------------------------------------------
    # Probabilistic dynamics
    # ------------------------------------------------------------------
    def propagate(self, initial: np.ndarray, steps: int) -> np.ndarray:
        """Propagate an experience distribution forward for `steps` iterations."""
        state = np.asarray(initial, dtype=float)
        if state.ndim != 1 or state.size != self.n_experiences:
            raise ValueError("Initial state must be a one-dimensional probability vector.")
        if not np.allclose(state.sum(), 1.0):
            raise ValueError("Initial state must sum to one.")
        history = np.empty((steps + 1, self.n_experiences), dtype=float)
        history[0] = state
        current = state
        for t in range(1, steps + 1):
            current = self.kernel @ current
            history[t] = current
        return history

    def stationary_distribution(self, atol: float = 1e-10) -> np.ndarray:
        """Return the stationary distribution pi satisfying K pi = pi."""
        vals, vecs = np.linalg.eig(self.kernel)
        idx = np.argmin(np.abs(vals - 1.0))
        stationary = np.real(vecs[:, idx])
        stationary = stationary / stationary.sum()
        if np.any(stationary < -atol):
            stationary = np.maximum(stationary, 0.0)
            stationary = stationary / stationary.sum()
        return stationary

    # ------------------------------------------------------------------
    # Geometric observables
    # ------------------------------------------------------------------
    @staticmethod
    def fisher_rao_distance(p: np.ndarray, q: np.ndarray) -> float:
        """Fisher-Rao (Bhattacharyya) angle between two experience distributions."""
        p = np.asarray(p, dtype=float)
        q = np.asarray(q, dtype=float)
        inner = np.clip(np.sum(np.sqrt(p * q)), -1.0, 1.0)
        return float(np.arccos(inner))

    @staticmethod
    def fubini_study_distance(
        amplitudes_p: np.ndarray, amplitudes_q: np.ndarray
    ) -> float:
        """Fubini-Study distance between two amplitude vectors on complex projective space."""
        amplitudes_p = np.asarray(amplitudes_p, dtype=complex)
        amplitudes_q = np.asarray(amplitudes_q, dtype=complex)
        numerator = np.abs(np.vdot(amplitudes_p, amplitudes_q))
        norms = np.linalg.norm(amplitudes_p) * np.linalg.norm(amplitudes_q)
        if norms == 0:
            raise ValueError("Amplitude vectors must be non-zero.")
        inner = np.clip(numerator / norms, -1.0, 1.0)
        return float(np.arccos(inner))

    def commute_time_matrix(self) -> np.ndarray:
        """Return the square root of commute times between experience states."""
        P = self.kernel.T  # row-stochastic representation
        stationary = self.stationary_distribution()
        ones = np.ones((self.n_experiences, 1))
        fundamental = np.linalg.inv(
            np.eye(self.n_experiences) - P + ones @ stationary[np.newaxis, :]
        )
        mean_first_passage = np.zeros(
            (self.n_experiences, self.n_experiences), dtype=float
        )
        for i in range(self.n_experiences):
            for j in range(self.n_experiences):
                if i == j:
                    continue
                mean_first_passage[i, j] = (
                    fundamental[j, j] - fundamental[i, j]
                ) / stationary[j]
        commute = mean_first_passage + mean_first_passage.T
        commute = np.maximum(commute, 0.0)
        return np.sqrt(commute)

    def expected_hitting_time(self, start: int, target: int) -> float:
        """Compute E[T_target | start] using the fundamental matrix."""
        if start == target:
            return 0.0
        P = self.kernel.T
        stationary = self.stationary_distribution()
        ones = np.ones((self.n_experiences, 1))
        fundamental = np.linalg.inv(
            np.eye(self.n_experiences) - P + ones @ stationary[np.newaxis, :]
        )
        value = (
            fundamental[target, target] - fundamental[start, target]
        ) / stationary[target]
        return float(value)

    # ------------------------------------------------------------------
    # Monte Carlo experiments
    # ------------------------------------------------------------------
    def simulate_hitting_times(
        self,
        start: int,
        target: int,
        trials: int = 1000,
        max_steps: int = 100000,
        seed: Optional[int] = None,
    ) -> np.ndarray:
        """Monte Carlo estimate for first hitting times."""
        rng = np.random.default_rng(seed)
        times = np.empty(trials, dtype=float)
        for k in range(trials):
            state = start
            t = 0
            while state != target and t < max_steps:
                probs = self.kernel[:, state]
                state = int(rng.choice(self.n_experiences, p=probs))
                t += 1
            if state != target:
                times[k] = np.nan
            else:
                times[k] = t
        return times


def n_cycle_agent(
    n: int,
    forward: float,
    backward: float,
    stay: Optional[float] = None,
) -> ConsciousAgent:
    """
    Construct an n-cycle agent with biased transitions.

    Experiences and actions are both labelled 0, ..., n-1. At each step the
    agent moves forward with probability `forward`, backward with probability
    `backward`, and stays in place with probability `stay` (defaults to
    1 - forward - backward). These probabilities must be non-negative and sum
    to one.
    """
    if stay is None:
        stay = 1.0 - forward - backward
    if not np.isclose(forward + backward + stay, 1.0):
        raise ValueError("Probabilities must add to one.")
    if min(forward, backward, stay) < 0:
        raise ValueError("Probabilities must be non-negative.")
    kernel = np.zeros((n, n), dtype=float)
    for j in range(n):
        kernel[(j + 1) % n, j] += forward
        kernel[(j - 1) % n, j] += backward
        kernel[j, j] += stay
    perception = kernel  # choose perception = kernel, decision = identity
    decision = np.eye(n)
    agent = ConsciousAgent(perception=perception, decision=decision)
    agent.metadata = {"forward": forward, "backward": backward, "stay": stay}
    return agent


def lorentz_factor_from_hitting_times(
    agent: ConsciousAgent, distance: int
) -> Tuple[float, float, float]:
    """
    Compare biased and symmetric hitting times over a fixed graph distance.

    Returns:
        v: effective dimensionless velocity (forward minus backward probability)
        gamma_empirical: ratio of biased to symmetric hitting time
        gamma_relativistic: special-relativistic prediction 1/sqrt(1 - v^2)
    """
    meta = getattr(agent, "metadata", None)
    if meta is None:
        raise ValueError("Agent metadata missing.")
    forward = meta["forward"]
    backward = meta["backward"]
    stay = meta["stay"]
    v = forward - backward
    n = agent.n_experiences
    reference = n_cycle_agent(
        n,
        forward=(1.0 - stay) / 2.0,
        backward=(1.0 - stay) / 2.0,
        stay=stay,
    )
    start, target = 0, distance % n
    ht_ref = reference.expected_hitting_time(start, target)
    ht_bias = agent.expected_hitting_time(start, target)
    gamma_empirical = ht_bias / ht_ref
    gamma_relativistic = 1.0 / np.sqrt(max(1e-12, 1.0 - v**2))
    return v, gamma_empirical, gamma_relativistic


def demo_cycle_agent() -> None:
    """Run a demonstration showcasing geometric observables and simulations."""
    n = 6
    forward = 0.58
    backward = 0.32
    stay = 0.10
    agent = n_cycle_agent(n, forward, backward, stay)
    print("=== n-cycle conscious agent demonstrator ===")
    print(
        f"States: {n}, forward={forward:.2f}, backward={backward:.2f}, stay={stay:.2f}"
    )
    print("Transition kernel K:")
    np.set_printoptions(precision=3, suppress=True)
    print(agent.kernel)

    pi = agent.stationary_distribution()
    print("\nStationary distribution pi:")
    print(pi)

    commute = agent.commute_time_matrix()
    print("\nCommute-time distance matrix sqrt(kappa_ij):")
    print(commute)

    start, target = 0, 3
    analytic_ht = agent.expected_hitting_time(start, target)
    samples = agent.simulate_hitting_times(start, target, trials=5000, seed=1234)
    empirical_ht = np.nanmean(samples)
    std_ht = np.nanstd(samples)
    print(f"\nHitting time E[T_{target} | {start}] analytic: {analytic_ht:.2f}")
    print(f"Hitting time Monte Carlo mean: {empirical_ht:.2f} (std {std_ht:.2f})")

    history = agent.propagate(initial=np.eye(n)[0], steps=25)
    fisher_distances = [
        ConsciousAgent.fisher_rao_distance(history[0], history[t]) for t in range(1, 6)
    ]
    print("\nFisher-Rao distance from initial state over first five steps:")
    for t, dist in enumerate(fisher_distances, start=1):
        print(f"  t={t}: {dist:.4f} rad")

    v, gamma_emp, gamma_rel = lorentz_factor_from_hitting_times(agent, distance=3)
    print(
        f"\nEffective velocity v={v:.3f}. "
        f"Empirical gamma={gamma_emp:.3f}, relativistic gamma={gamma_rel:.3f}"
    )


if __name__ == "__main__":
    demo_cycle_agent()
