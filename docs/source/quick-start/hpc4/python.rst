Python Quick Start in HPC4
===============================================

Overview
--------
This guide provides recommended practice 

.. note::
   TODO: Make below a warning note:
   You will need to use the SLURM scheduler for installing, debugging and production runs. Please do not run jobs directly on the login nodes.

1. `SLURM command overview <#ep-1-transfer-data>`_
2. `Partition and policies <#step-2-compiling-code>`_
3. `Using interactive sessions <#step-3-testing-compiled-program>`_
4. `Using batch sessions <#step-4-testing-compiled-program>`_
5. `Accepted commandline parameters <#step-5-production-run-with-slurm>`_

Step 2: Running an interactive sessions
-----------------------------------------
Use SLURM to access a node of the correct CPU type.

For AMD node (256 cores):

.. code-block:: bash

   srun -A jiy -p cpu -C amd --nodes=1 --ntasks-per-node=1 --cpus-per-task=256 --pty bash

For Intel node (128 cores):

.. code-block:: bash

   srun -A jiy -p cpu -C intel --nodes=1 --ntasks-per-node=1 --cpus-per-task=128 --pty bash

Step 3: Compiling Code
-----------------------
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
-----------------------------------
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