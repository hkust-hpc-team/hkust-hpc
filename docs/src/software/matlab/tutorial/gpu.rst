GPU Computing with MATLAB
==========================

Accelerate MATLAB computations using GPUs on HPC4's GPU partition.

GPU Resources on HPC4
----------------------

The ``gpu-a30`` partition provides:

- **GPU model:** NVIDIA A30 (24GB memory)
- **CPUs per node:** 16 cores
- **System memory:** 256GB
- **CUDA support:** Yes (via NVIDIA drivers)

GPU Availability
----------------

Check if GPU computing is available:

.. code-block:: matlab

   % Check if Parallel Computing Toolbox with GPU support is available
   if gpuDeviceCount > 0
       fprintf('GPU devices available: %d\n', gpuDeviceCount);
       
       % Get GPU information
       gpu = gpuDevice();
       fprintf('GPU: %s\n', gpu.Name);
       fprintf('Compute Capability: %s\n', gpu.ComputeCapability);
       fprintf('Total Memory: %.2f GB\n', gpu.TotalMemory / 1e9);
       fprintf('Available Memory: %.2f GB\n', gpu.AvailableMemory / 1e9);
       fprintf('CUDA Version: %s\n', gpu.ToolkitVersion);
   else
       fprintf('No GPU devices available\n');
   end

Accessing GPU Nodes
-------------------

Interactive GPU Session
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Request GPU node interactively
   srun --account=exampleproj --partition=gpu-a30 \
        --gres=gpu:1 --cpus-per-task=8 --mem=64G \
        --time=2:00:00 --pty bash
   
   # Activate Spack
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load MATLAB
   module load matlab/R2023b
   
   # Start MATLAB
   matlab -nodisplay

Verify GPU is accessible:

.. code-block:: matlab

   >> gpu = gpuDevice()
   
   gpu = 
   
     CUDADevice with properties:
   
                     Name: 'NVIDIA A30'
                    Index: 1
         ComputeCapability: '8.0'
            SupportsDouble: 1
             DriverVersion: 12.2
            ToolkitVersion: 11.8
                MaxThreads: 1024
              ...

Batch GPU Job
~~~~~~~~~~~~~

**run_gpu.sh:**

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=matlab-gpu
   #SBATCH --partition=gpu-a30
   #SBATCH --gres=gpu:1              # Request 1 GPU
   #SBATCH --cpus-per-task=8
   #SBATCH --mem=64G
   #SBATCH --time=04:00:00
   #SBATCH --output=gpu-job-%j.out
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   matlab -batch "my_gpu_script.m"

Submit with:

.. code-block:: bash

   sbatch run_gpu.sh

See :doc:`batch` for more batch job details.

GPU Arrays
----------

Transfer data to GPU using ``gpuArray``:

Basic GPU Array Operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Create data on CPU
   A_cpu = rand(10000, 10000);
   B_cpu = rand(10000, 10000);
   
   % Transfer to GPU
   fprintf('Transferring data to GPU...\n');
   tic;
   A_gpu = gpuArray(A_cpu);
   B_gpu = gpuArray(B_cpu);
   transfer_time = toc;
   fprintf('Transfer time: %.3f seconds\n', transfer_time);
   
   % Computation on GPU
   fprintf('Computing on GPU...\n');
   tic;
   C_gpu = A_gpu * B_gpu;
   gpu_time = toc;
   fprintf('GPU computation time: %.3f seconds\n', gpu_time);
   
   % Transfer result back to CPU
   tic;
   C_cpu = gather(C_gpu);
   gather_time = toc;
   fprintf('Gather time: %.3f seconds\n', gather_time);
   
   % Compare with CPU computation
   fprintf('Computing on CPU...\n');
   tic;
   C_cpu_only = A_cpu * B_cpu;
   cpu_time = toc;
   fprintf('CPU computation time: %.3f seconds\n', cpu_time);
   fprintf('Speedup: %.2fx\n', cpu_time / gpu_time);

Creating Arrays Directly on GPU
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Create directly on GPU (more efficient)
   A = gpuArray.rand(10000, 10000);
   B = gpuArray.zeros(5000, 5000);
   C = gpuArray.ones(1000, 1000);
   
   % Check where array is stored
   fprintf('A is on GPU: %d\n', isa(A, 'gpuArray'));

GPU-Accelerated Functions
--------------------------

Many MATLAB functions automatically work with GPU arrays:

Mathematical Operations
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Linear algebra
   A = gpuArray.rand(5000, 5000);
   B = gpuArray.rand(5000, 5000);
   
   C = A * B;           % Matrix multiplication
   [L, U] = lu(A);      % LU decomposition
   [Q, R] = qr(A);      % QR decomposition
   e = eig(A);          % Eigenvalues
   
   % Element-wise operations
   D = sin(A);          % Element-wise sine
   E = exp(B);          % Element-wise exponential
   F = A .^ 2;          % Element-wise power

FFT and Signal Processing
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % FFT on GPU
   signal = gpuArray.rand(1, 1e7);
   
   tic;
   spectrum = fft(signal);
   fprintf('GPU FFT time: %.3f seconds\n', toc);
   
   % Inverse FFT
   reconstructed = ifft(spectrum);

Image Processing
~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Image operations on GPU
   img = gpuArray(imread('image.jpg'));
   
   % Filtering
   h = fspecial('gaussian', [5 5], 2);
   filtered = imfilter(img, h);
   
   % Gather result
   filtered_cpu = gather(filtered);
   imwrite(filtered_cpu, 'filtered_image.jpg');

Custom GPU Kernels
------------------

Write custom CUDA kernels for specialized operations:

.. code-block:: matlab

   % Define CUDA kernel as string
   kernel_code = [ ...
       '__global__ void addKernel(double *out, const double *a, const double *b, int n) {', ...
       '    int idx = blockIdx.x * blockDim.x + threadIdx.x;', ...
       '    if (idx < n) {', ...
       '        out[idx] = a[idx] + b[idx];', ...
       '    }', ...
       '}'];
   
   % Create kernel object
   kernel = parallel.gpu.CUDAKernel(kernel_code, 'addKernel');
   
   % Set thread dimensions
   n = 1e6;
   kernel.ThreadBlockSize = 256;
   kernel.GridSize = ceil(n / kernel.ThreadBlockSize);
   
   % Create GPU arrays
   a = gpuArray.rand(n, 1);
   b = gpuArray.rand(n, 1);
   c = gpuArray.zeros(n, 1);
   
   % Execute kernel
   c = feval(kernel, c, a, b, n);

arrayfun for Element-wise Operations
-------------------------------------

Use ``arrayfun`` for element-wise operations on GPU:

.. code-block:: matlab

   % Define custom function
   my_func = @(x) sin(x) .^ 2 + cos(x) .^ 2;
   
   % CPU version
   x_cpu = rand(1e7, 1);
   tic;
   result_cpu = my_func(x_cpu);
   cpu_time = toc;
   
   % GPU version with arrayfun
   x_gpu = gpuArray(x_cpu);
   tic;
   result_gpu = arrayfun(my_func, x_gpu);
   gpu_time = toc;
   
   fprintf('CPU time: %.3f seconds\n', cpu_time);
   fprintf('GPU time: %.3f seconds\n', gpu_time);
   fprintf('Speedup: %.2fx\n', cpu_time / gpu_time);

Deep Learning on GPU
--------------------

MATLAB's Deep Learning Toolbox automatically uses GPUs:

.. code-block:: matlab

   % Check GPU availability for deep learning
   canUseGPU()
   
   % Load pretrained network
   net = resnet50;
   
   % Classify image on GPU
   img = imread('example.jpg');
   img_resized = imresize(img, net.Layers(1).InputSize(1:2));
   
   % Prediction automatically uses GPU
   tic;
   [label, scores] = classify(net, img_resized);
   inference_time = toc;
   
   fprintf('Predicted: %s (%.2f confidence)\n', label, max(scores));
   fprintf('Inference time: %.3f seconds\n', inference_time);

Training Neural Networks
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Create simple network
   layers = [
       imageInputLayer([28 28 1])
       convolution2dLayer(3, 8, 'Padding', 'same')
       reluLayer
       maxPooling2dLayer(2, 'Stride', 2)
       fullyConnectedLayer(10)
       softmaxLayer
       classificationLayer];
   
   % Training options with GPU
   options = trainingOptions('sgdm', ...
       'ExecutionEnvironment', 'gpu', ...  % Use GPU
       'MaxEpochs', 10, ...
       'MiniBatchSize', 128, ...
       'Verbose', true);
   
   % Train network (automatically uses GPU)
   net = trainNetwork(training_data, layers, options);

Performance Optimization
------------------------

When to Use GPU
~~~~~~~~~~~~~~~

✅ **Good GPU candidates:**

- Large matrix operations (size > 1000×1000)
- Element-wise operations on large arrays
- FFT on large signals
- Image/video processing
- Deep learning training and inference
- Monte Carlo simulations with many iterations

❌ **Not suitable for GPU:**

- Small matrices (< 100×100)
- Operations with many CPU-GPU transfers
- Sparse matrix operations (limited support)
- Code with complex branching logic

Minimizing Data Transfer
~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % ❌ BAD: Excessive transfers
   A = rand(5000, 5000);
   for i = 1:100
       A_gpu = gpuArray(A);      % Transfer to GPU
       A_gpu = A_gpu * 2;
       A = gather(A_gpu);        % Transfer back
   end
   
   % ✅ GOOD: Transfer once
   A = rand(5000, 5000);
   A_gpu = gpuArray(A);          % Transfer once
   for i = 1:100
       A_gpu = A_gpu * 2;        % Compute on GPU
   end
   A = gather(A_gpu);            % Transfer back once

Memory Management
~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Check available GPU memory
   gpu = gpuDevice();
   fprintf('Available GPU memory: %.2f GB\n', gpu.AvailableMemory / 1e9);
   
   % Clear GPU memory
   clear A_gpu B_gpu C_gpu
   
   % Reset GPU (clears all GPU memory)
   reset(gpu);
   
   % Monitor memory during computation
   A = gpuArray.rand(10000, 10000);
   fprintf('Memory used: %.2f GB\n', ...
           (gpu.TotalMemory - gpu.AvailableMemory) / 1e9);

Batch Processing
~~~~~~~~~~~~~~~~

Process large datasets in batches to fit in GPU memory:

.. code-block:: matlab

   % Process data in batches
   total_data = rand(100000, 1000);  % Too large for GPU
   batch_size = 10000;
   num_batches = ceil(size(total_data, 1) / batch_size);
   
   results = zeros(size(total_data, 1), 1);
   
   for b = 1:num_batches
       start_idx = (b-1)*batch_size + 1;
       end_idx = min(b*batch_size, size(total_data, 1));
       
       % Process batch on GPU
       batch = gpuArray(total_data(start_idx:end_idx, :));
       batch_result = sum(batch .^ 2, 2);
       results(start_idx:end_idx) = gather(batch_result);
       
       fprintf('Processed batch %d/%d\n', b, num_batches);
   end

Complete GPU Example
--------------------

**gpu_matrix_benchmark.m:**

.. code-block:: matlab

   function gpu_matrix_benchmark()
       % Benchmark GPU vs CPU for matrix operations
       
       fprintf('=== GPU Matrix Benchmark ===\n\n');
       
       % Check GPU availability
       if gpuDeviceCount == 0
           error('No GPU available');
       end
       
       gpu = gpuDevice();
       fprintf('GPU: %s\n', gpu.Name);
       fprintf('Memory: %.2f GB\n', gpu.TotalMemory / 1e9);
       fprintf('Compute Capability: %s\n\n', gpu.ComputeCapability);
       
       % Test different matrix sizes
       sizes = [1000, 2000, 5000, 10000];
       
       fprintf('%-10s %-15s %-15s %-15s %-10s\n', ...
               'Size', 'CPU Time (s)', 'GPU Time (s)', 'Transfer (s)', 'Speedup');
       fprintf('%s\n', repmat('-', 1, 70));
       
       for n = sizes
           % CPU computation
           A_cpu = rand(n, n);
           B_cpu = rand(n, n);
           
           tic;
           C_cpu = A_cpu * B_cpu;
           cpu_time = toc;
           
           % GPU computation (including transfer)
           tic;
           A_gpu = gpuArray(A_cpu);
           B_gpu = gpuArray(B_cpu);
           transfer_time = toc;
           
           tic;
           C_gpu = A_gpu * B_gpu;
           wait(gpu);  % Ensure computation completes
           gpu_compute_time = toc;
           
           tic;
           C_cpu_from_gpu = gather(C_gpu);
           gather_time = toc;
           
           total_gpu_time = transfer_time + gpu_compute_time + gather_time;
           speedup = cpu_time / total_gpu_time;
           
           fprintf('%-10d %-15.3f %-15.3f %-15.3f %-10.2fx\n', ...
                   n, cpu_time, total_gpu_time, transfer_time, speedup);
           
           % Verify results match
           max_diff = max(abs(C_cpu(:) - C_cpu_from_gpu(:)));
           if max_diff > 1e-10
               warning('Results differ by %.2e', max_diff);
           end
       end
       
       fprintf('\nBenchmark complete\n');
   end

**run_gpu_benchmark.sh:**

.. code-block:: bash

   #!/bin/bash
   #SBATCH --account=exampleproj
   #SBATCH --job-name=gpu-benchmark
   #SBATCH --partition=gpu-a30
   #SBATCH --gres=gpu:1
   #SBATCH --cpus-per-task=4
   #SBATCH --mem=32G
   #SBATCH --time=01:00:00
   #SBATCH --output=gpu-benchmark-%j.out
   
   echo "Job started at: $(date)"
   echo "Running on: $(hostname)"
   
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load matlab/R2023b
   
   matlab -batch "gpu_matrix_benchmark"
   
   echo "Job finished at: $(date)"

Multiple GPUs
-------------

HPC4 gpu-a30 partition has 1 GPU per node. For multi-GPU:

.. code-block:: matlab

   % Check number of GPUs
   n_gpus = gpuDeviceCount;
   fprintf('Number of GPUs: %d\n', n_gpus);
   
   % Select specific GPU
   gpuDevice(1);  % Use GPU 1
   
   % For multi-GPU, use SPMD
   spmd
       gpu = gpuDevice(labindex);
       fprintf('Worker %d using %s\n', labindex, gpu.Name);
       
       % Each worker uses its GPU
       data = gpuArray.rand(5000, 5000);
       result = data * data';
   end

Troubleshooting
---------------

GPU Not Detected
~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Check if GPU is available
   if gpuDeviceCount == 0
       % Possible reasons:
       % 1. Not on GPU node (check: squeue -u $USER)
       % 2. GPU not requested in sbatch (need: --gres=gpu:1)
       % 3. CUDA driver issue (check: nvidia-smi in terminal)
   end

Out of GPU Memory
~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Monitor memory usage
   gpu = gpuDevice();
   
   % Check before allocation
   needed_memory = 8 * n * n;  % Bytes for double matrix
   if needed_memory > gpu.AvailableMemory
       error('Insufficient GPU memory');
   end
   
   % Or process in smaller batches
   % See "Batch Processing" section above

Slow Performance
~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Common issues:
   
   % 1. Too many CPU-GPU transfers
   %    Solution: Keep data on GPU
   
   % 2. Matrix too small
   %    Solution: Use GPU only for large operations
   
   % 3. Not waiting for GPU to finish
   wait(gpuDevice());  % Ensure accurate timing

Best Practices
--------------

1. **Profile before GPU-ifying:**

   .. code-block:: matlab
   
      % Test with CPU first
      profile on
      my_computation();
      profile viewer
      % Identify bottlenecks suitable for GPU

2. **Transfer data once:**

   .. code-block:: matlab
   
      data_gpu = gpuArray(data);
      for iter = 1:niters
          data_gpu = process(data_gpu);  % Keep on GPU
      end
      result = gather(data_gpu);

3. **Use appropriate data types:**

   .. code-block:: matlab
   
      % Single precision is faster on GPU
      A = gpuArray(single(rand(10000, 10000)));
      
      % Double precision if needed
      B = gpuArray(rand(10000, 10000));  % default is double

4. **Clean up GPU memory:**

   .. code-block:: matlab
   
      % At end of script
      clear gpu_variables
      reset(gpuDevice());

5. **Check GPU utilization:**

   In terminal while job runs:

   .. code-block:: bash
   
      # SSH to GPU node
      ssh <gpu-node-name>
      
      # Monitor GPU usage
      watch -n 1 nvidia-smi

Next Steps
----------

- :doc:`parallel` - Combine GPU with parallel computing
- :doc:`batch` - Running GPU jobs in batch mode
- :doc:`interactive` - Interactive GPU development
- :doc:`index` - MATLAB overview

See Also
--------

- `GPU Computing in MATLAB <https://www.mathworks.com/solutions/gpu-computing.html>`_
- `GPU Coder <https://www.mathworks.com/products/gpu-coder.html>`_
- `Deep Learning Toolbox <https://www.mathworks.com/products/deep-learning.html>`_
- :doc:`../index` - HPC4 software overview
