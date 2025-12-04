How to Use SLURM Array Jobs for Parameter Sweeps and Batch Processing
======================================================================

.. meta::
    :description: Guide to using SLURM array jobs for parameter sweeps, batch processing, and parallel task execution
    :keywords: slurm, array job, parameter sweep, batch processing, job array, parallel tasks
    :author: HPC Support Team <cchelp@ust.hk>

.. rst-class:: header

    | Last updated: 2025-12-04
    | *Solution under review*

Environment
-----------

    - HPC4 cluster
    - Superpod cluster
    - SLURM workload manager
    - Tasks that need to run with different parameters or input files
    - Parameter sweeps, sensitivity analysis, batch data processing

Issue
-----

    - Need to run the same program with different parameters or input files
    - Want to process multiple datasets with the same analysis script
    - Conducting parameter sweeps for optimization or sensitivity analysis
    - Have many independent tasks that can run in parallel
    - Submitting individual jobs for each parameter is time-consuming and error-prone
    - Need efficient way to manage hundreds or thousands of similar jobs

Resolution
----------

Use SLURM array jobs with the ``--array`` option to submit multiple similar tasks with a single command. Each array task gets a unique ``$SLURM_ARRAY_TASK_ID`` that can be used to select parameters or input files.

Basic Array Job Syntax
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=array_example
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=1-10
   #SBATCH --output=array_%A_%a.out
   #SBATCH --error=array_%A_%a.err
   
   # $SLURM_ARRAY_TASK_ID contains the array index (1, 2, 3, ..., 10)
   echo "This is array task $SLURM_ARRAY_TASK_ID"
   
   # Use the task ID in your computation
   python process.py --task-id $SLURM_ARRAY_TASK_ID

This submits 10 jobs (array tasks) with indices 1 through 10.

Array Job Environment Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 40 60
   :header-rows: 1

   * - Variable
     - Description
   * - ``$SLURM_ARRAY_TASK_ID``
     - Current array task index (e.g., 1, 2, 3, ...)
   * - ``$SLURM_ARRAY_JOB_ID``
     - Job ID of the entire array (same for all tasks)
   * - ``$SLURM_ARRAY_TASK_MIN``
     - Minimum array index
   * - ``$SLURM_ARRAY_TASK_MAX``
     - Maximum array index
   * - ``$SLURM_ARRAY_TASK_COUNT``
     - Total number of array tasks

Use Case 1: Processing Multiple Input Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Process different data files using the array task ID to select the file.

Method 1: Numbered Files
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=process_data
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=1-100
   #SBATCH --output=logs/job_%A_%a.out
   
   # Process file based on array task ID
   # i.e. data/input_1.txt, data/input_2.txt, ...
   INPUT_FILE="data/input_${SLURM_ARRAY_TASK_ID}.txt"
   OUTPUT_FILE="results/output_${SLURM_ARRAY_TASK_ID}.txt"
   
   python analyze.py --input $INPUT_FILE --output $OUTPUT_FILE

Method 2: File List
^^^^^^^^^^^^^^^^^^^

Read filenames from a list and select based on array task ID.

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=file_processing
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=1-50
   #SBATCH --output=logs/job_%A_%a.out
   
   # Get the filename from a list
   FILE_LIST="file_list.txt"
   INPUT_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILE_LIST)
   
   # Process the file
   echo "Processing: $INPUT_FILE"
   python process.py $INPUT_FILE

**Example file_list.txt:**

.. code-block:: text

   /path/to/dataset1.dat
   /path/to/dataset2.dat
   /path/to/dataset3.dat
   ...

Use Case 2: Parameter Sweeps
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Run simulations or analyses with different parameter values.

Simple Parameter Mapping
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=param_sweep
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=0-99
   #SBATCH --output=logs/param_%A_%a.out
   
   # Map array task ID to parameter values
   # Example: sweep learning rate from 0.001 to 0.1
   LEARNING_RATE=$(awk "BEGIN {print 0.001 + $SLURM_ARRAY_TASK_ID * 0.001}")
   
   echo "Running with learning rate: $LEARNING_RATE"
   python train_model.py --lr $LEARNING_RATE

Multi-Dimensional Parameter Grid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sweep multiple parameters simultaneously.

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=grid_search
   #SBATCH --account=exampleproj
   #SBATCH --partition=gpu
   #SBATCH --gpus-per-task=1
   #SBATCH --array=0-99
   #SBATCH --output=logs/grid_%A_%a.out
   
   # Define parameter grid
   # 10 learning rates × 10 batch sizes = 100 combinations
   LR_VALUES=(0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1.0)
   BATCH_VALUES=(16 32 64 128 256 512 1024 2048 4096 8192)
   
   # Calculate indices
   LR_IDX=$((SLURM_ARRAY_TASK_ID / 10))
   BATCH_IDX=$((SLURM_ARRAY_TASK_ID % 10))
   
   # Get parameter values
   LR=${LR_VALUES[$LR_IDX]}
   BATCH=${BATCH_VALUES[$BATCH_IDX]}
   
   echo "Learning Rate: $LR, Batch Size: $BATCH"
   python train.py --lr $LR --batch-size $BATCH

Using Parameter File
^^^^^^^^^^^^^^^^^^^^

Read parameter combinations from a file.

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=param_file
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=1-100
   #SBATCH --output=logs/param_%A_%a.out
   
   # Read parameters from file (one combination per line)
   PARAMS=$(sed -n "${SLURM_ARRAY_TASK_ID}p" parameters.txt)
   
   # Parse parameters (assuming space-separated)
   read -r ALPHA BETA GAMMA <<< "$PARAMS"
   
   echo "Running with α=$ALPHA, β=$BETA, γ=$GAMMA"
   ./simulation --alpha $ALPHA --beta $BETA --gamma $GAMMA

**Example parameters.txt:**

.. code-block:: text

   0.1 0.5 1.0
   0.1 0.5 2.0
   0.1 1.0 1.0
   0.2 0.5 1.0
   ...

Use Case 3: Processing Folders
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Process data in different directories.

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=folder_processing
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --array=1-20
   #SBATCH --output=logs/folder_%A_%a.out
   
   # Define folder pattern
   FOLDER_PREFIX="/data/experiment"
   FOLDER="${FOLDER_PREFIX}_${SLURM_ARRAY_TASK_ID}"
   
   # Check if folder exists
   if [ -d "$FOLDER" ]; then
       echo "Processing folder: $FOLDER"
       cd $FOLDER
       python ../analysis.py
   else
       echo "Warning: Folder $FOLDER does not exist"
       exit 1
   fi

Array Job Array Specifications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Different ways to specify array indices:

.. code-block:: bash

   # Range: tasks 1, 2, 3, ..., 100
   #SBATCH --array=1-100
   
   # Range with step: tasks 0, 10, 20, ..., 100
   #SBATCH --array=0-100:10
   
   # Specific values: tasks 1, 5, 10, 15
   #SBATCH --array=1,5,10,15
   
   # Mixed: tasks 1, 2, 3, 4, 5, 10, 20, 30
   #SBATCH --array=1-5,10,20,30
   
   # Limit concurrent tasks: max 10 running at once
   #SBATCH --array=1-1000%10

.. tip::
   Use ``%`` to limit concurrent array tasks. This prevents overwhelming the system with too many simultaneous jobs while still allowing all tasks to queue.

Managing Array Jobs
~~~~~~~~~~~~~~~~~~~

Monitoring Array Jobs
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # View all array tasks
   squeue -u $USER
   
   # View specific array job
   squeue -j 12345
   
   # Count running/pending tasks
   squeue -u $USER --array -t RUNNING | wc -l
   squeue -u $USER --array -t PENDING | wc -l

Canceling Array Tasks
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Cancel entire array job
   scancel 12345
   
   # Cancel specific array task
   scancel 12345_5
   
   # Cancel range of array tasks
   scancel 12345_[10-20]
   
   # Cancel all array tasks with specific job name
   scancel --name=array_job

Output File Naming
^^^^^^^^^^^^^^^^^^

Use special placeholders in output filenames:

.. code-block:: bash

   # %A = array job ID (same for all tasks)
   # %a = array task ID (unique for each task)
   #SBATCH --output=results_%A_%a.out
   #SBATCH --error=errors_%A_%a.err
   
   # Organize outputs in subdirectories
   #SBATCH --output=logs/task_%a/output.log
   #SBATCH --error=logs/task_%a/error.log

Best Practices
~~~~~~~~~~~~~~

**Array Job Design**

- Make each array task independent - no dependencies between tasks
- Ensure all tasks have similar resource requirements
- Use ``--array=1-N%M`` to limit concurrent tasks and avoid overwhelming the scheduler
- Test with a small array (e.g., ``--array=1-3``) before scaling up

**Resource Management**

- Request resources per task, not for the entire array
- Consider task runtime - all tasks should finish in similar time
- Use appropriate concurrency limits based on cluster policy

**Data Management**

- Use unique output filenames with ``%A_%a`` to avoid conflicts
- Create output directories before submitting if needed
- Consider using task-specific working directories
- Clean up intermediate files from completed tasks

**Error Handling**

- Include error checking in your script
- Log which parameter combination or file each task processes
- Failed tasks can be identified and resubmitted individually
- Use ``set -e`` to exit on errors

**Debugging**

- Test with ``--array=1`` or ``--array=1-3`` first
- Check one output file to verify correctness
- Use explicit echo statements to log task ID and parameters
- Verify file/parameter selection logic works correctly

Advanced Techniques
~~~~~~~~~~~~~~~~~~~

Dynamic Array Size from File Count
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Count files and create array job
   NUM_FILES=$(ls data/*.txt | wc -l)
   sbatch --array=1-$NUM_FILES process_files.sh

Resubmitting Failed Tasks
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Find failed tasks from sacct
   sacct -j 12345 --format=JobID,State | grep FAILED | awk '{print $1}' > failed_tasks.txt
   
   # Create array specification from failed tasks
   FAILED_ARRAY=$(cat failed_tasks.txt | sed 's/12345_//' | tr '\n' ',' | sed 's/,$//')
   
   # Resubmit only failed tasks
   sbatch --array=$FAILED_ARRAY rerun_job.sh

Root Cause
----------

Array jobs solve the problem of submitting and managing large numbers of similar tasks:

**Without Array Jobs:**
- Need to write loops to submit hundreds of individual jobs
- Job IDs are unrelated, making management difficult  
- Output files need manual naming conventions
- Monitoring and canceling groups of related jobs is tedious

**With Array Jobs:**
- Single submission for all related tasks
- Automatic task indexing with ``$SLURM_ARRAY_TASK_ID``
- Unified job ID for the entire array
- Easy monitoring and cancellation of task groups
- Built-in output file naming with ``%A_%a``
- Scheduler can optimize resource allocation for task groups

References
----------

**Related Articles**

- :doc:`slurm-how-to-submit-and-run-batch-jobs-G75o-i` - Basic batch job submission
- :doc:`slurm-how-to-request-interactive-sessi-HV7WS9` - Interactive testing before array submission

**SLURM Documentation**

- `SLURM Job Arrays <https://slurm.schedmd.com/job_array.html>`_
- `SLURM sbatch Command <https://slurm.schedmd.com/sbatch.html>`_
- `SLURM Environment Variables <https://slurm.schedmd.com/sbatch.html#SECTION_OUTPUT-ENVIRONMENT-VARIABLES>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-12-04
      | Issued by: kftse@ust.hk
