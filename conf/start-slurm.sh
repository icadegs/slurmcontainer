#!/bin/bash
set -e

# Start slurmdbd
echo "Starting slurmdbd..."
/sbin/slurmdbd -Dvvv &

# Wait for it to start
sleep 2

# Start slurmctld
echo "Starting slurmctld..."
/sbin/slurmctld -Dvvv &

echo "All Slurm services started."
