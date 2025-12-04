Launching MATLAB GUI
====================

The MATLAB graphical user interface (GUI) provides an integrated development 
environment for writing, testing, and debugging MATLAB code.

When to Use MATLAB GUI
-----------------------

✅ **Appropriate Uses:**

- Writing and editing MATLAB scripts and functions
- Exploring data structures and variables
- Creating and testing visualizations
- Installing MATLAB Add-Ons
- Quick syntax checking and debugging small code snippets
- Developing code before running on compute nodes

❌ **Not Appropriate For:**

- Running computationally intensive simulations
- Large-scale data processing
- Parallel computing with ``parfor``
- Long-running calculations
- Production workflows

.. warning::
   The login node is a **shared resource** used by all HPC4 users. Running heavy 
   computations will impact everyone. For actual computational work, use 
   :doc:`interactive` sessions or :doc:`batch` jobs.

Prerequisites
-------------

Before starting MATLAB GUI, activate the Spack environment:

.. code-block:: bash

   # Activate Spack
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load MATLAB module
   module load matlab/R2023b

Starting MATLAB GUI
-------------------

On the Login Node
~~~~~~~~~~~~~~~~~

After loading the module, simply run:

.. code-block:: bash

   matlab

This launches the full MATLAB desktop environment with:

- **Command Window** - Interactive MATLAB prompt
- **Editor** - Script and function editor with syntax highlighting
- **Workspace** - View and manage variables
- **Current Folder** - File browser
- **Command History** - Previous commands

Using the MATLAB Desktop
-------------------------

Command Window
~~~~~~~~~~~~~~

Execute MATLAB commands interactively:

.. code-block:: matlab

   >> x = 1:10;
   >> mean(x)
   ans =
        5.5000
   
   >> plot(x, x.^2)
   >> title('Quadratic Function')

Editor
~~~~~~

Create and edit scripts:

1. Click **New Script** or **Ctrl+N**
2. Write your MATLAB code
3. Save with ``.m`` extension
4. Run with **F5** or click **Run**

Example script:

.. code-block:: matlab

   % simple_plot.m
   % Create a simple visualization
   
   x = linspace(0, 2*pi, 100);
   y = sin(x);
   
   figure;
   plot(x, y, 'LineWidth', 2);
   xlabel('x');
   ylabel('sin(x)');
   title('Sine Wave');
   grid on;

Workspace Browser
~~~~~~~~~~~~~~~~~

View all variables in memory:

- Double-click variables to open in Variable Editor
- Right-click for options (save, clear, etc.)
- Monitor memory usage

.. code-block:: matlab

   % Create some variables
   A = rand(100, 100);
   vec = 1:1000;
   data = struct('name', 'experiment1', 'results', rand(10, 1));
   
   % View in workspace
   whos

Installing Add-Ons
------------------

The MATLAB GUI provides access to the Add-On Explorer for installing additional 
toolboxes and packages.

Using Add-On Explorer
~~~~~~~~~~~~~~~~~~~~~

1. In MATLAB, click **Home** tab
2. Click **Add-Ons** → **Get Add-Ons**
3. Browse or search for desired add-on
4. Click **Install**

Add-ons are automatically installed to ``$HOME/.matlab/R2023b/`` and will be 
available in all future MATLAB sessions, including compute node jobs.

Verifying Installed Add-Ons
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % List all installed add-ons
   matlab.addons.installedAddons

Managing Add-Ons
~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Disable an add-on
   matlab.addons.disableAddon('addon-name')
   
   % Enable an add-on
   matlab.addons.enableAddon('addon-name')
   
   % Uninstall an add-on
   matlab.addons.uninstall('addon-name')

Typical Development Workflow
-----------------------------

Step-by-Step Process
~~~~~~~~~~~~~~~~~~~~

1. **Start MATLAB GUI on login node**

   .. code-block:: bash
   
      source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
      module load matlab/R2023b
      matlab

2. **Develop your code** in the Editor with small test data

   .. code-block:: matlab
   
      % Test with small dataset first
      test_data = rand(10, 10);
      result = my_analysis(test_data);
      disp(result);

3. **Save your script** to a file (e.g., ``my_analysis.m``)

4. **Exit MATLAB** when development is complete

5. **Test on compute node** with representative data (see :doc:`interactive`)

6. **Submit production job** with full dataset (see :doc:`batch`)

Example Development Session
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % 1. Develop function in Editor
   % Save as: process_data.m
   function results = process_data(data)
       % Process input data
       results = mean(data, 2);
   end
   
   % 2. Test in Command Window with small data
   test_data = rand(5, 100);
   test_results = process_data(test_data);
   disp(test_results);
   
   % 3. If it works, prepare for compute node testing
   save('test_data.mat', 'test_data');

Best Practices
--------------

On the Login Node
~~~~~~~~~~~~~~~~~

**Do:**

- ✅ Write and edit code
- ✅ Test with very small datasets (< 1MB)
- ✅ Create visualizations with minimal data
- ✅ Install and configure add-ons
- ✅ Debug syntax and logic errors

**Don't:**

- ❌ Run loops over large arrays
- ❌ Create ``parfor`` pools
- ❌ Load large datasets (> 100MB)
- ❌ Run simulations or optimizations
- ❌ Leave long-running processes

Code Development Tips
~~~~~~~~~~~~~~~~~~~~~

1. **Test incrementally** - Run small portions of code as you write

2. **Use small data** - Create tiny test datasets:

   .. code-block:: matlab
   
      % Instead of loading full dataset
      % test_data = load('huge_file.mat');
      
      % Use small synthetic data
      test_data = rand(10, 10);

3. **Comment your code** - Document parameters and expected inputs:

   .. code-block:: matlab
   
      % PROCESS_DATA Process experimental data
      %   results = process_data(data, threshold)
      %
      %   Inputs:
      %       data - MxN matrix of measurements
      %       threshold - scalar cutoff value
      %   Outputs:
      %       results - Mx1 vector of processed values

4. **Save often** - Use **Ctrl+S** frequently

5. **Version control** - Consider using git for your MATLAB code

Transitioning to Compute Nodes
-------------------------------

Once your code is developed, move to compute nodes for actual execution:

**For testing and debugging:**

See :doc:`interactive` for using ``srun`` to test your code interactively on 
compute nodes with more resources.

**For production runs:**

See :doc:`batch` for submitting batch jobs that run unattended.

**For parallel computing:**

See :doc:`parallel` for using the Parallel Computing Toolbox with multiple cores.

MATLAB Path Configuration
--------------------------

Custom Functions and Paths
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add custom directories to your MATLAB path:

.. code-block:: matlab

   % Add a directory
   addpath('/home/username/matlab/functions');
   
   % Add with subdirectories
   addpath(genpath('/home/username/matlab/toolbox'));
   
   % Save path for future sessions
   savepath

The path is saved to ``$HOME/.matlab/R2023b/pathdef.m`` and persists across sessions.

Viewing Current Path
~~~~~~~~~~~~~~~~~~~~

.. code-block:: matlab

   % Display current path
   path
   
   % Or get as cell array
   p = strsplit(path, ':');
   disp(p');

Troubleshooting
---------------

GUI Won't Start
~~~~~~~~~~~~~~~

.. code-block:: bash

   # Check if MATLAB module is loaded
   module list
   
   # Verify MATLAB is available
   which matlab
   
   # Check X11 forwarding (if SSH)
   echo $DISPLAY

If using SSH, ensure X11 forwarding is enabled:

.. code-block:: bash

   # Disconnect and reconnect with X11 forwarding
   ssh -X username@hpc4.ust.hk

GUI is Slow or Unresponsive
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Close unused figures and windows
- Clear workspace of large variables: ``clear``
- Don't run heavy computations - move to compute nodes
- Close and restart MATLAB if needed

Graphics Issues
~~~~~~~~~~~~~~~

If plots or figures don't display:

.. code-block:: matlab

   % Check graphics renderer
   opengl info
   
   % Try different renderer
   set(gcf, 'Renderer', 'painters');

Can't Install Add-Ons
~~~~~~~~~~~~~~~~~~~~~~

Check disk quota:

.. code-block:: bash

   # Exit MATLAB and check quota in terminal
   quota

If quota is exceeded, clean up old files or request increase.

Next Steps
----------

After developing your code in the GUI:

1. **Test interactively** - :doc:`interactive` - Debug on compute nodes
2. **Run in batch** - :doc:`batch` - Submit production jobs  
3. **Add parallelism** - :doc:`parallel` - Use multiple cores
4. **Use GPU** - :doc:`gpu` - Accelerate with GPU computing

See Also
--------

- :doc:`index` - MATLAB overview and quick start
- :doc:`interactive` - Interactive development on compute nodes
- :doc:`batch` - Batch job submission
- `MATLAB Desktop <https://www.mathworks.com/help/matlab/desktop.html>`_
