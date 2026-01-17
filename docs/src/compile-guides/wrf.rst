WRF-ARW Modeling System
=======================

The Weather Research and Forecasting (WRF) Model is a mesoscale numerical weather prediction system designed for both atmospheric research and operational forecasting applications.

.. contents:: Table of Contents
   :local:
   :depth: 2

Overview
--------

**WRF Version:** v4.7.1

**Official Repository:** https://github.com/wrf-model/WRF

**Recommended Compiler Stack:** Intel OneAPI Compiler + Intel OneAPI MPI

This guide demonstrates how to compile WRF using the HPC module system with Intel compilers, which are known to provide good performance and compatibility.

Prerequisites
-------------

Required Modules
^^^^^^^^^^^^^^^^

WRF requires the following software components:

- Intel OneAPI Compilers
- Intel OneAPI MPI
- NetCDF-C (with parallel I/O support)
- NetCDF-Fortran
- Parallel-NetCDF (PnetCDF)
- HDF5 (with parallel I/O support)

System Requirements
^^^^^^^^^^^^^^^^^^^

- Sufficient disk space (~2GB for source code and build)
- Memory: At least 4GB RAM for compilation
- Time: Compilation typically takes 20-30 minutes

Download WRF Source Code
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create a working directory
   mkdir -p ~/wrf-build
   cd ~/wrf-build
   
   # Clone WRF repository
   git clone https://github.com/wrf-model/WRF.git
   cd WRF
   
   # Checkout the desired version
   git checkout v4.7.1

Compilation Steps
-----------------

.. important::
   **Do not compile on login nodes!** Compilation is resource-intensive and should be performed on compute nodes.

Request Interactive Compute Node
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before compiling, request an interactive session on a compute node. For detailed instructions and examples, see:

:doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`

Once the interactive session starts, you'll be on a compute node where you can safely compile WRF.

Step 1: Load Required Modules
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

   For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"
   
   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load Intel OneAPI compiler
   module load intel-oneapi-compilers/2025
   
   # Load Intel OneAPI MPI
   module load intel-oneapi-mpi
   
   # Load NetCDF and HDF5 libraries
   module load hdf5
   module load netcdf-c
   module load netcdf-fortran
   module load parallel-netcdf
   
   # Verify modules are loaded
   module list

Step 2: Set Environment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

WRF requires specific environment variables to locate libraries:

.. code-block:: bash

   # Set NetCDF paths
   export NETCDF=$(nc-config --prefix)
   export NETCDFF=$(nf-config --prefix)
   
   # Set Parallel-NetCDF path
   export PNETCDF=$(pnetcdf-config --prefix)
   
   # Set HDF5 path
   export HDF5=$(pkg-config --variable=prefix hdf5)
   
   # Set compiler environment variables
   export CC=mpicc
   export CXX=mpicxx
   export FC=mpifort
   export F77=mpifort
   
   # Verify paths
   echo "NETCDF: $NETCDF"
   echo "NETCDFF: $NETCDFF"
   echo "PNETCDF: $PNETCDF"
   echo "HDF5: $HDF5"

Step 3: Configure WRF
^^^^^^^^^^^^^^^^^^^^^^

Run the WRF configuration script:

.. code-block:: bash

   # Clean any previous configuration
   ./clean -a
   
   # Run configure script
   ./configure

The configure script will present options for your system. For Intel compilers with distributed memory (MPI):

**Recommended Option:** Select option **15** (dmpar - Distributed Memory Parallel) for Intel compilers

**Nesting Option:** Select **1** (basic) unless you need specialized nesting

Example configuration selection:

.. code-block:: text

   Please select from among the following Linux x86_64 options:
   
   1. (serial)   2. (smpar)   3. (dmpar)   4. (dm+sm)   PGI (pgf90/gcc)
   ...
   15. (dmpar)  INTEL (ifort/icc)
   ...
   
   Enter selection [1-75] : 15
   
   Compile for nesting? (1=basic, 2=preset moves, 3=vortex following) [default 1]: 1

Step 4: Compile WRF
^^^^^^^^^^^^^^^^^^^

Compile WRF with parallel make:

.. code-block:: bash

   # Compile WRF (use multiple cores for faster compilation)
   # Replace 8 with the number of CPU cores you want to use
   ./compile em_real >& compile.log
   
   # Monitor compilation progress in another terminal
   tail -f compile.log

.. tip::
   Compilation typically takes 20-30 minutes. You can monitor progress by watching the ``compile.log`` file.

Step 5: Verify Compilation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

After compilation completes, verify that the executables were created:

.. code-block:: bash

   # Check for required executables
   ls -lh main/*.exe
   
   # You should see these files:
   # - ndown.exe
   # - real.exe
   # - tc.exe
   # - wrf.exe

If all four executables are present, WRF has been successfully compiled.

.. code-block:: bash

   # Verify executables are linked correctly
   ldd main/wrf.exe | grep -E "netcdf|hdf5|mpi"

Running WRF
-----------

Basic Workflow
^^^^^^^^^^^^^^

1. **Prepare Input Data** - Use WPS (WRF Preprocessing System) to generate initial and boundary conditions
2. **Run real.exe** - Initialize the model
3. **Run wrf.exe** - Execute the simulation

SLURM Batch Script Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=wrf_run
   #SBATCH --nodes=2
   #SBATCH --ntasks-per-node=32
   #SBATCH --time=24:00:00
   #SBATCH --partition=cpu
   
   # Activate Spack environment
   export SPACK_ROOT="/path/to/spack"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load the same modules used for compilation
   module load intel-oneapi-compilers/2025
   module load intel-oneapi-mpi/2021
   module load netcdf-c/4.9.2
   module load netcdf-fortran/4.6.1
   module load parallel-netcdf/1.14.0
   module load hdf5/1.14.6
   
   # Set environment variables
   export NETCDF=$(nc-config --prefix)
   export NETCDFF=$(nf-config --prefix)
   export PNETCDF=$(pnetcdf-config --prefix)
   
   # Navigate to run directory
   cd $SLURM_SUBMIT_DIR
   
   # Run real.exe to initialize
   srun -n 64 ./real.exe
   
   # Run wrf.exe for simulation
   srun -n 64 ./wrf.exe

Troubleshooting
---------------

Compilation Errors
^^^^^^^^^^^^^^^^^^

**Error: NetCDF library not found**

.. code-block:: bash

   # Verify NetCDF modules are loaded
   module list | grep netcdf
   
   # Check environment variables
   echo $NETCDF
   echo $NETCDFF
   
   # Reload modules if necessary
   module purge
   module load intel-oneapi-compilers/2025
   module load intel-oneapi-mpi/2021
   module load netcdf-c/4.9.2
   module load netcdf-fortran/4.6.1

**Error: Missing executables after compilation**

.. code-block:: bash

   # Check compile.log for errors
   grep -i error compile.log
   grep -i failed compile.log
   
   # Clean and recompile
   ./clean -a
   ./configure
   ./compile em_real >& compile.log

Runtime Errors
^^^^^^^^^^^^^^

**Error: Segmentation fault**

- Check that all required modules are loaded in your batch script
- Verify that environment variables (NETCDF, PNETCDF, etc.) are set correctly
- Ensure sufficient memory is allocated in your SLURM script

**Error: MPI initialization failed**

.. code-block:: bash

   # Verify MPI module is loaded
   module list | grep mpi
   
   # Check that you're using srun (not mpirun) in SLURM scripts
   srun -n <ntasks> ./wrf.exe

Performance Optimization
------------------------

Compiler Optimization
^^^^^^^^^^^^^^^^^^^^^

For production runs, you may want to modify compiler flags in ``configure.wrf``:

.. code-block:: bash

   # After running ./configure, edit configure.wrf
   # Look for FCOPTIM and CFLAGS lines
   
   # Example optimizations for Intel compilers:
   FCOPTIM = -O3 -xHost -ip -fp-model fast=2
   CFLAGS  = -O3 -xHost -ip -fp-model fast=2

Domain Decomposition
^^^^^^^^^^^^^^^^^^^^

For parallel runs, optimize the domain decomposition in ``namelist.input``:

.. code-block:: text

   &domains
   nproc_x = 8,    ! Number of processors in X direction
   nproc_y = 8,    ! Number of processors in Y direction
   ...

.. tip::
   ``nproc_x * nproc_y`` should equal the total number of MPI tasks. Balance the decomposition based on your domain dimensions.

Support and Resources
---------------------

**WRF Documentation**

- `WRF User's Guide <https://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/contents.html>`_
- `WRF Online Tutorial <https://www2.mmm.ucar.edu/wrf/OnLineTutorial/index.php>`_
- `WRF GitHub Repository <https://github.com/wrf-model/WRF>`_

**WRF Preprocessing System (WPS)**

- `WPS User's Guide <https://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/users_guide_chap3.html>`_
- `WPS GitHub Repository <https://github.com/wrf-model/WPS>`_

**Community Support**

- `WRF Forum <https://forum.mmm.ucar.edu/>`_
- `WRF Email Lists <https://www2.mmm.ucar.edu/wrf/users/support/wrf_lists.html>`_
