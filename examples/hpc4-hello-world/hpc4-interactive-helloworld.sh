#!/bin/bash

## TODO: Update account name

# 1 Node of AMD CPU
echo srun --account=exampleproj \
     --partition=amd \
     --nodes=1 \
     --ntasks-per-node=1 \
     --cpus-per-task=256 \
     --time=4:0:0 \
     --pty bash

# 1 Node of Intel CPU
echo srun --account=exampleproj \
     --partition=intel \
     --nodes=1 \
     --ntasks-per-node=1 \
     --cpus-per-task=128 \
     --time=4:0:0 \
     --pty bash

# 1 GPU - Nvidia A30
echo srun --account=exampleproj \
     --partition=gpu-a30 \
     --nodes=1 \
     --gpus-per-node=1 \
     --ntasks-per-node=1 \
     --cpus-per-task=16 \
     --time=4:0:0 \
     --pty bash
