#!/bin/sh
set -eu

# Create container-side MUNGE directories with strict perms
mkdir -p /etc/munge /var/run/munge /var/lib/munge /var/log/munge
chown -R munge:munge /etc/munge /var/run/munge /var/lib/munge /var/log/munge
chmod 700 /var/run/munge /var/lib/munge /var/log/munge

# Lock down key if it is present at build time (it might be mounted later instead)
if [ -f /etc/munge/munge.key ]; then
  chown munge:munge /etc/munge/munge.key
  chmod 400 /etc/munge/munge.key
else
  echo "Note: /etc/munge/munge.key not present at build time (will be mounted or copied at runtime)."
fi

echo "MUNGE build-time setup complete."
