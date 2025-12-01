Software Support Overview
=========================

The HKUST HPC clusters provide a wide range of pre-installed software modules. We utilize **Spack** for package management and **Lmod** for environment module management.

Our software stack is organized in a hierarchy:

1.  **Core (Root)**: Compilers, Interpreters, Utilities, and GPU Drivers (Listed below).
2.  **Compiler Dependent**: Libraries and tools built with a specific compiler.
3.  **MPI Dependent**: Parallel applications built with a specific Compiler and MPI combination.

Up-to-date software is available **through activating of an alternative Spack instance.**


.. contents:: Table of Contents
   :local:
   :depth: 3

Spack Instances
---------------

We maintain multiple Spack instances to provide different sets of software packages:

.. list-table::
   :widths: 25 35 40
   :header-rows: 1

   * - Characteristic
     - Default Instance
     - Edge Instance
   * - **Date of Build**
     - Mid 2024
     - Weekly updates
   * - **Software Ecosystem**
     - Basic
     - Large, multi-versioned
   * - **CUDA Support**
     - ✓
     - ✓
   * - **Lmod Hierarchy**
     - Flat
     - Hierarchical (Compiler + MPI)
   * - **Spack Version**
     - 0.22.0 (May 2024)
     - 0.23.x (Mar 2025) with package backports
   * - **Status**
     - Deprecating (Frozen)
     - Semi-stable
   * - **Compatibility**
     - Standalone
     - Forward-compatible
   * - **$SPACK_ROOT**
     - | HPC4: ``/opt/shared/spack``
       |
       | Superpod: ✗
     - | HPC4: ``/opt/shared/.spack-edge``
       |
       | Superpod: ``/scratch/spack/2025``

.. tip::

   We recommend using the **edge instance** for all new work as it provides the latest software packages and is forward-compatible with future updates.
   
   The default instance is deprecated and maintained only for backward compatibility.

Activating a Spack Instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **default** instance, when available, is automatically activated upon login on HPC4.

To activate the **alternative instance**, source its setup script:

.. code-block:: bash

   # Acknowledge the Terms of Service and activate an alternative spack instance
   source "${SPACK_ROOT}/dist/bin/setup-envs.sh"

.. note::
   The first-time activation includes a bootstrapping process that may take a few minutes. Subsequent activations will be much faster.

When activating an alternative Spack instance for the first time, you'll see output similar to:

.. code-block:: console

   [user@login2 ~]$ source /opt/shared/.spack-edge/dist/bin/setup-env.sh

   You are using non-default spack instances.
   Please do not mix packages installed from different spack instances.

   This script will unload all other spack instances and modules automatically.

   ==> Checking spack config and cache paths


       Spack instance root: /opt/shared/.spack-edge
       Shared apps and modules: /opt/shared/.spack-edge/dist
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       Your spack config: /home/user/.spack-edge
       Your spack apps: /home/user/.spack-edge
       Tmpdir (TMPDIR and TMP): /tmp/user-XXXX

   ==> Activate spack instance [edge]? [y/N] y

   i=> You can use '-y' option to skip this confirmation next time.

   ==> First launch: bootstrapping spack [edge]
       This may take a few minutes, please wait...
   ==> First launch: bootstrapping spack [dev]
       This may take a few minutes, please wait...
   ==> Warning: error detecting "msvc" from prefix /opt/shared/.spack-dev/opt/spack/linux-rocky9-x86_64_v4/gcc-11.5.0.spack/intel-oneapi-compilers-2025.0.4-sn26au2eyxigpsati3gb5oxmtku6s5uo/compiler/2025.0/bin: [KeyError: 'cxx']
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:16f27dafb233a9aff14adff75112d0a8b2e03492f796f12101785c02950aa7f6
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:b76a4eaef54b24d0ea9b8dfa9392f7ab519f918ae7e1a8bb919539d9adeddbcb
   ==> Installing "gcc-runtime@=10.2.1 build_system=generic arch=linux-centos7-x86_64 %gcc@=10.2.1" from a buildcache
   ==> Warning: The default behavior of tarfile extraction has been changed to disallow common exploits (including CVE-2007-4559). By default, absolute/parent paths are disallowed and some mode bits are cleared. See https://access.redhat.com/articles/7004769 for more details.
   ==> Warning: lib/libgfortran.so.5
           libz.so.1 => not found
   dependencies:
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:5367a0d038a87532fbbe373da31502bd32e399cc113343f403ebbc9d8ca7d552
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:79dfb7064e7993a97474c5f6b7560254fe19465a6c4cfc44569852e5a6ab542b
   ==> Installing "patchelf@=0.17.2 build_system=autotools arch=linux-centos7-x86_64 %gcc@=10.2.1" from a buildcache
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:82ec278bef26c42303a2c2c888612c0d37babef615bc9a0003530e0b8b4d3d2c
   ==> Fetching https://ghcr.io/v2/spack/bootstrap-buildcache-v1/blobs/sha256:0c5831932608e7b4084fc6ce60e2b67b77dab76e5515303a049d4d30cd772321
   ==> Installing "clingo-bootstrap@=spack~docs+ipo+optimized+python+static_libstdcpp build_system=cmake build_type=Release generator=make patches=bebb819,ec99431 arch=linux-centos7-x86_64 %gcc@=10.2.1" from a buildcache


   ==> Spack [edge] environment is ready

For non-interactive shells (e.g., in batch scripts), use the ``-y`` flag to avoid prompts

.. code-block:: bash

   # Non-interactive activation, do not ask for input
   source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y

After sourcing, you can verify the active instance:

.. code-block:: bash

   # Check which Spack instance is active
   echo $SPACK_VARIANT

.. caution::

   **Do not add Spack activation to your** ``~/.bashrc`` **or** ``~/.bash_profile``. Activating Spack automatically may cause slow login and compatibility issues with SLURM batch jobs.

   **Best practice**: Activate Spack on-demand when you need to use software modules, or at the beginning of SLURM job scripts. For batch scripts, always use the ``-y`` flag to skip confirmation prompts:

   .. code-block:: bash

      # In SLURM job scripts
      source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
      module load python/3.12.9
      # ... rest of your job script

Spack Environment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When a Spack instance is activated, we configure Spack to use certain paths and set a number of environment variables.

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Variable
     - Description
   * - ``$SPACK_ROOT``
     - Root directory of the active Spack instance
   * - ``$SPACK_VARIANT``
     - Name of the active instance
   * - ``$SPACK_PYTHON``
     - Python interpreter used by Spack
   * - ``$SPACK_SYSTEM_CONFIG_PATH``
     - System-level Spack configuration directory
   * - ``$SPACK_USER_CONFIG_PATH``
     - User-specific Spack configuration directory
   * - ``$SPACK_USER_CACHE_PATH``
     - User-specific Spack cache directory

.. seealso::
   For more information about Spack, refer to the official documentation: https://spack.readthedocs.io/en/latest/

Lmod Modules
------------

Lmod modules are provided by the Spack instance, so the available modules depend on which instance is active.

.. tip::

   Check that your desired Spack instance is active before using ``module`` commands.

Loading and managing modules
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To load a specific software module, use the ``module`` command:

.. code-block:: bash

   # List available modules
   module avail

   # Load a specific module (e.g., Python 3.12)
   module load python/3.12.9

   # Unload a specific module
   module unload python

   # Unload all modules
   module purge

.. important::
   **Do not include the 7-digit hash suffix** when loading modules (e.g., use ``python/3.12.9`` instead of ``python/3.12.9-abc1234``). The hash may change when packages are rebuilt, which would break your scripts.

Understanding the Lmod Hierarchy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We adopt a **hierarchical module system** where loading a compiler or MPI library reveals additional modules built with that toolchain.

**Example workflow:**

1. **Initially**, you see only core modules:

   .. code-block:: bash

      $ module avail
      ---- Core Modules ----
      gcc/14.2.0
      intel-oneapi-compilers/2025.0.4
      python/3.12.9
      ...

2. **After loading a compiler**, compiler-dependent modules become available:

   .. code-block:: bash

      $ module load intel-oneapi-compilers/2025.0.4
      $ module avail

      ---- Core Modules ----
      ...

      ---- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/oneapi/2025.0.4 ----       
      fftw/3.3.10                   openmpi/4.1.8
      intel-oneapi-mpi/2021.14.2    openmpi/5.0.6              (D)
      ...

3. **After loading an MPI library**, MPI-dependent modules appear:

   .. code-block:: bash

      $ module load openmpi/5.0.6
      $ module avail

      ---- Core Modules ----
      ...

      ---- /opt/shared/.spack-edge/.../oneapi/2025.0.4 ----
      ...

      ---- /opt/shared/.spack-edge/.../oneapi/2025.0.4/openmpi/5.0.6 ----
      hdf5/1.14.5            netcdf-c/4.9.2
      parallel-netcdf/1.12.3 scalapack/2.2.0
      ...

This hierarchy ensures you're using compatible versions of libraries built with the same compiler and MPI combination.

.. seealso::
   For more information about Lmod, refer to the official documentation: https://lmod.readthedocs.io/en/latest/


Compiler Support
----------------

Here is a list of maintained C/C++/Fortran compilers for building high-performance applications.

.. caution::

   Libraries built with AMD AOCC are only compatible with AMD CPU (zen4 architecture). **Do not use AOCC-built libraries on Intel CPUs** as it may lead to unexpected crashes.

.. note::
   **Bold** versions are the default versions loaded when using ``module load`` without specifying a version number.
   
   Deprecated package are marked as :strike:`versions @edge` in the ``edge`` Spack variant, deprecated packages will be removed in the next production variant.

.. list-table::
   :widths: 20 20 15 15 30
   :header-rows: 1

   * - Compiler
     - Versions
     - Library Support
     - MPI Support
     - Compiler Command
   * - **AMD aocc**
     - | :strike:`4.2.0 @edge`
       | **5.0.0**
     - ✓
     - ✓
     - .. code-block::

          CC=clang
          CXX=clang++
          FC=flang
   * - **GNU gcc**
     - | 12.4.0
       | 13.3.0
       | **14.2.0**
     - 
     - 
     - .. code-block::

          CC=gcc
          CXX=g++
          FC=gfortran
   * - **Intel OneAPI**
     - | :strike:`2021.4.0 @edge`
       | :strike:`2022.2.1 @edge`
       | 2023.2.4
       | 2024.2.1
       | **2025.0.4**
     - ✓
     - ✓
     - .. code-block::

          CC=icx
          CXX=icpx
          FC=ifx
   * - **Intel Classic**
     - **2021.10.0**
     - ✓
     - ✓
     - .. code-block::

          CC=icc
          CXX=icpc
          FC=ifort
   * - **Nvidia nvhpc**
     - | 23.11
       | 24.11
       | **25.1**
     - 
     - 
     - .. code-block::

          CC=nvc
          CXX=nvc++
          FC=nvfortran

MPI Support
^^^^^^^^^^^

The following table shows tested compiler and MPI combinations available in the edge instance. A checkmark (✓) indicates the combination has been tested and is available.

.. list-table::
   :widths: 30 20 20 20
   :header-rows: 1
   :stub-columns: 1

   * - Compiler / MPI
     - Intel MPI 2021.14
     - OpenMPI 4.1.x
     - OpenMPI 5.x
   * - **AOCC 5.0**
     - 
     - ✓
     - ✓
   * - **AOCC 4.2**
     - 
     - 
     - 
   * - **Intel OneAPI 2025**
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2024**
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2023**
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2022**
     - 
     - 
     - 
   * - **Intel OneAPI 2021**
     - 
     - 
     - 
   * - **Intel Classic 2021.10 (OneAPI 2023)**
     - ✓
     - 
     - 
   * - **NVHPC 25.1**
     - 
     - ✓
     - ✓
   * - **NVHPC 24.11**
     - 
     - ✓
     - ✓
   * - **NVHPC 23.11**
     - 
     - ✓
     - ✓
   * - **GCC 14.2**
     - 
     - 
     - 
   * - **GCC 13.3**
     - 
     - 
     - 
   * - **GCC 12.4**
     - 
     - 
     - 

CUDA Support
^^^^^^^^^^^^

The following table shows which compilers have CUDA support enabled for GPU programming and their MPI compatibility when building packages via Spack.

**[untested]** For compilers without Spack's native CUDA support (GCC, AOCC), directly loading CUDA Toolkit separately with ``module load cuda`` might work.

.. list-table::
   :widths: 30 15 15 15 15
   :header-rows: 1
   :stub-columns: 1

   * - Compiler / MPI
     - CUDA Support
     - Intel MPI 2021.14
     - OpenMPI 4.1.x
     - OpenMPI 5.x
   * - **NVHPC 25.1**
     - ✓
     - 
     - ✓
     - ✓
   * - **NVHPC 24.11**
     - ✓
     - 
     - ✓
     - ✓
   * - **NVHPC 23.11**
     - ✓
     - 
     - ✓
     - ✓
   * - **Intel OneAPI 2025**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2024**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2023**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Intel OneAPI 2022**
     - ✗
     - 
     - 
     - 
   * - **Intel OneAPI 2021**
     - ✗
     - 
     - 
     - 
   * - **Intel Classic 2021.10**
     - ✗
     - 
     - 
     - 
   * - **GCC (all versions)**
     - ✗
     - 
     - 
     - 
   * - **AOCC (all versions)**
     - ✗
     - 
     - 
     - 

List of pre-built software and libraries
----------------------------------------

Libraries compiled by Intel compilers are optimized for latest Intel and AMD CPUs, while those compiled by AOCC are optimized for AMD CPUs only.

.. caution::

   Libraries built with AMD AOCC are only compatible with AMD CPU (zen4 architecture). **Do not use AOCC-built libraries on Intel CPUs** as it may lead to unexpected crashes.

.. note::
   **Bold** versions are the default versions loaded when using ``module load`` without specifying a version number.
   
   Deprecated package are marked as :strike:`versions @edge` in the ``edge`` Spack variant, deprecated packages will be removed in the next production variant.

Pre-built HPC Applications
^^^^^^^^^^^^^^^^^^^^^^^^^^

MPI-enabled Libraries
^^^^^^^^^^^^^^^^^^^^^

These libraries become available after loading both a compiler and an MPI implementation. They are built specifically for parallel computing applications.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **fftw**
     - | Fastest Fourier Transform in the West
       | - Single & Double precision
     - **3.3.10**
     - 
   * - **hdf5**
     - | Hierarchical Data Format 5
       | - Subfile, szip enabled
     - **1.14.5**
     - 
   * - **netcdf-c**
     - | Network Common Data Form (C library)
       | - Pnetcdf, szip enabled
     - **4.9.2**
     - 
   * - **netcdf-fortran**
     - Network Common Data Form (Fortran library)
     - **4.6.1**
     - 
   * - **parallel-netcdf**
     - Parallel I/O library for NetCDF file access
     - **1.14.0**
     - 
   * - **parallelio**
     - | High-level parallel I/O library
       | - Pnetcdf enabled
     - **2.6.3**
     - 

Intel Compiler Specific Libraries
""""""""""""""""""""""""""""""""""

Libraries exclusively available when using Intel OneAPI or Intel Classic compilers with MPI.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **intel-oneapi-mkl**
     - | Intel Math Kernel Library
       | - ScaLAPACK, Distributed FFT etc. included
     - | 2023.2.0
       | 2024.2.2
       | **2025.0.1**
     - 

Compiler-optimized Libraries
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These libraries are optimized for specific compiler toolchains and become available after loading the corresponding compiler module.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **boost**
     - | Boost C++ Libraries
       | - all subsets included
     - **1.87.0**
     - 
   * - **eigen**
     - C++ Template Library for Linear Algebra
     - **3.4.0**
     - 
   * - **fftw**
     - | Fastest Fourier Transform in the West
       | - Single & Double precision
     - **3.3.10**
     - 
   * - **glib**
     - GNOME Core Library
     - **2.72.4**
     - 
   * - **gsl**
     - GNU Scientific Library
     - **2.8**
     - 

AOCC Specific Libraries
"""""""""""""""""""""""

AMD-optimized libraries available exclusively with AMD Optimizing C/C++ Compiler (AOCC).

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **AMD AOCL**
     - | AMD AOCL Libraries
       | - all features enabled
     - **5.0**
     - 
   * - **amdblis**
     - AMD BLAS-Like Instant Software (Optimized BLAS)
     - **5.0**
     - 
   * - **amdfftw**
     - AMD Optimized FFTW (Fast Fourier Transform)
     - **5.0**
     - 
   * - **amdlibflame**
     - AMD FLAME Library (Linear algebra)
     - **5.0**
     - 
   * - **amdlibm**
     - AMD Math Library (Optimized libm)
     - **5.0**
     - 

Generic Software
^^^^^^^^^^^^^^^^

The following sections list categories of software packages available at the **Root** level. Packages are compiled with a freshly built GCC 11.5.0 compiler independent of OS.

GPU & AI Infrastructure
"""""""""""""""""""""""

Core libraries and drivers for GPU computing.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **CUDA**
     - NVIDIA Compute Unified Device Architecture
     - | 11.8.0
       | 12.2.2
       | 12.3.2
       | 12.4.1
       | 12.5.1
       | 12.6.3
       | **12.8.0**
     - 
   * - **cuDNN**
     - NVIDIA CUDA Deep Neural Network library for CUDA 11/12
     - | 8.9.7
       | **9.2.0**
     - 

Math & Data Science
"""""""""""""""""""

Platforms for mathematical computing, statistical analysis, and data science.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **MATLAB**
     - Numerical computing platform
     - | R2019b
       | R2022b
       | **R2023b**
     - :doc:`Details <./matlab/index>`
   * - **Octave**
     - Scientific Programming Language (MATLAB-compatible)
     - **9.4.0**
     - 
   * - **Python**
     - Python Programming Language
     - | 3.9.21
       | 3.10.16
       | 3.11.11
       | 3.12.9
       | **3.13.2**
     - :doc:`Details <./python/index>`
   * - **Anaconda3**
     - Python Data Science Platform
     - **2024.10**
     - :doc:`Details <./python/index>`
   * - **R**
     - R Language for Statistical Computing
     - **4.4.2**
     - :doc:`Details <./r/index>`
   * - **RStudio**
     - Integrated Development Environment for R
     - **2024.12.1**
     - :doc:`Details <./r/index>`

Language Runtimes
"""""""""""""""""

Runtime environments for various programming languages.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **OpenJDK**
     - Open Source Java Development Kit
     - | 1.8.0_265
       | 11.0.23
       | **17.0.11**
     - :doc:`Details <./java/index>`
   * - **Rust**
     - Rust Systems Programming Language
     - **1.85.0**
     - 
   * - **Go**
     - The Go Programming Language
     - **1.24.1**
     - 
   * - **Dotnet Core SDK**
     - .NET Core Software Development Kit
     - **8.0.4**
     - 
   * - **Node.js**
     - JavaScript runtime built on Chrome's V8
     - **22.14.0**
     - 
   * - **OCaml**
     - Functional programming language
     - **5.2.1**
     - 

Scripting Languages
"""""""""""""""""""

High-level scripting and interpreted languages.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Perl**
     - Practical Extraction and Report Language
     - **5.40.0**
     - :doc:`Details <./perl/index>`
   * - **Ruby**
     - Dynamic, open source programming language
     - **3.3.5**
     - 
   * - **Lua**
     - Lightweight, multi-paradigm scripting language
     - **5.4.6**
     - 
   * - **Tcl**
     - Tool Command Language
     - **8.6.12**
     - 
   * - **Bash**
     - GNU Bourne Again Shell
     - **5.2**
     - 
   * - **Tcsh**
     - C Shell with file name completion
     - **6.24.14**
     - 

Visualization & Media
"""""""""""""""""""""

Tools for graphics, visualization, and media processing.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Gnuplot**
     - Portable command-line driven graphing utility
     - **6.0.0**
     - 
   * - **VMD**
     - Visual Molecular Dynamics
     - **1.9.3**
     - 
   * - **ImageMagick**
     - Image creation and modification tools
     - **7.1.1-39**
     - 
   * - **FFmpeg**
     - Video and Audio processing suite
     - | 4.4.4
       | 5.1.4
       | 6.1.1
       | **7.1**
     - 

Build Tools & Development
"""""""""""""""""""""""""

Tools for building, configuring, and managing software projects.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Binutils**
     - GNU Binary Utilities
     - **2.43.1**
     - 
   * - **CMake**
     - Cross-platform build system generator
     - **3.31.6**
     - 
   * - **Meson**
     - Modern build system
     - **1.7.0**
     - 
   * - **Ninja**
     - Small build system with a focus on speed
     - **1.12.1**
     - 
   * - **Autotools**
     - GNU Build System (Autoconf, Automake, Libtool)
     - **master**
     - 
   * - **Gmake**
     - GNU Make
     - **4.4.1**
     - 
   * - **SCons**
     - Software construction tool
     - **4.7.0**
     - 
   * - **Bazel**
     - Build and test tool (Google)
     - **7.0.2**
     - 
   * - **Maven**
     - Build automation tool for Java
     - **3.9.8**
     - 
   * - **Gradle**
     - Build automation tool for multi-language
     - **8.10.2**
     - 
   * - **Ant**
     - Java build tool
     - **1.10.14**
     - 

Version Control
"""""""""""""""

Version control systems and related tools.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Git**
     - Distributed version control system
     - **2.48.1**
     - 
   * - **Git-LFS**
     - Git Large File Storage
     - **3.5.1**
     - 
   * - **Subversion**
     - Centralized version control system
     - **1.14.2**
     - 
   * - **Mercurial**
     - Distributed version control system
     - **6.7.3**
     - 
   * - **CVS**
     - Concurrent Versions System
     - **1.12.13**
     - 

Debugging & Profiling
"""""""""""""""""""""

Tools for debugging, testing, and code analysis.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **GDB**
     - GNU Debugger
     - **15.2**
     - 
   * - **GoogleTest**
     - Google C++ Testing Framework
     - **1.15.2**
     - 

Libraries
"""""""""

Core system libraries and development tools.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Jasper**
     - JPEG-2000 codec library
     - | 1.900.31
       | **4.2.8**
     - 
   * - **libpng**
     - PNG reference library
     - **1.6.39**
     - 
   * - **libtirpc**
     - Transport Independent RPC library
     - **1.3.3**
     - 

Utilities & Tools
"""""""""""""""""

General system utilities, editors, and productivity tools.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **Emacs**
     - Extensible text editor
     - **30.1**
     - 
   * - **Neovim**
     - Hyperextensible Vim-based text editor
     - **0.11.5**
     - 
   * - **Zsh**
     - Z Shell
     - **5.9**
     - 
   * - **Screen**
     - Terminal multiplexer
     - **4.9.1**
     - 
   * - **Parallel**
     - GNU Parallel (Shell tool for executing jobs in parallel)
     - **20240822**
     - 
   * - **dos2unix**
     - Text file format converter
     - **7.4.4**
     - 
   * - **EasyBuild**
     - Software build and installation framework
     - **4.7.0**
     - 

Cloud CLI & Package Managers
"""""""""""""""""""""""""""""

Command-line tools for cloud services and package management.

.. list-table::
   :widths: 25 40 20 15
   :header-rows: 1

   * - Software
     - Description
     - Version
     - Docs
   * - **AWS CLI v2**
     - Amazon Web Services Command Line Interface
     - **2.24.24**
     - 
   * - **Google Cloud CLI**
     - Google Cloud SDK
     - **504.0.1**
     - 
   * - **NPM**
     - Node Package Manager
     - **11.2.0**
     - 
   * - **Yarn**
     - JavaScript package manager
     - **1.22.22**
     - 
   * - **FPM**
     - Fortran Package Management
     - **0.10.0**
     - 

**Bold** denotes the default version.
