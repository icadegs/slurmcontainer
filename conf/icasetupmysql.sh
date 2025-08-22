#!/bin/sh
set -e

# Create required directories under /slurm
for d in /slurm/tmp /slurm/run /slurm/log /slurm/mysql; do
    mkdir -p "$d"
    chown -R mysql:mysql "$d"
done

# Hand over to whatever the container should run
exec "$@"
