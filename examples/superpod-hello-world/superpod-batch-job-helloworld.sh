#!/bin/bash

## TODO: Update account name
#SBATCH --account=exampleproj

#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=28
#SBATCH --time=3-0:0:0
#SBATCH --output=slurm-%j.out

echo "Hello, World! from SLURM job $SLURM_JOB_ID"
echo "Running on node(s): $SLURM_NODELIST"
echo "Number of CPU cores: $(nproc)"
echo "Allocated GPUs: $SLURM_GPUS_ON_NODE"
nvidia-smi
echo "Job completed successfully."
