How to Submit Overlapping SLURM Jobs Using Scrontab
===================================================

.. meta::
    :description: A guide to using scrontab to submit SLURM jobs at regular intervals, allowing overlapping execution when previous jobs haven't completed
    :keywords: scrontab, slurm, cron, overlapping jobs, scheduled jobs, periodic submission
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-11-18
    | *Solution under review*

Environment
-----------

    - SLURM workload manager with scrontab support
    - Any HPC partition (e.g., amd, intel)

Issue
-----

    Users may need to submit jobs at regular intervals regardless of whether previously submitted jobs have completed. This creates a scenario where:

    - Jobs need to run periodically (e.g., every minute, every hour)
    - Multiple instances of the same job should be allowed to run simultaneously
    - Previous job runs should continue executing without being cancelled
    - The scheduling should not wait for previous jobs to complete before submitting new ones

    Traditional cron-like scheduling might wait for job completion, but some workflows require overlapping execution for parallel processing or continuous monitoring tasks.

Resolution
----------

Use ``scrontab`` to submit SLURM jobs at scheduled intervals. The scrontab entry itself is a minimal SLURM job that runs the ``sbatch`` command to submit your actual workload.

Configure the scrontab entry
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a scrontab entry that submits your job script at the desired interval. The scrontab itself should be a lightweight job:

.. code-block:: shell-session

    $ scrontab -l
    #SCRON --job-name=periodic_submit
    #SCRON --account=username
    #SCRON --partition=amd
    #SCRON --nodes=1
    #SCRON --ntasks-per-node=1
    #SCRON --cpus-per-task=1
    #SCRON --time=0:0:5
    * * * * * sbatch /home/username/path/to/job.sbatch

The cron schedule ``* * * * *`` means the job will be submitted every minute. You can adjust this to your needs:

- ``*/5 * * * *`` - every 5 minutes
- ``0 * * * *`` - every hour
- ``0 0 * * *`` - daily at midnight

Please refer to :doc:`slurm-how-to-run-slurm-jobs-periodical-3bPCd_` for basic SLURM cronjob creation.

Create your actual job script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The job script referenced in the scrontab entry contains your actual workload:

.. code-block:: bash

    #!/bin/bash

    #SBATCH --account=username
    #SBATCH --partition=amd
    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=1
    #SBATCH --cpus-per-task=256
    #SBATCH --time=1:0:0

    echo "Hello, World! The time is $(date)"
    # Your actual processing logic here

Edit your scrontab
~~~~~~~~~~~~~~~~~~

To add or modify scrontab entries:

.. code-block:: shell-session

    $ scrontab -e

This opens your default editor to modify the scrontab configuration.

Verify overlapping execution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After setup, check the job queue to verify multiple instances are running:

.. code-block:: shell-session

    $ squeue -u username
     JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    212355       amd periodic username PD       0:00      1 (BeginTime)
    212455       amd job      username  R       0:19      1 cpu43
    212452       amd job      username  R       1:19      1 cpu42
    212447       amd job      username  R       2:19      1 cpu41
    212437       amd job      username  R       3:24      1 cpu33
    212433       amd job      username  R       4:21      1 cpu39
    212429       amd job      username  R       5:19      1 cpu38
    212424       amd job      username  R       6:23      1 cpu37
    212420       amd job      username  R       7:16      1 cpu36
    212419       amd job      username  R       8:20      1 cpu58
    212417       amd job      username  R       9:20      1 cpu44

In this output, you can see multiple instances of the same job running simultaneously, with the ``periodic_submit`` job scheduled to run again (PD status with BeginTime reason).

.. note::
    
    Be mindful of resource usage when allowing overlapping jobs. Ensure your account has sufficient allocation and the cluster has enough resources to accommodate multiple concurrent instances.

.. warning::

    Monitor your job queue regularly to prevent excessive accumulation of jobs if they run longer than expected. Consider implementing job duration limits or dependency chains if jobs should not overlap indefinitely.

Root Cause
----------

The scrontab mechanism works by submitting a lightweight SLURM job at the scheduled interval. This job executes ``sbatch``, which submits another independent job to the queue. Since each submission creates a new, separate job, they can overlap freely without interfering with each other.

This approach differs from traditional job dependencies (``--dependency=afterok:jobid``) which would wait for completion. The scrontab method provides true periodic submission regardless of previous job states, making it ideal for:

- Continuous monitoring or polling tasks
- Parallel processing of time-windowed data
- Periodic backup or checkpointing operations
- Concurrent analysis pipelines

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-11-18
      | Issued by: kftse@ust.hk
