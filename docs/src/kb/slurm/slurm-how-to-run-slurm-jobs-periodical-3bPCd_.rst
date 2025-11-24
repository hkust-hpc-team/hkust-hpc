How to Run SLURM Jobs Periodically Using scrontab
=================================================

.. meta::
    :description: Guide to scheduling periodic SLURM jobs using scrontab, similar to crontab
    :keywords: slurm, scrontab, crontab, periodic jobs, scheduled jobs, recurring tasks
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-11-18
    | *Solution under review*

Environment
-----------

    - SLURM workload manager with scrontab support
    - HPC cluster environment

Issue
-----

    - Users need to run SLURM jobs periodically at scheduled intervals, similar to how ``crontab`` works for regular shell commands.

      - Jobs need to be submitted through SLURM's resource allocation system
      - Resource requirements (CPUs, GPUs, memory) must be specified
      - Jobs should respect the cluster's scheduling policies and fair-share allocation

Resolution
----------

Use ``scrontab`` to schedule periodic SLURM jobs. The ``scrontab`` command works similarly to crontab but integrates with SLURM's scheduling system.

.. note::
    **Job overlap prevention**: Only one instance of a scheduled job will run at any time. If a job takes longer than its scheduled interval, the next scheduled execution will be skipped until the current job completes. This prevents resource conflicts and ensures predictable behavior.
    
    **Need overlapping jobs?** If you require multiple instances of the same job to run simultaneously (e.g., for parallel processing pipelines), see :doc:`slurm-how-to-submit-overlapping-slurm--sDhSiw` for details on achieving overlapping execution with scrontab.

Setting up a periodic job
~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Open the scrontab editor** by running:

   .. code-block:: shell-session

       $ scrontab

   This opens a text editor (typically vim) where you can define your scheduled jobs.

2. **Add your job schedule** using the following format:

   .. code-block:: bash

       #SCRON --job-name=hello-world
       #SCRON --account=exampleproj
       #SCRON --partition=amd
       #SCRON --nodes=1
       #SCRON --ntasks-per-node=1
       #SCRON --cpus-per-task=256
       #SCRON --time=1:0:0
       5 * * * * /home/exampleuser/hello-world.sbatch
       #
       # min hour day-of-month month day-of-week command

   - Lines starting with ``#SCRON`` define SLURM resource parameters (similar to ``#SBATCH`` in batch scripts)
   - The timing line follows standard crontab format: ``min hour day-of-month month day-of-week command``
   - In this example, the job runs at 5 minutes past every hour

   .. hint::
       **Timing precision**: Scheduled jobs may have a delay of ~10 seconds from the exact scheduled time due to SLURM's polling interval.

3. **Save and exit** the editor. The scheduled job will be automatically registered with SLURM.

4. **Verify the scheduled job** by checking the queue:

   .. code-block:: shell-session

       $ squeue -u exampleuser
                JOBID PARTITION     NAME        USER ST       TIME  NODES NODELIST(REASON)
               160651       amd hello-wo exampleuser PD       0:00      1 (BeginTime)

   The job will show as pending (``PD``) with the reason ``BeginTime`` until its scheduled execution time.

   .. note::
       The ``#SCRON`` directives apply to all scheduled jobs in the scrontab file. Use the same syntax as ``#SBATCH`` directives in regular SLURM batch scripts.

Viewing and managing scrontab entries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **View current scrontab**: Run ``scrontab -l`` or ``scrontab`` to list your scheduled jobs
- **Remove scrontab**: Run ``scrontab -r`` to remove all scheduled jobs
- **Edit scrontab**: Run ``scrontab`` to modify existing schedules

Managing output files
~~~~~~~~~~~~~~~~~~~~~

By default, SLURM output files (``slurm-<jobid>.out``) will overwrite each other with each execution. To preserve logs from each run, redirect output within your script using timestamps:

.. code-block:: bash

    #!/bin/bash
    #SBATCH --output=/dev/null
    
    # Redirect to timestamped log file
    LOGFILE="/home/exampleuser/logs/job-$(date +%Y%m%d-%H%M%S).log"
    exec &> "$LOGFILE"
    
    # Your job commands here
    echo "Job started at $(date)"

This approach creates a unique log file for each execution, making it easier to track job history and debug issues.

Root Cause
----------

Traditional ``crontab`` runs commands directly on the login node, which bypasses SLURM's resource management. This can cause issues:

- Jobs running on login nodes can overload shared resources
- No accounting or fair-share enforcement
- No resource isolation or allocation

The ``scrontab`` utility solves this by integrating cron-like scheduling with SLURM's job submission system. Each scheduled execution creates a new SLURM job with proper resource allocation and accounting.

References
----------

- SLURM scrontab documentation: https://slurm.schedmd.com/scrontab.html
- Crontab time format reference: https://crontab.guru/
- For allowing multiple concurrent job instances: :doc:`slurm-how-to-submit-overlapping-slurm--sDhSiw`


.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-11-18
      | Issued by: kftse@ust.hk
