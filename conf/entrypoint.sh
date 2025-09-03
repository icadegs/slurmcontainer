#!/bin/sh
set -e

# --- Prepare persistent /slurm subdirs (host bind mount) ---
# Do NOT chown -R /slurm or /slurm/log; only create the dirs.
for d in /slurm/tmp /slurm/run /slurm/log /slurm/mysql; do
  mkdir -p "$d" || true
done


### --- MUNGE bootstrap ---
id munge >/dev/null 2>&1 || useradd -r -s /usr/sbin/nologin munge

# PRNG + log dirs
install -d -m 0700 -o munge -g munge /var/lib/munge /var/log/munge
# Socket dir needs execute for all
install -d -o munge -g munge /run/munge
chmod 0755 /run/munge

# Seed + key
touch /run/munge/prng.seed && chown munge:munge /run/munge/prng.seed && chmod 600 /run/munge/prng.seed
[ -f /etc/munge/munge.key ] && chown munge:munge /etc/munge/munge.key && chmod 400 /etc/munge/munge.key

# Start munged
runuser -u munge -- /usr/sbin/munged \
  --key-file=/etc/munge/munge.key \
  --seed-file=/run/munge/prng.seed \
  --log-file=/var/log/munge/munged.log || true

# Wait for socket
i=0; while [ $i -lt 25 ] && [ ! -S /run/munge/munge.socket.2 ]; do i=$((i+1)); sleep 0.2; done

### --- Your other startup tasks below ---
exec "$@"

