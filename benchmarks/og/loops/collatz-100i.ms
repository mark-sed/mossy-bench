fun collatz(n) {
    //d"""
    //Collatz conjecture test
    //@param n Value to test the collatz conjecture for
    //@return nil
    //@note Prints intermediate values to the stdout
    //"""
    while(n != 1) {
        if(n % 2 == 0) {
            n /= 2
        }
        else {
            n = 3*n + 1
        }
    }
}

for (i : 0..100) {
    ~collatz(27) // 111 iters
    ~collatz(6171) // 261 iters
    ~collatz(837799) // 525 iters
    ~collatz(77031) // 350 iters
}
"\n"
