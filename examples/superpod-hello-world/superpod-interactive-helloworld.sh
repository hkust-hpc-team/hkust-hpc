#!/bin/bash

## TODO: Update account name
srun --account=itscspod \
     --partition=normal \
     --nodes=1 \
     --gpus-per-node=1 \
     --ntasks-per-node=1 \
     --cpus-per-task=28 \
     --time=4:0:0 \
     --pty bash
