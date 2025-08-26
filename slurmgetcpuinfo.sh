#!/bin/sh
echo "CPUs=$(nproc)"
echo "RealMemory=$(($(free -m | awk 'NR==2{print $2}') - 1024))"

