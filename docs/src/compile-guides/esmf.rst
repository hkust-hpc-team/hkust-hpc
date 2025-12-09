ESMF (Earth System Modeling Framework) v9
==========================================

The Earth System Modeling Framework (ESMF) is a high-performance, flexible software infrastructure for building and coupling weather, climate, and related Earth science applications.

.. contents:: Table of Contents
   :local:
   :depth: 2

Overview
--------

**ESMF Version:** v9.0.0b06

**Official Repository:** https://github.com/esmf-org/esmf

**Official Build Documentation:** https://earthsystemmodeling.org/docs/nightly/develop/ESMF_usrdoc/node10.html

.. important::
   This guide is specific to ESMF version 9.x. The build system and compilation methods may differ for other major versions. For example, older versions may only support Intel Classic compilers.

This guide demonstrates how to compile ESMF using the HPC module system with multiple compiler toolchains. ESMF v9.0.0b06 supports AMD AOCC and Intel Classic compilers.


Prerequisites
-------------

Required Software Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ESMF requires the following software components:

- C/CXX/Fortran compiler toolset (Intel Classic or AMD AOCC)
- An MPI implementation (Intel MPI or OpenMPI)
- NetCDF-C (with parallel I/O support)
- NetCDF-Fortran
- Parallel-NetCDF (PnetCDF)
- ParallelIO (PIO)
- HDF5 (with parallel I/O support)
- CMake (for ParallelIO dependency)

.. caution::
   As tested on 2025-12-09, the Intel OneAPI compilers (icx, icpx, ifx) are not compatible with ESMF v9.0.0b06 when used with either Intel MPI or OpenMPI for missing ``-lmpi++`` linkage. There is no known workaround at this time.
   
   Use Intel Classic compilers (icc, icpc, ifort) instead.

System Requirements
^^^^^^^^^^^^^^^^^^^

- Sufficient disk space (~3GB for source code and build)
- Memory: At least 8GB RAM for serial compilation, more for parallelized builds
- Time: Compilation takes approx. 1 hour

Supported Compiler Toolchains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following table summarizes the supported compiler toolchains and their configurations:

.. list-table:: Compiler Toolchain Configuration
   :header-rows: 1
   :widths: 35 30 35

   * - Configuration
     - **AMD AOCC**
     - **Intel Classic**
   * - Compiler Module
     - ``aocc/5``
     - ``intel-oneapi-compilers-classic``
   * - MPI Module
     - ``openmpi/5``
     - ``intel-oneapi-mpi``
   * - ``ESMF_COMPILER``
     - ``aocc``
     - ``intel``
   * - ``ESMF_COMM``
     - ``openmpi``
     - ``intelmpi``
   * - ``ESMF_C``
     - (unset)
     - ``icc``
   * - ``ESMF_CXX``
     - (unset)
     - ``icpc``
   * - ``ESMF_F90``
     - (unset)
     - ``ifort``
   * - Additional Flags
     - None
     - | ``CFLAGS="-diag-disable=10441"``
       | ``CXXFLAGS="-diag-disable=10441"``

.. warning::
   **Intel OneAPI Compatibility Issue:** The Intel OneAPI compilers (icx, icpx, ifx) are currently not compatible with ESMF v9.0.0b06 when used with either Intel MPI or OpenMPI. There is no known workaround at this time. Use Intel Classic compilers (icc, icpc, ifort) instead.

Download ESMF Source Code
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create a working directory
   mkdir -p ~/esmf-build
   cd ~/esmf-build
   
   # Clone ESMF repository
   git clone https://github.com/esmf-org/esmf.git
   cd esmf
   
   # Checkout the desired version
   git checkout v9.0.0b06

Compilation Steps
-----------------

.. important::
   **Do not compile on login nodes!** Compilation is resource-intensive and should be performed on compute nodes.

Request Interactive Compute Node
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before compiling, request an interactive session on a compute node. For detailed instructions and examples, see:

:doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`

Once the interactive session starts, you'll be on a compute node where you can safely compile ESMF.

.. note::

   For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

Option 1: Build with AMD AOCC + OpenMPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This configuration uses the AMD Optimizing C/C++ and Fortran Compilers with OpenMPI.

.. code-block:: bash

   # Navigate to ESMF source directory
   cd ~/esmf-build/esmf
   
   # Activate Spack environment
   export SPACK_ROOT="/opt/shared/.spack-edge"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load build tools first
   module purge
   module load cmake
   
   # Load AMD AOCC compiler and OpenMPI
   module load aocc/5
   module load openmpi/5
   
   # Load required libraries
   module load hdf5
   module load netcdf-c
   module load netcdf-fortran
   module load parallel-netcdf
   module load parallelio
   
   # Verify modules are loaded
   module list
   
   # Set ESMF build environment variables
   export ESMF_DIR="$(pwd)"
   export ESMF_SITE="hkust_hpc4"
   export ESMF_OS="Linux"
   export ESMF_COMPILER="aocc"
   export ESMF_COMM="openmpi"
   export ESMF_ABI="64"
   
   # Set library paths
   export ESMF_NETCDF="nc-config"
   export ESMF_PNETCDF="pnetcdf-config"
   export ESMF_PIO="external"
   export ESMF_NUMA="ON"
   
   # Compile ESMF (use all available cores)
   make -j $(nproc) 2>&1 | tee hpc4_build.log

Option 2: Build with Intel Classic Compilers + Intel MPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This configuration uses the classic Intel compilers (icc, icpc, ifort) with Intel MPI.

.. code-block:: bash

   # Navigate to ESMF source directory
   cd ~/esmf-build/esmf
   
   # Activate Spack environment
   export SPACK_ROOT="/opt/shared/.spack-edge"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load build tools first
   module purge
   module load cmake
   
   # Load Intel Classic compilers and MPI
   module load intel-oneapi-compilers-classic
   module load intel-oneapi-mpi
   
   # Load required libraries
   module load hdf5
   module load netcdf-c
   module load netcdf-fortran
   module load parallel-netcdf
   module load parallelio
   
   # Verify modules are loaded
   module list
   
   # Set ESMF build environment variables
   export ESMF_DIR="$(pwd)"
   export ESMF_SITE="hkust_hpc4"
   export ESMF_OS="Linux"
   export ESMF_COMPILER="intel"
   export ESMF_COMM="intelmpi"
   export ESMF_ABI="64"
   
   # Explicitly set Intel Classic compilers
   export ESMF_C="icc"
   export ESMF_CXX="icpc"
   export ESMF_F90="ifort"
   
   # Suppress Intel Classic compiler deprecation warnings
   export CFLAGS="-diag-disable=10441"
   export CXXFLAGS="-diag-disable=10441"
   
   # Set library paths
   export ESMF_NETCDF="nc-config"
   export ESMF_PNETCDF="pnetcdf-config"
   export ESMF_PIO="external"
   export ESMF_NUMA="ON"
   
   # Set optimization level
   export ESMF_BOPT="O"
   
   # Compile ESMF library only (use all available cores)
   make -j $(nproc) lib 2>&1 | tee hpc4_build.log

.. tip::
   Compilation typically takes approximately 1 hour. You can monitor progress by watching the build log file.

Verify Compilation
^^^^^^^^^^^^^^^^^^

After compilation completes, verify that ESMF was built successfully. At the end of the build log, you should see a message similar to:

.. code-block:: console

  ESMF library built successfully on Mon Dec 8 17:39:53 HKT 2025
  To verify, build and run the unit and system tests with: make check
  or the more extensive: make all_tests

You can check the build status and library files as follows:

.. code-block:: bash

   # Check build status
   make info
   
   # The output should show:
   # - ESMF_VERSION_STRING
   # - Compiler settings
   # - Library locations
   
   # Check for library files
   ls -lh lib/
   
   # You should see ESMF library files such as:
   # - libesmf.a
   # - libesmf.so (if shared libraries were built)

.. tip::
   **Verify Build Quality with Tests**
   
   To ensure ESMF was built correctly and all functionality works as expected, run the test suites:
   
   - **Quick verification** (recommended): Run ``make check`` to execute unit and system tests. This typically takes 15-30 minutes.
   - **Comprehensive testing**: Run ``make all_tests`` for the complete test suite, which includes additional validation tests. This may take several hours.
   
   Both test commands should be run in the same environment (with the same modules loaded) used for compilation. Test failures may indicate compatibility issues or missing dependencies.

Using ESMF in Your Application
-------------------------------

Setting Up ESMF Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After building ESMF, you need to set up the environment to use it in your applications:

.. code-block:: bash

   # Set ESMF installation directory
   export ESMFMKFILE=/path/to/esmf/lib/libO/Linux.intel.64.mpi.default/esmf.mk
   
   # Verify the file exists
   ls -l $ESMFMKFILE

The exact path to ``esmf.mk`` depends on your build configuration. Check the ``lib`` directory after compilation.

Compiling Applications with ESMF
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To compile applications that use ESMF, include the ESMF makefile fragment:

.. code-block:: makefile

   # Include ESMF configuration
   include $(ESMFMKFILE)
   
   # Use ESMF variables in your build
   my_app: my_app.o
       $(ESMF_F90LINKER) $(ESMF_F90LINKOPTS) -o $@ $^ $(ESMF_F90LINKPATHS) $(ESMF_F90LINKLIBS)
   
   my_app.o: my_app.F90
       $(ESMF_F90COMPILER) -c $(ESMF_F90COMPILEOPTS) $(ESMF_F90COMPILEPATHS) $<

ESMF Environment Variables Reference
-------------------------------------

Core Build Variables
^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Essential ESMF Environment Variables
   :header-rows: 1
   :widths: 25 50 25

   * - Variable
     - Description
     - Example Value
   * - ``ESMF_DIR``
     - Root directory of ESMF source code
     - ``$(pwd)``
   * - ``ESMF_SITE``
     - Site identifier for this build
     - ``hkust_hpc4``
   * - ``ESMF_OS``
     - Operating system
     - ``Linux``
   * - ``ESMF_COMPILER``
     - Compiler family (``aocc``, ``intel``, etc.)
     - ``intel``
   * - ``ESMF_COMM``
     - Communication layer (``openmpi``, ``intelmpi``, ``mpiuni``)
     - ``intelmpi``
   * - ``ESMF_ABI``
     - Application Binary Interface (32 or 64 bit)
     - ``64``

Compiler-Specific Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Compiler Selection Variables
   :header-rows: 1
   :widths: 25 50 25

   * - Variable
     - Description
     - Example Value
   * - ``ESMF_C``
     - C compiler executable
     - ``icx`` or ``icc``
   * - ``ESMF_CXX``
     - C++ compiler executable
     - ``icpx`` or ``icpc``
   * - ``ESMF_F90``
     - Fortran compiler executable
     - ``ifx`` or ``ifort``

Library Configuration Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Library Integration Variables
   :header-rows: 1
   :widths: 25 50 25

   * - Variable
     - Description
     - Example Value
   * - ``ESMF_NETCDF``
     - NetCDF configuration method
     - ``nc-config``
   * - ``ESMF_PNETCDF``
     - Parallel-NetCDF configuration method
     - ``pnetcdf-config``
   * - ``ESMF_PIO``
     - ParallelIO integration (``external`` or ``internal``)
     - ``external``
   * - ``ESMF_NUMA``
     - NUMA-awareness support (``ON`` or ``OFF``)
     - ``ON``
   * - ``ESMF_BOPT``
     - Build optimization (``O`` for optimized, ``g`` for debug)
     - ``O``

For a complete list of ESMF environment variables and build options, refer to the `official ESMF build documentation <https://earthsystemmodeling.org/docs/nightly/develop/ESMF_usrdoc/node10.html>`_.

Performance Optimization
------------------------

Build Optimization Levels
^^^^^^^^^^^^^^^^^^^^^^^^^^

ESMF supports different optimization levels through the ``ESMF_BOPT`` variable:

.. code-block:: bash

   # Optimized build (recommended for production)
   export ESMF_BOPT="O"
   
   # Debug build (for development and troubleshooting)
   export ESMF_BOPT="g"

Compiler-Specific Optimizations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For advanced users, you can add compiler-specific optimization flags:

**Intel Compilers:**

.. code-block:: bash

   # Add to your build environment
   export ESMF_F90COMPILEOPTS="-O3 -xHost -ip"
   export ESMF_CXXCOMPILEOPTS="-O3 -xHost -ip"

**AMD AOCC:**

.. code-block:: bash

   # Add to your build environment
   export ESMF_F90COMPILEOPTS="-O3 -march=native"
   export ESMF_CXXCOMPILEOPTS="-O3 -march=native"

.. warning::
   Custom compiler flags may affect portability. Test thoroughly before deploying to production.

NUMA Optimization
^^^^^^^^^^^^^^^^^

For systems with NUMA architecture, enabling NUMA support can improve performance:

.. code-block:: bash

   export ESMF_NUMA="ON"

This is particularly beneficial for multi-socket systems where memory locality matters.

Support and Resources
---------------------

**ESMF Documentation**

- `ESMF User's Guide <https://earthsystemmodeling.org/docs/nightly/develop/ESMF_usrdoc/>`_
- `ESMF Reference Manual <https://earthsystemmodeling.org/docs/nightly/develop/ESMF_refdoc/>`_
- `ESMF Build Documentation <https://earthsystemmodeling.org/docs/nightly/develop/ESMF_usrdoc/node10.html>`_
- `ESMF GitHub Repository <https://github.com/esmf-org/esmf>`_

**Compatible Architectures**

For a complete list of supported platforms, compilers, and configurations, see the `Supported Platforms section <https://earthsystemmodeling.org/docs/nightly/develop/ESMF_usrdoc/node10.html#SECTION000106000000000000000>`_ in the official documentation.

**Community Support**

- `ESMF Support Page <https://earthsystemmodeling.org/support/>`_
- `ESMF GitHub Discussions <https://github.com/orgs/esmf-org/discussions/>`_

**Version-Specific Notes**

.. important::
   This guide is specific to ESMF v9.x. For other versions:
   
   - ESMF v8.x may have different build requirements
   - Older versions may only support Intel Classic compilers
   - Check the version-specific documentation for compatibility information
