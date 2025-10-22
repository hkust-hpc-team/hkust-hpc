# Submit Your First SLURM Job

This example demonstrates how to submit your first job to the SLURM workload manager on the HPC cluster. It includes two approaches: submitting a batch job and starting an interactive session.

## Prerequisites

Before running these examples, make sure you:
1. Have access to the HPC cluster
2. Know your SLURM account name (replace `exampleproj` in the scripts)
3. Are familiar with basic Linux commands

## Files in This Example

- `superpod-interactive-helloworld.sh` - Start an interactive session
- `superpod-batch-job-helloworld.sh` - Submit a non-interactive batch job

## Option 1: Interactive Session (Recommended for Getting Started)

### What is an Interactive Session?

An interactive session gives you a live shell on a compute node with allocated resources. This is the best way to get started with the cluster, as it allows you to explore, test commands, and understand the environment before running automated batch jobs.

### How to Use

1. **Edit the script** to update your account name:
   ```bash
   nano superpod-interactive-helloworld.sh
   ```
   Change `--account=exampleproj` to your actual account name.

2. **Start an interactive session**:
   ```bash
   bash superpod-interactive-helloworld.sh
   ```
   Or directly with:
   ```bash
   srun --account=<your_account> \
        --partition=normal \
        --nodes=1 \
        --gpus-per-node=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=28 \
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

1. **Edit the script** to update your account name:
   ```bash
   nano superpod-batch-job-helloworld.sh
   ```
   Change `--account=exampleproj` to your actual account name.

2. **Submit the job** to SLURM:
   ```bash
   sbatch superpod-batch-job-helloworld.sh
   ```

3. **Check job status**:
   ```bash
   squeue -u $USER
   ```

4. **View the output** once the job completes:
   ```bash
   cat slurm-<job_id>.out
   ```
   Replace `<job_id>` with the actual job ID returned when you submitted the job.

### What the Script Does

The batch job script:
- Requests 1 node with 1 GPU and 28 CPU cores
- Prints "Hello, World!" with job information
- Shows which node(s) are allocated
- Displays CPU core count
- Lists GPU information using `nvidia-smi`
- Writes all output to `slurm-<job_id>.out`

## Resource Allocation Explained

Both scripts request the following resources:
- `--account`: Your billing account
- `--partition=normal`: The job queue/partition to use
- `--nodes=1`: Number of compute nodes
- `--gpus-per-node=1`: One GPU per node
- `--ntasks-per-node=1`: One task per node
- `--cpus-per-task=28`: 28 CPU cores per task
- `--time`: Maximum runtime before the job is automatically terminated
  - Interactive session: `4:0:0` (4 hours) - suitable for exploration and testing
  - Batch job: `3-0:0:0` (3 days) - allows longer production runs

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
