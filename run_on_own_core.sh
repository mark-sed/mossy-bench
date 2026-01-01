#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 command..."
    exit 1
fi

CMD="$*"

# Pick last CPU
CPU=$(nproc)
CPU=$((CPU - 1))

exec sudo systemd-run \
    --quiet \
    --scope \
    -p AllowedCPUs=$CPU \
    -p CPUAccounting=yes \
    taskset -c $CPU bash -c "$CMD"