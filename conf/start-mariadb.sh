#!/bin/bash
set -e

DATADIR=${MYSQL_DATADIR:-/slurm/mysql}
RUNDIR=${MYSQL_RUNDIR:-/slurm/run}

# Ensure runtime directory exists
mkdir -p "$RUNDIR"
chown -R mysql:mysql "$RUNDIR"

# Initialize database if needed
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB data directory at $DATADIR..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR"
fi

echo "Starting MariaDB..."
exec mysqld \
    --datadir="$DATADIR" \
    --socket="$RUNDIR/mysqld.sock" \
    --pid-file="$RUNDIR/mysqld.pid" \
    --user=mysql  &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to accept connections..."
until mysqladmin ping -h127.0.0.1 --silent; do
  sleep 1
done

# This solves the issue with the "first time run" of slurm.
# [2025-09-05T14:59:19.959] fatal: No Assoc usage file (/slurm/slurmica/slurmctld/assoc_usage) to recover
mkdir -p /slurm/slurmica/slurmctld
chown -R slurm:slurm /slurm/slurmica/slurmctld

# Start slurmdbd
echo "Starting slurmdbd..."
/sbin/slurmdbd -Dvvv &

# Optional: wait a few seconds before starting slurmctld
sleep 2

# Start slurmctld
echo "Starting slurmctld..."
/sbin/slurmctld -Dvvv &

# Keep container alive by waiting on the first background job
wait -n
