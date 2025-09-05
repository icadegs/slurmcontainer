#!/bin/sh
docker run --hostname=luigi -it --rm \
  --name slurmcontroller \
  -v /volume2/slurm:/slurm \
  slurmcontroller
