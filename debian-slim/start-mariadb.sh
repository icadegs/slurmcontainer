#!/bin/bash
set -e

# Optional: allow override of datadir
DATADIR=${MYSQL_DATADIR:-/slurm/mysql}

# Initialize if needed
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB data directory at $DATADIR..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir="$DATADIR"
fi

echo "Starting MariaDB with datadir=$DATADIR..."
exec mysqld --datadir="$DATADIR"


