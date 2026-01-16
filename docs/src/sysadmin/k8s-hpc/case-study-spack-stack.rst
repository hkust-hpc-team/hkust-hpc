=========================================================
Case Study: Kubernetes-Based Spack Stack Builds
=========================================================

This case study demonstrates using Kubernetes to automate Spack-based hierarchical software stack builds and testing. Parallel execution addresses combinatorial complexity inherent in multi-compiler, multi-MPI, multi-architecture HPC environments while container-based testing validates functionality before production deployment.

**Automation Scope:**

- Parallel builds across compiler/MPI/architecture combinations
- Dependency-aware orchestration (compilers → MPI → applications)
- Container-based software validation (compilation, linking, execution)
- Module system regeneration and cache updates

**Deferred to Production Testing:**

- SLURM scheduler integration (PMIx coordination)
- Cross-node MPI communication
- Network fabric performance (InfiniBand/RoCE)
- Production filesystem access under load

**Value Proposition:** Kubernetes orchestration transforms serial, manually-coordinated builds (8-12 hours wall-clock time) into parallel, dependency-managed workflows (2-3 hours), enabling more frequent updates while trading computing resources for manual administrative effort.

Problem Context
===============

Hierarchical Module System Complexity
--------------------------------------

HPC software environments employ hierarchical modules (Lmod + Spack) enforcing compatibility (see :doc:`../software-ecosystem/scientific-software-stack` for detailed architecture):

.. code-block:: text

   Core Modules (always available)
   ├── Compilers: gcc, aocc, intel-oneapi-compilers
   └── When compiler loaded → MPI modules appear
       └── When MPI loaded → Applications appear

**Example:** 3 compilers × 3 MPI implementations × 50 applications = ~450 software builds

This combinatorial explosion creates significant build and maintenance challenges.

Manual Build Process Limitations
---------------------------------

**Traditional workflow:**

1. Build compiler toolchains serially (GCC, Intel oneAPI, AMD AOCC)
2. For each compiler, build MPI implementations (OpenMPI, Intel MPI)
3. For each compiler/MPI combination, build scientific libraries (HDF5, NetCDF, FFTW)
4. Build applications against specific toolchain combinations
5. Regenerate Lmod module files and caches
6. Manual testing of module hierarchy and application functionality

**Operational constraints:**

- **Serial execution:** Builds proceed sequentially, requiring 8-12 hours wall-clock time
- **Manual coordination:** Administrator must initiate each build phase after dependency completion
- **Long feedback cycles:** Build failures discovered hours after initiation
- **Limited testing:** Validation depends on administrator availability and memory
- **Update hesitancy:** Long build/test cycles discourage frequent software updates

**Consequence:** Software stack updates occur quarterly rather than monthly, delaying researcher access to new features and bug fixes.

Solution Architecture
=====================

Kubernetes-based Argo Workflows orchestrate parallel builds with dependency management, containerized testing, and automatic module system updates.

Workflow Overview
-----------------

.. code-block:: text

   Git Commit → Concretize Dependencies → Parallel Builds → Container Tests → Module Regen
                                               ↓
                                      (tests pass)
                                               ↓
                               Production Deployment Validation
                                               ↓
                                   SLURM Integration Tests (bare-metal)
                                               ↓
                                        Progressive Rollout

**Design rationale:** Parallel execution within dependency tiers dramatically reduces wall-clock time. Container-based testing validates software functionality before expensive production integration testing.

Parallel Build Orchestration
=============================

Dependency-Aware Parallelization
---------------------------------

Workflow orchestrates builds respecting hierarchical dependencies while maximizing parallelism:

**Build tiers:**

.. code-block:: text

   Tier 1: Core Compilers (parallel)
   ├── gcc/14.2
   ├── aocc/5.0
   └── intel-oneapi-compilers/2025
   
   Tier 2: MPI Implementations (parallel per compiler)
   ├── gcc/14.2 → openmpi/4, openmpi/5
   ├── aocc/5.0 → openmpi/5
   └── intel/2025 → intel-oneapi-mpi/2021, openmpi/5
   
   Tier 3: Scientific Libraries (parallel per compiler+MPI)
   ├── gcc/14.2 + openmpi/5 → netcdf, fftw, hdf5
   ├── aocc/5.0 + openmpi/5 → netcdf, fftw, amdlibs
   └── intel/2025 + intel-mpi/2021 → netcdf, fftw, mkl
   
   Tier 4: Applications (parallel per toolchain)
   └── lammps, openfoam, mpas-model

**Time savings:** Serial execution requires 8-12 hours; parallel execution completes in 2-3 hours (wall-clock time).

Workflow Implementation
-----------------------

Simplified Argo Workflow demonstrating dependency structure (excerpt from actual Helm chart):

.. code-block:: yaml

   apiVersion: argoproj.io/v1alpha1
   kind: WorkflowTemplate
   metadata:
     name: spack-build-workflow
   spec:
     entrypoint: main
     
     templates:
     - name: main
       steps:
       # Step 1: Concretize dependencies (parallel)
       - - name: relock-compilers
           template: run-relock-compilers
         - name: relock-aocc-openmpi-toolset
           template: run-relock-aocc-openmpi-toolset
         - name: relock-oneapi-impi-toolset
           template: run-relock-oneapi-impi-toolset
         - name: relock-python
           template: run-relock-python
       
       # Step 2: Build compilers and independent toolsets (parallel)
       - - name: build-compilers
           template: run-build-compilers
         - name: build-aocc-openmpi-toolset
           template: run-build-aocc-openmpi-toolset
         - name: build-oneapi-impi-toolset
           template: run-build-oneapi-impi-toolset
         - name: build-python
           template: run-build-python
       
       # Step 3: Post-processing
       - - name: lmod-refresh
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: lmod
     
     # Compiler builds (excerpt showing parallel structure)
     - name: run-build-compilers
       steps:
       - - name: build-gcc
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@1002-cc-gcc
         - name: build-nvhpc
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@1001-cc-nvhpc
         - name: build-cuda
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@1001-cuda
     
     # Toolset builds (excerpt showing MPI + libraries)
     - name: run-build-oneapi-impi-toolset
       steps:
       - - name: build-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@2000-oneapi-impi
       - - name: build-netcdf-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@3000-netcdf-oneapi-impi
         - name: build-mkl-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@3000-mkl-oneapi-impi
         - name: build-fftw-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@3000-fftw-oneapi-impi
       - - name: build-openfoam-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@4001-openfoam-org-oneapi-impi
         - name: build-lammps-oneapi-impi
           template: run-make-target
           arguments:
             parameters:
             - name: make-target
               value: build@4001-lammps-oneapi-impi

**Build execution template:**

.. code-block:: yaml

   - name: run-make-target
     inputs:
       parameters:
       - name: make-target
     volumes:
     - name: shared-storage
       persistentVolumeClaim:
         claimName: spack-pvc
     container:
       image: rhel9-spack-builder:latest
       command: ["/bin/bash", "-c"]
       args:
       - |
         source "${SPACK_ROOT}/dist/bin/setup-envs.sh" -y
         cd "${SPACK_ROOT}/dist/envs"

         # make build@${spack_environment} is just a shorthand for
         #   spack -e ${spack_environment} install --only-concrete
         make {{`{{inputs.parameters.make-target}}`}}
       env:
       - name: SPACK_ROOT
         value: /opt/shared/.spack-edge
       volumeMounts:
       - name: shared-storage
         mountPath: /opt/shared
       resources:
         requests:
           cpu: "16"
           memory: "48Gi"

Each build executes in isolated container with shared storage for Spack installation directory.

Container-Based Testing
=======================

Test Organization
-----------------

Automated tests validate compiler/MPI combinations and runtime environments as documented in :doc:`../software-ecosystem/scientific-software-stack`:

.. code-block:: text

   Compiler Tests (parallel)
   ├── gcc/14.2 → compile C/C++/Fortran
   ├── aocc/5.0 → compile C/C++/Fortran
   └── intel/2025 → compile C/C++/Fortran
   
   MPI Compiler Tests (parallel, 16 CPU, 48Gi RAM, 32Gi shm)
   ├── gcc/14.2 + openmpi/5 → MPI hello world
   ├── aocc/5.0 + openmpi/5 → MPI communication
   └── intel/2025 + intel-mpi/2021 → MPI collective ops
   
   Runtime Tests (parallel)
   ├── python/3.11, 3.12, 3.13 → pip, poetry, pdm, uv
   ├── r/4.4 → CRAN package installation
   └── matlab/R2024a → parallel computing toolbox

Test Workflow Structure
------------------------

Argo Workflow orchestrates test matrix execution (excerpt from actual Helm chart):

.. code-block:: yaml

   apiVersion: argoproj.io/v1alpha1
   kind: WorkflowTemplate
   metadata:
     name: spack-tests
   spec:
     entrypoint: main
     
     templates:
     - name: main
       inputs:
         parameters:
         - name: image-tag
           default: "latest"
       steps:
       - - name: compiler-tests
           template: compiler-tests
         - name: mpi-compiler-tests
           template: mpi-compiler-tests
         - name: runtime-tests
           template: runtime-tests
     
     # Compiler tests (parallel execution)
     - name: compiler-tests
       steps:
       - - name: gcc-14-2
           template: run-compiler-test
           arguments:
             parameters:
             - name: cc-family
               value: "gcc"
             - name: cc-version
               value: "14.2"
         - name: aocc-5-0
           template: run-compiler-test
           arguments:
             parameters:
             - name: cc-family
               value: "aocc"
             - name: cc-version
               value: "5.0"
         - name: intel-2025
           template: run-compiler-test
           arguments:
             parameters:
             - name: cc-family
               value: "intel-oneapi-compilers"
             - name: cc-version
               value: "2025"
     
     # MPI compiler tests (parallel, larger resources)
     - name: mpi-compiler-tests
       steps:
       - - name: gcc-14-2-openmpi-5
           template: run-mpi-compiler-test
           arguments:
             parameters:
             - name: cc-family
               value: "gcc"
             - name: cc-version
               value: "14.2"
             - name: mpi-family
               value: "openmpi"
             - name: mpi-version
               value: "5"
         - name: aocc-5-0-openmpi-5
           template: run-mpi-compiler-test
           arguments:
             parameters:
             - name: cc-family
               value: "aocc"
             - name: cc-version
               value: "5.0"
             - name: mpi-family
               value: "openmpi"
             - name: mpi-version
               value: "5"
     
     # Runtime tests (parallel)
     - name: runtime-tests
       steps:
       - - name: python-3-12
           template: run-runtime-test
           arguments:
             parameters:
             - name: test-name
               value: "test-spack-rt-python"
             - name: test-version
               value: "3.12"
         - name: matlab-r2024a
           template: run-runtime-test-large
           arguments:
             parameters:
             - name: test-name
               value: "test-spack-rt-matlab"
             - name: test-version
               value: "R2024a"

**MPI test execution (requires shared memory for intra-process communication):**

.. code-block:: yaml

   - name: run-mpi-compiler-test
     inputs:
       parameters:
       - name: cc-family
       - name: cc-version
       - name: mpi-family
       - name: mpi-version
     volumes:
     - name: shared-storage
       persistentVolumeClaim:
         claimName: spack-pvc
         readOnly: true
     - name: dshm
       emptyDir:
         medium: Memory
         sizeLimit: 32Gi
     container:
       image: rhel9-spack-tester:latest
       command: ["/bin/bash", "-c"]
       args:
       - |
         source /etc/profile
         export SPACK_DISABLE_LOCAL_CONFIG=1
         "${HPC_SPACK_TEST_DIR}/run-test-spack-mpicc.sh" \
           "$HPC_LMOD_CC_FAMILY" "$HPC_LMOD_CC_VERSION" \
           "$HPC_LMOD_MPI_FAMILY" "$HPC_LMOD_MPI_VERSION"
       env:
       - name: HPC_LMOD_CC_FAMILY
         value: "{{`{{inputs.parameters.cc-family}}`}}"
       - name: HPC_LMOD_CC_VERSION
         value: "{{`{{inputs.parameters.cc-version}}`}}"
       - name: HPC_LMOD_MPI_FAMILY
         value: "{{`{{inputs.parameters.mpi-family}}`}}"
       - name: HPC_LMOD_MPI_VERSION
         value: "{{`{{inputs.parameters.mpi-version}}`}}"
       - name: SPACK_ROOT
         value: /opt/shared/.spack-edge
       resources:
         requests:
           cpu: 16
           memory: 48Gi
       volumeMounts:
       - name: shared-storage
         mountPath: /opt/shared
         readOnly: true
       - name: dshm
         mountPath: /dev/shm

MPI tests require 32Gi shared memory for ``mpirun`` intra-process communication. Runtime tests for MATLAB parallel computing similarly require large shared memory allocation.

Why Kubernetes for This Testing
================================

Kubernetes Advantages for Combinatorial Complexity
---------------------------------------------------

**Parallel test matrix execution:**
  450+ compiler/MPI/application combinations execute concurrently across cluster nodes. Traditional serial testing would require days; Kubernetes completes testing within hours.

**Declarative test specifications:**
  Helm chart templates generate test matrix from configuration, enabling addition of new compiler/MPI combinations through configuration changes rather than workflow modification.

**Resource management:**
  Different test categories require different resources (MPI tests: 16 CPU, 48Gi RAM; simple compiler tests: 4 CPU, 12Gi RAM). Kubernetes scheduler optimizes resource allocation.

**Reproducible test environments:**
  Container isolation ensures consistent test conditions across all compiler/MPI combinations, eliminating "works with this compiler but not that compiler" environmental variability.

**Infrastructure as code:**
  Workflow and test definitions in Git provide version-controlled, auditable build and test procedures.

Automation Scope and Limitations
---------------------------------

**What k8s testing validates effectively:**

Software functionality exhibiting identical behavior in containers and bare-metal:

- Compiler toolchain operation (compilation, linking)
- Library dependency resolution
- Module system hierarchy
- Single-node MPI initialization
- Runtime ecosystem functionality (Python package managers, R CRAN, MATLAB toolboxes)

**What requires bare-metal validation:**

Production integration aspects dependent on physical hardware and scheduler:

- SLURM PMIx integration (MPI process management)
- Cross-node MPI communication across physical interconnect
- Network fabric performance (InfiniBand/RoCE RDMA)
- Filesystem behavior under concurrent access
- GPU workload execution

**Design principle:** Container tests validate software layer integrity; production tests validate scheduler and hardware integration. This separation enables rapid iteration on software configuration while deferring expensive integration testing.

Operational Impact
------------------

**Reduced build time:**
  Wall-clock build time reduced from 8-12 hours (serial) to 2-3 hours (parallel). Enables more frequent software updates (monthly versus quarterly).

**Systematic testing:**
  Automated test matrix validates all compiler/MPI combinations rather than subset chosen by administrator. Catches regressions across entire software stack.

**Documented procedures:**
  Workflow definitions explicitly document build dependencies and testing requirements. New team members reference workflow configurations rather than tribal knowledge.

**Resource trade-off:**
  Exchanges computing resources (Kubernetes cluster hours) for manual administrative time. Infrastructure cost justified by reduced manual coordination and testing effort.

Current Limitations and Future Considerations
==============================================

Known Constraints
-----------------

**Container test fidelity:**
  Some MPI configurations behave differently in containers versus bare-metal (UCX transport selection, shared memory access patterns). Container tests catch majority of issues but not all.

**Build reproducibility:**
  Spack build caching reduces rebuild time but introduces potential for stale cache issues. Workflow includes cache invalidation steps but cache management remains complex.

**Resource contention:**
  Large build workflows (450+ packages) consume significant cluster resources. Concurrent workflows may exhaust available resources, requiring coordination.

**Maintenance overhead:**
  Workflow definitions require updates when Spack package definitions change or new compiler/MPI combinations are introduced. Maintenance effort ongoing but manageable.

Future Development
------------------

Potential enhancements under consideration:

- Automated SLURM test job submission post-container validation
- Binary cache optimization for faster incremental builds
- Historical build time tracking for workflow optimization
- Enhanced failure notification and automated rollback

Implementation priorities driven by operational needs and available resources.

Conclusion
==========

Kubernetes-based orchestration transforms Spack software stack maintenance from manually-coordinated serial execution to automated parallel workflows. This addresses combinatorial complexity inherent in multi-compiler, multi-MPI HPC environments while enabling more frequent updates through systematic testing.

Container-based validation rapidly identifies software configuration errors, deferring expensive bare-metal integration testing until software integrity is confirmed. The approach trades computing resources for manual administrative effort, a worthwhile exchange given manual coordination costs and error risks.

Workflow definitions document build dependencies and testing procedures as executable specifications, reducing institutional knowledge dependency while enabling new team members to understand and modify build processes.

Related Documentation
=====================

- :doc:`../software-ecosystem/scientific-software-stack` - Spack configuration and testing methodology
- :doc:`../software-ecosystem/os-software-stack` - Base OS software stack validation
- :doc:`case-study-pxe-images` - OS image build automation
