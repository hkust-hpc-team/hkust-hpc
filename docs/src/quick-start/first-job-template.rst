Submit Your First Job
==========================

.. meta::
    :description: Minimal first SLURM batch job walkthrough for HPC4 and SuperPOD users who want one fast, successful CPU submission.
    :keywords: HPC4, SuperPOD, SLURM, sbatch, first job, quick start, batch job

.. rst-class:: header

    | Last updated: 2026-06-04

This page is the shortest path to a first successful batch job on HPC4 or SuperPOD.
It keeps the scope narrow: one small CPU script, one ``sbatch``, one output file.

.. warning::

   On **SuperPOD**, GPU partitions (``normal``) always allocate a full GPU node.
   You cannot request CPU-only resources on these partitions.
   For initial testing, use the ``cpu`` partition to avoid unnecessary GPU charges.

Before You Start
----------------

Make sure you can already log in to the cluster (HPC4 or SuperPOD).
Then confirm one valid SLURM account and CPU partition pair:

.. code-block:: bash

    sacctmgr show user $USER withassoc

Example output (your account and partitions will differ):

.. code-block:: text

       User    Def Acct     Admin    Cluster    Account  Partition     Share   Priority  MaxJobs  MaxNodes  MaxCPUs  MaxSubmit  MaxWall  MaxCPUMins  QOS   Def QOS  GrpCPUs  GrpJobs  GrpNodes  GrpSubmit  GrpWall  GrpCPUMins
    --------- ---------- --------- ---------- ---------- ---------- --------- --------- -------- --------- -------- ---------- -------- ---------- ----- -------- -------- -------- --------- ---------- -------- -----------
       alice        itsc      None       hpc4        itsc        amd         1                                                      normal
       alice        itsc      None       hpc4        itsc       intel        1                                                      normal
       alice        itsc      None       hpc4        itsc     gpu-a30        1                                                      normal

Use your own account and partition values from that output.
One tested CPU combination on one account was ``--account=itsc`` with ``--partition=amd``.

.. warning::

   If ``sbatch`` reports ``Invalid account or account/partition combination specified``,
   re-check your ``#SBATCH --account`` and ``#SBATCH --partition`` pair against the
   output of ``sacctmgr show user $USER withassoc``.

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

Expected output:

.. code-block:: text

    Submitted batch job 1404973

Replace ``1404973`` below with the actual job ID returned by your submission.

Optional Quick Status Check
---------------------------

While the job is queued or running, check its status with:

.. code-block:: bash

    squeue -j 1404973

If the command returns only the header line, the job may have already finished because the example job is very short.

Check the Output
----------------

After the job completes, inspect the output file:

.. code-block:: bash

    cat quick-start.out

Expected output:

.. code-block:: text

    Hello from cpu13

Next Step
---------

After this first CPU job works, move on to :doc:`job-submission` for GPU batch jobs, MPI batch jobs, interactive ``srun`` sessions, and ``squeue`` or ``scancel`` usage.

For more complete SLURM templates, see the canonical example scripts:
`HPC4 examples <https://github.com/hkust-hpc-team/hkust-hpc/tree/main/examples/hpc4-hello-world>`__
(CPU, GPU, MPI, and interactive sessions).

See Also
--------

- :doc:`/software/software-support-overview`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
