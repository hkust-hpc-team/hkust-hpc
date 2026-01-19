============================
SPEC HPC 2021 Benchmark
============================

SPEC HPC 2021 is a comprehensive benchmark suite for high-performance computing systems, measuring parallel application performance across diverse scientific workloads. This document describes practical approaches for deploying, configuring, and running SPEC HPC in production HPC environments.

.. contents::
   :local:
   :depth: 2

Overview
========

SPEC HPC 2021 (Standard Performance Evaluation Corporation High-Performance Computing 2021) is the industry-standard benchmark suite for evaluating HPC system performance through representative scientific application workloads.

Value Proposition
-----------------

**External validation and comparability:**
  - Published results database (https://www.spec.org/hpc2021/results/) enables direct comparison with other HPC facilities using standardized, reproducible methodology
  - Validates system performance against industry benchmarks
  - Provides quantitative evidence for procurement decisions and system qualification

**Comprehensive workload coverage:**
  - Applications span weather modeling, quantum chemistry, molecular dynamics, computational fluid dynamics, seismic analysis, and particle physics
  - Non-uniform, application-defined MPI communication patterns test real-world network performance characteristics
  - Multiple parallelization strategies (MPI-only, hybrid MPI+OpenMP, GPU acceleration) validate different execution models

**Statistical rigor:**
  - Three iterations with geometric mean scoring provide confidence in result stability
  - Scaling studies across problem sizes (tiny, small, medium, large) characterize performance across operational ranges
  - Intuitive scoring (higher = better) simplifies interpretation and communication

**Infrastructure validation:**
  - Successful SPEC HPC completion demonstrates correct compiler toolchain, MPI library, job scheduler integration, and multi-node communication infrastructure
  - Reveals subtle configuration issues (NUMA binding, network fabric tuning, filesystem performance) that simpler tests miss

Limitations and Considerations
------------------------------

**Setup complexity:**
  - Initial deployment requires days to weeks of configuration effort
  - Steep learning curve for configuration syntax and toolchain integration
  - Debugging requires understanding of multiple subsystems (compiler, MPI, scheduler)

**Execution requirements:**
  - Runtime varies from hours (tiny suite) to days (large suite)
  - Requires substantial compute resources for meaningful validation
  - Multi-node execution depends on job scheduler availability

**Licensing and access:**
  - Commercial product requiring license purchase
  - Results submission subject to SPEC review and approval
  - Not freely redistributable

Learning Curve
--------------

**Difficulty: Hard**

SPEC HPC 2021 presents a steep initial learning curve driven by configuration complexity rather than conceptual difficulty. The benchmark infrastructure (specperl-based harness, configuration syntax, build system integration) is intricate and poorly documented. Error messages are often cryptic, making initial setup challenging for HPC administrators.

The primary challenge lies in achieving the first successful run. Getting the specperl toolchain operational, preparing compliant compiler flags, integrating with job schedulers, and diagnosing infrastructure issues requires significant time investment - expect days to weeks for initial deployment.

**Reproducibility advantage:** Once a working configuration is established for one node type, extension to additional hardware platforms is straightforward. Most configuration elements (compiler flags, MPI settings, scheduler integration) remain constant across platforms. Only hardware-specific metadata (core counts, memory capacity, processor models) requires adjustment.

**Recommendation:** Prioritize establishing a working configuration on a single node type first, using a monolithic configuration file. Defer modular configuration decomposition and extensive customization until basic functionality is achieved.

Benchmark Structure
===================

Test Cases and Problem Sizes
-----------------------------

SPEC HPC 2021 organizes workloads by problem size and application domain:

**Problem size categories:**

- **Tiny (5xx series):** Small-scale problems for rapid testing and single-node validation
- **Small (6xx series):** Medium-scale problems suitable for few-node configurations (1-32 nodes)
- **Medium (7xx series):** Large-scale problems requiring substantial resources (8-128 nodes)
- **Large (8xx series):** Extra-large problems for capability computing evaluation (64+ nodes)

**Representative test cases:**

.. list-table::
   :header-rows: 1
   :widths: 15 20 15 50

   * - Test ID
     - Application
     - Language
     - Application Area
   * - 505/605/705/805
     - LBM D2Q37
     - C
     - Computational Fluid Dynamics
   * - 513/613
     - SOMA
     - C
     - Physics / Polymeric Systems
   * - 518/618/718/818
     - Tealeaf
     - C
     - Physics / High Energy Physics
   * - 519/619/719/819
     - Cloverleaf
     - Fortran
     - Physics / High Energy Physics
   * - 521/621
     - Minisweep
     - C
     - Nuclear Engineering - Radiation Transport
   * - 528/628/728/828
     - POT3D
     - Fortran
     - Solar Physics
   * - 532/632
     - SPH-EXA
     - C++14
     - Astrophysics and Cosmology
   * - 534/634/734/834
     - HPGMG-FV
     - C
     - Cosmology, Astrophysics, Combustion
   * - 535/635/735/835
     - miniWeather
     - Fortran
     - Weather

Each test case runs three times. SPEC HPC computes geometric mean across all test cases within a problem size category, producing a single aggregate score.

Parallelization Models
-----------------------

SPEC HPC supports multiple parallel execution strategies:

- **MPI-only (pmodel=MPI):** Pure message passing parallelism
- **Hybrid MPI+OpenMP (pmodel=OMP):** Distributed + shared memory parallelism
- **GPU acceleration (pmodel=ACC, pmodel=TGT):** OpenACC or OpenMP target offload to accelerators

Our deployment focuses on MPI and hybrid MPI+OpenMP configurations, as these represent the most common HPC workload patterns.

Scoring System
--------------

SPEC HPC reports base scores (no aggressive optimization) and peak scores (vendor-specific tuning allowed). Base scores ensure comparability; peak scores demonstrate maximum achievable performance.

Scores represent throughput: **higher values indicate better performance**. A score of 10.0 means the system completes workloads 10× faster than the SPEC-defined reference system. Scores scale approximately linearly with compute resources under ideal conditions, though communication overhead and synchronization reduce scaling efficiency as node count increases.

Installation and Setup
======================

Prerequisites
-------------

**Hardware requirements:**

- Compute nodes with MPI-capable interconnect (InfiniBand, RoCE, OPA, or standard Ethernet)
- Shared filesystem accessible from all compute nodes (NFS, Lustre, GPFS, BeeGFS)
- Sufficient disk space for source code, build artifacts, and result data (~50-100 GB)

**Software requirements:**

- Linux operating system (RHEL/Rocky/AlmaLinux, Ubuntu, SUSE recommended)
- Modern C/C++/Fortran compilers (GCC, Intel oneAPI, AMD AOCC, NVIDIA HPC SDK)
- MPI library (Open MPI, Intel MPI, MPICH, MVAPICH2)
- Job scheduler (SLURM, PBS, LSF) - optional but recommended for multi-node runs
- Perl 5 (system Perl typically sufficient)

Obtaining SPEC HPC 2021
------------------------

SPEC HPC 2021 is a licensed commercial product. Organizations must purchase a license from SPEC (https://www.spec.org/order.html). Academic institutions may qualify for discounted pricing.

.. important::

   **Licensing logistics require advance planning.** While academic licenses are typically free, the application and approval process requires several days to complete. Unlike open-source benchmarks (HPL, HPCG, OSU Microbenchmarks) that can be downloaded and deployed immediately, SPEC HPC adoption requires coordination with SPEC's licensing process. Factor this timeline into project planning - you cannot begin deployment until license approval completes.

**Installation:**

.. code-block:: bash

   # Extract SPEC HPC distribution
   tar -xzf spechpc2021-1.1.9.tar.gz
   cd spechpc2021
   
   # Install using provided script
   ./install.sh
   
   # Source the environment
   source shrc

The installation creates a directory structure:

.. code-block:: text

   spechpc2021/
   ├── benchspec/      # Benchmark source code and data
   ├── bin/            # Tools (runhpc, rawformat, etc.)
   ├── config/         # Configuration files
   ├── Docs/           # Documentation
   ├── result/         # Output reports
   └── tools/          # specperl and utilities

Specperl Verification
---------------------

SPEC HPC uses a custom Perl interpreter (specperl) bundled with the suite. Verify it works:

.. code-block:: bash

   # Test specperl
   specperl -v
   
   # Should output SPEC-customized Perl version
   # If fails, reinstall or check architecture compatibility

Common issue: Specperl binaries are architecture-specific. If your system architecture doesn't match provided binaries, you'll need to rebuild the tools (consult SPEC documentation, this is uncommon).

Basic Configuration
-------------------

A minimal SPEC HPC configuration file requires:

.. code-block:: perl

   # Output and reporting
   output_format = pdf,text
   teeout = yes
   
   # System identification
   system_vendor = Your Organization
   system_name = Your System Name
   hw_vendor_list = Hardware Vendor
   hw_model_list = Hardware Model
   
   # Compiler settings
   CC = mpicc
   CXX = mpicxx
   FC = mpifort
   
   # Optimization flags
   OPTIMIZE = -O3 -march=native
   
   # MPI configuration
   submit = mpirun -np $ranks $command
   
   # Base run configuration
   default=base=default:
   pmodel = MPI
   ranks = 256  # Adjust for your hardware

This minimal configuration will fail for many test cases - they require additional portability flags, library links, or environment variables. Real configurations expand to hundreds of lines as requirements are discovered.

**Configuration file placement:**

Place custom configs in ``$SPECHPC/config/``. Name them descriptively: ``config/mysite-intel-mpi.cfg``, ``config/mysite-amd-hybrid.cfg``, etc.

Basic Usage
===========

The standard workflow minimizes wasted computation and catches issues early:

1. **Load environment:** Activate compiler and MPI modules
2. **Mockup:** Generate report template without running benchmarks
3. **Test single case:** Run one test case to validate infrastructure
4. **Run full suite:** Execute reportable run (3 iterations) for all test cases

Let's walk through each step.

Step 1: Environment Setup
--------------------------

Load your compiler and MPI environment before invoking SPEC HPC:

.. code-block:: bash

   # Example: Intel oneAPI with Intel MPI
   module purge
   module load compiler/intel-oneapi/2025.0
   module load mpi/intel-mpi/2021.14
   
   # Source SPEC HPC environment
   cd /path/to/spechpc2021
   source shrc
   
   # Verify MPI works
   mpirun -np 4 hostname

This ensures SPEC HPC inherits the correct compiler wrappers and MPI libraries.

Step 2: Mockup Report
----------------------

**Critical step:** Mockup is mandatory before attempting any reportable runs. This stage prevents wasting hours of computation on non-reportable results.

Mockup generates a report template with placeholder scores, performing comprehensive pre-flight validation:

.. code-block:: bash

   runhpc --config myconfig --define nodes_def=1 --define env_def=mpi \
          --action report --reportable --mockup --tune base tiny

**What mockup accomplishes:**

1. **Reportability verification:** Validates configuration complies with SPEC run rules
   
   - Checks all required metadata fields are present
   - Verifies compiler flags are properly documented
   - Ensures configuration meets SPEC submission requirements

2. **Build verification:** Compiles all benchmarks without executing them
   
   - Tests compiler toolchain integration
   - Validates library dependencies and paths
   - Identifies missing portability flags
   - Confirms MPI wrapper configuration

3. **Report generation test:** Creates sample PDF/text reports with zero scores
   
   - Validates LaTeX/PDF dependencies
   - Tests flagsurl accessibility and format
   - Verifies metadata formatting
   - Generates example output for review

**Why mockup is essential:**

Running a full reportable suite takes hours to days. Discovering reportability violations or build failures after completion wastes substantial compute time and delays deployment. Mockup identifies these issues in minutes, ensuring subsequent runs will be valid.

**Mockup failures indicate configuration problems:**

- Missing required metadata fields (``system_vendor``, ``hw_model_list``)
- Invalid compiler flag documentation (``flagsurl`` path errors)
- LaTeX/PDF generation dependencies not installed
- Incorrect file paths or permissions

**Important:** Mockup success validates reporting infrastructure and build process, but does not guarantee runtime success. Execution issues (memory allocation, MPI configuration, numerical stability) are discovered during actual benchmark runs.

Step 3: Test Single Case
-------------------------

Run one test case to validate the complete execution pipeline:

.. code-block:: bash

   runhpc --config myconfig --define nodes_def=1 --define env_def=mpi \\
          --ranks 256 --tune base --loose --iterations 1 \\
          --action run --size test 519

**Why test size:**

- Test problems complete in seconds to minutes (ref size: minutes to hours)
- Validates compilation, execution, and validation passes
- Reveals environment issues (missing libraries, incorrect paths, MPI configuration)

**If test succeeds, try ref size:**

.. code-block:: bash

   runhpc --config myconfig --define nodes_def=1 --define env_def=mpi \\
          --ranks 256 --tune base --loose --iterations 1 \\
          --action run --size ref 519

Ref size uses production problem inputs. Success here means your configuration likely works for full suite runs.

Debug issues on a single test case before attempting full suite execution. Full suite runs take hours - isolate and resolve problems at the single-case level first.

Step 4: Reportable Run
-----------------------

Once a test case completes successfully with ref size, run the full suite:

.. code-block:: bash

   runhpc --config myconfig --define nodes_def=1 --define env_def=mpi \\
          --ranks 256 --tune base --reportable --iterations 3 \\
          --action run --size ref tiny

**Reportable run requirements:**

- Three iterations of each test case
- Ref problem size
- ``--reportable`` flag (enforces SPEC rules)
- No modifications between iterations

Tiny suite completion takes 30 minutes to 2 hours depending on hardware. Small suite: 2-8 hours. Medium: 8-24 hours. Large: 24+ hours.

**Monitoring progress:**

.. code-block:: bash

   # SPEC HPC writes progress to result directory
   tail -f result/SPEC*_myconfig_*/buildlogs/build.*.log
   
   # Check for completed test cases
   ls result/SPEC*_myconfig_*/run/build_*/

Report Generation
-----------------

After successful completion, SPEC HPC generates reports automatically:

.. code-block:: bash

   # Reports appear in result directory
   ls result/SPEC*_myconfig_*/
   # Look for: .pdf, .txt, .html files

If report generation fails, manually trigger it:

.. code-block:: bash

   runhpc --config myconfig --define nodes_def=1 --define env_def=mpi \\
          --action report --reportable

Interpreting Results
====================

Score Metrics
-------------

SPEC HPC output provides base and peak scores:

- **Base score:** Conservative optimization following SPEC portability rules
- **Peak score:** Aggressive, vendor-specific tuning for maximum performance

Higher scores indicate better performance. Scores represent relative throughput compared to the reference system.

**Example score interpretation:**

- Score of 10.0: System is 10× faster than reference
- Score of 5.0: System is 5× faster than reference

Scores should be compared within the same problem size category (tiny, small, medium, large) and parallelization model (MPI-only vs hybrid).

Performance Validation
-----------------------

After successful completion, validate results against expectations:

1. **Internal consistency:** All three iterations should produce similar runtimes (< 5% variation)
2. **Scaling behavior:** Larger problem sizes should show reasonable scaling characteristics
3. **Individual test case review:** Identify outliers that may indicate configuration issues

Report files are generated in ``$SPECHPC/result/``:

.. code-block:: bash

   # View summary
   ls $SPECHPC/result/*.txt
   
   # Check PDF report (if generated)
   ls $SPECHPC/result/*.pdf

Use Case: External Validation
===============================

SPEC HPC excels at external performance validation through comparison with published results.

Published Results Database
----------------------------

Official results: https://www.spec.org/hpc2021/results/

Search for systems with identical or similar processor models. Published results exhibit **performance variance of 20% or more** between vendors and configurations, revealing subtle but impactful differences.

**Configuration factors affecting performance:**

- Node-local configuration: PCIe topology, memory configuration, BIOS settings
- Kernel parameters: CPU governor, isolation settings, NUMA configuration  
- Cooling and thermal characteristics
- Network fabric configuration and topology

First Successful Run Milestone
-------------------------------

After achieving the first successful single-node run, immediately compare against published results. This validates correct node-local configuration before scaling to multi-node deployments.

**Validation procedure:**

1. Find published results with identical processor model
2. Compare single-node tiny/small scores against published range
3. If scores fall significantly below published results (> 15% gap), investigate node-local configuration
4. Review published system descriptions for BIOS settings, kernel parameters, and hardware configurations

**Note:** External validation provides a performance floor - your system should perform within the range of published results for similar hardware. Significant deviations indicate configuration issues requiring investigation.

Use Case: Multi-Node Scaling Analysis
======================================

SPEC HPC enables systematic scaling studies across problem sizes and node counts.

Scaling Methodology
-------------------

Execute identical configurations across increasing node counts:

.. code-block:: bash

   # Single node baseline
   runhpc --config myconfig --define nodes_def=1 --size=ref --reportable

   # Scale to multiple nodes
   runhpc --config myconfig --define nodes_def=2 --size=ref --reportable
   runhpc --config myconfig --define nodes_def=4 --size=ref --reportable
   runhpc --config myconfig --define nodes_def=8 --size=ref --reportable

Compare scores across node counts to assess scaling efficiency.

**Scaling efficiency calculation:**

Efficiency = (Score at N nodes) / (N × Score at 1 node)

Perfect scaling achieves 100% efficiency. Real-world efficiency degrades due to communication overhead, synchronization, and load imbalance.

**Our multi-node results:**

Refer to :doc:`../../../benchmarks/multi-node` for detailed scaling analysis from 1 to 32 nodes on Dell R6625 systems.

Advanced Usage
==============

Modular Configuration Approach
-------------------------------

**Critical guidance:** The modular configuration structure described below represents an evolved organization developed through multiple refactoring iterations. Do not adopt this structure for initial deployment.

**Evolution path:**

1. Initial deployment: Single node type, monolithic configuration
2. First refactor: Support multiple node types
3. Second refactor: Multi-node benchmark support  
4. Third refactor: Multiple compiler + MPI combinations
5. Fourth refactor: Decoupled compiler and MPI configurations

Refactor based on operational needs, not preemptive organization.

**Once established, modular organization provides:**

- Separation of concerns: Hardware metadata, compiler settings, MPI configuration
- Reusability across platforms
- Simplified maintenance when updating compilers or MPI libraries

Configuration File Decomposition
---------------------------------

Example modular structure:

.. code-block:: text

   config/
   ├── base-common.cfg          # Shared settings
   ├── compilers/
   │   ├── intel-oneapi.cfg     # Intel compiler flags
   │   └── amd-aocc.cfg         # AMD compiler flags
   ├── mpi/
   │   ├── openmpi.cfg          # Open MPI submit commands
   │   └── intel-mpi.cfg        # Intel MPI submit commands
   └── hardware/
       ├── dell-r6625.cfg       # Dell R6625 metadata
       └── dell-r660.cfg        # Dell R660 metadata

Each configuration file focuses on a single concern, included via specperl ``%include`` directives.

Compiler Configuration
----------------------

SPEC HPC allows base (conservative, portable) and peak (aggressive, platform-specific) optimization flags. Most HPC centers focus on base results for comparability.

**Example: Intel oneAPI base flags**

.. code-block:: perl

   # config/compilers/intel-oneapi.cfg
   
   CC  = icx
   CXX = icpx  
   FC  = ifx
   CXX = icpx
   FC  = ifx
   
   # Base optimization flags
   OPTIMIZE = -march=common-avx512 -Ofast -flto -ffast-math
   COPTIMIZE = -ansi-alias
   CXXOPTIMIZE = -ansi-alias
   FOPTIMIZE = -nostandard-realloc-lhs -align array64byte
   
   # Portability flags (required for some test cases)
   CPORTABILITY = -lstdc++

**Example: AMD AOCC base flags**

.. code-block:: perl

   CC  = clang
   CXX = clang++
   FC  = flang
   
   OPTIMIZE = -march=znver4 -O3 -ffast-math -flto
   PORTABILITY = -lm

**Flag considerations:**

- ``-march``: Target architecture. Use ``common-avx512`` for Intel, ``znver4`` for AMD EPYC 9004, ``native`` for single-arch deployments
- ``-Ofast``: Aggressive optimization (may violate strict IEEE 754 compliance)
- ``-flto``: Link-time optimization (improves performance, increases build time)
- ``-ffast-math``: Relaxed floating-point semantics (acceptable for most HPC workloads)

Some test cases fail with aggressive optimization. If encountering numerical validation failures, try ``-O2`` instead of ``-Ofast``, or disable LTO for specific benchmarks.

**Flag validation for reportable runs:**

Reportable runs enforce strict compliance with SPEC rules, including permitted compiler flags. Before submitting results:

- Consult SPEC's official flags database: https://www.spec.org/cpu2017/flags/
- Check for up-to-date ``flags.xml`` files for your compiler
- Include ``flagsurl`` directive in configuration pointing to approved flags XML

Invalid or undocumented flags will cause reportable runs to fail validation during report generation.

MPI Integration
---------------

SPEC HPC requires MPI for parallel test cases. Configure via ``submit`` command:

**MPI-only execution:**

.. code-block:: perl

   # Pure MPI configuration
   pmodel = MPI
   submit = mpirun -np $ranks $command

**Hybrid MPI+OpenMP execution:**

.. code-block:: perl

   # Hybrid configuration
   pmodel = OMP
   OPTIMIZE += -qopenmp  # or -fopenmp for GCC/Clang
   submit = mpirun -np $ranks -x OMP_NUM_THREADS=$threads $command

**Environment variable propagation:**

Ensure MPI propagates environment variables to ranks:

.. code-block:: perl

   # Open MPI: -x VAR exports variable
   submit = mpirun -np $ranks -x OMP_NUM_THREADS -x OMP_PROC_BIND $command
   
   # Intel MPI: -genv VAR exports variable  
   submit = mpiexec -n $ranks -genv OMP_NUM_THREADS $threads $command

**NUMA and process binding:**

For optimal performance, bind MPI ranks to NUMA domains:

.. code-block:: perl

   # Open MPI with binding
   submit = mpirun -np $ranks --bind-to core --map-by socket $command
   
   # Intel MPI with binding
   submit = mpiexec -n $ranks -genv I_MPI_PIN_DOMAIN=socket $command

Job Script Wrapper
-------------------

Simplify repeated invocations with a shell script wrapper:

.. code-block:: bash

   #!/bin/bash
   # run-spechpc.sh
   
   cd /path/to/spechpc2021
   source shrc
   
   CONFIG="mysite"
   ACTION="$1"    # mockup, run, report, etc.
   SIZE="$2"      # tiny, small, medium, large
   
   CMD="runhpc --config $CONFIG"
   CMD="$CMD --define host_def=dell-r6625"
   CMD="$CMD --define compiler_def=intel-oneapi"
   CMD="$CMD --define mpi_def=openmpi"
   CMD="$CMD --define env_def=mpi"
   CMD="$CMD --tune base --reportable"
   CMD="$CMD --action $ACTION --size ref $SIZE"
   
   eval $CMD

Usage: ``./run-spechpc.sh run small``

Best Practices
==============

Configuration Strategy
----------------------

**Start monolithic, refactor incrementally:**

Begin with a single configuration file containing all settings. The SPEC HPC configuration syntax has subtle behaviors - establishing a working baseline takes precedence over elegant organization. Only refactor for modularity after achieving stable, repeatable results.

**Evolution path:**

1. Single node type, monolithic config
2. Support multiple node types (update metadata only)
3. Multi-node benchmark support (SLURM integration)
4. Multiple compiler combinations (separate compiler configs)
5. Decoupled MPI configurations

Refactor based on operational needs, not preemptive organization.

Platform Extension
------------------

When deploying to new hardware:

**Changed elements:**

- Hardware metadata (vendor, model, core count, memory)
- Processor-specific compiler flags (``-march`` settings)

**Unchanged elements:**

- Compiler optimization strategy
- MPI configuration
- Job scheduler integration

**Time investment pattern:**

- First platform: Days to weeks (configuration development)
- Subsequent platforms: Hours (metadata updates only)

**Porting checklist:**

1. Copy reference hardware configuration
2. Update system metadata (``lscpu``, ``free -h``)
3. Test single benchmark case with test size
4. Verify performance reasonableness against published results
5. Run full tiny suite
6. Scale to multi-node gradually (1 → 2 → 4 → 8 nodes)

Validation Cadence
------------------

**Single-node validation:**

- After OS/kernel updates
- After compiler toolchain changes
- After BIOS/firmware updates
- Quarterly drift detection

**Multi-node validation:**

- After network fabric changes
- After scheduler upgrades
- Semi-annual comprehensive validation

**Problem size selection:**

- Tiny: Quick validation (< 2 hours), post-change verification
- Small: Standard validation (2-8 hours), routine testing
- Medium/Large: Capability demonstration, infrequent execution

Result Archival
---------------

Maintain historical SPEC HPC results:

.. code-block:: bash

   # Archive results with metadata
   SYSTEM=dell-r6625
   DATE=$(date +%Y%m%d)
   CONFIG=intel-oneapi-mpi
   
   cp $SPECHPC/result/SPEChpc2021*.* \\
      /archive/spechpc/$SYSTEM/$DATE-$CONFIG/

Store configurations alongside results for future reference.

Known Issues
============

Specperl Installation Requires libnl3
--------------------------------------

Specperl requires libnl3 (Netlink Protocol Library Suite version 3). This library is often missing in "Minimal Server" installations of Linux distributions.

**Symptoms:**

- Specperl verification fails (``specperl -v`` produces errors)
- Installation script reports missing dependencies
- Benchmark execution fails during initialization

**Resolution:**

.. code-block:: bash

   # RHEL/Rocky/AlmaLinux
   sudo dnf install libnl3
   
   # Ubuntu/Debian
   sudo apt install libnl-3-200
   
   # Verify specperl works after installation
   specperl -v

SPH-EXA (532/632) MPI Communication Issues
-------------------------------------------

The SPH-EXA benchmarks (532.sph_exa_t, 632.sph_exa_s) redefine MPI communication groups on every iteration. This implementation pattern exposes bugs in certain MPI library implementations.

**Symptoms:**

- Benchmark execution hangs indefinitely
- Numerical validation failures (NaN results)
- Inconsistent behavior across runs

**Known problematic configurations:**

- OpenMPI 5.x with default topology algorithms

**Resolution:**

Disable problematic MPI topology algorithms. For OpenMPI 5.x:

.. code-block:: perl

   # In SPEC HPC configuration file
   submit = mpirun -np $ranks --mca topo ^treematch $command

The ``^treematch`` option excludes the unstable treematch topology algorithm.

**If issues persist:**

- Test with alternative MPI libraries (Intel MPI, MPICH, MVAPICH2)
- Verify network fabric firmware is current
- Check MPI library release notes for known issues with dynamic communicator creation
- Consider excluding SPH-EXA from reportable runs if unresolvable

References and Resources
=========================

Official SPEC Resources
------------------------

- **SPEC HPC 2021 homepage:** https://www.spec.org/hpc2021/
- **Published results database:** https://www.spec.org/hpc2021/results/
- **Ordering information:** https://www.spec.org/order.html
- **Documentation:** https://www.spec.org/hpc2021/Docs/ (requires license)
- **Run and reporting rules:** https://www.spec.org/hpc2021/Docs/runrules.html

Community Resources
-------------------

- **SPEC mailing lists:** https://www.spec.org/spec/mailinglists.html - Discussion of configuration issues and results interpretation
- **Vendor optimization guides:** Intel, AMD, NVIDIA publish SPEC HPC tuning guides for their hardware

Our Results
-----------

Detailed performance analysis and platform comparisons:

- **Single-node performance:** :doc:`../../../benchmarks/single-node` - Comparing Dell R6625, Gigabyte R183 (AMD EPYC 9754), and Dell R660 (Intel Xeon 8592+)
- **Multi-node scalability:** :doc:`../../../benchmarks/multi-node` - Scaling from 1 to 32 nodes on Dell R6625

Related Benchmarks
------------------

SPEC HPC 2021 complements other HPC benchmarks:

- **HPL (High-Performance Linpack):** Dense linear algebra, simpler setup but less representative of real workloads
- **HPCG (High-Performance Conjugate Gradient):** Sparse linear algebra, tests memory bandwidth characteristics
- **MLPerf:** Machine learning training and inference benchmarks
- **STREAM:** Memory bandwidth benchmark
- **IMB-MPI1:** MPI communication microbenchmarks for infrastructure validation (:doc:`imb-mpi1`)

SPEC HPC provides application-level validation complementing infrastructure-focused benchmarks.
