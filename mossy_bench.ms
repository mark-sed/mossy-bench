#!/usr/bin/moss
d"""
Runs moss benchmark suite.
"""

import subprocess
import sys
import time

__VERSION = "0.1.0"

MOSS_PATH = "moss"
TIME_PATH = "/bin/time"
WORK_DIR = "./"
BENCH_DIR = WORK_DIR
VERBOSE = false

fun print_help() {
    f"""Moss benchmarking suite (version {::__VERSION})
Usage: moss mossy_bench.ms [-moss path_to_moss]
"""
}

fun parse_args(args) {
    i = 0
    while (i < args.length()) {
        a = args[i]
        switch (a) {
            case "-moss": {
                i += 1
                ::MOSS_PATH = args[i]
            }
            case "-time-path": {
                i += 1
                ::TIME_PATH = args[i]
            }
            case "-pwd", "-wd": {
                i += 1
                ::WORK_DIR = args[i]
            }
            case "bench-dir": {
                i+= 1
                ::BENCH_DIR = args[i]
            }
            case "-v", "--verbose": {
                ::VERBOSE = true
            }
            case "-h", "--help": {
                ~print_help()
                exit(256)
            }
            default: {
                ~print("Unknown argument: " ++ a)
                exit(1)
            }
        }
        i += 1
    }
}

fun debug(msg:String) {
    if (not ::VERBOSE)
        return
    ~print(msg)
}

fun time_benchmark(path:String, params:String="") {
    ~debug("Running benchmark")
    result = subprocess.run(f"bash {::WORK_DIR}/run_on_own_core.sh {::TIME_PATH} -f \"%e,%P\" {::MOSS_PATH} {::BENCH_DIR}/{path} {params}")
    ~debug("Run finished")
    return result.stderr
}

fun run_og() {
    time_benchmark("benchmarks/og/genetic/pso-100p-100i.ms")
    time_benchmark("benchmarks/og/io/mcat.ms", params=f"-n -E {::BENCH_DIR}/benchmarks/og/io/cities.txt {::BENCH_DIR}/benchmarks/og/io/lorem.txt")
    time_benchmark("benchmarks/og/loops/anti-primes-15.ms")
    time_benchmark("benchmarks/og/loops/collatz-100i.ms")
    time_benchmark("benchmarks/og/recursion/ackermann-3-7.ms")
    time_benchmark("benchmarks/og/recursion/fibonacci-30.ms")
}

fun run_all() {
    ~run_og()
}

@main
fun main() {
    ~parse_args(args)
    ~debug("Starting mossy bench.")
    ~run_all();
    ~debug("Mossy bench finished.")
}