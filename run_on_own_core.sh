#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 command..."
    exit 1
fi

CMD="$*"

# --- Core Selection Logic ---
# Get the total number of processing units (cores/threads)
TOTAL_CORES=$(nproc)

# Check if the system has at least 4 cores (index 0, 1, 2, 3)
if [ "$TOTAL_CORES" -ge 4 ]; then
    # If 4 or more, pick the 4th core (index 3).
    # This avoids core 0 (often handling interrupts) and the last cores (potential E-cores).
    CPU=3
else
    # If less than 4, pick the 1st core (index 0).
    CPU=0
fi

exec sudo systemd-run \
    --quiet \
    --scope \
    -p AllowedCPUs=$CPU \
    -p CPUAccounting=yes \
    taskset -c $CPU bash -c "$CMD"