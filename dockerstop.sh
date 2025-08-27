#!/bin/sh

CONTAINER="slurmcontroller"
TIMEOUT=30

# 1) Only act if the container is currently RUNNING
if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "Container '$CONTAINER' is not running. Nothing to stop."
  exit 0
fi

echo "Stopping $CONTAINER with timeout $TIMEOUT seconds..."
docker stop -t "$TIMEOUT" "$CONTAINER" &
STOP_PID=$!

# 2) Countdown that aborts once docker stop finishes
i=$TIMEOUT
while [ $i -gt 0 ]; do
  # If docker stop is done, break immediately
  if ! kill -0 "$STOP_PID" 2>/dev/null; then
    printf "\rStopped with %2d seconds left.           \n" "$i"
    break
  fi
  printf "\rShutting down... %2d seconds remaining" "$i"
  sleep 1
  i=$((i - 1))
done

# 3) Ensure docker stop really completed
wait "$STOP_PID" 2>/dev/null

echo "Checking status..."
if docker ps -a --format '{{.Names}} {{.Status}}' | grep -q "^$CONTAINER "; then
  docker ps -a --filter "name=^${CONTAINER}$"
else
  echo "$CONTAINER is gone."
fi
