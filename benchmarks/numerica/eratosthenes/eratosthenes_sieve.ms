fun sieve(limit) {
    is_prime = [true] * (limit + 1)
    is_prime[0] = false
    if (limit >= 1)
        is_prime[1] = false
    p = 2
    while (p * p <= limit) {
        if (is_prime[p]) {
            step = p
            start = p * p
            for (multiple : start, start+step..limit + 1) {
                is_prime[multiple] = false
            }
        }
        p += 1
    }

    return is_prime
}

fun prime_summary(is_prime, bins=10) {
    limit = is_prime.length() - 1
    top = [0] * bins
    count = 0

    for (i : 2..limit+1) {
        if (is_prime[i]) {
            count += 1

            min_i = 0
            min_val = top[0]
            for (j : 1..bins) {
                if (top[j] < min_val) {
                    min_val = top[j]
                    min_i = j
                }
            }

            if (i > min_val)
                top[min_i] = i
        }
    } 

    return [count, top]
}

@main
fun main() {
    LIMIT = 500_000

    is_prime = sieve(LIMIT)
    count, top = prime_summary(is_prime)
    
    ~print("Sieve limit:", LIMIT)
    ~print("Prime count:", count)
    ~print("Largest primes found:")
    for (i, p: Enumerate(top)) {
        ~print(f"  {i}: {p}")
    }
}