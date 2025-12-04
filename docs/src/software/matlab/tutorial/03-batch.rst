Running MATLAB Batch Jobs
==========================

Submit long-running MATLAB computations as Slurm batch jobs for unattended execution 
with dedicated resources.

When to Use Batch Jobs
-----------------------

Batch jobs are ideal for:

- ✅ **Production workflows** - Reproducible, automated analyses
- ✅ **Long computations** - Jobs taking hours to days
- ✅ **Unattended execution** - Run overnight or over weekends
- ✅ **Resource-intensive tasks** - Large datasets, complex simulations
- ✅ **Parameteric studies** - Multiple similar jobs with different parameters

Prerequisites
-------------

- MATLAB scripts ready to run
- Estimated runtime and resource requirements
- Slurm account and partition access

Basic Batch Job Structure
--------------------------

All MATLAB batch jobs follow this pattern:

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj        # Your Slurm account
   #SBATCH --partition=amd               # Partition to use
   #SBATCH --job-name=matlab-job         # Job name
   #SBATCH --nodes=1                     # Number of nodes
   #SBATCH --ntasks-per-node=1           # Tasks per node
   #SBATCH --cpus-per-task=16            # CPUs per task
   #SBATCH --time=08:00:00               # Max runtime (HH:MM:SS)
   #SBATCH --output=matlab-%j.out        # Output file (%j = job ID)
   
   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load MATLAB module
   module load matlab/R2023b
   
   # Run MATLAB script
   matlab -batch "my_script"

Single-Node Computational Job
------------------------------

Example: Matrix Analysis
~~~~~~~~~~~~~~~~~~~~~~~~

**analysis.m** - Your MATLAB script:

.. code-block:: matlab

   % Production analysis script
   fprintf('Starting analysis at %s\n', datestr(now));
   
   % Load data
   load('input_data.mat');
   
   % Perform computation
   n = 5000;
   A = rand(n, n);
   B = rand(n, n);
   
   fprintf('Computing matrix multiplication...\n');
   tic;
   C = A * B;
   elapsed = toc;
   
   fprintf('Computation completed in %.2f seconds\n', elapsed);
   fprintf('Result matrix size: %dx%d\n', size(C));
   
   % Save results
   save('results.mat', 'C');
   fprintf('Results saved at %s\n', datestr(now));
   disp('Analysis complete');

**run_analysis.sh** - Slurm batch script:

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=matlab-analysis
   #SBATCH --partition=amd
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --cpus-per-task=32
   #SBATCH --mem=64G
   #SBATCH --time=08:00:00
   #SBATCH --output=analysis-%j.out
   #SBATCH --error=analysis-%j.err
   
   echo "Job started at: $(date)"
   echo "Running on node: $(hostname)"
   echo "Job ID: $SLURM_JOB_ID"
   
   # Activate Spack
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load MATLAB
   module load matlab/R2023b
   
   # Run analysis
   matlab -batch "analysis.m"
   
   echo "Job finished at: $(date)"

Submit the job:

.. code-block:: bash

   sbatch run_analysis.sh

Parallel Computing Job
----------------------

For jobs using multiple CPU cores with ``parfor``.

**parallel_simulation.m** - Script using parallel pool:

.. code-block:: matlab

   % Parallel simulation
   fprintf('MATLAB version: %s\n', version);
   fprintf('Job started at: %s\n', datestr(now));
   
   % Get allocated CPUs from Slurm
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   fprintf('Allocated CPUs: %d\n', num_cpus);
   
   % Create parallel pool
   fprintf('Creating parallel pool...\n');
   pool = parpool('local', num_cpus);
   fprintf('Pool created with %d workers\n', pool.NumWorkers);
   
   % Parallel computation
   n = 1000;
   data = rand(n, 1000);
   results = zeros(n, 1);
   
   fprintf('Starting parallel computation...\n');
   tic;
   parfor i = 1:n
       % Process each iteration independently
       row = data(i, :);
       results(i) = mean(row) * std(row) + max(row);
   end
   elapsed = toc;
   
   fprintf('Parallel computation completed in %.2f seconds\n', elapsed);
   fprintf('Mean result: %.6f\n', mean(results));
   fprintf('Std result: %.6f\n', std(results));
   
   % Save results
   save('parallel_results.mat', 'results', 'elapsed');
   fprintf('Results saved\n');
   
   % Cleanup
   delete(pool);
   fprintf('Job completed at: %s\n', datestr(now));

**run_parallel.sh** - Batch script with multiple CPUs:

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=matlab-parallel
   #SBATCH --partition=amd
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --cpus-per-task=64          # More CPUs for parallel pool
   #SBATCH --mem=128G
   #SBATCH --time=12:00:00
   #SBATCH --output=parallel-%j.out
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "parallel_simulation.m"

See :doc:`parallel` for detailed information on parallel computing.

Array Jobs for Parameter Sweeps
--------------------------------

Run multiple similar jobs with different parameters using Slurm job arrays.

**sweep_analysis.m** - Parameterized script:

.. code-block:: matlab

   % Parameter sweep analysis
   % Read parameter from environment variable
   task_id = str2num(getenv('SLURM_ARRAY_TASK_ID'));
   
   % Define parameter values
   parameters = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0];
   param = parameters(task_id);
   
   fprintf('Running analysis with parameter = %.2f\n', param);
   
   % Run computation with this parameter
   results = run_simulation(param);
   
   % Save results with unique filename
   filename = sprintf('results_param_%.2f.mat', param);
   save(filename, 'results', 'param');
   
   fprintf('Task %d complete\n', task_id);

**run_sweep.sh** - Array job script:

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=matlab-sweep
   #SBATCH --partition=amd
   #SBATCH --array=1-6                  # Run 6 jobs (one per parameter)
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --cpus-per-task=16
   #SBATCH --mem=32G
   #SBATCH --time=04:00:00
   #SBATCH --output=sweep-%A-%a.out     # %A = array job ID, %a = task ID
   
   echo "Array Job ID: $SLURM_ARRAY_JOB_ID"
   echo "Task ID: $SLURM_ARRAY_TASK_ID"
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "sweep_analysis.m"

This submits 6 independent jobs, each with a different parameter value.

Managing Output Files
----------------------

Output Logging
~~~~~~~~~~~~~~

Control where job output goes:

.. code-block:: bash

   #SBATCH --output=logs/job-%j.out     # Standard output
   #SBATCH --error=logs/job-%j.err      # Standard error (separate file)
   
   # Or combine both:
   #SBATCH --output=logs/job-%j.log     # Combined output

Create logs directory before submission:

.. code-block:: bash

   mkdir -p logs
   sbatch run_analysis.sh

MATLAB Output
~~~~~~~~~~~~~

Redirect MATLAB output within the script:

.. code-block:: matlab

   % Open log file
   diary(sprintf('matlab_log_%s.txt', datestr(now, 'yyyymmdd_HHMMSS')));
   diary on;
   
   % Your code here
   disp('Analysis running...');
   
   % Close log
   diary off;

Saving Results
~~~~~~~~~~~~~~

Organize output files:

.. code-block:: matlab

   % Create output directory
   output_dir = 'results';
   if ~exist(output_dir, 'dir')
       mkdir(output_dir);
   end
   
   % Save with timestamp
   timestamp = datestr(now, 'yyyymmdd_HHMMSS');
   filename = fullfile(output_dir, sprintf('results_%s.mat', timestamp));
   save(filename, 'results');

Job Submission and Management
------------------------------

Submitting Jobs
~~~~~~~~~~~~~~~

.. code-block:: bash

   # Submit a single job
   sbatch run_analysis.sh
   
   # Submit with different parameters
   sbatch --cpus-per-task=32 --mem=128G run_analysis.sh
   
   # Submit array job
   sbatch run_sweep.sh

Checking Job Status
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # View your jobs
   squeue -u $USER
   
   # Detailed job info
   scontrol show job <job_id>
   
   # View job accounting
   sacct -j <job_id> --format=JobID,JobName,State,Elapsed,MaxRSS,CPUTime

Monitoring Running Jobs
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Watch job queue (updates every 2 seconds)
   watch -n 2 squeue -u $USER
   
   # View real-time output
   tail -f matlab-<job_id>.out
   
   # Check specific job details
   sstat -j <job_id> --format=JobID,MaxRSS,AveCPU

Canceling Jobs
~~~~~~~~~~~~~~

.. code-block:: bash

   # Cancel specific job
   scancel <job_id>
   
   # Cancel all your jobs
   scancel -u $USER
   
   # Cancel jobs by name
   scancel --name=matlab-analysis

Job Efficiency
~~~~~~~~~~~~~~

After job completes, check how efficiently resources were used:

.. code-block:: bash

   # View efficiency statistics
   seff <job_id>

This shows:

- CPU efficiency (should be high for compute-intensive jobs)
- Memory efficiency (how much requested memory was actually used)
- Runtime vs. time limit

Optimizing Resource Requests
-----------------------------

CPU Allocation
~~~~~~~~~~~~~~

.. code-block:: bash

   # Single-threaded MATLAB
   #SBATCH --cpus-per-task=1
   
   # MATLAB with implicit multithreading (BLAS, etc.)
   #SBATCH --cpus-per-task=8
   
   # Parallel Computing Toolbox with parfor
   #SBATCH --cpus-per-task=32

Memory Allocation
~~~~~~~~~~~~~~~~~

Rules of thumb:

- Start with 2-4 GB per CPU for general computing
- Increase if handling large datasets
- Monitor actual usage with ``seff`` and adjust

.. code-block:: bash

   # Light computation
   #SBATCH --mem=16G
   
   # Moderate data processing
   #SBATCH --mem=64G
   
   # Large datasets
   #SBATCH --mem=256G

Time Limits
~~~~~~~~~~~

.. code-block:: bash

   # Test runs
   #SBATCH --time=01:00:00    # 1 hour
   
   # Standard jobs
   #SBATCH --time=12:00:00    # 12 hours
   
   # Long simulations
   #SBATCH --time=3-00:00:00  # 3 days

Add 20-30% buffer to your estimated time.

Job Dependencies
----------------

Run jobs in sequence:

.. code-block:: bash

   # Submit first job
   job1=$(sbatch --parsable preprocessing.sh)
   
   # Submit second job that depends on first
   job2=$(sbatch --dependency=afterok:$job1 analysis.sh)
   
   # Submit third job that depends on second
   sbatch --dependency=afterok:$job2 postprocessing.sh

Checkpointing for Long Jobs
----------------------------

For very long jobs, implement checkpointing to save progress:

**simulation_with_checkpoint.m:**

.. code-block:: matlab

   % Simulation with checkpointing
   checkpoint_file = 'checkpoint.mat';
   
   % Check if checkpoint exists
   if exist(checkpoint_file, 'file')
       fprintf('Loading checkpoint...\n');
       load(checkpoint_file);
       start_iteration = iteration + 1;
   else
       % Initialize
       start_iteration = 1;
       results = [];
   end
   
   % Run simulation
   for iteration = start_iteration:1000
       % Do computation
       result = compute_iteration(iteration);
       results = [results; result];
       
       % Save checkpoint every 100 iterations
       if mod(iteration, 100) == 0
           save(checkpoint_file, 'iteration', 'results');
           fprintf('Checkpoint saved at iteration %d\n', iteration);
       end
   end
   
   % Save final results
   save('final_results.mat', 'results');
   delete(checkpoint_file);  % Clean up checkpoint

Best Practices
--------------

Script Design
~~~~~~~~~~~~~

1. **Make scripts self-contained:**

   .. code-block:: matlab
   
      % Include all necessary setup in the script
      addpath('/path/to/functions');
      
      % Load dependencies
      % Run computation
      % Save results

2. **Add informative logging:**

   .. code-block:: matlab
   
      fprintf('=== Analysis Started ===\n');
      fprintf('Timestamp: %s\n', datestr(now));
      fprintf('MATLAB version: %s\n', version);
      fprintf('Hostname: %s\n', getenv('HOSTNAME'));

3. **Handle errors gracefully:**

   .. code-block:: matlab
   
      try
           results = main_computation();
           save('results.mat', 'results');
       catch ME
           fprintf('ERROR: %s\n', ME.message);
           save('error_state.mat', 'ME');
           exit(1);  % Exit with error code
       end

Job Organization
~~~~~~~~~~~~~~~~

.. code-block:: text

   project/
   ├── scripts/
   │   ├── analysis.m
   │   ├── preprocessing.m
   │   └── postprocessing.m
   ├── slurm/
   │   ├── run_analysis.sh
   │   ├── run_preprocessing.sh
   │   └── run_postprocessing.sh
   ├── logs/
   │   └── (job output files)
   └── results/
       └── (analysis output)

Testing Before Production
~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Test with small data interactively (see :doc:`interactive`)
2. Submit short test job with subset of data
3. Verify output is correct
4. Submit full production job

Common Issues
-------------

Job Doesn't Start
~~~~~~~~~~~~~~~~~

Check:

.. code-block:: bash

   # View job status and reason
   squeue -u $USER
   
   # Common reasons:
   # - QOSMaxCpuPerUserLimit: Reduce --cpus-per-task
   # - PartitionNodeLimit: Reduce --nodes
   # - ReqNodeNotAvail: Reduce --time or wait

Job Fails Immediately
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Check output file
   cat matlab-<job_id>.out
   
   # Common issues:
   # - Spack not activated
   # - Module not loaded
   # - Script file not found
   # - Syntax errors in script

Out of Memory
~~~~~~~~~~~~~

.. code-block:: bash

   # Check memory usage after job
   seff <job_id>
   
   # If exceeded, increase memory
   #SBATCH --mem=128G  # Instead of 64G

Job Timeout
~~~~~~~~~~~

.. code-block:: bash

   # Check actual runtime
   sacct -j <job_id> --format=JobID,Elapsed,State
   
   # Increase time limit
   #SBATCH --time=24:00:00  # Instead of 12:00:00

Next Steps
----------

- :doc:`parallel` - Detailed parallel computing with Parallel Toolbox
- :doc:`gpu` - GPU-accelerated MATLAB computations
- :doc:`interactive` - Interactive testing before batch submission
- :doc:`index` - MATLAB overview

See Also
--------

- `MATLAB Batch Scripts <https://www.mathworks.com/help/matlab/batch-processing.html>`_
- Slurm sbatch documentation
- :doc:`../index` - HPC4 software overview
