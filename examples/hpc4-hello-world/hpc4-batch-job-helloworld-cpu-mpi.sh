#!/bin/bash

## TODO: Update account name
#SBATCH --account=exampleproj

#SBATCH --partition=amd
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=256
#SBATCH --cpus-per-task=1
#SBATCH --time=3-0:0:0
#SBATCH --output=slurm-%j.out

srun --cpu-bind=cores bash -c 'echo -e "Hello, World! from SLURM job $SLURM_JOB_ID rank $SLURM_PROCID\nrunning on node(s): $SLURM_NODELIST\nNumber of CPU cores: $(nproc)"'
