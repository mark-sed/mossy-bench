"""
Trigonometric integral

Compute:
    ∫ sin(x) * cos(2x) * exp(-x^2) dx
using Simpson's rule.
"""

import math


def integrand(x):
    return math.sin(x) * math.cos(2.0 * x) * math.exp(-x * x)


def simpson(a, b, n):
    """
    Simpson's rule integration of integrand from a to b.
    n must be even.
    """
    if n % 2 != 0:
        raise ValueError("n must be even for Simpson's rule")

    h = (b - a) / n
    s = integrand(a) + integrand(b)

    # odd indices
    for i in range(1, n, 2):
        x = a + i * h
        s += 4.0 * integrand(x)

    # even indices
    for i in range(2, n, 2):
        x = a + i * h
        s += 2.0 * integrand(x)

    return s * (h / 3.0)


def result_summary(value, samples):
    """
    Produce a deterministic summary to avoid dead-code elimination
    """
    acc = 0.0
    v = value

    for i in range(samples):
        acc += math.sin(v + i * 0.0001) * math.cos(v - i * 0.0002)
        v = math.sqrt(abs(acc)) + 1e-12

    return acc, v


def main():
    A = 0.0
    B = 6.0
    N = 200_000  # must be even; increase for heavier workload

    integral = simpson(A, B, N)
    acc, final = result_summary(integral, 1000)

    print("Integral range:", A, "to", B)
    print("Simpson steps:", N)
    print("Integral value:", f"{integral:.10f}")
    print("Derived accumulator:", f"{acc:.10f}")
    print("Final derived value:", f"{final:.10f}")


if __name__ == "__main__":
    main()