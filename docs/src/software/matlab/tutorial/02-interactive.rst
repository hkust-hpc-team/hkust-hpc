Interactive MATLAB Development on SLURM
========================================

Use Slurm's ``srun`` command to request interactive compute nodes for testing and 
debugging MATLAB code with dedicated resources.

When to Use Interactive Sessions
---------------------------------

Interactive sessions are ideal for:

✅ **Testing** - Verify scripts work correctly before batch submission
✅ **Debugging** - Troubleshoot errors with full compute resources
✅ **Parameter tuning** - Experiment with different settings
✅ **Moderate computations** - Run analyses that take minutes to hours
✅ **Interactive exploration** - Explore data interactively with adequate resources

**Not ideal for:**

- Very long jobs (> 4-8 hours) - use :doc:`batch` instead
- Fully debugged production workflows - use :doc:`batch` instead

Prerequisites
-------------

You need:

- An active Slurm account
- Spack environment activation
- Your MATLAB scripts ready to test

Requesting an Interactive Session
----------------------------------

Use ``srun`` to request an interactive compute node:

AMD CPU Node
~~~~~~~~~~~~

Best for large parallel jobs (up to 256 cores):

.. code-block:: bash

   srun --account=exampleproj \
        --partition=amd \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=16 \
        --mem=32G \
        --time=4:00:00 \
        --pty bash

Intel CPU Node
~~~~~~~~~~~~~~

Good for general computing (up to 128 cores):

.. code-block:: bash

   srun --account=exampleproj \
        --partition=intel \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=16 \
        --mem=32G \
        --time=4:00:00 \
        --pty bash

GPU Node
~~~~~~~~

For GPU-accelerated workloads:

.. code-block:: bash

   srun --account=exampleproj \
        --partition=gpu-a30 \
        --nodes=1 \
        --gpus-per-node=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=16 \
        --mem=32G \
        --time=4:00:00 \
        --pty bash

.. note::
   Replace ``exampleproj`` with your actual Slurm account name.

Resource Guidelines
~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 25 25 25 25

   * - Task Type
     - CPUs
     - Memory
     - Time
   * - Small tests
     - 4-8
     - 8-16 GB
     - 1-2 hours
   * - Medium analysis
     - 16-32
     - 32-64 GB
     - 2-4 hours
   * - Large debugging
     - 32-64
     - 64-128 GB
     - 4-8 hours

Running MATLAB Interactively
-----------------------------

Once your interactive session starts, you'll be on a compute node.

Setup Environment
~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Activate Spack (on the compute node)
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load MATLAB module
   module load matlab/R2023b
   
   # Verify MATLAB is available
   which matlab
   matlab --version

Running MATLAB Scripts
~~~~~~~~~~~~~~~~~~~~~~

Execute your scripts in batch mode:

.. code-block:: bash

   # Run a single script
   matlab -batch "my_script.m"
   
   # Run script with command
   matlab -batch "disp('Hello from compute node!')"
   
   # Run and save output
   matlab -batch "my_script.m" > output.log 2>&1

Example Test Scripts
~~~~~~~~~~~~~~~~~~~~

**test_math.m** - Test mathematical operations:

.. code-block:: matlab

   % Mathematical computation test
   disp('Testing MATLAB mathematical capabilities...')
   
   % Create matrices
   A = rand(100, 100);
   B = rand(100, 100);
   
   % Matrix multiplication
   C = A * B;
   
   % Eigenvalues
   eigenvalues = eig(C);
   
   % Display results
   fprintf('Matrix size: %dx%d\n', size(C));
   fprintf('Max eigenvalue: %.4f\n', max(abs(eigenvalues)));
   fprintf('Min eigenvalue: %.4f\n', min(abs(eigenvalues)));
   
   disp('✓ Mathematical computation successful')

**test_computation.m** - Test computational performance:

.. code-block:: matlab

   % Performance test
   fprintf('MATLAB version: %s\n', version);
   fprintf('Running on: %s\n', getenv('HOSTNAME'));
   
   % Run computation
   n = 2000;
   fprintf('Computing %dx%d matrix multiplication...\n', n, n);
   
   A = rand(n, n);
   B = rand(n, n);
   
   tic;
   C = A * B;
   elapsed = toc;
   
   fprintf('Computation completed in %.2f seconds\n', elapsed);
   fprintf('Performance: %.2f GFLOPS\n', (2*n^3 / elapsed) / 1e9);

Run the tests:

.. code-block:: bash

   matlab -batch "test_math.m"
   matlab -batch "test_computation.m"

Typical Interactive Workflow
-----------------------------

Complete Example Session
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Step 1: Request interactive node
   srun --account=exampleproj \
        --partition=amd \
        --cpus-per-task=16 \
        --mem=32G \
        --time=2:00:00 \
        --pty bash
   
   # Step 2: Setup environment (now on compute node)
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   
   # Step 3: Run your scripts
   matlab -batch "test_script.m"
   
   # Step 4: Check results
   ls -lh *.mat
   
   # Step 5: Debug if needed
   matlab -batch "debug_version.m"
   
   # Step 6: Exit when done
   exit

Iterative Development
~~~~~~~~~~~~~~~~~~~~~

You can edit scripts on the login node and test on the compute node:

**Terminal 1 (Login Node):**

.. code-block:: bash

   # Edit your script
   nano my_analysis.m
   # Save changes

**Terminal 2 (Compute Node via srun):**

.. code-block:: bash

   # Test the updated script
   matlab -batch "my_analysis.m"
   
   # Check output
   cat results.log

Repeat until your script works correctly.

Working with Data Files
------------------------

Loading Data
~~~~~~~~~~~~

.. code-block:: matlab

   % load_and_process.m
   disp('Loading data...');
   
   % Load data file
   load('input_data.mat');
   
   % Process data
   results = analyze_data(data);
   
   % Save results
   save('results.mat', 'results');
   disp('Results saved');

Run on compute node:

.. code-block:: bash

   # Ensure data file is accessible
   ls -lh input_data.mat
   
   # Run analysis
   matlab -batch "load_and_process.m"
   
   # Check output
   ls -lh results.mat

Handling Large Files
~~~~~~~~~~~~~~~~~~~~

For large datasets, use the scratch filesystem:

.. code-block:: bash

   # Copy data to scratch (faster I/O)
   cp /home/username/data/large_dataset.mat /scratch/username/
   
   # Run MATLAB with scratch data
   cd /scratch/username
   matlab -batch "analysis_script.m"
   
   # Copy results back
   cp results.mat /home/username/output/

Testing Parallel Code
----------------------

Test parallel pool creation:

**test_parallel.m:**

.. code-block:: matlab

   % Test parallel computing
   disp('Testing parallel pool...');
   
   % Get allocated CPUs
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   fprintf('Allocated CPUs: %d\n', num_cpus);
   
   % Create small pool for testing
   pool_size = min(8, num_cpus);
   fprintf('Creating pool with %d workers...\n', pool_size);
   
   pool = parpool('local', pool_size);
   fprintf('Pool created: %d workers active\n', pool.NumWorkers);
   
   % Simple parallel test
   n = 50;
   results = zeros(1, n);
   
   tic;
   parfor i = 1:n
       results(i) = sum(rand(500, 500), 'all');
   end
   elapsed = toc;
   
   fprintf('Parallel test completed in %.2f seconds\n', elapsed);
   
   % Cleanup
   delete(pool);
   disp('✓ Parallel computing test successful');

Request session with multiple CPUs:

.. code-block:: bash

   srun --account=exampleproj \
        --partition=amd \
        --cpus-per-task=16 \
        --mem=32G \
        --time=1:00:00 \
        --pty bash
   
   # On compute node
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "test_parallel.m"

See :doc:`parallel` for detailed parallel computing guide.

Monitoring Resource Usage
--------------------------

Check CPU and Memory
~~~~~~~~~~~~~~~~~~~~

While MATLAB is running, open another terminal and SSH to the same compute node:

.. code-block:: bash

   # Find your running job
   squeue -u $USER
   
   # Note the node name (e.g., compute-amd-01)
   ssh compute-amd-01
   
   # Check resource usage
   top -u $USER
   htop -u $USER  # If available

View Job Statistics
~~~~~~~~~~~~~~~~~~~

After your interactive session or script completes:

.. code-block:: bash

   # Check efficiency (after job ends)
   seff <job_id>

This shows:

- CPU efficiency
- Memory usage vs. requested
- Actual runtime vs. requested

Debugging Common Issues
-----------------------

Script Errors
~~~~~~~~~~~~~

If your script has errors, MATLAB will show them in the output:

.. code-block:: bash

   # Run script and capture all output
   matlab -batch "my_script.m" 2>&1 | tee output.log
   
   # Review errors
   cat output.log

Add error handling in your scripts:

.. code-block:: matlab

   % my_script.m
   try
       % Your code here
       result = risky_computation(data);
   catch ME
       fprintf('Error: %s\n', ME.message);
       fprintf('In file: %s\n', ME.stack(1).file);
       fprintf('At line: %d\n', ME.stack(1).line);
       exit(1);  % Exit with error code
   end

Out of Memory
~~~~~~~~~~~~~

If MATLAB runs out of memory:

.. code-block:: bash

   # Request more memory
   exit  # Exit current session
   
   srun --account=exampleproj \
        --partition=amd \
        --cpus-per-task=16 \
        --mem=128G \  # Increased memory
        --time=2:00:00 \
        --pty bash

Or optimize your MATLAB code to use less memory.

Slow Performance
~~~~~~~~~~~~~~~~

Check if your code is actually using the allocated CPUs:

.. code-block:: matlab

   % Check max threads
   maxNumCompThreads
   
   % For parallel code, verify pool size
   pool = gcp('nocreate');
   if ~isempty(pool)
       fprintf('Pool size: %d\n', pool.NumWorkers);
   end

Session Timeout
~~~~~~~~~~~~~~~

If your interactive session is about to time out:

.. code-block:: bash

   # Check remaining time
   squeue -u $USER
   
   # Save your work before timeout
   # Consider using batch jobs for longer runs

Best Practices
--------------

Efficient Interactive Development
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Start small** - Test with subset of data first
2. **Iterate quickly** - Fix errors and re-run immediately
3. **Save frequently** - Save intermediate results
4. **Monitor resources** - Check if you're using allocated resources efficiently
5. **Clean up** - Delete temporary files before exiting

Resource Management
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Request only what you need
   --cpus-per-task=8   # Not 256 if you don't use them
   --mem=16G           # Not 512G if you don't need it
   --time=2:00:00      # Not 24:00:00 for a 30-minute job

Code Organization
~~~~~~~~~~~~~~~~~

Keep your code modular:

.. code-block:: matlab

   % main_analysis.m
   % Main script - calls smaller functions
   
   data = load_data('input.mat');
   processed = preprocess(data);
   results = analyze(processed);
   save_results(results, 'output.mat');

This makes debugging easier - test each function separately.

Transitioning to Batch Jobs
----------------------------

Once your code works in interactive mode, submit it as a batch job:

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --partition=amd
   #SBATCH --cpus-per-task=16
   #SBATCH --mem=32G
   #SBATCH --time=08:00:00
   #SBATCH --output=matlab-%j.out
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "my_analysis.m"

See :doc:`batch` for detailed batch job information.

Next Steps
----------

- :doc:`batch` - Submit production batch jobs
- :doc:`parallel` - Use Parallel Computing Toolbox
- :doc:`gpu` - GPU-accelerated computing
- :doc:`index` - MATLAB overview

See Also
--------

- `MATLAB Batch Processing <https://www.mathworks.com/help/matlab/batch-processing.html>`_
- Slurm ``srun`` documentation
- HPC4 partition information
