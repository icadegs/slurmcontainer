#!/bin/bash
#echo "CPUs=$(nproc)"
#echo "RealMemory=$(($(free -m | awk 'NR==2{print $2}') - 1024))"

PARTITION_NAME="design"
MEMORY_BUFFER_MB=2048  # Memory to reserve for OS (in MB)
DEFAULT_PARTITION="YES"
MAX_TIME="INFINITE"

# Get system information
HOSTNAME=$(hostname -s)
TOTAL_CPUS=$(nproc)
TOTAL_MEMORY_MB=$(free -m | awk 'NR==2{print $2}')
SOCKETS=$(lscpu | grep "Socket(s):" | awk '{print $2}')
CORES_PER_SOCKET=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
THREADS_PER_CORE=$(lscpu | grep "Thread(s) per core:" | awk '{print $4}')

# Calculate usable memory (total - buffer)
REAL_MEMORY=$((TOTAL_MEMORY_MB - MEMORY_BUFFER_MB))

# Ensure we don't go negative on memory
if [ $REAL_MEMORY -lt 1024 ]; then
    echo "Warning: Very low memory after buffer. Using 1024 MB." >&2
    REAL_MEMORY=1024
fi

# Generate configuration lines
echo "# Configuration for $(hostname)"
echo "NodeName=$HOSTNAME CPUs=$TOTAL_CPUS RealMemory=$REAL_MEMORY Sockets=$SOCKETS CoresPerSocket=$CORES_PER_SOCKET ThreadsPerCore=$THREADS_PER_CORE State=UNKNOWN"
echo "PartitionName=$PARTITION_NAME Nodes=$HOSTNAME Default=$DEFAULT_PARTITION MaxTime=$MAX_TIME State=UP"
echo ""

# Optional: Show system info for verification
if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
    echo "# System Information:"
    echo "# Hostname: $HOSTNAME"
    echo "# Total CPUs (logical): $TOTAL_CPUS"
    echo "# Total Memory: ${TOTAL_MEMORY_MB} MB"
    echo "# Usable Memory: ${REAL_MEMORY} MB (after ${MEMORY_BUFFER_MB} MB buffer)"
    echo "# CPU Sockets: $SOCKETS"
    echo "# Cores per Socket: $CORES_PER_SOCKET"
    echo "# Threads per Core: $THREADS_PER_CORE"
    echo "# Physical Cores: $((SOCKETS * CORES_PER_SOCKET))"
    echo ""
fi
