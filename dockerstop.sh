#!/bin/sh

CONTAINER="slurmcontroller"
TIMEOUT=30

echo "Stopping $CONTAINER with timeout $TIMEOUT seconds..."
docker stop -t $TIMEOUT "$CONTAINER" &

# Simple countdown loop
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