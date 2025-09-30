#!/bin/bash

set -o pipefail

export DEBUG=$(echo "${DEBUG,,}" | grep -q -e '^on\|y\(es\)\?\|t\(rue\)\?\|1$' && echo 1 || echo 0)
export SLURM_INTERACTIVE=$(test -n "$SLURM_PTY_PORT" && echo 1)

export PYTHONFAULTHANDLER=${PYTHONFAULTHANDLER:-1}
export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:0}
export NCCL_DEBUG=${NCCL_DEBUG:-WARN}
export NCCL_DEBUG_SUBSYS=${NCCL_DEBUG_SUBSYS:-INIT,NET}

[ $DEBUG -eq 1 ] && set -x
[ -z "$SLURM_INTERACTIVE" ] && set -eu

# Job GPT_TIMESTAMPING ===
[ -z "$SLURM_INTERACTIVE" ] && (
  bash -c "while sleep 120; do date --iso-8601=sec; done" &
  export GPT_TIMESTAMPING_PID=$!
)
# End ====================

date
module use /cm/local/modulefiles
module use /cm/shared/modulefiles
module purge
module load slurm/slurm

export MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | sort | head -n 1)
export MASTER_PORT=54321
export GPT_GLOBAL_SEED="$(python -c 'import numpy; print(numpy.random.randint(2**30-1))')"

if [ -z "$SLURM_INTERACTIVE" ]; then
  exec srun --mpi=none ./train-redpajama-launcher.sh
else
  unset SLURM_LOCALID SLURM_NODEID SLURM_PROCID SLURM_PTY_PORT SLURM_PTY_COL SLURM_PTY_ROW
  export SLURM_JOB_GPUS=$SLURM_STEP_GPUS
  export SLURM_DISTRIBUTION=block
  exec srun --overlap --nodes=1 --ntasks-per-node=8 --cpus-per-task=28 --gpus-per-node=8 --mpi=none ./train-redpajama-launcher.sh
fi

# Kill GPT_TIMESTAMPING
[ -z "$SLURM_INTERACTIVE" ] && kill $GPT_TIMESTAMPING_PID
