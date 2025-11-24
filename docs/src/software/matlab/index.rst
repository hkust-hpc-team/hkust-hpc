MATLAB Support
==============

MATLAB is available through the Spack package manager with support for 
parallel computing, GPU acceleration, and comprehensive toolboxes.

.. contents:: Table of Contents
   :local:
   :depth: 2

Quick Start
-----------

.. code-block:: bash

   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-envs.sh -y
   
   # Check available MATLAB versions
   module avail matlab
   
   # Load MATLAB
   module load matlab/R2023b
   
   # Start MATLAB
   matlab -nodisplay           # Command-line mode
   matlab                      # GUI mode (on login node)
   
   # Run a script in batch mode
   matlab -batch "my_script"

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``matlab/R2023b-7r5y3as``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``R2023b``) is sufficient.

Features Availability
---------------------

.. list-table::
   :header-rows: 1
   :widths: 30 17 17 17 19

   * - Feature / Version
     - R2019b
     - R2022b
     - R2023b
     - Others :sup:`[1]`
   * - **License**
     - Campus
     - Campus
     - Campus
     - Campus
   * - **Installed**
     - ✓
     - ✓
     - ✓ (Default)
     - ✗ :sup:`[1]`
   * - **Core Features**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **GPU Support**
     - ✓ :sup:`[2]`
     - ✓
     - ✓
     - ✓
   * - **Parallel Toolbox**
     - ✓
     - ✓
     - ✓
     - Untested :sup:`[3]`
   * - **SLURM Compatibility**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Distributed Computing Server**
     - ✗
     - ✗
     - ✗
     - ✗

**Notes:**

:sup:`[1]` **Others (R2018b-R2024a):** Can be installed on your own via Spack (not pre-installed as module). Self-installed versions have not been tested by HPC team.

:sup:`[2]` **Auto-recompile:** GPU kernels may require automatic recompilation on first use

:sup:`[3]` **Untested:** Have not been tested by HPC team

Environment Variables
---------------------

When loading the MATLAB module, the following environment variables are set automatically.

MATLABPATH
^^^^^^^^^^
Specifies the user-specific directory for MATLAB paths and user settings.

**Default:** ``$HOME/.matlab/<version>``

.. note::
   These environment variables are automatically configured when you load the MATLAB module. 
   You typically don't need to modify them manually.

Support and Resources
---------------------

**MATLAB Documentation**

- `MATLAB Documentation <https://www.mathworks.com/help/matlab/>`_
- `Parallel Computing Toolbox <https://www.mathworks.com/help/parallel-computing/>`_
- `GPU Computing <https://www.mathworks.com/help/parallel-computing/gpu-computing.html>`_
