Parallel Computing with MATLAB
===============================

Use MATLAB's Parallel Computing Toolbox to leverage multiple CPU cores for faster computation.

Parallel Computing Toolbox
---------------------------

The Parallel Computing Toolbox provides:

✅ **parfor** - Parallel for-loops for independent iterations
✅ **spmd** - Single Program Multiple Data for distributed arrays
✅ **parfeval** - Asynchronous parallel function execution
✅ **Parallel pools** - Manage worker processes
✅ **GPU computing** - See :doc:`gpu` for GPU-accelerated computing

Check Toolbox Availability
---------------------------

Verify Parallel Computing Toolbox is installed:

.. code-block:: matlab

   % Check if toolbox is available
   license('test', 'Distrib_Computing_Toolbox')
   
   % List all available toolboxes
   ver

Available in all MATLAB versions on HPC4 (R2019b, R2022b, R2023b).

Parallel For-Loops (parfor)
----------------------------

Use ``parfor`` when loop iterations are independent.

Basic parfor Example
~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Serial version
   n = 1000;
   results = zeros(n, 1);
   
   tic;
   for i = 1:n
       results(i) = expensive_computation(i);
   end
   serial_time = toc;
   fprintf('Serial time: %.2f seconds\n', serial_time);
   
   % Parallel version
   results_parallel = zeros(n, 1);
   
   tic;
   parfor i = 1:n
       results_parallel(i) = expensive_computation(i);
   end
   parallel_time = toc;
   fprintf('Parallel time: %.2f seconds\n', parallel_time);
   fprintf('Speedup: %.2fx\n', serial_time / parallel_time);

When to Use parfor
~~~~~~~~~~~~~~~~~~

✅ **Good candidates:**

- Loop iterations are independent
- Each iteration takes significant time (>0.1 seconds)
- Number of iterations >> number of workers
- Minimal data transfer between iterations

❌ **Not suitable for:**

- Iterations depend on each other
- Very fast iterations (overhead dominates)
- Small number of iterations
- Heavy data passing between master and workers

parfor Restrictions
~~~~~~~~~~~~~~~~~~~

Variables in parfor loops must follow specific patterns:

.. code-block:: matlab

   % ✅ GOOD: Independent loop variable
   parfor i = 1:n
       results(i) = process(data(i));
   end
   
   % ❌ BAD: Loop-carried dependency
   parfor i = 2:n
       results(i) = results(i-1) + data(i);  % Error!
   end
   
   % ✅ GOOD: Reduction variable
   total = 0;
   parfor i = 1:n
       total = total + compute(i);  % Allowed reduction
   end
   
   % ❌ BAD: Irregular indexing
   parfor i = 1:n
       results(indices(i)) = process(i);  % Error!
   end

Managing Parallel Pools
------------------------

Creating Pools
~~~~~~~~~~~~~~

.. code-block:: matlab

   % Create default local pool (uses all available cores)
   pool = parpool('local');
   
   % Create pool with specific number of workers
   pool = parpool('local', 16);
   
   % Get number of CPUs from Slurm environment
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   pool = parpool('local', num_cpus);

Pool Information
~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Get current pool
   pool = gcp('nocreate');
   
   if ~isempty(pool)
       fprintf('Pool has %d workers\n', pool.NumWorkers);
       fprintf('Pool is %s\n', pool.Cluster.Profile);
   else
       fprintf('No pool is running\n');
   end

Closing Pools
~~~~~~~~~~~~~

.. code-block:: matlab

   % Delete current pool
   delete(gcp('nocreate'));
   
   % Or explicitly
   pool = gcp;
   delete(pool);

Pool automatically closes when MATLAB exits.

Interactive Parallel Development
---------------------------------

On HPC4, request CPUs with srun for interactive parallel testing:

.. code-block:: bash

   # Request 32 CPUs on AMD partition
   srun --account=exampleproj --partition=amd \
        --cpus-per-task=32 --mem=64G --time=2:00:00 \
        --pty bash
   
   # Activate Spack and load MATLAB
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   
   # Start MATLAB
   matlab -nodisplay

Then in MATLAB:

.. code-block:: matlab

   % Create parallel pool using allocated CPUs
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   fprintf('Creating pool with %d workers\n', num_cpus);
   pool = parpool('local', num_cpus);
   
   % Test parallel code
   n = 1000;
   results = zeros(n, 1);
   
   parfor i = 1:n
       results(i) = sum(rand(1000, 1000), 'all');
   end
   
   fprintf('Computation complete\n');

See :doc:`interactive` for more interactive development patterns.

Batch Parallel Jobs
--------------------

Production parallel jobs should use Slurm batch scripts.

Example Script
~~~~~~~~~~~~~~

**parallel_analysis.m:**

.. code-block:: matlab

   % Parallel analysis script
   fprintf('Starting parallel analysis at %s\n', datestr(now));
   
   % Get allocated CPUs from Slurm
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   fprintf('Allocated CPUs: %d\n', num_cpus);
   
   % Create parallel pool
   fprintf('Creating parallel pool...\n');
   pool = parpool('local', num_cpus);
   fprintf('Pool created with %d workers\n', pool.NumWorkers);
   
   % Load data
   fprintf('Loading data...\n');
   load('input_data.mat');
   
   % Parallel computation
   n = size(data, 1);
   results = zeros(n, 1);
   
   fprintf('Processing %d items in parallel...\n', n);
   tic;
   parfor i = 1:n
       results(i) = analyze_item(data(i, :));
   end
   elapsed = toc;
   
   fprintf('Analysis completed in %.2f seconds\n', elapsed);
   fprintf('Throughput: %.2f items/second\n', n/elapsed);
   
   % Save results
   save('parallel_results.mat', 'results', 'elapsed');
   fprintf('Results saved\n');
   
   % Cleanup
   delete(pool);
   fprintf('Job completed at %s\n', datestr(now));

**run_parallel.sh:**

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=matlab-parallel
   #SBATCH --partition=amd
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --cpus-per-task=64
   #SBATCH --mem=128G
   #SBATCH --time=12:00:00
   #SBATCH --output=parallel-%j.out
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "parallel_analysis.m"

Submit with:

.. code-block:: bash

   sbatch run_parallel.sh

See :doc:`batch` for detailed batch job information.

Advanced Parallel Patterns
---------------------------

Parallel Data Processing Pipeline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Process large datasets in parallel:

.. code-block:: matlab

   % Process files in parallel
   files = dir('data/*.mat');
   num_files = length(files);
   
   parfor i = 1:num_files
       % Load file
       data = load(fullfile(files(i).folder, files(i).name));
       
       % Process
       result = process_data(data);
       
       % Save result
       output_file = sprintf('results/result_%03d.mat', i);
       parsave(output_file, result);
   end
   
   function parsave(filename, result)
       % Helper function for saving in parfor
       save(filename, 'result');
   end

Nested Parallel Loops
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Outer parallel loop over datasets
   num_datasets = 10;
   
   parfor d = 1:num_datasets
       fprintf('Processing dataset %d\n', d);
       data = load_dataset(d);
       
       % Inner serial loop (only outer loop is parallel)
       n = size(data, 1);
       results = zeros(n, 1);
       for i = 1:n
           results(i) = process(data(i, :));
       end
       
       save(sprintf('dataset_%d_results.mat', d), 'results');
   end

Parallel Function Evaluation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use ``parfeval`` for asynchronous execution:

.. code-block:: matlab

   % Start parallel pool
   pool = parpool('local', 8);
   
   % Submit multiple tasks asynchronously
   futures = cell(100, 1);
   for i = 1:100
       futures{i} = parfeval(pool, @expensive_function, 1, i);
   end
   
   % Collect results as they complete
   results = cell(100, 1);
   for i = 1:100
       [idx, value] = fetchNext(futures);
       results{idx} = value;
       fprintf('Task %d completed\n', idx);
   end

SPMD (Single Program Multiple Data)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For explicit parallel programming with distributed arrays:

.. code-block:: matlab

   % Create parallel pool
   pool = parpool('local', 4);
   
   spmd
       % Each worker executes this block
       worker_id = labindex;  % Worker number (1 to 4)
       num_workers = numlabs;  % Total workers
       
       fprintf('Worker %d of %d\n', worker_id, num_workers);
       
       % Each worker processes its portion of data
       local_n = 1000;
       local_data = rand(local_n, 100);
       local_result = sum(local_data, 2);
       
       % Results stay on workers (distributed)
   end
   
   % Access distributed results
   all_results = [local_result{:}];  % Gather to client

Performance Optimization
------------------------

Minimizing Data Transfer
~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % ❌ BAD: Large data copying
   big_matrix = rand(10000, 10000);
   parfor i = 1:100
       result(i) = sum(big_matrix(:, i));  % Copies big_matrix to each worker
   end
   
   % ✅ GOOD: Pre-send data to workers
   big_matrix = rand(10000, 10000);
   parfor i = 1:100
       % Only column i is sent
       col = big_matrix(:, i);
       result(i) = sum(col);
   end

Slicing Arrays
~~~~~~~~~~~~~~

.. code-block:: matlab

   % ✅ GOOD: Sliced array (each worker gets a slice)
   data = rand(1000, 1000);
   results = zeros(1000, 1);
   
   parfor i = 1:1000
       results(i) = mean(data(i, :));  % Row i sliced to worker
   end
   
   % ❌ BAD: Non-sliced irregular access
   parfor i = 1:1000
       indices = get_indices(i);
       results(i) = mean(data(indices, :));  % Cannot slice
   end

Broadcast Variables
~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Constant data automatically broadcast once
   lookup_table = load('lookup.mat');
   
   parfor i = 1:n
       % lookup_table sent once to each worker
       result(i) = process(data(i), lookup_table);
   end

Measuring Speedup
~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Benchmark function
   function speedup = benchmark_parallel(computation, n_workers_list)
       % Serial baseline
       tic;
       result_serial = computation('serial');
       serial_time = toc;
       
       fprintf('Serial time: %.2f seconds\n', serial_time);
       
       speedup = zeros(length(n_workers_list), 1);
       
       for i = 1:length(n_workers_list)
           n = n_workers_list(i);
           pool = parpool('local', n);
           
           tic;
           result_parallel = computation('parallel');
           parallel_time = toc;
           
           delete(pool);
           
           speedup(i) = serial_time / parallel_time;
           efficiency = speedup(i) / n * 100;
           
           fprintf('%d workers: %.2f seconds, speedup: %.2fx, efficiency: %.1f%%\n', ...
                   n, parallel_time, speedup(i), efficiency);
       end
   end

Debugging Parallel Code
------------------------

Common Issues
~~~~~~~~~~~~~

**Race Conditions:**

.. code-block:: matlab

   % ❌ BAD: Race condition
   count = 0;
   parfor i = 1:1000
       if condition(i)
           count = count + 1;  % Unpredictable!
       end
   end
   
   % ✅ GOOD: Use reduction or collect flags
   flags = false(1000, 1);
   parfor i = 1:1000
       flags(i) = condition(i);
   end
   count = sum(flags);

**Variable Classification Errors:**

.. code-block:: matlab

   % ❌ ERROR: Cannot classify variable
   indices = [];
   parfor i = 1:n
       if condition(i)
           indices = [indices i];  % Error!
       end
   end
   
   % ✅ GOOD: Use logical indexing
   keep = false(n, 1);
   parfor i = 1:n
       keep(i) = condition(i);
   end
   indices = find(keep);

Debugging Tips
~~~~~~~~~~~~~~

1. **Test with small data serially first:**

   .. code-block:: matlab
   
      % Test with for loop first
      for i = 1:10  % Small n
          results(i) = my_function(data(i));
      end
      
      % Then switch to parfor
      parfor i = 1:1000
          results(i) = my_function(data(i));
      end

2. **Add diagnostic output:**

   .. code-block:: matlab
   
      parfor i = 1:n
          fprintf('Worker processing item %d\n', i);
          result(i) = process(data(i));
      end

3. **Use parallel profiler:**

   .. code-block:: matlab
   
      % Profile parallel code
      mpiprofile on
      parfor i = 1:n
          results(i) = process(data(i));
      end
      mpiprofile viewer

Resource Guidelines
-------------------

Choosing Number of Workers
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **General rule:** 1 worker per CPU core
- **Memory-limited:** Fewer workers if each needs lots of memory
- **I/O-heavy:** Fewer workers to avoid I/O contention

.. code-block:: matlab

   % Calculate optimal workers based on memory
   total_mem_gb = str2num(getenv('SLURM_MEM_PER_NODE')) / 1024;
   mem_per_worker_gb = 4;  % Estimated memory per worker
   max_workers_mem = floor(total_mem_gb / mem_per_worker_gb);
   
   num_cpus = str2num(getenv('SLURM_CPUS_PER_TASK'));
   num_workers = min(num_cpus, max_workers_mem);
   
   fprintf('Creating pool with %d workers (CPU limit: %d, memory limit: %d)\n', ...
           num_workers, num_cpus, max_workers_mem);
   pool = parpool('local', num_workers);

Memory Considerations
~~~~~~~~~~~~~~~~~~~~~

Each worker is a separate MATLAB process with its own memory:

.. code-block:: bash

   # If each worker needs 8GB, request:
   # 64 workers × 8GB = 512GB minimum
   #SBATCH --cpus-per-task=64
   #SBATCH --mem=512G

Partition Selection
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # AMD partition: up to 256 cores
   #SBATCH --partition=amd
   #SBATCH --cpus-per-task=128
   
   # Intel partition: up to 128 cores
   #SBATCH --partition=intel
   #SBATCH --cpus-per-task=64
   
   # GPU partition: 16 cores + GPU (see gpu doc)
   #SBATCH --partition=gpu-a30
   #SBATCH --cpus-per-task=16

Best Practices
--------------

1. **Profile before parallelizing:**

   .. code-block:: matlab
   
      profile on
      my_serial_function();
      profile viewer
      % Identify bottlenecks, then parallelize those

2. **Chunk work appropriately:**

   .. code-block:: matlab
   
      % Too many small tasks (overhead dominates)
      parfor i = 1:1000000
          result(i) = i^2;  % Too simple!
      end
      
      % Better: chunk into larger tasks
      chunk_size = 1000;
      n_chunks = 1000;
      results = zeros(n_chunks * chunk_size, 1);
      
      parfor c = 1:n_chunks
          start_idx = (c-1)*chunk_size + 1;
          end_idx = c*chunk_size;
          for i = start_idx:end_idx
              results(i) = expensive_computation(i);
          end
      end

3. **Monitor parallel efficiency:**

   .. code-block:: matlab
   
      % Good parallel efficiency (>70%)
      % means code benefits from parallelization

4. **Clean up pools in production:**

   .. code-block:: matlab
   
      try
          % Create pool and do work
          pool = parpool('local', num_workers);
          parfor i = 1:n
              results(i) = process(i);
          end
      catch ME
          fprintf('Error: %s\n', ME.message);
      end
      
      % Always cleanup
      delete(gcp('nocreate'));

Example: Monte Carlo Simulation
--------------------------------

Complete parallel Monte Carlo example:

**monte_carlo_pi.m:**

.. code-block:: matlab

   function estimate_pi_parallel()
       % Estimate pi using parallel Monte Carlo simulation
       
       % Setup
       num_samples = 1e9;  % 1 billion samples
       num_workers = str2num(getenv('SLURM_CPUS_PER_TASK'));
       
       fprintf('Estimating pi with %g samples using %d workers\n', ...
               num_samples, num_workers);
       
       % Create parallel pool
       pool = parpool('local', num_workers);
       
       % Divide work among workers
       samples_per_worker = ceil(num_samples / num_workers);
       
       % Parallel Monte Carlo
       tic;
       inside_counts = zeros(num_workers, 1);
       
       parfor w = 1:num_workers
           % Each worker does independent sampling
           count = 0;
           for i = 1:samples_per_worker
               x = rand();
               y = rand();
               if (x^2 + y^2) <= 1
                   count = count + 1;
               end
           end
           inside_counts(w) = count;
       end
       
       elapsed = toc;
       
       % Combine results
       total_inside = sum(inside_counts);
       total_samples = samples_per_worker * num_workers;
       pi_estimate = 4 * total_inside / total_samples;
       error = abs(pi_estimate - pi);
       
       fprintf('\nResults:\n');
       fprintf('  Estimated pi: %.10f\n', pi_estimate);
       fprintf('  Actual pi:    %.10f\n', pi);
       fprintf('  Error:        %.10f\n', error);
       fprintf('  Time:         %.2f seconds\n', elapsed);
       fprintf('  Throughput:   %.2e samples/second\n', total_samples/elapsed);
       
       % Cleanup
       delete(pool);
   end

**run_monte_carlo.sh:**

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=monte-carlo-pi
   #SBATCH --partition=amd
   #SBATCH --cpus-per-task=64
   #SBATCH --mem=128G
   #SBATCH --time=01:00:00
   #SBATCH --output=monte-carlo-%j.out
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "estimate_pi_parallel"

Next Steps
----------

- :doc:`gpu` - GPU-accelerated computing with MATLAB
- :doc:`batch` - Running parallel jobs in batch mode
- :doc:`interactive` - Interactive parallel development
- :doc:`index` - MATLAB overview

See Also
--------

- `Parallel Computing Toolbox Documentation <https://www.mathworks.com/help/parallel-computing/>`_
- `parfor Performance <https://www.mathworks.com/help/parallel-computing/parfor.html>`_
- :doc:`../index` - HPC4 software overview
