#!/bin/sh
set -e

# Prep dirs & perms every boot
install -d -m 700 -o munge -g munge /var/run/munge /var/lib/munge
install -d -m 700 -o munge -g munge /slurm/log/munge
[ -f /etc/munge/munge.key ] && chown munge:munge /etc/munge/munge.key && chmod 400 /etc/munge/munge.key

# Start MUNGE
/usr/sbin/munged --key-file=/etc/munge/munge.key \
  --log-file=/slurm/log/munge/munged.log || true

# Wait briefly for socket
i=0; while [ $i -lt 25 ] && [ ! -S /var/run/munge/munge.socket.2 ]; do i=$((i+1)); sleep 0.2; done

exec "$@"
