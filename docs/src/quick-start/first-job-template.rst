Submit Your First HPC4 Job
==========================

.. meta::
    :description: Minimal first SLURM batch job walkthrough for HPC4 users who want one fast, successful CPU submission.
    :keywords: HPC4, SLURM, sbatch, first job, quick start, batch job

.. rst-class:: header

    | Last updated: 2026-06-04

This page is the shortest path to a first successful HPC4 batch job.
It keeps the scope narrow: one small CPU script, one ``sbatch``, one output file.

Before You Start
----------------

Make sure you can already log in to HPC4.
Then confirm one valid SLURM account and CPU partition pair:

.. code-block:: bash

    sacctmgr show user <username> withassoc

Use your own account and partition values from that output.
One tested CPU combination on one account was ``--account=hpcintern`` with ``--partition=amd``.

.. important::

    Replace placeholders such as ``<username>``, ``<your-account>``, ``<your-partition>``, and ``<job_id>`` before running the commands.
    If you type the angle brackets literally, the shell will treat them as redirection syntax and the command will fail.

Create the Smallest Useful Script
---------------------------------

Create a file named ``submit.sh`` with the following content:

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=quick-start
    #SBATCH --output=quick-start.out
    #SBATCH --open-mode=truncate
    #SBATCH --time=00:05:00
    #SBATCH --nodes=1
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=1
    #SBATCH --account=<your-account>
    #SBATCH --partition=<your-partition>

    echo "Hello from $(hostname)"

This script is intentionally minimal. It only proves that batch submission works and that the job can run on a compute node.

Submit the Job
--------------

Submit the script with:

.. code-block:: bash

    sbatch submit.sh

If ``sbatch`` reports ``Invalid account or account/partition combination specified``, compare your ``#SBATCH --account`` and ``#SBATCH --partition`` settings with the output of ``sacctmgr show user <username> withassoc``.

Expected output:

.. code-block:: text

    Submitted batch job <job_id>

On one tested short CPU run, the command returned ``Submitted batch job 1404973``.

Replace ``<job_id>`` below with the actual job ID returned by your submission.

Optional Quick Status Check
---------------------------

While the job is queued or running, check its status with:

.. code-block:: bash

    squeue -j <job_id>

If the command returns ``Invalid job id``, the job may have already finished because the example job is very short.

Check the Output
----------------

After the job completes, inspect the output file:

.. code-block:: bash

    cat quick-start.out

Expected output:

.. code-block:: text

    Hello from cpu01

On one tested short CPU run, the output file contained ``Hello from cpu13``.

Next Step
---------

After this first CPU job works, move on to :doc:`job-submission` for GPU batch jobs, MPI batch jobs, interactive ``srun`` sessions, and ``squeue`` or ``scancel`` usage.

See Also
--------

- :doc:`/software/software-support-overview`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
