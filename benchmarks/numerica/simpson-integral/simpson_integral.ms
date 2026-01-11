d"""
Trigonometric integral

Compute:
    ∫ sin(x) * cos(2x) * exp(-x^2) dx
using Simpson's rule.
"""

fun integrand(x) = Math.sin(x) * Math.cos(2.0 * x) * (Math.e ^ (-x * x))

fun simpson(a, b, n) {
    if (n % 2 != 0)
        raise ValueError("n must be even for Simpson's rule")

    h = (b - a) / n
    s = integrand(a) + integrand(b)

    for (i : 1,3..n) {
        x = a + i * h
        s += 4.0 * integrand(x)
    }

    for (i: 2,4..n) {
        x = a + i * h
        s += 2.0 * integrand(x)
    }

    return s * (h / 3.0)
}

fun result_summary(value, samples) {
    acc = 0.0
    v = value

    for (i : 0..samples) {
        acc += Math.sin(v + i * 0.0001) * Math.cos(v - i * 0.0002)
        v = Math.sqrt(Math.abs(acc)) + 1e-12
    }

    return [acc, v]
}

@main
fun main() {
    A = 0.0
    B = 6.0
    N = 200_000

    integral = simpson(A, B, N)
    acc, final = result_summary(integral, 1000)

    ~print("Integral range:", A, "to", B)
    ~print("Simpson steps:", N)
    ~print("Integral value:", f"{integral}")
    ~print("Derived accumulator:", f"{acc}")
    ~print("Final derived value:", f"{final}")
}