Job Submission
==============

.. meta::
    :description: Quick-start SLURM guide for HPC4 users covering CPU, GPU, MPI, interactive sessions, and basic job control.
    :keywords: HPC4, SLURM, sbatch, srun, squeue, scancel, GPU, MPI

.. rst-class:: header

    | Last updated: 2026-06-04

This page extends :doc:`first-job-template`.
Use it after your first simple CPU batch job already works and you need GPU, MPI, interactive, or job-control patterns.

Environment
-----------

    - Users who can already log in to HPC4
    - Users who already know their available SLURM account and partition
    - Basic familiarity with shell commands and text editors

Before You Submit
-----------------

Before writing a job script, confirm your SLURM association and available partitions.

.. code-block:: bash

    sacctmgr show user <username> withassoc

Use your own account and partition values from that query.

.. important::

    Replace placeholders such as ``<username>``, ``<your-account>``, ``<your-gpu-partition>``, and ``<job_id>`` before running the commands.
    If you type the angle brackets literally, the shell will treat them as redirection syntax and the command will fail.

Example output from one HPC4 account included entries for:

- account ``hpcintern`` on partitions ``amd`` and ``intel``
- account ``hpcintern`` on GPU partitions such as ``gpu-rtx4090d``, ``gpu-rtx5880``, ``gpu-l20``, and ``gpu-a30``

One tested CPU combination on one account was:

- ``--account=hpcintern`` with ``--partition=amd``

SLURM Templates
---------------

CPU Batch Template
~~~~~~~~~~~~~~~~~~

Use this for a simple non-MPI CPU job.

If ``sbatch`` reports ``Invalid account or account/partition combination specified``, re-check your ``#SBATCH --account`` and ``#SBATCH --partition`` pair against the output of ``sacctmgr show user <username> withassoc``.
One tested script only succeeded after the account and partition values were corrected to a valid pair.

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

GPU Batch Template
~~~~~~~~~~~~~~~~~~

Use this when your application needs one GPU.

One tested HPC4 batch script used ``--account=hpcintern``, ``--partition=gpu-a30``, and ``--gres=gpu:1``.

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
    #SBATCH --gres=gpu:1

    nvidia-smi
    hostname

One tested submission returned ``Submitted batch job 1405013`` and produced output that included ``NVIDIA A30`` followed by ``gpu01``.

MPI Batch Template
~~~~~~~~~~~~~~~~~~

Use this when your application launches multiple ranks.

One tested HPC4 batch script used one node on ``amd`` with two tasks and ran ``srun -n 2 hostname``.
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

One tested submission returned ``Submitted batch job 1405014`` and produced:

.. code-block:: text

    cpu74
    cpu74

.. important::

   On HPC4, prefer ``srun`` in SLURM jobs.
   Do not assume ``mpirun`` or ``mpiexec`` is the recommended launcher for the provided OpenMPI build.

Real-time Status Viewing
------------------------

After submitting a batch script with ``sbatch``, monitor it with ``squeue``.

Check all of your jobs:

.. code-block:: bash

    squeue -u $USER

Example output from one HPC4 login-node session:

.. code-block:: text

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)

If no jobs are running or pending, you may only see the header line.

Check one specific job:

.. code-block:: bash

    squeue -j <job_id>

Remember to replace ``<job_id>`` with the actual numeric job ID returned by ``sbatch``.

Example output from one HPC4 login-node session after a short CPU job completed:

.. code-block:: text

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)

If the job is very short, it may already have finished before you run ``squeue -j <job_id>``.

Example output from one HPC4 login-node session while a cancel test job was still running:

.. code-block:: text

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           1405015       amd cancel-t <username>  R       0:04      1 cpu42

Cancel a specific job:

.. code-block:: bash

    scancel <job_id>

Example output from one HPC4 login-node session immediately after ``scancel 1405015``:

.. code-block:: text

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           1405015       amd cancel-t <username> CG       0:04      1 cpu42

Cancel all of your jobs only when you really mean to do so:

.. code-block:: bash

    scancel -u $USER

.. warning::

    ``scancel -u $USER`` cancels all of your jobs, including an active interactive ``srun --pty bash`` session.
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
         --gres=gpu:1 \
         --time=00:10:00 \
         --pty bash

.. important::

    Do not request GPU resources together with a CPU-only partition such as ``amd``.
    On one tested HPC4 account, ``--gpus-per-task=1`` and ``--gpus=1`` were both rejected on ``gpu-a30``.
    The tested working form was ``--gres=gpu:1`` on ``--partition=gpu-a30``.

One tested failure case requested GPU resources on ``--partition=amd`` and returned:

.. code-block:: text

    srun: error: Unable to allocate resources: Requested node configuration is not available

One tested failure case requested ``--gpus-per-task=1`` on ``--partition=gpu-a30`` and returned a resource-limit error stating that 0 GPUs were requested.

Once the session starts, run a small check such as:

.. code-block:: bash

    hostname
    pwd

Example output from one HPC4 login-node session:

.. code-block:: text

    srun: job 1404966 queued and waiting for resources
    srun: job 1404966 has been allocated resources
    [<username>@cpu69 ~]$ hostname
    cpu69
    [<username>@cpu69 ~]$ pwd
    /home/<username>

If you requested a GPU, also check:

.. code-block:: bash

    nvidia-smi

If you are not actually on a GPU node, ``nvidia-smi`` may not be available.

Example output from one HPC4 GPU interactive session:

.. code-block:: text

    srun: job 1405005 queued and waiting for resources
    srun: job 1405005 has been allocated resources
    Thu Jun  4 16:10:31 2026
    | NVIDIA A30 |
    gpu01
    /home/<username>

Leave the interactive session with:

.. code-block:: bash

    exit

Practical Notes
---------------

- Use short walltimes while testing.
- Keep output files named with ``%j`` so different runs do not overwrite each other.
- Use batch jobs for unattended work and interactive sessions for short manual checks.
- Avoid heavy compilation or long-running tasks on login nodes.
- If a command example contains angle-bracket placeholders, replace them before pressing Enter.
- A very short batch job may finish before ``squeue -j <job_id>`` shows anything useful.

Minimal Successful Batch Example
--------------------------------

One tested short CPU script was submitted successfully with ``sbatch`` and produced a normal output file.

Example submission output:

.. code-block:: text

    Submitted batch job 1404973

Example output file content:

.. code-block:: text

    Hello from cpu13

See Also
--------

- :doc:`first-job-template`
- :doc:`/software/software-support-overview`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
- :doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`
