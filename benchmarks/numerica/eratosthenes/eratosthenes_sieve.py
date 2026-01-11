
def sieve(limit):
    """
    Returns a boolean array is_prime[0..limit]
    """
    is_prime = [True] * (limit + 1)
    is_prime[0] = False
    if limit >= 1:
        is_prime[1] = False

    p = 2
    while p * p <= limit:
        if is_prime[p]:
            step = p
            start = p * p
            for multiple in range(start, limit + 1, step):
                is_prime[multiple] = False
        p += 1

    return is_prime


def prime_summary(is_prime, bins=10):
    """
    Collect useful information without sorting:
    - prime count
    - top-K largest primes
    - checksum
    """
    limit = len(is_prime) - 1
    top = [0] * bins
    count = 0

    for i in range(2, limit + 1):
        if is_prime[i]:
            count += 1

            # find smallest in top[]
            min_i = 0
            min_val = top[0]
            for j in range(1, bins):
                if top[j] < min_val:
                    min_val = top[j]
                    min_i = j

            if i > min_val:
                top[min_i] = i

    return count, top


def main():
    LIMIT = 500_000  # increase for heavier workload

    is_prime = sieve(LIMIT)
    count, top = prime_summary(is_prime)

    print("Sieve limit:", LIMIT)
    print("Prime count:", count)
    print("Largest primes found:")
    for i, p in enumerate(top):
        print(f"  {i}: {p}")


if __name__ == "__main__":
    main()