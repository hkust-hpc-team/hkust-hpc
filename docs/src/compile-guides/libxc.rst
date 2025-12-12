Libxc (Exchange-Correlation Functional Library)
===============================================

Libxc is a library of exchange-correlation functionals for density-functional theory (DFT). The library provides a comprehensive collection of local and semi-local functionals, as well as some hybrid functionals, widely used in quantum chemistry and solid-state physics applications.

.. contents:: Table of Contents
   :local:
   :depth: 2

Overview
--------

**Libxc Version:** 7.0.0

**Official Repository:** https://gitlab.com/libxc/libxc

**Official Documentation:** https://www.tddft.org/programs/libxc/

.. note::
   **Try Spack Pre-compiled Version First**
   
   If you only need Libxc in its default configuration for your application, we strongly recommend using the pre-compiled version available through Spack. See the :doc:`Libxc Usage Guide </software/libxc/index>` for instructions on loading and using the module.

This guide demonstrates how to compile Libxc using the HPC module system with multiple compiler toolchains. Libxc supports compilation with various compilers and can be built as both static and shared libraries.

This guide is tested against Libxc version 7.0.0 on 2025-12-12. The build system uses the GNU Autotools build system (configure/make) and supports multiple compiler toolchains including AMD AOCC, Intel OneAPI, and Intel Classic compilers.

Prerequisites
-------------

Required Software Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Libxc requires the following software components:

- C/CXX/Fortran compiler toolset (AMD AOCC, Intel OneAPI, or Intel Classic)
- GNU Autotools (autoconf, automake, libtool)
- Binutils (for AMD AOCC builds)

System Requirements
^^^^^^^^^^^^^^^^^^^

- Sufficient disk space (~500MB for source code and build)
- Memory: At least 4GB RAM for serial compilation
- Time: Compilation takes approximately 15-30 minutes

Supported Compiler Toolchains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following table summarizes the supported compiler toolchains and their configurations:

.. list-table:: Compiler Toolchain Configuration
   :header-rows: 1
   :widths: 35 30 35

   * - Configuration
     - **Compiler Modules**
     - **Environment Variables**
   * - AMD AOCC
     - | ``autotools``
       | ``binutils``
       | ``aocc/5``
     - | ``CC="clang"``
       | ``CXX="clang++"``
       | ``FC="flang"``
   * - Intel OneAPI
     - | ``autotools``
       | ``binutils``
       | ``intel-oneapi-compilers``
     - | ``CC="icx"``
       | ``CXX="icpx"``
       | ``FC="ifx"``
   * - Intel Classic
     - | ``autotools``
       | ``intel-oneapi-compilers-classic``
     - | ``CC="icc"``
       | ``CXX="icpc"``
       | ``FC="ifort"``

Download Libxc Source Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create a working directory
   mkdir -p ~/libxc-build
   cd ~/libxc-build
   
   # Clone Libxc repository (version 7.0.0)
   git clone --depth 1 -b 7.0.0 https://gitlab.com/libxc/libxc.git
   cd libxc

Compilation Steps
-----------------

.. important::
   **Do not compile on login nodes!** Compilation is resource-intensive and should be performed on compute nodes.

Request Interactive Compute Node
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before compiling, request an interactive session on a compute node. For detailed instructions and examples, see:

:doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`

Once the interactive session starts, you'll be on a compute node where you can safely compile Libxc.

.. note::

   For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

Option 1: Build with AMD AOCC
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This configuration uses the AMD Optimizing C/C++ and Fortran Compilers.

.. note::
   **Important for AMD AOCC builds:** A manual modification to the libtool configuration is required before running configure. This addresses a linker compatibility issue with the AOCC compiler suite.

.. code-block:: bash

   # Navigate to Libxc source directory
   cd ~/libxc-build/libxc
   
   # Activate Spack environment
   export SPACK_ROOT="/opt/shared/.spack-edge"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load required build tools
   module purge
   module load autotools binutils
   
   # Load AMD AOCC compiler
   module load aocc/5
   
   # Verify modules are loaded
   module list
   
   # Clean previous build artifacts
   rm -rf build configure
   
   # Set compiler environment variables
   export CC="clang"
   export CXX="clang++"
   export FC="flang"
   
   # Generate configure script
   autoreconf -i 2>&1 | tee hpc4_build.log

**Manual Configuration File Edit:**

Before proceeding with the configure step, you must manually edit the ``m4/libtool.m4`` file:

1. Open ``m4/libtool.m4`` in your preferred editor
2. Search for the line containing: ``$wl-soname $wl$soname``
3. Replace it with: ``-fuse-ld=ld -Wl,-soname,$soname``
4. Save the file

.. code-block:: bash

   # After editing m4/libtool.m4, continue with configuration and build
   ./configure --prefix=$(pwd)/build --enable-shared --enable-static 2>&1 | tee -a hpc4_build.log
   
   # Compile Libxc (use all available cores)
   make -j $(nproc) 2>&1 | tee -a hpc4_build.log
   
   # Run test suite
   make check 2>&1 | tee -a hpc4_build.log
   
   # Install to build directory
   make install 2>&1 | tee -a hpc4_build.log

Option 2: Build with Intel OneAPI Compilers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This configuration uses the modern Intel OneAPI compilers (icx, icpx, ifx).

.. code-block:: bash

   # Navigate to Libxc source directory
   cd ~/libxc-build/libxc
   
   # Activate Spack environment
   export SPACK_ROOT="/opt/shared/.spack-edge"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load required build tools
   module purge
   module load autotools binutils
   
   # Load Intel OneAPI compilers
   module load intel-oneapi-compilers
   
   # Verify modules are loaded
   module list
   
   # Clean previous build artifacts
   rm -rf build configure
   
   # Set compiler environment variables
   export CC="icx"
   export CXX="icpx"
   export FC="ifx"
   
   # Generate configure script
   autoreconf -i 2>&1 | tee hpc4_build.log
   
   # Configure build
   ./configure --prefix=$(pwd)/build --enable-shared --enable-static 2>&1 | tee -a hpc4_build.log
   
   # Compile Libxc (use all available cores)
   make -j $(nproc) 2>&1 | tee -a hpc4_build.log
   
   # Run test suite
   make check 2>&1 | tee -a hpc4_build.log
   
   # Install to build directory
   make install 2>&1 | tee -a hpc4_build.log

Option 3: Build with Intel Classic Compilers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This configuration uses the classic Intel compilers (icc, icpc, ifort).

.. code-block:: bash

   # Navigate to Libxc source directory
   cd ~/libxc-build/libxc
   
   # Activate Spack environment
   export SPACK_ROOT="/opt/shared/.spack-edge"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load required build tools
   module purge
   module load autotools
   
   # Load Intel Classic compilers
   module load intel-oneapi-compilers-classic
   
   # Verify modules are loaded
   module list
   
   # Clean previous build artifacts
   rm -rf build configure
   
   # Set compiler environment variables
   export CC="icc"
   export CXX="icpc"
   export FC="ifort"
   
   # Generate configure script
   autoreconf -i 2>&1 | tee hpc4_build.log
   
   # Configure build
   ./configure --prefix=$(pwd)/build --enable-shared --enable-static 2>&1 | tee -a hpc4_build.log
   
   # Compile Libxc (use all available cores)
   make -j $(nproc) 2>&1 | tee -a hpc4_build.log
   
   # Run test suite
   make check 2>&1 | tee -a hpc4_build.log
   
   # Install to build directory
   make install 2>&1 | tee -a hpc4_build.log

.. tip::
   Compilation typically takes approximately 15-30 minutes depending on the number of cores used. You can monitor progress by watching the build log file.

Verify Compilation
^^^^^^^^^^^^^^^^^^

After compilation completes, verify that Libxc was built successfully:

.. code-block:: bash

   # Check installation directory
   ls -lh build/
   
   # You should see directories such as:
   # - include/  (header files)
   # - lib/      (library files)
   # - share/    (documentation and data files)
   
   # Check for library files
   ls -lh build/lib/
   
   # You should see Libxc library files such as:
   # - libxc.a
   # - libxc.so
   # - libxcf03.a (Fortran 2003 interface)
   # - libxcf90.a (Fortran 90 interface)

.. tip::
   **Verify Build Quality with Tests**
   
   The ``make check`` command runs the test suite to ensure Libxc was built correctly and all functionals work as expected. This typically takes 5-10 minutes.

Using Libxc in Your Application
--------------------------------

Setting Up Libxc Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After building Libxc, you need to set up the environment to use it in your applications:

.. code-block:: bash

   # Set Libxc installation directory
   export LIBXC_ROOT=/path/to/libxc/build
   
   # Add library path
   export LD_LIBRARY_PATH=${LIBXC_ROOT}/lib:${LD_LIBRARY_PATH}
   
   # Add include path for compilation
   export CPATH=${LIBXC_ROOT}/include:${CPATH}


Configure Options Reference
----------------------------

For advanced users who need specific optimizations or features, additional flags can be passed to the ``./configure`` script.

.. code-block:: bash

   # Example: Disable Fortran interfaces if not needed
   ./configure --prefix=$(pwd)/build --enable-shared --enable-static --disable-fortran
   
   # Example: Enable specific optimization flags
   CFLAGS="-O3 -march=native" ./configure --prefix=$(pwd)/build --enable-shared --enable-static

.. tip::
   Use ``./configure --help`` to see all available configuration options for Libxc.

Integration with DFT Codes
---------------------------

Libxc is commonly used with various density-functional theory codes.

Support and Resources
---------------------

**Libxc Documentation**

- `Libxc Website <https://www.tddft.org/programs/libxc/>`_
- `Libxc GitLab Repository <https://gitlab.com/libxc/libxc>`_
- `GitLab Issues <https://gitlab.com/libxc/libxc/-/issues>`_

**Citations**

If you use Libxc in your research, please cite the appropriate papers:

- S. Lehtola et al., *SoftwareX* **7**, 1 (2018)
- M.A.L. Marques et al., *Comput. Phys. Commun.* **183**, 2272 (2012)
