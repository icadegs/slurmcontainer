#!/bin/sh

CONTAINER="slurmcontroller"
TIMEOUT=30

# Check if the container exists (running or stopped)
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}\$"; then
    echo "Container '$CONTAINER' does not exist. Nothing to stop."
    exit 0
fi

echo "Stopping $CONTAINER with timeout $TIMEOUT seconds..."
docker stop -t $TIMEOUT "$CONTAINER" &

# Countdown loop
for i in $(seq $TIMEOUT -1 1); do
    printf "\rShutting down... %2d seconds remaining" $i
    sleep 1
done

echo
echo "Shutdown command issued. Checking status..."

# Wait for docker stop to finish
wait

# Confirm container state
if docker ps -a --format '{{.Names}} {{.Status}}' | grep -q "^$CONTAINER "; then
    echo "$CONTAINER is still present:"
    docker ps -a --filter "name=$CONTAINER"
else
    echo "$CONTAINER has stopped and been removed."
fi
