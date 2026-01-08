#!/usr/bin/moss
d"""
Runs moss benchmark suite.
"""

import subprocess
import sys
import time
import re
import csv_parser as csv

__VERSION = "0.1.0"

MOSS_PATH = "moss"
TIME_PATH = "/bin/time"
WORK_DIR = "./"
BENCH_DIR = WORK_DIR
OUT_PATH = "./"
VERBOSE = false
PLATFORM_INFO = {:}

PLATFORM = sys.platform()
if (PLATFORM == sys.Platform.Linux) {
    C_OFF="\q033[0m"
    C_RED="\q033[0;31m"
    C_GREEN="\q033[0;32m"
    C_GRAY="\q033[1;30m"
    C_PURPLE="\q033[0;35m"
    C_BLUE="\q033[0;34m"
} else {
    C_OFF=""
    C_RED=""
    C_GREEN=""
    C_GRAY=""
}

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
            case "-o": {
                i += 1
                ::OUT_PATH = args[i]
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

fun running(name:String) {
    ~print(f"[ RUN] {name}")
}

fun finished(name:String, result:Dict) {
    ~print(f"""[{C_GREEN}DONE{C_OFF}] {name}: {result["time_s"]} s""")
}

fun running_suite(name:String) {
    ~print(f"""[ RUN] Benchmark suite {C_PURPLE}{name}{C_OFF}...""")
}

fun get_platform_info() {
    result = subprocess.run(f"bash {::WORK_DIR}/get_platform_info.sh")
    if (result.return_code != 0) {
        ~print(f"ERROR: Extraction of platform information has failed: '{results.stderr}'.")
        ~exit(1)
    }
    res_dict = csv.dict_reader(result.stdout)
    res_dict = res_dict[0]
    res_dict["timestamp"] = time.time()
    // TODO: Get moss (--moss) version and output warning when DEBUG
    return res_dict
}

fun time_benchmark(path:String, name:String, params:String="", moss_args:String="") {
    ~running(name)
    ~debug("Running benchmark")
    result = subprocess.run(f"bash {::WORK_DIR}/run_on_own_core.sh {::TIME_PATH} -f \"%e,%P,%MKB\" {::MOSS_PATH} {moss_args} {::BENCH_DIR}/{path} {params}")
    ~debug("Run finished")
    if (result.return_code != 0) {
        ~print(f"ERROR: Benchmark '{path}' has failed with: '{result.stderr}'.")
        ~exit(1)
    }
    measurements = result.stderr
    regex = re.compile(r"(.*),(.*)%,(.*)KB\n")
    match = regex.match(measurements)
    if (match == nil || match.groups.length() != 4) {
        ~print(f"ERROR: Benchmark output is incorrect and measurements cannot be extracted. Got: '{measurements}'.")
        ~exit(1)
    }
    m_time = Float(match[1])
    m_cpu = Float(match[2])
    m_max_mem = Int(match[3])
    result_dict = {"name": name, "params": params, "time_s": m_time, "cpu": m_cpu, "moss_version": sys.version,
                   "memory_max_kb": m_max_mem}
    for (k, v: ::PLATFORM_INFO) {
        result_dict[k] = v
    }
    ~finished(name, result_dict)
    return result_dict
}

fun run_og() {
    ~running_suite("OG")
    return [
        time_benchmark("benchmarks/og/genetic/pso-100p-100i.ms", "pso-100p-100i"),
        time_benchmark("benchmarks/og/io/mcat.ms", "mcat", params=f"-n -E {::BENCH_DIR}/benchmarks/og/io/cities.txt {::BENCH_DIR}/benchmarks/og/io/lorem.txt"),
        time_benchmark("benchmarks/og/loops/anti-primes-15.ms", "anti-primes-15"),
        time_benchmark("benchmarks/og/loops/collatz-100i.ms", "collatz-100i"),
        time_benchmark("benchmarks/og/recursion/ackermann-3-7.ms", "ackermann-3-7"),
        time_benchmark("benchmarks/og/recursion/fibonacci-30.ms", "fibonacci-30"),
    ]
}

fun run_parsing() {
    ~running_suite("Parsing")
    return [
        time_benchmark("benchmarks/parsing/md/output_md.ms", "md-to-html-syntax", params=f"{::BENCH_DIR}/benchmarks/parsing/md/syntax.md", moss_args="-f html"),
        time_benchmark("benchmarks/parsing/md/output_txt.ms", "md-to-txt-syntax", params=f"{::BENCH_DIR}/benchmarks/parsing/md/syntax.md"),

        time_benchmark("benchmarks/parsing/csv/to_dict.ms", "csv-parsing-3000", params=f"{::BENCH_DIR}/benchmarks/parsing/csv/f1_results.csv"),
        time_benchmark("benchmarks/parsing/csv/to_dict.ms", "csv-parsing-3000-nn", params=f"{::BENCH_DIR}/benchmarks/parsing/csv/f1_results.csv nn"),
    ]
}

fun run_all() {
    results = []
    results += run_og()
    results += run_parsing()
    return results
}

@main
fun main() {
    ~parse_args(args)
    ~debug("Starting mossy bench.")

    // Init general info variable from "get_platform_info.sh"
    ~debug("Getting platform info.")
    ::PLATFORM_INFO = get_platform_info()
    ~debug("Got platform info: "++::PLATFORM_INFO)

    f_name = f"""{::OUT_PATH}/results-{time.strftime("%Y_%m_%d_%H_%M")}.csv"""
    // Prettify path
    f_name = f_name.replace("//", "/")
    res_file = open(f"{f_name}", "w")
    // Measure time
    start_time = time.time()
    
    results = run_all();
    
    end_time = time.time()
    elapsed_time = Int((end_time - start_time)/60.0)
    
    writer = csv.CSVWriter(res_file)
    // Header
    keys = results[0].keys()
    ~writer.write_row(keys)
    // To ensure correct order in lists extract values
    res_list = [[v[k] : k = keys] : v = results]
    ~writer.write_rows(res_list)
    ~res_file.close()
    ~print(f"Results stored to file: {C_BLUE}{f_name}{C_OFF}.")
    ~print(f"[{C_GREEN}SUCCESS{C_OFF}] Benchmarks finished in {elapsed_time} minutes.")

    ~debug("Mossy bench finished.")
}

// TODO: Run all benchmarks also compiled and store that into results (or leave empty if not run)