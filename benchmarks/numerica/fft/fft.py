
import math


def fft(x):
    n = len(x)
    if n == 1:
        return x

    if n & (n - 1) != 0:
        raise ValueError("Input length must be a power of 2")

    even = fft(x[0::2])
    odd = fft(x[1::2])

    result = [0] * n
    for k in range(n // 2):
        angle = -2.0 * math.pi * k / n
        w = complex(math.cos(angle), math.sin(angle))
        t = w * odd[k]
        result[k] = even[k] + t
        result[k + n // 2] = even[k] - t

    return result


def generate_signal(n):
    """
    Deterministic multi-frequency signal
    """
    signal = []
    for i in range(n):
        v = (
            math.sin(2.0 * math.pi * i / n) +
            0.5 * math.sin(4.0 * math.pi * i / n) +
            0.25 * math.cos(6.0 * math.pi * i / n) +
            0.125 * math.sin(8.0 * math.pi * i / n)
        )
        signal.append(complex(v, 0.0))
    return signal


def spectrum_summary(freqs, bins=10):
    """
    Compute top-K magnitudes without sorting the full array.
    Also computes a checksum to force full traversal.
    """
    top = [0.0] * bins
    checksum = 0.0

    for f in freqs:
        m = abs(f)
        checksum += math.sqrt(m)

        # Find index of smallest value in top[]
        min_idx = 0
        min_val = top[0]
        for i in range(1, bins):
            if top[i] < min_val:
                min_val = top[i]
                min_idx = i

        # Replace if current magnitude is larger
        if m > min_val:
            top[min_idx] = m

    return top, checksum


def main():
    N = 4096  # power of two, increase for heavier workload

    signal = generate_signal(N)
    freqs = fft(signal)

    top_bins, checksum = spectrum_summary(freqs)

    print("FFT size:", N)
    print("Top frequency magnitudes:")
    for i, v in enumerate(top_bins):
        print(f"  {i}: {v:.6f}")

    print("Spectrum checksum:", f"{checksum:.6f}")


if __name__ == "__main__":
    main()