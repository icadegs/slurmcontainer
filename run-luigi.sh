#!/bin/sh
docker run -it --rm \
  --name slurmcontroller \
  -v /volume2/slurm:/slurm \
  slurmcontroller
