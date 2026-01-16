==========================================
Scientific Software Stack (Spack/Lmod)
==========================================

The scientific software stack represents Tier 2 of the HPC software ecosystem (see :doc:`index`), providing optimized, architecture-specific research software through Spack package manager and hierarchical Lmod modules. While the base OS provides system-integrated software requiring root privileges (:doc:`os-software-stack`), this tier addresses research computing requirements: multiple compiler toolchains, MPI implementations, scientific libraries, and domain-specific applications.

**Design principle:** Researchers access pre-built, optimized software through ``module load`` commands without administrative intervention or compilation expertise. The module system abstracts underlying complexity while enforcing compatibility through hierarchical organization.

Spack Overview
==============

Spack provides three critical capabilities for HPC software management:

**Multi-versioned software**
  Multiple versions of identical software coexist without conflicts. Researchers select versions matching application requirements independent of system-wide defaults.

**Multi-compiler/MPI combinations**
  Software builds against different compiler toolchains (GCC, Intel oneAPI, AMD AOCC, NVIDIA HPC SDK) and MPI implementations (OpenMPI, Intel MPI, MPICH). This addresses architecture-specific optimization requirements and application compatibility constraints.

**Multi-architecture targets**
  Architecture-specific builds optimize for target processors (AMD Zen4, Intel Sapphire Rapids, generic x86-64). Performance-sensitive applications leverage instruction set extensions (AVX-512, AVX2) without sacrificing portability to alternative architectures.

Module Provision and User Interaction
--------------------------------------

Spack's primary function is generating Lmod modules for researcher consumption:

**Standard interaction model:**
  Researchers use ``module load`` commands to access pre-built software. The module system abstracts Spack complexity while providing flexible access to optimized software stacks.

**Direct Spack usage limitations:**
  - Proprietary or highly customized software falls outside Spack's package scope
  - Module interface simplifies software selection compared to Spack's specification syntax
  - Researchers typically standardize on single architecture/compiler/MPI combinations
  - Spack requires understanding complex dependency resolution and build semantics

**Advanced user extensibility:**
  Users with Spack expertise can build additional software independently. The administrator-maintained module tree addresses common research requirements, while user Spack installations provide extensibility for specialized needs.

Hierarchical Module System
===========================

Architecture
------------

The hierarchical structure enforces compatibility by hiding incompatible software combinations:

.. important::
   
   This software layer builds upon the base OS software stack (:doc:`os-software-stack`). System compilers (GCC, system libraries) must function correctly before scientific software deployment. Container-based testing validates base OS integrity before Spack-based software installation.

.. code-block:: text

   Core Modules (always available)
   ├── Compilers: gcc, aocc, intel-oneapi-compilers, nvhpc
   ├── Runtimes: python, R, matlab, julia
   ├── Tools: cmake, git, ninja, maven
   └── ...
   
   Loading Compiler (e.g., aocc/5) reveals:
   ├── Compiler-specific libraries: boost, eigen, gsl
   ├── MPI implementations: openmpi, intel-oneapi-mpi
   └── Non-MPI scientific software
   
   Loading Compiler + MPI (e.g., aocc/5 + openmpi/5) reveals:
   ├── MPI-dependent libraries: hdf5, netcdf, parallel-netcdf
   ├── MPI applications: lammps, openfoam, mpas-model
   └── Parallel scientific frameworks

Example: AMD AOCC with OpenMPI
-------------------------------

Loading AMD-optimized toolchain for Zen4 architecture:

.. code-block:: console

   $ module load aocc/5 openmpi/5
   $ module avail

   --- Compiler + MPI specific (aocc/5 + openmpi/5) ---
   fftw/3.3.10           netcdf-c/4.9.2           parallel-netcdf/1.14.0
   hdf5/1.14.5           netcdf-fortran/4.6.1     parallelio/2.6.3

   --- Compiler specific (aocc/5) ---
   amdblis/5.0           aocl-compression/5.0     boost/1.87.0         libxc/7.0.0
   amdfftw/5.0           aocl-crypto/5.0          eigen/3.4.0          openmpi/4.1.8
   amdlibflame/5.0       aocl-libmem/5.0          gsl/2.8              openmpi/5.0.6 (L,D)

   --- Core (always available) ---
   anaconda3/2025        cmake/3.31               gcc/14.2             python/3.13
   aocc/5.0 (L)          cuda/12.8                git/2.48             r/4.4.2
   bash/5.2              ffmpeg/7.1               nvhpc/25.1           ...

Example: Intel oneAPI Toolchain
--------------------------------

Intel compilers with Intel MPI provide broader architecture support:

.. code-block:: console

   $ module load intel-oneapi-compilers/2025 intel-oneapi-mpi/2021
   $ module avail

   --- Compiler + MPI specific (oneapi/2025 + intel-mpi/2021) ---
   fftw/3.3.10           mpas-model/8.1           netcdf-fortran/4.6.1
   hdf5/1.14.5           netcdf-c/4.9.2           parallel-netcdf/1.14.0
   lammps/20250204       openfoam-org/12          parallelio/2.6.3

   --- Compiler specific (oneapi/2025) ---
   boost/1.87.0          gsl/2.8                  openmpi/4.1.8
   eigen/3.4.0           intel-oneapi-mkl/2025    openmpi/5.0.6
   glib/2.72.4           libxc/7.0.0              intel-oneapi-mpi/2021 (L)

Drop-in Replacement Capability
-------------------------------

Software stacks are designed for seamless compiler/MPI substitution. Loading equivalent libraries with different toolchains enables performance comparisons without code modification:

.. code-block:: console

   $ module load aocc/5 openmpi/5
   $ module load hdf5 netcdf-c netcdf-fortran fftw libxc
   
   $ module load intel-oneapi-compilers/2025 intel-oneapi-mpi/2021

   Lmod is automatically replacing "aocc/5" with "oneapi/2025"
   Lmod is automatically replacing "openmpi/5" with "intel-oneapi-mpi/2021"

   The following have been reloaded with version/architecture changes:
     1) fftw/3.3.10-zen4 => fftw/3.3.10-x86_64_v4
     2) hdf5/1.14.5-zen4 => hdf5/1.14.5-x86_64_v4
     3) netcdf-c/4.9.2-zen4 => netcdf-c/4.9.2-x86_64_v4
     4) netcdf-fortran/4.6.1-zen4 => netcdf-fortran/4.6.1-x86_64_v4
     5) libxc/7.0.0-zen4 => libxc/7.0.0-x86_64_v4

Software Management Strategy
=============================

Opinionated Defaults
--------------------

Reduce configuration complexity by establishing sensible defaults:

**Example: HDF5 configuration**

.. code-block:: yaml

   packages:
     hdf5:
       prefer:
         - "@1.14:"          # Recent version
         - +cxx +fortran     # Language bindings
         - +hl +map          # High-level APIs
         - +mpi +parallel    # Parallel I/O
         - +shared           # Shared libraries
         - +threadsafe       # Thread safety
       require:
         - +szip             # Compression support (mandatory)

**Example: NetCDF configuration**

.. code-block:: yaml

   packages:
     netcdf-c:
       prefer:
         - "@4.9:"           # Recent version
         - +blosc +zstd      # Modern compression
         - +mpi +parallel    # Parallel I/O
         - +optimize         # Performance optimizations
       require:
         - +parallel-netcdf  # PnetCDF support (mandatory)

**Rationale:**
  - Reduces "which variant do I need?" questions
  - Ensures commonly required features are available
  - Maintains consistency across compiler/MPI combinations
  - Simplifies troubleshooting (fewer configuration permutations)

Rebuild GCC from Source
------------------------

System GCC often lags current versions or lacks features. Rebuilding provides:

**Consistent baseline**
  Identical GCC version across all builds eliminates compiler version as variable in debugging.

**Feature completeness**
  Enable graphite optimization framework, profile-guided optimization, and link-time optimization (LTO).

**Architecture optimization**
  Bootstrap compiler with native architecture flags for optimal performance.

**Avoid OS bugs**
  Circumvent distribution-specific patches or configurations causing issues.

Example bootstrap configuration:

.. code-block:: yaml

   spack:
     compilers:
       - compiler:
           spec: gcc@=11.4.1.os  # System GCC
           paths:
             cc: /usr/bin/gcc
             cxx: /usr/bin/g++
             f77: /usr/bin/gfortran
             fc: /usr/bin/gfortran
     
     packages:
       all:
         require: "target=x86_64_v4 %gcc@11.4.1.os"
     
     specs:
       - "gcc@11.5.0 +binutils+bootstrap+graphite+piclibs+profiled \
          languages=c,c++,fortran,lto ^binutils@2.36:"

Modular Environments and Configurations
----------------------------------------

Spack environments partition software into logical groups, enabling parallel builds and maintainability:

**Environment organization:**

.. code-block:: console

   envs/
   ├── 0000-spack-gcc                # Bootstrap GCC
   ├── 1000-build-tools               # CMake, Make, Autotools
   ├── 1000-core-packages             # Python, R, Runtimes
   ├── 1001-cc-aocc                   # AMD AOCC compiler
   ├── 1001-cc-intel-oneapi           # Intel oneAPI compilers
   ├── 1001-cc-nvhpc                  # NVIDIA HPC SDK
   ├── 2000-aocc-openmpi              # AOCC + OpenMPI stack
   ├── 2000-oneapi-impi               # Intel + Intel MPI stack
   ├── 3000-netcdf-aocc-openmpi       # NetCDF built with AOCC
   ├── 3000-netcdf-oneapi-impi        # NetCDF built with Intel
   ├── 4001-lammps-oneapi-impi        # LAMMPS application
   ├── 5001-python                    # Python with packages
   ├── 5001-r                         # R with packages
   └── ...

**Configuration modularity:**

.. code-block:: yaml

   # include.yaml
   include:
     - path: package-policies/externals/os-external.yaml
     - path: package-policies/core.yaml
     - path: package-policies/build.yaml
     - path: package-policies/compilers/gcc.yaml
     - path: package-policies/compilers/aocc.yaml
     - path: package-policies/compilers/oneapi.yaml
     - path: package-policies/mpi-roce-slurm.yaml
     - path: package-policies/apps/hdf5-netcdf.yaml
     - path: package-policies/apps/cuda.yaml

**Benefits:**
  - Parallel environment builds reduce total build time
  - Isolated failures don't affect unrelated environments
  - Version control tracks configuration evolution
  - Modular structure simplifies updates and maintenance

GPU Software on CPU Nodes
--------------------------

CUDA and ROCm software builds don't require physical GPUs. Only matching driver/toolkit installation is necessary:

**Requirements:**
  - CUDA toolkit (matching driver version) installed on build node
  - No GPU hardware required during compilation
  - Runtime GPU access required only for execution

**Advantages:**
  - Build nodes don't require expensive GPU hardware
  - Parallel builds don't contend for limited GPU resources
  - Cross-compilation for multiple GPU architectures

Testing Scientific Software Stack
==================================

Test Strategy
-------------

Scientific software testing validates compiler/MPI combinations and runtime environments:

**Spack-level tests (containerized)**
  Verify software builds successfully and executes basic functionality. Run in isolated containers for rapid iteration.

**SLURM integration tests (production environment)**
  Validate scheduler integration, PMIx functionality, network fabric utilization, and multi-node communication.

Spack Test Suite (Containerized)
---------------------------------

Tests execute in containers matching production environments:

**Compiler validation:**

.. code-block:: bash

   #!/bin/bash
   # run-test-spack-cc.sh
   set -e
   
   # Load Spack
   source /opt/shared/.spack-edge/dist/bin/setup-env.sh
   
   # Test multiple compilers
   for COMPILER in gcc@14 aocc@5 intel-oneapi-compilers@2025; do
       module purge
       module load ${COMPILER}
       
       # Test C compiler
       echo "Testing ${COMPILER}"
       cat > test.c << 'EOF'
   #include <stdio.h>
   int main() { printf("Hello from C\n"); return 0; }
   EOF
       
       which gcc || which clang || which icx
       cc test.c -o test_c
       ./test_c
       
       echo "✓ ${COMPILER} validated"
   done

**MPI validation:**

.. code-block:: bash

   #!/bin/bash
   # run-test-spack-mpicc.sh
   set -e
   
   source /opt/shared/.spack-edge/dist/bin/setup-env.sh
   
   # Test compiler/MPI combinations
   for COMBO in "aocc/5 openmpi/5" "oneapi/2025 intel-oneapi-mpi/2021"; do
       module purge
       module load ${COMBO}
       
       # MPI Hello World
       cat > mpi_hello.c << 'EOF'
   #include <mpi.h>
   #include <stdio.h>
   int main(int argc, char** argv) {
       MPI_Init(&argc, &argv);
       int rank, size;
       MPI_Comm_rank(MPI_COMM_WORLD, &rank);
       MPI_Comm_size(MPI_COMM_WORLD, &size);
       printf("Rank %d of %d\n", rank, size);
       MPI_Finalize();
       return 0;
   }
   EOF
       
       mpicc mpi_hello.c -o mpi_hello
       mpirun -np 2 ./mpi_hello
       
       echo "✓ ${COMBO} validated"
   done

**Runtime validation (Python, R, MATLAB):**

Runtime testing validates not only executable presence but ecosystem functionality - package managers, parallel computing capabilities, and library repositories that define practical usability.

**Python ecosystem validation:**

.. code-block:: bash

   #!/bin/bash
   # run-test-spack-rt-python.sh
   set -e
   
   source "${SPACK_ROOT}/dist/bin/setup-envs.sh" -y
   module load python/${PYTHON_VERSION}
   
   # Basic interpreter
   python -c "print('Hello from Python')"
   
   # Package managers (essential for user workflows)
   pip3 --version
   poetry --version
   pdm --version
   uv --version
   
   # User package installation (validates ~/.local/ integration)
   pip3 install --user numpy
   python -c "import numpy; print(f'numpy {numpy.__version__}')"
   pip3 uninstall -y numpy

Python modules must provide package managers (pip, poetry, pdm, uv) as researchers depend on these tools for environment management and dependency installation. Testing user package installation validates ``~/.local/`` path integration.

**MATLAB parallel computing validation:**

.. code-block:: matlab

   % fixtures/test_parfor.m
   % Test MATLAB Parallel Computing Toolbox
   if license('test', 'Distrib_Computing_Toolbox')
       disp('Creating parallel pool with 16 workers...');
       pool = parpool('local', 16);
       
       n = 100;
       results = zeros(1, n);
       parfor i = 1:n
           results(i) = i^2;
       end
       
       expected = (1:n).^2;
       if isequal(results, expected)
           disp('parfor computation successful');
       else
           error('parfor computation failed');
       end
       
       delete(pool);
   else
       error('Parallel Computing Toolbox license not available');
   end

.. code-block:: bash

   # run-test-spack-rt-matlab.sh
   matlab -batch "run('test_parfor.m')"

MATLAB without Parallel Computing Toolbox provides limited utility for HPC applications. Testing ``parfor`` validates both license availability and parallel execution infrastructure.

**R CRAN repository validation:**

.. code-block:: bash

   #!/bin/bash
   # run-test-spack-rt-r.sh
   module load r/${R_VERSION}
   
   # Basic interpreter
   Rscript -e "print('Hello from R')"
   
   # CRAN repository access (essential for package ecosystem)
   Rscript -e "install.packages('ggplot2', repos='https://cran.rstudio.com/')"
   Rscript -e "library(ggplot2); print(packageVersion('ggplot2'))"

R without CRAN access cannot install packages, rendering it impractical for research workflows. Testing package installation validates repository connectivity and library installation mechanisms.

**Rationale:** These tests validate ecosystem completeness rather than mere executable presence. Researchers require functional package managers (Python), parallel computing capabilities (MATLAB), and library repositories (R) - basic "hello world" execution proves insufficient for production readiness.

SLURM Integration Tests (Production)
-------------------------------------

End-to-end validation through actual cluster job submission verifies scheduler integration and communication infrastructure:

**Validation requirements:**

Bare minimum testing validates all compiler/MPI combinations execute successfully in both single-node and cross-node configurations. This catches common failure modes:

- **PMIx integration failures:** MPI runtime fails to coordinate with SLURM process manager
- **Communication backend misconfiguration:** UCX or ibverbs libraries fail to link correctly or initialize network fabric
- **Network fabric driver issues:** InfiniBand/RoCE hardware not accessible to MPI runtime
- **Cross-node communication failures:** Single-node execution succeeds but inter-node communication fails

**Test program (validates communication infrastructure):**

.. code-block:: c

   // fixtures/mpi_hello.c
   #include <mpi.h>
   #include <stdio.h>
   #include <unistd.h>
   
   int main(int argc, char **argv) {
       int rank, size;
       char hostname[256];
       int sum_of_ranks;
   
       MPI_Init(&argc, &argv);
       MPI_Comm_rank(MPI_COMM_WORLD, &rank);
       MPI_Comm_size(MPI_COMM_WORLD, &size);
   
       gethostname(hostname, sizeof(hostname));
       printf("Hello from rank %d of %d on %s\n", rank, size, hostname);
   
       // Verify inter-process synchronization
       MPI_Barrier(MPI_COMM_WORLD);
   
       if (rank == 0) {
           printf("MPI Barrier completed successfully with %d processes\n", size);
       }
   
       // Verify collective communication
       MPI_Allreduce(&rank, &sum_of_ranks, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
   
       if (rank == 0) {
           printf("Sum of all ranks: %d\n", sum_of_ranks);
       }
   
       MPI_Finalize();
       return 0;
   }

The test program validates both synchronization (``MPI_Barrier``) and collective communication (``MPI_Allreduce``), ensuring the communication backend functions correctly across all processes.

**SLURM job script (excerpt):**

.. code-block:: bash

   #!/bin/bash
   #SBATCH --ntasks-per-node=256
   
   set -euo pipefail
   
   # Load compiler and MPI modules
   source "${SPACK_ROOT}/dist/bin/setup-envs.sh" -y
   module load ${CC_FAMILY}/${CC_VERSION}
   module load ${MPI_FAMILY}/${MPI_VERSION}
   
   # Configure MPI compiler wrapper
   case $MPI_FAMILY in
     openmpi)
       export OMPI_CC="$CC"
       MPICC="mpicc"
       ;;
     intel-oneapi-mpi)
       export I_MPI_CC="$CC"
       MPICC="mpicc"
       ;;
   esac
   
   # Compile test program
   ${MPICC} -o mpi_hello mpi_hello.c
   
   # Execute with SLURM (uses srun for PMIx integration)
   EXPECTED_SUM=$((SLURM_NTASKS * (SLURM_NTASKS - 1) / 2))
   srun mpi_hello > output.log 2>&1
   
   # Verify communication correctness
   ACTUAL_SUM=$(grep "Sum of all ranks:" output.log | awk '{print $NF}')
   if [ "$ACTUAL_SUM" = "$EXPECTED_SUM" ]; then
       echo "✓ Test passed: sum verified ($ACTUAL_SUM)"
   else
       echo "✗ Test failed: expected $EXPECTED_SUM, got $ACTUAL_SUM"
       exit 1
   fi

**Test submission script (generates test matrix):**

.. code-block:: bash

   #!/bin/bash
   # submit-mpi-tests.sh
   
   submit_job() {
     local nodes="$1"
     local cc_family="$2"
     local cc_version="$3"
     local mpi_family="$4"
     local mpi_version="$5"
     
     sbatch --nodes="$nodes" --time=00:30:00 \
       --export=ALL,CC_FAMILY="$cc_family",CC_VERSION="$cc_version",\
       MPI_FAMILY="$mpi_family",MPI_VERSION="$mpi_version" \
       run-test-slurm-mpicc.sh
   }
   
   # Test all compiler/MPI combinations, single and cross-node
   for nodes in 1 2; do
     # Intel oneAPI with multiple MPI options
     for cc_ver in 2023 2024 2025; do
       submit_job "$nodes" "intel-oneapi-compilers" "$cc_ver" \
         "intel-oneapi-mpi" "2021"
       submit_job "$nodes" "intel-oneapi-compilers" "$cc_ver" \
         "openmpi" "5"
     done
     
     # AMD AOCC with OpenMPI
     submit_job "$nodes" "aocc" "5" "openmpi" "5"
   done

**Success criteria:**
  - Compilation succeeds using Spack-provided MPI compiler wrappers
  - ``srun`` successfully launches processes via PMIx
  - ``MPI_Barrier`` completes (verifies synchronization infrastructure)
  - ``MPI_Allreduce`` produces correct result (verifies collective communication)
  - Cross-node tests verify inter-node fabric functionality

**Common failure modes:**
  - **PMIx coordination failure:** ``srun`` cannot communicate with MPI runtime
  - **UCX/ibverbs linking errors:** MPI runtime fails loading communication transport
  - **Network fabric initialization failure:** RDMA hardware not accessible
  - **Cross-node communication timeout:** Single-node succeeds but cross-node hangs or crashes

These tests execute automatically as part of scientific software stack deployment validation.

Usage-Driven Maintenance
=========================

Module usage statistics inform maintenance priorities:

**Metrics collection**
  Track module load frequency, user population, and usage patterns.

**Maintenance prioritization**
  - Frequently used software receives regular updates and testing
  - Rarely used packages may be deprecated
  - New software additions guided by usage trends

**Deprecation decisions**
  Data-driven approach to removing unmaintained or unused software reduces maintenance burden while preserving relevant capabilities.

Version Control and Reproducibility
====================================

All Spack configurations and environments reside in version control:

**Repositories:**
  - Forked Spack: https://github.com/hkust-hpc-team/spack
  - Environment configs: https://github.com/hkust-hpc-team/spack-community-config
  - Custom packages: https://github.com/hkust-hpc-team/spack-meta-pkgs

**Benefits:**
  - Complete software stack reproducibility
  - Configuration change tracking
  - Collaborative maintenance
  - Documented evolution of software environment

Conference Presentation
=======================

Comprehensive discussion of this approach presented at HPCSFcon 2025:

**An Opinionated-Default Approach to Enhance Spack Developer Experience**

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/bvQs5R_Ey0g" 
   title="An Opinionated-Default Approach to Enhance Spack Developer Experience" 
   frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
   allowfullscreen></iframe>

`Watch on YouTube <https://www.youtube.com/watch?v=bvQs5R_Ey0g>`_

Conclusion
==========

The Spack-based scientific software stack provides researchers with flexible, optimized, architecture-specific software without administrative intervention. Hierarchical modules enforce compatibility while enabling drop-in replacement of compiler/MPI combinations. Comprehensive testing validates functionality before deployment, reducing researcher-impacting issues.

Next: :doc:`container-support` describes container runtime integration for portable, reproducible workflows.
