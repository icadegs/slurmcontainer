#!/bin/sh
set -e

# --- Prepare persistent /slurm mount paths at runtime (host bind) ---
for d in /slurm/log/munge /slurm/tmp /slurm/run /slurm/mysql; do
  mkdir -p "$d" || true
done

# Try to secure the munge log directory on the host mount
LOGDIR=/slurm/log/munge
chown -R munge:munge "$LOGDIR" 2>/dev/null || true
chmod 700 "$LOGDIR" 2>/dev/null || true

# Determine logging mode for munged: file if secure/writable, else syslog
LOG_OPTS=""
if [ -w "$LOGDIR" ] && [ "$(stat -c %U "$LOGDIR" 2>/dev/null || echo root)" = "munge" ]; then
  LOG_OPTS="--log-file=$LOGDIR/munged.log"
else
  echo "Warning: cannot secure $LOGDIR; using syslog for munged."
  LOG_OPTS="--syslog"
fi

# Ensure container runtime dirs are correct every boot
install -d -m 700 -o munge -g munge /var/run/munge /var/lib/munge
# Fix key perms if present (works for both baked-in and mounted keys)
if [ -f /etc/munge/munge.key ]; then
  chown munge:munge /etc/munge/munge.key 2>/dev/null || true
  chmod 400 /etc/munge/munge.key 2>/dev/null || true
fi

# Start MUNGE first (daemonizes by default)
if [ -f /etc/munge/munge.key ]; then
  /usr/sbin/munged --key-file=/etc/munge/munge.key $LOG_OPTS || true
  # wait briefly for socket
  i=0; while [ $i -lt 25 ] && [ ! -S /var/run/munge/munge.socket.2 ]; do i=$((i+1)); sleep 0.2; done
else
  echo "Warning: /etc/munge/munge.key not found; Slurm auth will fail until you provide it."
fi

# Hand off to the main process (from CMD or docker run args)
exec "$@"

