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
    --pid-file="$RUNDIR/mysqld.pid"

