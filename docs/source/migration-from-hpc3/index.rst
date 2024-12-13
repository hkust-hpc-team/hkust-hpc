Migration from HPC3 to HPC4
===========================

Overview
--------

This guide will assist you in migrating your work from the HPC3 system to the new HPC4 system. The process involves several key steps:

1. `Transferring your data and code from HPC3 to HPC4 <#step-1-transfer-data>`_
2. `Accessing the new HPC4 system <#step-2-compiling-code>`_
3. `Compiling your code on HPC4 <#step-3-testing-compiled-program>`_
4. `Testing your code on HPC4 <#step-4-testing-compiled-program>`_
5. `Running large jobs on HPC4 using SLURM <#step-5-production-run-with-slurm>`_

Each step is crucial for ensuring a smooth transition to the new system.

While this guide aims to make the process as straightforward as possible, if you encounter any issues, please contact the ITSC Helpdesk at cchelp@ust.hk for assistance.

Step 1: Transfer Data
---------------------

In this initial step, you will transfer your files from HPC3 to HPC4. This process can be conceptualized as migrating your digital research environment from one computing infrastructure to another. We will utilize two primary tools:

- ``sshfs``: This tool enables access to HPC3's file system as if it were locally mounted on HPC4.
- ``fpsync``: This utility efficiently copies files between directories by grouping them into batches and synchronizing them in parallel.

Transferring Files from Your HPC3 Home Directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Follow these steps to transfer files from your HPC3 home directory:

.. code-block:: bash

    # Run on >>> HPC4 <<<
    # ===================


    # 1. Create a mount point on HPC4 for HPC3 files
    #
    #[itsc@login1 ~]$
    mkdir ~/hpc3-storage


    # 2. Mount HPC3's file system
    #
    #[itsc@login1 ~]$
    sshfs $USER@hpc3.ust.hk:/home/$USER ~/hpc3-storage
    #.. (itsc@hpc3.ust.hk) Password:
    #.. (itsc@hpc3.ust.hk) Duo two-factor login for itsc
    #.. Enter a passcode or select one of the following options:
    #.. 1. Duo Push to +XXX XXXX 9092
    #.. 2. SMS passcodes to +XXX XXXX 9092 (next code starts with: 1)
    #..
    #.. Passcode or option (1-2): 1


    # 3. Verify the mounted directory
    #
    #[itsc@login1 ~]$
    ls ~/hpc3-storage/my-source-code/
    #.. file1.c  file2.c  file3.c  ...


    # 3. Copy files from HPC3 to HPC4
    #    This command copies all files, displaying progress (-vv) and using 16 parallel processes (-n 16)
    #
    #[itsc@login1 ~]$
    fpsync -vv -f 1024 -n 16 ~/hpc3-storage/my-source-code/ ~/my-source-code/

    #.. 1727407161 Info: [41058] Syncing ~/hpc3-storage/my-source-code/ => ~/my-source-code/
    #.. 1727407161 Info: Run ID: 1727407161-41058
    #.. 1727407161 Info: Start time: Fri Sep 27 11:19:21 HKT 2024
    #.. 1727407161 Info: Concurrent sync jobs: 16
    #.. 1727407161 Info: Workers: local
    #.. 1727407161 Info: Shared dir: /tmp/fpsync
    #.. 1727407161 Info: Temp dir: /tmp/fpsync
    #.. 1727407161 Info: Tool name: "rsync"
    #.. 1727407161 Info: Tool path: "/usr/bin/rsync"
    #.. 1727407161 Info: Tool options: "-lptgoD -v --numeric-ids"
    #.. 1727407161 Info: Fpart options: "-x|.zfs|-x|.snapshot*|-x|.ckpt"
    #.. 1727407161 Info: Max files or directories per sync job: 2048
    #.. 1727407161 Info: Max bytes per sync job: 10G
    #.. 1727407161 ===> Starting Fpart
    #.. 1727407161 <=== Fpart started (from sub-shell pid=41157)
    #.. 1727407161 ===> Analyzing filesystem...
    #.. 1727407161 ===> Use ^C to abort, ^T (SIGINFO) to display status
    #.. 1727407161 ===> [QMGR] Starting queue manager
    #.. 1727407161 ==> [FPART] Partition 1 written
    #.. 1727407161 ==> [FPART] Partition 2 written
    #.. 1727407161 => [QMGR] Starting job /tmp/fpsync/work/1727407161-41058/1 (local)
    #.. 1727407161 ==> [FPART] Partition 3 written
    #.. 1727407161 => [QMGR] Starting job /tmp/fpsync/work/1727407161-41058/2 (local)
    #.. ...
    #.. 1727407162 <=== Fpart crawling finished
    #.. 1727407162 <=== [QMGR] Done submitting jobs. Waiting for them to finish.
    #.. 1727407163 <= [QMGR] Job 41793:12:local finished
    #.. 1727407163 <= [QMGR] Job 41806:13:local finished
    #.. ...
    #.. 1727407443 <=== [QMGR] Queue processed
    #.. 1727407443 <=== Parts done: 13/13 (100%), remaining: 0
    #.. 1727407443 <=== Time elapsed: 12s, remaining: 0s (~1s/job)
    #.. 1727407443 <=== Fpsync completed without error in 22s.
    #.. 1727407443 <=== End time: Fri Sep 27 11:24:03 HKT 2024


    # 4. Unmount HPC3's file system when finished
    #
    #[itsc@login1 ~]$
    pkill sshfs && rmdir ~/hpc3-storage

Transferring Large Datasets from Scratch Space
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For larger datasets stored in the scratch space, it's crucial to first estimate the data size:

.. code-block:: bash

    # Run on >>> HPC3 <<<
    # ===================

    # Determine the total size of your dataset
    #
    # itsc@login-0 ~]$
    du -sh /scratch/PI/[pi-name]/path/to/dataset/
    #.. 102G   /scratch/PI/[pi-name]/path/to/dataset/

This command will display the total size of the specified directory and its contents.

.. note::

    If your total data size exceeds 500GB, you'll need to request additional quota. Please email `cchelp@ust.hk`_ with the following information:

    - Your Principal Investigator's username
    - Current data size in HPC3 (as determined by the ``du -sh`` command)
    - Requested quota for HPC4, considering:
          - Current data volume
          - Storage needed for research outputs
          - Anticipated data growth in the near future

Transfer Time Estimation
~~~~~~~~~~~~~~~~~~~~~~~~

Large data transfers can be time-consuming. It's advisable to plan accordingly and consider initiating transfers during off-peak hours. The following table provides estimated transfer times based on data volume, assuming a typical transfer speed of 2Gbps:

========= ==============
Data Size Estimated Time
========= ==============
1 GB      4 seconds
10 GB     40 seconds
100 GB    6.7 minutes
1 TB      1.1 hours
10 TB     11.1 hours
========= ==============

Please note that these are approximate times and may vary based on network conditions and other factors.

Transferring Data from Scratch Space
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you've estimated your data size and requested additional quota if necessary, follow these steps to transfer data from the scratch space:

.. code-block:: bash

    # Run on >>> HPC4 <<<
    # ===================
    # [PLACEHOLDERS] are shown in square brackets:
    #   - [PI-NAME]: Replace with your Principal Investigator's username


    # 1. Create a mount point for HPC3 scratch space
    #
    #[itsc@login1 ~]$
    mkdir ~/hpc3-scratch


    # 2. Mount HPC3's scratch space
    #
    #[itsc@login1 ~]$
    sshfs $USER@hpc3.ust.hk:/scratch/PI/[PI-NAME] ~/hpc3-scratch

    # 3. Verify the mounted directory
    #
    #[itsc@login1 ~]$
    ls ~/hpc3-scratch/path/to/hpc3/dataset/


    # 4. Copy datasets to HPC4's scratch space
    #    See optimization options below for faster transfer
    #
    #[itsc@login1 ~]$
    fpsync -vv -f 2048 -s 10G -n 16 ~/hpc3-scratch/path/to/hpc3/dataset/ /scratch/[PI-NAME]/my-hpc3-dataset/


    # 4. Unmount when finished
    #
    #[itsc@login1 ~]$
    pkill sshfs && rmdir ~/hpc3-scratch

Optimizing fpsync Performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``fpsync`` command offers several options to optimize transfer performance:

- ``-vv``: Displays detailed progress of the file transfer.
- ``-f 2048``: Sets the maximum number of files per batch to 2048.
      - Increase this value for numerous small files
      - Decrease for a small number of large files
- ``-s 10G``: Sets the approximate total file size per batch to 10GB.
      - Consider increasing for very large files (e.g., video datasets)
- ``-n 16``: Utilizes 16 parallel processes for faster copying. Please maintain this setting.

Verification
~~~~~~~~~~~~

After completing these steps, your code and datasets will be available on the HPC4 system, ready for subsequent stages of compilation and execution. We recommend verifying the successful transfer by comparing file sizes and counts in the source and destination directories.

Step 2: Interactive Session
---------------------------

Use SLURM to access a node of the correct CPU type.

For AMD node (256 cores):

.. code-block:: bash

    srun -A jiy -p cpu -C amd --nodes=1 --ntasks-per-node=1 --cpus-per-task=256 --pty bash

For Intel node (128 cores):

.. code-block:: bash

    srun -A jiy -p cpu -C intel --nodes=1 --ntasks-per-node=1 --cpus-per-task=128 --pty bash

Step 3: Compiling Code
----------------------

Use the appropriate compiler based on the CPU type.

For AMD:

.. code-block:: bash

    # Load AOCC compiler
    module load aocc

    # Compile example
    clang -O3 -march=native -mtune=native -fopenmp main.c -o main_amd

For Intel:

.. code-block:: bash

    # Load Intel compiler
    module load intel/oneapi-2023

    # Compile example
    icc -O3 -march=native -mtune=native -qopenmp main.c -o main_intel

Step 4: Testing Compiled Program
--------------------------------

Run a small test directly on the compiling node.

Example:

.. code-block:: bash

    # Set OpenMP threads
    export OMP_NUM_THREADS=4

    # Run the compiled program
    ./main_amd  # or ./main_intel

    # Check the output
    cat output.txt

Step 5: Production Run with SLURM
---------------------------------

Use ``sbatch`` command with a script for larger runs.

Create a SLURM job script (``job.sh``):

.. code-block:: bash

    #!/bin/bash

    #SBATCH --job-name=my-hpc4-job
    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=1
    #SBATCH --cpus-per-task=256
    #SBATCH --partition=cpu
    #SBATCH --constraint=amd
    #SBATCH --time=1-0:0:0
    #SBATCH --account=my-account
    #SBATCH --mail-user=username@ust.hk
    #SBATCH --mail-type=begin,end

    set -x

    # Load necessary modules
    module load aocc

    # Set environment variables
    export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

    # Run the program
    ./main_amd > output_large.txt

Submit the job:

.. code-block:: bash

    sbatch job.sh

Check job status:

.. code-block:: bash

    squeue -u $USER

After job completion, check the output:

.. code-block:: bash

    cat output_large.txt
    cat slurm-<job_id>.out  # For SLURM output and errors
