#!/bin/bash

# [info] Preparing environment...
#        Currently Loaded Modulefiles:
#         1) slurm/slurm/23.02.6  
#        Working dir: /scratch/$USER/py-in-container/lit-gpt
#        Virtualenv: /scratch/$USER/py-in-container/lit-gpt/.venv

# [info] Current configuration:
#          DEBUG: 0
#          PYTHONFAULTHANDLER: 1
#          CUDA_LAUNCH_BLOCKING: 0
#          NCCL_DEBUG: WARN
#          NCCL_DEBUG_SUBSYS: INIT,NET
#          Nodes: 4
#          GPUs per node: 8

# [info] SLURM Parameters:
#          Container mounts:
#            /scratch/$USER/py-in-container/lit-gpt:/scratch/$USER/py-in-container/lit-gpt
#            /scratch/$USER/data:/scratch/$USER/py-in-container/lit-gpt/data
#            /scratch/$USER/out:/scratch/$USER/py-in-container/lit-gpt/out
#          Container params:
#            --container-image=/scratch/$USER/home/containers/pytorch-23.10.sqsh
#            --no-container-mount-home
#            --container-remap-root
#            --container-workdir=/scratch/$USER/py-in-container/lit-gpt
#          Job params:
#            --account=itscspod
#            --partition=admin
#            --output=/scratch/$USER/out/slurm/slurm-%j.out
#          Resource params:
#            --nodes=4
#            --gpus-per-node=8
#            --ntasks-per-node=8
#            --cpus-per-task=28

sbatch  --nodes=4 --gpus-per-node=8 --ntasks-per-node=8 --cpus-per-task=28 \
        --account=itscspod --partition=admin \
        --output=/scratch/$USER/out/slurm/slurm-%j.out \
        --container-image=/scratch/$USER/home/containers/pytorch-23.10.sqsh \
        --no-container-mount-home --container-remap-root \
        --container-workdir=/scratch/$USER/py-in-container/lit-gpt \
        --container-mounts=/scratch/$USER/py-in-container/lit-gpt:/scratch/$USER/py-in-container/lit-gpt,/scratch/$USER/data:/scratch/$USER/py-in-container/lit-gpt/data,/scratch/$USER/out:/scratch/$USER/py-in-container/lit-gpt/out \
        ./train-redpajama-prelaunch.sh
