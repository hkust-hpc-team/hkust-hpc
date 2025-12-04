How to Submit and Run Batch Jobs with SLURM
============================================

.. meta::
    :description: Guide to submitting and running batch jobs on HPC clusters using SLURM workload manager
    :keywords: slurm, batch job, sbatch, job submission, hpc, queue
    :author: HPC Support Team <cchelp@ust.hk>

.. rst-class:: header

    | Last updated: 2025-12-04
    | Solution verified: 2025-12-04

Environment
-----------

    - HPC4 cluster
    - Superpod cluster
    - SLURM workload manager
    - Any batch computational task (simulations, data processing, training, etc.)

Issue
-----

    - Users need to run computational tasks that don't require interactive input
    - Jobs should run unattended in the background, possibly for extended periods
    - Resources need to be scheduled and allocated fairly among all users
    - Users want to submit multiple jobs and have them queue automatically
    - Need to run jobs on specific partitions (CPU, GPU) with defined resource requirements


Resolution
----------

Use the ``sbatch`` command to submit batch job scripts to SLURM. Batch scripts contain resource requirements and the commands to execute.

Basic Batch Job Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~

1. Create a batch script with resource requirements and commands
2. Submit the script using ``sbatch``
3. Monitor job status with ``squeue``
4. Retrieve results from output files after job completes

Creating a Batch Script
~~~~~~~~~~~~~~~~~~~~~~~

A batch script is a shell script with special SLURM directives (``#SBATCH``) that specify resource requirements.

Basic CPU Job (HPC4)
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=my_cpu_job
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=32
   #SBATCH --time=24:00:00
   #SBATCH --output=job_%j.out
   #SBATCH --error=job_%j.err
   
   # Load required modules
   module load python/3.12
   
   # Run your application
   python my_script.py

GPU Job (Superpod)
^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=my_gpu_job
   #SBATCH --account=exampleproj
   #SBATCH --partition=gpu
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --cpus-per-task=32
   #SBATCH --gpus-per-task=1
   #SBATCH --time=48:00:00
   #SBATCH --output=gpu_job_%j.out
   #SBATCH --error=gpu_job_%j.err
   
   # Load CUDA and other modules
   module load cuda/12.6
   module load python/3.12
   
   # Run GPU application
   python train_model.py

MPI Parallel Job
^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=mpi_job
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --nodes=4
   #SBATCH --ntasks-per-node=64
   #SBATCH --time=12:00:00
   #SBATCH --output=mpi_%j.out
   
   # Load compiler and MPI
   module load intel-oneapi-compilers/2025
   module load intel-oneapi-mpi/2021
   
   # Run MPI application
   srun ./my_mpi_program

Common SBATCH Directives
~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Directive
     - Description
   * - ``--job-name=<name>``
     - Name for the job (shows in queue)
   * - ``--account=<project>``
     - Project account to charge (required)
   * - ``--partition=<name>``
     - Partition to use (amd, intel, gpu, etc.)
   * - ``--nodes=<n>``
     - Number of nodes to allocate
   * - ``--ntasks-per-node=<n>``
     - Number of tasks (MPI ranks) per node
   * - ``--cpus-per-task=<n>``
     - Number of CPU cores per task
   * - ``--gpus-per-task=<n>``
     - Number of GPUs per task (GPU partitions)
   * - ``--time=<D-HH:MM:SS>``
     - Maximum wall time (days-hours:minutes:seconds)
   * - ``--output=<file>``
     - File for standard output (``%j`` = job ID)
   * - ``--error=<file>``
     - File for standard error (``%j`` = job ID)
   * - ``--mail-type=<events>``
     - Email notification events (BEGIN, END, FAIL, ALL)
   * - ``--mail-user=<email>``
     - Email address for notifications

.. important::
   **Do not specify** ``--mem`` or ``--mem-per-cpu`` options. Memory is automatically allocated proportionally based on the number of CPUs or GPUs requested.

Submitting Jobs
~~~~~~~~~~~~~~~

.. code-block:: bash

   # Submit a batch job
   sbatch my_job_script.sh
   
   # Output shows job ID
   # Submitted batch job 12345

The job is now queued and will start when resources are available.

Monitoring Jobs
~~~~~~~~~~~~~~~

Check Job Status
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # View your jobs in the queue
   squeue -u $USER
   
   # View specific job details
   squeue -j 12345
   
   # View all jobs on a partition
   squeue -p amd

Example ``squeue`` output:

.. code-block:: text

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
             12345       amd  my_job  username  R      10:23      2 node[001-002]
             12346       gpu gpu_job  username PD       0:00      1 (Resources)

Job states: ``R`` (Running), ``PD`` (Pending), ``CG`` (Completing), ``F`` (Failed)

View Job Details
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Detailed job information
   scontrol show job 12345
   
   # Job accounting information
   sacct -j 12345 --format=JobID,JobName,Partition,State,Elapsed,MaxRSS

Canceling Jobs
~~~~~~~~~~~~~~

.. code-block:: bash

   # Cancel a specific job
   scancel 12345
   
   # Cancel all your jobs
   scancel -u $USER
   
   # Cancel all your jobs in a partition
   scancel -u $USER -p amd

Job Output Files
~~~~~~~~~~~~~~~~

Output files are created in the directory where you submitted the job (unless you specify absolute paths).

.. code-block:: bash

   # View output while job is running
   tail -f job_12345.out
   
   # Check for errors
   cat job_12345.err
   
   # View completed job output
   less job_12345.out

Use ``%j`` in filenames to include the job ID automatically:

.. code-block:: bash

   #SBATCH --output=results_%j.out
   #SBATCH --error=errors_%j.err

Array Jobs
~~~~~~~~~~

For running multiple similar jobs with different parameters or input files, see the dedicated array jobs guide:

:doc:`slurm-how-to-use-slurm-array-jobs-for--sQ5r9U`

Job Dependencies
~~~~~~~~~~~~~~~~

Chain jobs to run sequentially:

.. code-block:: bash

   # Submit first job
   JOB1=$(sbatch --parsable first_job.sh)
   
   # Submit second job that depends on first
   sbatch --dependency=afterok:$JOB1 second_job.sh
   
   # Or depend on successful completion
   sbatch --dependency=afterok:$JOB1 analysis_job.sh

Dependency types:
- ``afterok:jobid`` - Start after job completes successfully
- ``afterany:jobid`` - Start after job completes (any state)
- ``afternotok:jobid`` - Start only if job fails

Best Practices
~~~~~~~~~~~~~~

**Resource Requests**

- Request only the resources you need
- Use ``--time`` wisely - jobs with shorter time limits may start sooner
- Test with small jobs before scaling up
- Monitor resource usage to optimize future requests

**Script Organization**

- Use descriptive job names
- Include comments explaining what the job does
- Set up proper output/error file naming
- Load all required modules at the start

**Error Handling**

- Check exit codes in your scripts
- Use ``set -e`` to exit on errors
- Redirect errors to separate log files
- Test scripts interactively first (see :doc:`slurm-how-to-request-interactive-sessi-HV7WS9`)

**Output Management**

- Use unique output filenames with ``%j`` (job ID)
- Organize outputs in subdirectories for large job sets
- Clean up old output files periodically
- Consider redirecting verbose output to /dev/null

Root Cause
----------

Batch job systems exist because:

**Shared Resource Management**
- Compute clusters are shared among many users
- Fair scheduling ensures everyone gets their allocated share
- Queue system prevents resource conflicts

**Unattended Execution**
- **Jobs are not affected by login node reboot or network disconnection**
- Jobs can run for extended periods over days
- Failed jobs can be automatically requeued
- Long-running jobs don't need interactive supervision

**Resource Optimization**
- Scheduler can pack jobs efficiently across nodes
- Automatic resource allocation based on requirements
- Better overall cluster utilization

References
----------

**Example Scripts**

- `HPC4 Batch Job Examples <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/hpc4-hello-world>`_
  
  - `CPU Batch Job <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/hpc4-hello-world/hpc4-batch-job-helloworld-cpu.sh>`_
  - `CPU MPI Batch Job <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/hpc4-hello-world/hpc4-batch-job-helloworld-cpu-mpi.sh>`_
  - `GPU Batch Job <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/hpc4-hello-world/hpc4-batch-job-helloworld-gpu.sh>`_

- `Superpod Batch Job Examples <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/superpod-hello-world>`_

  - `Batch Job <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/superpod-hello-world/superpod-batch-job-helloworld.sh>`_

**Related Articles**

- :doc:`slurm-how-to-request-interactive-sessi-HV7WS9` - For interactive development and testing

**SLURM Documentation**

- `SLURM sbatch Command <https://slurm.schedmd.com/sbatch.html>`_
- `SLURM squeue Command <https://slurm.schedmd.com/squeue.html>`_
- `SLURM Job Arrays <https://slurm.schedmd.com/job_array.html>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-12-04
      | Issued by: kftse@ust.hk
