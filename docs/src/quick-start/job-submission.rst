Job Templates and Control
=========================

.. meta::
    :description: Quick-start SLURM guide for HPC4 and SuperPOD users covering CPU, GPU, MPI, interactive sessions, and basic job control.
    :keywords: HPC4, SuperPOD, SLURM, sbatch, srun, squeue, scancel, GPU, MPI

.. rst-class:: header

    | Last updated: 2026-06-04

This page extends :doc:`first-job-template`.
Use it after your first simple CPU batch job already works and you need GPU, MPI, interactive, or job-control patterns.

Environment
-----------

    - Users who can already log in to the cluster (HPC4 or SuperPOD)
    - Users who already know their available SLURM account and partition
    - Basic familiarity with shell commands and text editors

Before You Submit
-----------------

Before writing a job script, confirm your SLURM association and available partitions.

.. code-block:: bash

    sacctmgr show user $USER withassoc

Example output (your account and partitions will differ):

.. code-block:: text

       User    Def Acct     Admin    Cluster    Account  Partition     Share   Priority  MaxJobs  MaxNodes  MaxCPUs  MaxSubmit  MaxWall  MaxCPUMins  QOS   Def QOS  GrpCPUs  GrpJobs  GrpNodes  GrpSubmit  GrpWall  GrpCPUMins
    --------- ---------- --------- ---------- ---------- ---------- --------- --------- -------- --------- -------- ---------- -------- ---------- ----- -------- -------- -------- --------- ---------- -------- -----------
       alice        itsc      None       hpc4        itsc        amd         1                                                      normal
       alice        itsc      None       hpc4        itsc       intel        1                                                      normal
       alice        itsc      None       hpc4        itsc     gpu-a30        1                                                      normal
       alice        itsc      None       hpc4        itsc     gpu-l20        1                                                      normal

Use your own account and partition values from that query.

.. warning::

   If ``sbatch`` reports ``Invalid account or account/partition combination specified``,
   re-check your ``#SBATCH --account`` and ``#SBATCH --partition`` pair against the
   output of ``sacctmgr show user $USER withassoc``.

SLURM Templates
---------------

CPU Batch Template
~~~~~~~~~~~~~~~~~~

Use this for a simple non-MPI CPU job.

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=cpu-quick-start
    #SBATCH --output=cpu-%j.out
    #SBATCH --time=00:30:00
    #SBATCH --nodes=1
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=1
    #SBATCH --account=<your-account>
    #SBATCH --partition=amd

    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.13.2

    python my_script.py

Create ``my_script.py`` alongside ``submit.sh``:

.. code-block:: python

    import platform
    print(f"Hello from {platform.node()}")
    print(f"Python {platform.python_version()}")

GPU Batch Template
~~~~~~~~~~~~~~~~~~

Use this when your application needs one GPU.

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=gpu-quick-start
    #SBATCH --output=gpu-%j.out
    #SBATCH --time=00:10:00
    #SBATCH --nodes=1
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=8
    #SBATCH --account=<your-account>
    #SBATCH --partition=<your-gpu-partition>
    #SBATCH --gpus-per-node=1

    nvidia-smi
    hostname

MPI Batch Template
~~~~~~~~~~~~~~~~~~

Use this when your application launches multiple ranks.
On the edge Spack instance, load a compiler first so that the hierarchical Lmod tree exposes ``openmpi``.

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=mpi-quick-start
    #SBATCH --output=mpi-%j.out
    #SBATCH --time=00:10:00
    #SBATCH --nodes=1
    #SBATCH --ntasks=2
    #SBATCH --account=<your-account>
    #SBATCH --partition=amd

    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load intel-oneapi-compilers/2025.0.4
    module load openmpi/5.0.6

    srun -n 2 hostname

.. important::

   On HPC4, prefer ``srun`` in SLURM jobs.
   Do not assume ``mpirun`` or ``mpiexec`` is the recommended launcher for the provided OpenMPI build.

Real-time Status Viewing
------------------------

After submitting a batch script with ``sbatch``, monitor it with ``squeue``.

Check all of your jobs:

.. code-block:: bash

    squeue --me

Example output while a job is running:

.. code-block:: text

              JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            1405015       amd cpu-quick    alice  R       0:04      1 cpu42

If no jobs are running or pending, you see only the header line.

Check one specific job:

.. code-block:: bash

    squeue -j 1404973

If the job is very short, it may already have finished before you run ``squeue -j``.

Cancel a specific job:

.. code-block:: bash

    scancel 1404973

Cancel all of your jobs only when you really mean to do so:

.. code-block:: bash

    scancel --me

.. warning::

   ``scancel --me`` cancels all of your jobs, including an active interactive ``srun --pty bash`` session.
   Use it only when you want to stop every running and pending job owned by your account.

Minimal status interpretation:

- ``R`` means running.
- ``PD`` means pending.
- ``CG`` means completing.
- ``F`` means failed.

Interactive Tasks
-----------------

Use an interactive session when you need a compute-node shell for testing, debugging, compilation, or short manual runs.

CPU interactive session example:

.. code-block:: bash

    srun --account=<your-account> \
         --partition=amd \
         --nodes=1 \
         --ntasks=1 \
         --cpus-per-task=4 \
         --time=00:10:00 \
         --pty bash

GPU interactive session example:

.. code-block:: bash

    srun --account=<your-account> \
         --partition=<your-gpu-partition> \
         --nodes=1 \
         --ntasks=1 \
         --cpus-per-task=8 \
         --gpus-per-node=1 \
         --time=00:10:00 \
         --pty bash

.. important::

   Do not request GPU resources together with a CPU-only partition such as ``amd``.
   On both HPC4 and SuperPOD, use ``--gpus-per-node=<n>`` to request GPUs.
   ``--gpus-per-task`` and ``--gpus`` are not recommended on GPU partitions.

Once the session starts, run a small check such as:

.. code-block:: bash

    hostname
    pwd

Example output from an HPC4 CPU interactive session:

.. code-block:: text

    srun: job 1404966 queued and waiting for resources
    srun: job 1404966 has been allocated resources
    [alice@cpu69 ~]$ hostname
    cpu69
    [alice@cpu69 ~]$ pwd
    /home/alice

If you requested a GPU, also check:

.. code-block:: bash

    nvidia-smi

If you are not actually on a GPU node, ``nvidia-smi`` may not be available.

Example output from an HPC4 GPU interactive session:

.. code-block:: text

    srun: job 1405005 queued and waiting for resources
    srun: job 1405005 has been allocated resources
    Thu Jun  4 16:10:31 2026
    | NVIDIA A30 |
    gpu01
    /home/alice

Leave the interactive session with:

.. code-block:: bash

    exit

Practical Notes
---------------

- Use short walltimes while testing.
- Keep output files named with ``%j`` so different runs do not overwrite each other.
- Use batch jobs for unattended work and interactive sessions for short manual checks.
- Avoid heavy compilation or long-running tasks on login nodes.
- A very short batch job may finish before ``squeue -j <job_id>`` shows anything useful.

See Also
--------

- :doc:`first-job-template`
- :doc:`/software/software-support-overview`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
- :doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`
- `HPC4 example scripts (CPU, GPU, MPI, interactive) <https://github.com/hkust-hpc-team/hkust-hpc/tree/main/examples/hpc4-hello-world>`__
- `SuperPOD example scripts <https://github.com/hkust-hpc-team/hkust-hpc/tree/main/examples/superpod-hello-world>`__
