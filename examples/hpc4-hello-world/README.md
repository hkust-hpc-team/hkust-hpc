# Submit Your First SLURM Job

This example demonstrates how to submit your first job to the SLURM workload manager on the HPC cluster. It includes two approaches: submitting a batch job and starting an interactive session.

## Prerequisites

Before running these examples, make sure you:
1. Have access to the HPC cluster
2. Know your SLURM account name (replace `exampleproj` in the scripts)
3. Are familiar with basic Linux commands

## Files in This Example

- `hpc4-interactive-helloworld.sh` - Start an interactive session (contains examples for CPU and GPU nodes)
- `hpc4-batch-job-helloworld-cpu.sh` - Submit a CPU-only batch job
- `hpc4-batch-job-helloworld-cpu-mpi.sh` - Submit a multi-process CPU batch job (MPI example)
- `hpc4-batch-job-helloworld-gpu.sh` - Submit a GPU batch job

## Option 1: Interactive Session (Recommended for Getting Started)

### What is an Interactive Session?

An interactive session gives you a live shell on a compute node with allocated resources. This is the best way to get started with the cluster, as it allows you to explore, test commands, and understand the environment before running automated batch jobs.

### How to Use

1. **Edit the script** to update your account name and choose your resource type:
   ```bash
   nano hpc4-interactive-helloworld.sh
   ```
   Change `--account=exampleproj` to your actual account name.
   
   The script contains three example commands (uncomment the one you want to use):
   - **AMD CPU** (256 cores): Uses `--partition=amd`
   - **Intel CPU** (128 cores): Uses `--partition=intel`
   - **GPU (Nvidia A30)**: Uses `--partition=gpu-a30`

2. **Start an interactive session** by uncommenting one line in the script and running:
   ```bash
   bash hpc4-interactive-helloworld.sh
   ```
   
   Or directly run one of these commands:
   
   **For AMD CPU:**
   ```bash
   srun --account=<your_account> \
        --partition=amd \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=256 \
        --time=4:0:0 \
        --pty bash
   ```
   
   **For GPU:**
   ```bash
   srun --account=<your_account> \
        --partition=gpu-a30 \
        --nodes=1 \
        --gpus-per-node=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=16 \
        --time=4:0:0 \
        --pty bash
   ```

3. **You'll get a shell prompt on the compute node** where you can run commands interactively:
   ```bash
   echo "Hello from $(hostname)"
   nvidia-smi
   # Run any other commands you need
   ```

    Note that billing **starts from the moment the interactive session is allocated, until you exit the session** with the `exit` command below.

4. **Exit the session** when done:
   ```bash
   exit
   ```

## Option 2: Batch Job (Recommended for Production)

### What is a Batch Job?

A batch job is submitted to the queue and runs without user interaction. Once you're comfortable with the cluster environment, batch jobs are the recommended way to run production workloads, as they allow the scheduler to optimize resource allocation and you don't need to keep your terminal open.

### How to Use

1. **Choose and edit the appropriate script** based on your needs:
   - `hpc4-batch-job-helloworld-cpu.sh` - For CPU-only jobs
   - `hpc4-batch-job-helloworld-cpu-mpi.sh` - For multi-process CPU jobs
   - `hpc4-batch-job-helloworld-gpu.sh` - For GPU jobs
   
   ```bash
   nano hpc4-batch-job-helloworld-cpu.sh
   ```
   Change `--account=exampleproj` to your actual account name.

2. **Submit the job** to SLURM:
   ```bash
   sbatch hpc4-batch-job-helloworld-cpu.sh
   ```
   (or use the GPU/MPI variant as needed)

3. **Check job status**:
   ```bash
   squeue -u $USER
   ```

4. **View the output** once the job completes:
   ```bash
   cat slurm-<job_id>.out
   ```
   Replace `<job_id>` with the actual job ID returned when you submitted the job.

### What the Scripts Do

**CPU Script** (`hpc4-batch-job-helloworld-cpu.sh`):
- Requests 1 AMD node with 256 CPU cores
- Prints "Hello, World!" with job information
- Shows which node(s) are allocated
- Displays CPU core count
- Writes all output to `slurm-<job_id>.out`

**CPU MPI Script** (`hpc4-batch-job-helloworld-cpu-mpi.sh`):
- Requests 1 AMD node with 256 MPI tasks
- Runs a parallel "Hello, World!" from each rank/process
- Demonstrates multi-process execution using `srun`
- Writes all output to `slurm-<job_id>.out`

**GPU Script** (`hpc4-batch-job-helloworld-gpu.sh`):
- Requests 1 GPU node (Nvidia A30) with 16 CPU cores
- Prints "Hello, World!" with job information
- Shows GPU information using `nvidia-smi`
- Writes all output to `slurm-<job_id>.out`

## Resource Allocation Explained

All scripts request the following common resources:
- `--account`: Your billing account
- `--partition`: The job queue/partition to use (specific to resource type)
- `--nodes=1`: Number of compute nodes
- `--time`: Maximum runtime before the job is automatically terminated
  - Interactive session: `4:0:0` (4 hours) - suitable for exploration and testing
  - Batch job: `3-0:0:0` (3 days) - allows longer production runs

### HPC4 Partitions and Resources

**CPU Partitions:**
- `amd`: AMD EPYC processors with 256 cores per node
- `intel`: Intel processors with 128 cores per node

**GPU Partition:**
- `gpu-a30`: Nvidia A30 GPUs with 16 CPU cores per GPU
- `gpu-l20`: Nvidia L40 GPUs with 16 CPU cores per GPU

### Resource Parameters

**For CPU jobs:**
- `--ntasks-per-node=1`: One task per node (single-process)
- `--cpus-per-task=256`: All 256 CPU cores for AMD (or 128 for Intel)

**For CPU MPI jobs:**
- `--ntasks-per-node=256`: 256 MPI tasks per node (multi-process)
- `--cpus-per-task=1`: One CPU core per task

**For GPU jobs:**
- `--gpus-per-node=1`: One GPU per node
- `--ntasks-per-node=1`: One task per node
- `--cpus-per-task=16`: 16 CPU cores per task

You can adjust these parameters based on your needs and available resources. The time format is `D-HH:MM:SS` (days-hours:minutes:seconds) or `HH:MM:SS` for durations less than a day.

## Common SLURM Commands

- `sbatch <script>` - Submit a batch job
- `squeue -u $USER` - Check your job status
- `scancel <job_id>` - Cancel a job

## Next Steps

After successfully running this hello world example, you can:
1. **Follow our workshops** for more in-depth tutorials and real-world examples: https://github.com/hkust-hpc-team/hkust-hpc/tree/main/workshops
2. Modify the scripts to run your own applications
3. Explore other examples in the parent directory

## Troubleshooting

- **Job stays in queue**: This is expected behavior when the cluster is busy. Your job will start automatically when resources become available. Check your job priority with squeue -u $USER
- **"Invalid account" error**: Make sure you've updated the account name to your actual SLURM account
- **Permission denied**: Make sure the scripts are executable with `chmod +x *.sh`

## Additional Resources

- HKUST HPC Documentation: https://hkust-hpc-docs.readthedocs.io/latest/
- HKUST HPC Workshops: https://github.com/hkust-hpc-team/hkust-hpc/tree/main/workshops
- SLURM Documentation: https://slurm.schedmd.com/
