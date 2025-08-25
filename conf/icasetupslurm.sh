#!/bin/sh
set -e

# Create required directories under /slurm
for d in /slurm/slurm /slurm/slurmica; do
    mkdir -p "$d"
    chown -R slurm:slurm "$d"
done

# Hand over to whatever the container should run
exec "$@"
