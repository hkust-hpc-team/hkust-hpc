==============================
Base OS Software Stack
==============================

The base operating system provides foundational software requiring root privileges or deep system integration. This document focuses on implementation: what software belongs in the base OS and how to validate it functions correctly on HPC hardware.

Software Catalog
================

The following categories represent commonly pre-installed software in HPC base OS images. Exact package lists evolve based on researcher requirements and operational experience.

Hardware and Infrastructure
----------------------------

- **GPU drivers:** NVIDIA CUDA drivers, AMD ROCm, Intel oneAPI runtimes
- **Network drivers:** Mellanox OFED, InfiniBand/RoCE vendor-specific drivers
- **Scheduling:** SLURM client tools, PMIx libraries, job execution frameworks
- **Monitoring:** Diagnostic tools, performance monitoring, logging frameworks

Development Tools
-----------------

- **Build automation:** cmake, gmake, autoconf, automake, libtool
- **Compilers (system):** gcc, g++, gfortran (OS-provided baseline)
- **Debugging:** gdb, valgrind
- **Version control:** git, git-lfs, subversion, mercurial
- **Code analysis:** doxygen, cppcheck

System Libraries
----------------

- **Compression:** zlib, bzip2, xz, lz4, zstd
- **Cryptography:** openssl, libsodium
- **Data formats:** json-c, yaml-cpp, hdf5 (if not Spack-managed)
- **Graphics (system):** mesa, cairo, fontconfig, freetype
- **GUI frameworks:** qt5, gtk3, wxwidgets
- **Network:** curl, libcurl, openssh
- **Parsing:** libxml2, expat
- **Scripting support:** tcl, tk, lua

Visualization and Interactive Tools
------------------------------------

- **2D/3D graphics:** gnuplot, imagemagick, graphviz
- **Remote access:** x11vnc, tigervnc, xrdp
- **Terminal utilities:** tmux, screen, htop, ncurses

Module System
-------------

- **Environment management:** lmod (Lua-based hierarchical modules)
- **Shell integration:** bash, zsh completion scripts

Container Runtimes
------------------

- **HPC containers:** enroot, pyxis (GPU-aware SLURM integration)
- **Standard runtime:** apptainer/singularity (OCI-compatible)

Testing Base OS Software
=========================

Why Test Base OS Software?
---------------------------

While distribution maintainers thoroughly test their packages, HPC environments introduce unique validation requirements. The question isn't whether upstream did their job, but whether their assumptions and hardware support match your specific HPC configuration.

Key validation scenarios:

- **Hardware compatibility:** Verification that shipped binutils support target CPU instruction sets and GPU drivers correctly identify accelerator models.
- **Dependency stack integrity:** Compilers require binutils; MPI implementations depend on specific PMIx versions. Missing or misconfigured base components cascade failures throughout the software stack.
- **Configuration correctness:** Package installation via ``dnf install`` does not validate system configurations such as X11Forwarding in ``/etc/ssh/sshd_config`` or user namespace permissions.
- **Regression detection:** OS updates may introduce incompatibilities with established workflows, requiring validation before deployment.

Test Dimensions
---------------

Comprehensive software validation extends beyond basic execution verification:

**Executable presence and functionality**
  Verify tools exist in PATH and execute basic operations. While necessary, this validation alone proves insufficient - binaries may be present yet fail under production workload conditions.

**Dynamic linking validation**
  Executables must successfully resolve and load shared library dependencies at runtime. Missing libraries or ABI incompatibilities manifest as runtime failures despite successful package installation.

**Development library completeness**
  Header files and static/shared libraries must enable compilation and linking of dependent software. Missing ``-devel`` packages prevent building software that depends on these libraries.

**Alternative selection verification**
  Certain software categories support multiple implementations (module systems: Lmod versus environment-modules; MPI: OpenMPI versus MPICH). Validation ensures the intended implementation is active and properly configured.

Test Categories and Examples
-----------------------------

The following test examples demonstrate validation approaches that can be replicated for other software components in each category.

**Command-line utilities**
  Verify essential tools exist and execute:

  .. code-block:: bash

     #!/bin/bash
     # run-test-commandline-utils.sh
     set -e
     
     # Test common utilities
     command -v bash || exit 1
     command -v make || exit 1
     command -v cmake || exit 1
     command -v git || exit 1
     command -v tmux || exit 1
     
     echo "✓ Command-line utilities validated"

**System compilers**
  Test OS-provided GCC, G++, GFortran compile and execute successfully:

  .. code-block:: bash

     #!/bin/bash
     # run-test-os-gcc.sh
     set -e
     
     # Test C compiler
     cat > test.c << 'EOF'
     #include <stdio.h>
     int main() { printf("Hello from C\n"); return 0; }
     EOF
     
     gcc test.c -o test_c
     ./test_c
     
     echo "✓ OS GCC validated"

  Similar tests validate G++ (C++), GFortran (Fortran).

**Development libraries (compilation + linking)**
  Compile test programs linking against system libraries. This approach validates both header file availability and dynamic linking behavior:

  .. code-block:: bash

     #!/bin/bash
     # run-test-curl-devel.sh
     set -e
     
     # Test libcurl development files
     cat > test_curl.c << 'EOF'
     #include <curl/curl.h>
     int main() {
         CURL *curl = curl_easy_init();
         if(curl) {
             curl_easy_cleanup(curl);
             return 0;
         }
         return 1;
     }
     EOF
     
     gcc test_curl.c -lcurl -o test_curl
     ./test_curl
     
     echo "✓ curl-devel validated"

  Similar tests verify fontconfig, pmix, munge, and other libraries. These compilation tests have caught missing ``-devel`` packages that would otherwise prevent building dependent software.

**MPI functionality**
  Test system-provided MPI (e.g., Mellanox OpenMPI) compiles, links, and executes with actual communication:

  .. code-block:: bash

     #!/bin/bash
     # run-test-mlnx-openmpi.sh
     set -e
     
     # Locate MPI compiler
     MPICC=$(command -v mpicc) || exit 1
     
     # Test MPI program with communication
     cat > mpi_hello.c << 'EOF'
     #include <mpi.h>
     #include <stdio.h>
     #include <unistd.h>
     
     int main(int argc, char **argv) {
         int rank, size;
         char hostname[256];
         
         MPI_Init(&argc, &argv);
         MPI_Comm_rank(MPI_COMM_WORLD, &rank);
         MPI_Comm_size(MPI_COMM_WORLD, &size);
         
         gethostname(hostname, sizeof(hostname));
         printf("Hello from rank %d of %d on %s\n", rank, size, hostname);
         
         // Verify actual communication with barrier
         MPI_Barrier(MPI_COMM_WORLD);
         
         if (rank == 0) {
             printf("MPI Barrier completed successfully with %d processes\n", size);
         }
         
         MPI_Finalize();
         return 0;
     }
     EOF
     
     $MPICC mpi_hello.c -o mpi_hello
     mpirun -np 2 ./mpi_hello
     
     echo "✓ MPI functionality validated"

  .. important::
     
     The barrier call validates actual inter-process communication. Operational experience demonstrates that MPI initialization may succeed while inter-process communication fails, necessitating explicit communication validation.

**Alternative selection (Lmod vs environment-modules)**
  Verify the correct module system implementation is active:

  .. code-block:: bash

     #!/bin/bash
     # run-test-lmod.sh
     set -euo pipefail
     
     echo "=== Testing Lmod ==="
     
     echo "Checking module command is Lmod:"
     module --version 2>&1 | tee /tmp/lmod-version.txt
     
     echo "Verifying Lmod version output:"
     if grep -q "Modules based on Lua" /tmp/lmod-version.txt; then
         echo "✓ Lmod is correctly installed and based on Lua"
     else
         echo "✗ Failed to verify Lmod (might be environment-modules)"
         exit 1
     fi
     
     echo "Listing available modules:"
     module avail
     
     echo "=== Lmod Test Complete ==="

  This test specifically verifies Lmod (Lua-based) rather than the older environment-modules implementation, as both provide a ``module`` command but with different capabilities.

**GUI libraries (Qt5 example)**
  Test Qt5 installation paths and pkg-config integration:

  .. code-block:: bash

     #!/bin/bash
     # run-test-qt5.sh
     set -euo pipefail
     
     echo "=== Testing Qt5 ==="
     
     # Verify qtpaths command and Qt5 version
     command -v qtpaths
     qtpaths --qt-version
     
     # Check install prefix
     INSTALL_PREFIX=$(qtpaths --install-prefix)
     if [[ "$INSTALL_PREFIX" == /usr* ]]; then
         echo "✓ Qt5 install prefix: $INSTALL_PREFIX"
     else
         echo "✗ Unexpected Qt5 prefix: $INSTALL_PREFIX"
         exit 1
     fi
     
     # Test pkg-config integration
     pkg-config --exists Qt5Core || exit 1
     pkg-config --modversion Qt5Core
     
     echo "✓ Qt5 test complete"

  This validation confirms Qt5 installation location, command availability, and pkg-config integration support for dependent software compilation. Analogous validation strategies apply to other GUI frameworks (GTK, ATK, wxWidgets) using framework-specific tools and pkg-config packages.

Test Execution Framework
-------------------------

Tests organize into container-based workflows:

.. code-block:: text

   image-tests/
   ├── fixtures/           # Test program source files
   │   ├── hello.c
   │   ├── mpi_hello.c
   │   ├── test_curl.c
   │   └── ...
   ├── run-test-commandline-utils.sh
   ├── run-test-os-gcc.sh
   ├── run-test-curl-devel.sh
   ├── run-test-mlnx-openmpi.sh
   ├── run-test-lmod.sh
   └── run-test-qt5.sh

Kubernetes-based automation executes these tests when building OS images (see :doc:`../k8s-hpc/case-study-pxe-images` for details). Tests can also run manually in bash shells for debugging purposes.

Validation Workflow
===================

Comprehensive Validation Strategy
----------------------------------

Base OS validation proceeds in stages, each addressing different validation dimensions:

**Stage 1: Container-based software validation**
  Automated tests execute in containers, validating software functionality:
  
  - Command-line utilities present and executable
  - Compilers compile and execute test programs
  - Development libraries support compilation and linking
  - MPI implementations initialize and communicate
  - Module system operates correctly
  - GUI libraries accessible via pkg-config

**Stage 2: Deployment validation**
  Images passing container tests deploy to isolated test nodes for bare-metal validation:
  
  - **Bootability:** PXE boot process, GRUB configuration, initramfs integrity
  - **Driver sanity:** GPU drivers recognize hardware, network drivers initialize
  - **Kernel module availability:** Required modules load successfully
  - **Hardware detection:** System recognizes CPUs, GPUs, network adapters
  - **SLURM integration:** Job scheduler communication, PMIx operation
  - **Cross-node MPI:** Multi-node communication across physical interconnect
  - **Filesystem mounting:** NFS/Lustre client connectivity to production storage
  - **Network fabric:** InfiniBand/RoCE performance validation

**Stage 3: Progressive production rollout**
  After successful test node validation:
  
  1. Deploy to small production subset (5-10 nodes)
  2. Monitor for unexpected behavior (24-48 hours)
  3. Gradually expand to remaining infrastructure
  4. Maintain rollback capability throughout deployment

.. important::
   
   Container-based tests validate software layer integrity but cannot verify deployment-specific aspects requiring bare-metal hardware. Images must pass both container validation and bare-metal deployment testing before production rollout.

Bootability and Driver Validation
----------------------------------

Deployment validation addresses aspects inaccessible to container testing:

**Boot process verification:**

.. code-block:: bash

   # Deploy image to test node via PXE
   # Monitor boot process for failures
   # Verify successful multi-user.target
   
   ssh test-node 'systemctl status multi-user.target'
   ssh test-node 'journalctl -b | grep -i error'

**GPU driver sanity:**

.. code-block:: bash

   # Verify GPU recognition
   ssh test-node 'nvidia-smi'
   ssh test-node 'nvidia-smi --query-gpu=name,driver_version --format=csv'
   
   # Test CUDA runtime
   ssh test-node 'nvidia-smi topo -m'  # Topology verification

**Network driver validation:**

.. code-block:: bash

   # Verify InfiniBand/RoCE interfaces
   ssh test-node 'ibstat'
   ssh test-node 'ip link show | grep ib'
   
   # Test RDMA capabilities
   ssh test-node 'ibv_devinfo'

**Kernel module verification:**

.. code-block:: bash

   # Verify critical modules loaded
   ssh test-node 'lsmod | grep -E "mlx5|nvidia|ib_core"'
   
   # Test module loading
   ssh test-node 'modprobe -n <module_name>'  # Dry-run test

**SLURM integration:**

.. code-block:: bash

   # Submit test job
   srun --nodes=1 --nodelist=test-node hostname
   
   # Verify PMIx communication
   srun --nodes=2 --ntasks=2 --nodelist=test-node[1-2] \
        --mpi=pmix /path/to/mpi_hello

These validation steps occur on dedicated test nodes before production deployment, confirming hardware integration and system-level functionality beyond container testing scope.

Operational Considerations
===========================

Update Management
-----------------

**OS baseline updates**
  RHEL/Rocky Linux point releases introduce updated package versions. Test suite validation prevents regression of essential functionality prior to production deployment.

**Security patches**
  Critical vulnerabilities necessitate expedited patching cycles. Automated testing validates emergency updates without compromising system stability.

**Dependency conflicts**
  System library updates may conflict with Spack-built software. Pre-deployment testing identifies incompatibilities before they impact production environments.

Package Selection Rationale
----------------------------

**Inclusion criteria**
  - Requires root privileges or deep system integration
  - Provides broad utility across research domains
  - Exhibits complexity or fragility when installed via user-space package managers
  - Maintained by OS vendor with regular security updates

**Exclusion criteria**
  - Requires architecture-specific optimizations (better addressed through Spack)
  - Exhibits frequent version updates incompatible with OS release cycles
  - Serves limited user populations with specialized requirements
  - Better suited for container-based distribution

Conclusion
==========

The base OS software stack establishes foundational capabilities that enable immediate researcher productivity. Pre-installation of system-integrated software and essential development tools eliminates common onboarding barriers while preserving flexibility for specialized requirements through complementary technologies: hierarchical module management via Spack and containerized workflows.

Next: :doc:`scientific-software-stack` describes the Spack-based hierarchical module system providing optimized, architecture-specific research software.
