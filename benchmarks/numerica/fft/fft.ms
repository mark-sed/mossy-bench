fun fft(x) {
    n = length(x)
    if (n == 1)
        return x
    if ((n and (n - 1)) != 0)
        raise ValueError("Input length must be a power of 2")
    
    even = fft(x[(0,2..length(x))])
    odd = fft(x[(1,3..length(x))])

    result = [0] * n
    for (k : 0..n/2) {
        angle = -2.0 * Math.pi * k / n
        w = Complex(Math.cos(angle), Math.sin(angle))
        t = w * odd[k]
        result[k] = even[k] + t
        result[k + n / 2] = even[k] - t 
    }

    return result
}

fun generate_signal(n) {
    d"""
    Deterministic multi-frequency signal
    """
    signal = []
    for (i : 0..n) {
        v = (
            Math.sin(2.0 * Math.pi * i / n) +
            0.5 * Math.sin(4.0 * Math.pi * i / n) +
            0.25 * Math.cos(6.0 * Math.pi * i / n) +
            0.125 * Math.sin(8.0 * Math.pi * i / n)
        )
        ~signal.append(Complex(v, 0.0))
    }
    return signal
}

fun complex_abs(z) {
    return Math.sqrt(z.real * z.real + z.imag * z.imag)
}

fun spectrum_summary(freqs, bins=10) {
    d"""
    Compute top-K magnitudes without sorting the full array.
    Also computes a checksum to force full traversal.
    """
    top = [0.0] * bins
    checksum = 0.0

    for (f: freqs) {
        m = complex_abs(f)
        checksum += Math.sqrt(m)

        min_idx = 0
        min_val = top[0]
        for (i : 1..bins) {
            if (top[i] < min_val) {
                min_val = top[i]
                min_idx = i
            }
        }

        if (m > min_val)
            top[min_idx] = m
    }

    return [top, checksum]
}

@main
fun main() {
    N = 4096

    signal = generate_signal(N)
    freqs = fft(signal)

    top_bins, checksum = spectrum_summary(freqs)

    ~print("FFT size:", N)
    ~print("Top frequency magnitudes:")
    for (i, v: Enumerate(top_bins))
        ~print(f"  {i}: {v}")
    
    ~print(f"Spectrum checksum: {checksum}")
}