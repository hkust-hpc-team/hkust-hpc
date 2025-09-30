#!/bin/bash

set -o pipefail

[ $DEBUG -eq 1 ] && set -x
[ -z "$SLURM_INTERACTIVE" ] && set -eu

module use /cm/local/modulefiles
module use /cm/shared/modulefiles
module purge
[ -z "$SLURM_INTERACTIVE" ] && module load slurm/slurm

. .venv/bin/activate
export GPT_WORLD_SIZE=$SLURM_STEP_NUM_TASKS
export GPT_NUM_NODES=$SLURM_STEP_NUM_NODES
export GPT_LOCAL_RANK=$SLURM_LOCALID
export GPT_NODE_RANK=$SLURM_NODEID
export GPT_GLOBAL_RANK=$(($SLURM_NODEID * $SLURM_NTASKS_PER_NODE + $SLURM_LOCALID))
export GPT_DEVICES_PER_NODE=${SLURM_GPUS_PER_TASK:-$SLURM_GPUS_PER_NODE}
export GPT_SLURM_INTERACTIVE=$([ -n "$SLURM_INTERACTIVE" ] && echo "--launch-interactive" || echo "")
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
echo "Launching [$GPT_GLOBAL_RANK/$GPT_WORLD_SIZE]: $SLURM_JOB_ID $SLURM_JOB_NODELIST:$GPT_NODE_RANK/$GPT_NUM_NODES;g=$GPT_DEVICES_PER_NODE $MASTER_ADDR $MASTER_PORT"

# Job NVIDIA_SMI_DMON ===
if [ -z "$SLURM_INTERACTIVE" ] && [ $SLURM_LOCALID -eq 0 ]; then
  nvidia-smi | grep "NVIDIA H800"
  nvidia-smi dmon --delay 15 --select pumt --options DT --filename $PWD/out/slurm/slurm-$SLURM_JOB_ID.$(hostname).gutil &
  export GPT_NVIDIA_SMI_DMON_PID=$!
fi
# End ====================


set -x
python3 pretrain/redpajama.py --name test --model_name tiny-llama-1.1b --reverse_tokens false \
  --max_steps 131072 --decay_steps 131072 --lr 5e-3 --micro_batch_size 10 --batch_size 2048 \
  --precision bf16-true --seed "$GPT_GLOBAL_SEED" --parallel_strategy "ddp" $GPT_SLURM_INTERACTIVE \
  --world_size "$GPT_WORLD_SIZE" --num_nodes "$GPT_NUM_NODES" --devices_per_node "$GPT_DEVICES_PER_NODE" \
  --global_rank "$GPT_GLOBAL_RANK" --node_rank "$GPT_NODE_RANK" --local_rank "$GPT_LOCAL_RANK" \
  --train_data_dir $(realpath ./data/redpajama-1t-llama/) --save_root $(realpath ./out) --resume true
set +x

# Kill NVIDIA_SMI_DMON
[ -z "$SLURM_INTERACTIVE" ] && [ $SLURM_LOCALID -eq 0 ] && kill $GPT_NVIDIA_SMI_DMON_PID
