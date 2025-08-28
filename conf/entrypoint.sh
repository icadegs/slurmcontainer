#!/bin/sh
set -e

# --- Prepare persistent /slurm subdirs (host bind mount) ---
# Do NOT chown -R /slurm or /slurm/log; only create the dirs.
for d in /slurm/tmp /slurm/run /slurm/log /slurm/mysql; do
  mkdir -p "$d" || true
done

# --- Prepare MUNGE runtime dirs on container filesystem ---
# These are NOT on the bind mount; safe, stable perms.
install -d -m 700 -o munge -g munge /var/run/munge /var/lib/munge
install -d -m 700 -o munge -g munge /var/log/munge

# Key perms (works for baked-in or runtime-mounted key)
if [ -f /etc/munge/munge.key ]; then
  chown munge:munge /etc/munge/munge.key 2>/dev/null || true
  chmod 400 /etc/munge/munge.key 2>/dev/null || true
else
  echo "WARNING: /etc/munge/munge.key missing; Slurm auth will fail until it is provided."
fi

# --- Start MUNGE (prefer container-local file log, fallback to --syslog) ---
LOG_OPTS="--log-file=/var/log/munge/munged.log"
if ! /usr/sbin/munged --test -f 2>/dev/null; then
  # Quick sanity: if munged --test complains about logging, fallback to syslog
  LOG_OPTS="--syslog"
fi

# Start daemon (daemonizes by default)
if [ -f /etc/munge/munge.key ]; then
  /usr/sbin/munged --key-file=/etc/munge/munge.key $LOG_OPTS || true
  # Wait briefly for the socket to appear so Slurm starts reliably after
  i=0
  while [ $i -lt 25 ] && [ ! -S /var/run/munge/munge.socket.2 ]; do
    i=$((i+1))
    sleep 0.2
  done
fi

# --- Hand off to the main process (from CMD or docker run args) ---
exec "$@"
