======================================================
Case Study: Kubernetes-Based OS Image Testing
======================================================

This case study demonstrates using Kubernetes to automate software-layer validation for PXE boot images. Container-based testing executes rapidly at scale, validating aspects functionally equivalent to bare-metal execution while deferring deployment-specific validation to dedicated test infrastructure.

**Automation Scope:**

- Software presence and basic functionality (compilers, libraries, utilities)
- Compilation and linking behavior (development packages, toolchains)
- Module system configuration (Lmod, environment setup)
- Single-node MPI operation (initialization, intra-process communication)

**Deferred to Bare-Metal Testing:**

- Boot process validation (PXE, GRUB, initramfs)
- Hardware driver operation (GPU, network fabric)
- SLURM scheduler integration
- Multi-node communication
- Production filesystem access

**Value Proposition:** Kubernetes enables rapid, repeatable software validation, identifying configuration errors within minutes rather than hours. This trades computing resources for manual administrative effort, deferring expensive bare-metal validation until software integrity is confirmed.

Problem Context
===============

Manual Image Validation Challenges
-----------------------------------

Traditional PXE image builds require extensive manual validation before deployment:

**Manual validation workflow:**

1. Build modified image on dedicated build system
2. Deploy test image to PXE infrastructure
3. Boot test node from network
4. SSH to test node and manually verify:
   
   - System boot successful
   - Kernel modules load correctly
   - Compilers function properly
   - Module system operates as expected
   - GPU drivers initialize
   - MPI implementations execute
   - Network connectivity established

5. Identify issues, rebuild image, repeat validation

**Operational challenges:**

- **Time investment:** Manual validation requires 2-3 hours per iteration
- **Limited coverage:** Validation depth depends on administrator memory and available time
- **Regression risk:** No systematic verification that previously resolved issues remain fixed
- **Undocumented procedures:** Validation knowledge resides in administrator experience rather than documented processes
- **Update hesitancy:** Manual validation burden discourages OS updates and security patches

**Representative failure modes encountered:**

- Kernel modules missing after kernel updates
- Module system reverting to environment-modules after package updates
- Compiler environment variables incorrectly configured
- MPI failing initialization due to missing system libraries
- GPU drivers incompatible with updated kernel versions

Solution Architecture
=====================

Automated testing executes in Kubernetes using Argo Workflows, validating image integrity before manual deployment validation.

Workflow Overview
-----------------

.. code-block:: text

    Git Commit → Build Image → Container Tests → Test Report
                                      ↓
                              (tests pass)
                                      ↓
                      Manual Deployment to Test Nodes
                                      ↓
                      Bare-Metal Validation (SLURM, MPI, etc.)
                                      ↓
                          Progressive Production Rollout

**Design rationale:** Container-based tests validate software functionality rapidly, deferring expensive manual validation until software integrity is established. This prevents wasted effort validating images with fundamental software defects.

Automated Test Suite
====================

Test Organization
-----------------

Tests validate base OS software stack components as documented in :doc:`../software-ecosystem/os-software-stack`:

.. code-block:: text

   image-tests/
   ├── fixtures/                     # Test program source code
   │   ├── hello.c
   │   ├── hello.cpp
   │   ├── hello.f90
   │   ├── mpi_hello.c
   │   ├── test_curl.c
   │   ├── test_fontconfig.c
   │   ├── test_munge.c
   │   └── test_pmix.c
   ├── run-test-commandline-utils.sh
   ├── run-test-os-gcc.sh
   ├── run-test-os-gxx.sh
   ├── run-test-os-gfortran.sh
   ├── run-test-curl-devel.sh
   ├── run-test-fontconfig-devel.sh
   ├── run-test-munge-devel.sh
   ├── run-test-pmix-devel.sh
   ├── run-test-mlnx-openmpi.sh
   ├── run-test-lmod.sh
   ├── run-test-qt5.sh
   └── run-test-env.sh

Test Categories
---------------

**Command-line utilities**
  Validates presence and basic operation of essential system tools (bash, make, cmake, git, tmux, rsync).

**System compilers**
  Verifies OS-provided GCC, G++, and GFortran can compile and execute test programs.

**Development libraries**
  Compiles test programs linking against system libraries (curl, fontconfig, pmix, munge), validating both header availability and dynamic linking.

**MPI functionality**
  Tests system-provided MPI (Mellanox OpenMPI) compilation, linking, and basic execution including communication primitives.

**Module system**
  Verifies Lmod installation and correct alternative selection (Lmod versus environment-modules).

**GUI libraries**
  Validates Qt5 installation paths and pkg-config integration.

**Environment configuration**
  Tests system-wide environment variables and shell initialization.

Test Implementation Example
----------------------------

Representative test structure (system compiler validation):

.. code-block:: bash

   #!/bin/bash
   # run-test-os-gcc.sh
   set -euo pipefail
   
   echo "=== Testing OS-provided GCC ==="
   
   # Verify compiler exists
   command -v gcc || exit 1
   
   # Test compilation
   cat > test.c << 'EOF'
   #include <stdio.h>
   int main() { 
       printf("Compiler validation successful\n"); 
       return 0; 
   }
   EOF
   
   gcc test.c -o test_c
   ./test_c
   
   echo "✓ OS GCC validated"

See :doc:`../software-ecosystem/os-software-stack` for comprehensive test examples and rationale.

Container Test Limitations
===========================

Scope of Container-Based Validation
------------------------------------

Container testing validates software functionality but cannot verify deployment-specific aspects requiring bare-metal hardware:

**Cannot validate in containers:**

- **Bootability:** PXE boot process, GRUB configuration, initramfs integrity
- **SLURM integration:** Job scheduler communication, process management via PMIx
- **Cross-node MPI:** Multi-node communication across physical interconnect
- **Network fabric drivers:** InfiniBand/RoCE hardware operation (containers use host networking)
- **GPU hardware detection:** Physical GPU recognition and initialization
- **Filesystem mounting:** NFS client behavior with production storage systems
- **Hardware-specific kernel modules:** Drivers for specialized HPC hardware

**Container testing validates:**

- Software package presence and basic functionality
- Compilation toolchain operation
- Library linking and dynamic loading
- Module system configuration
- Single-node MPI initialization and intra-process communication

.. important::
   
   Container tests serve as unit tests validating software layer integrity. Successful container tests indicate the image warrants deployment validation, but cannot verify bootability, hardware driver operation, or production integration. See :doc:`../software-ecosystem/os-software-stack` for comprehensive validation methodology including bare-metal testing and progressive rollout procedures.

Workflow Implementation
=======================

Argo Workflow Structure
------------------------

Simplified workflow template demonstrating test orchestration:

.. code-block:: yaml

   apiVersion: argoproj.io/v1alpha1
   kind: WorkflowTemplate
   metadata:
     name: pxe-image-build-test
   spec:
     entrypoint: main
     
     templates:
     - name: main
       steps:
       - - name: build-image
           template: build-pxe-image
       
       - - name: test-image
           template: run-test-suite
           arguments:
             artifacts:
             - name: image
               from: "{{steps.build-image.outputs.artifacts.image}}"
       
       - - name: generate-report
           template: create-test-report
           arguments:
             parameters:
             - name: results
               value: "{{steps.test-image.outputs.parameters.results}}"
     
     - name: build-pxe-image
       container:
         image: rhel9-build-tools:latest
         command: ["/scripts/build-pxe-image.sh"]
         volumeMounts:
         - name: shared-storage
           mountPath: /output
       outputs:
         artifacts:
         - name: image
           path: /output/pxe-image.img
     
     - name: run-test-suite
       inputs:
         artifacts:
         - name: image
       dag:
         tasks:
         - name: test-compilers
           template: test-compiler-suite
         - name: test-libraries
           template: test-library-suite
         - name: test-mpi
           template: test-mpi-suite
         - name: test-modules
           template: test-module-system
     
     - name: test-compiler-suite
       script:
         image: "{{workflow.parameters.test-image}}"
         command: [bash]
         source: |
           #!/bin/bash
           set -e
           /tests/run-test-os-gcc.sh
           /tests/run-test-os-gxx.sh
           /tests/run-test-os-gfortran.sh

Test execution occurs automatically on image builds, generating reports documenting validation results.

Why Kubernetes for This Testing
================================

Kubernetes Advantages
---------------------

**Rapid execution:**
  Container-based tests complete in minutes. Traditional approach requiring PXE deployment and manual SSH validation takes hours.

**Parallel test execution:**
  Kubernetes orchestrates multiple test suites concurrently. DAG-based workflows (Argo) efficiently manage test dependencies.

**Reproducible environment:**
  Container isolation ensures consistent test conditions. Eliminates "works on my test node" variability.

**Infrastructure as code:**
  Workflow definitions in Git provide version-controlled, auditable test procedures. Changes trigger automatic validation.

**Declarative test specifications:**
  YAML-defined workflows serve as executable documentation. New team members reference workflow definitions rather than tribal knowledge.

Automation Scope and Limitations
---------------------------------

**What k8s testing validates effectively:**

Software components exhibiting identical behavior in containers and bare-metal:

- Package installation and file presence
- Compiler toolchain functionality
- Library linking and symbol resolution
- Script execution and path resolution
- Module system operation (Lmod configuration)
- Environment variable configuration

**What requires bare-metal validation:**

Deployment aspects dependent on physical hardware or system integration:

- Boot process (firmware, bootloader, initramfs)
- Hardware driver initialization (GPU, InfiniBand)
- Kernel module loading in production kernel
- Scheduler integration (SLURM communication)
- Multi-node fabric communication
- Production storage system access

**Design principle:** Automate what's equivalent; defer what's not. Container tests catch software configuration errors rapidly, reserving expensive bare-metal validation for hardware-dependent verification.

Operational Impact
------------------

**Time savings:**
  Software-layer validation completes in 5-10 minutes (previously 2-3 hours manual testing).

**Documented procedures:**
  Test scripts explicitly document validation requirements. Reduces institutional knowledge dependency.

**Regression prevention:**
  Previously encountered issues become automated test cases, preventing recurrence.

**Resource trade-off:**
  Exchanges computing resources (Kubernetes cluster cycles) for human time. Kubernetes infrastructure cost justified by reduced manual effort.

Current Limitations and Future Considerations
==============================================

Known Constraints
-----------------

**Test coverage limitations:**

- Test suite validates common failure modes encountered operationally
- Coverage grows organically as new issues are discovered
- Some edge cases remain undetected until manual validation

**Maintenance requirements:**

- Tests require updates when OS versions change (RHEL 8 to 9 transitions)
- New software additions necessitate corresponding test development
- Hardware changes (new GPU models, network adapters) require test modifications

**Infrastructure dependencies:**

- Kubernetes cluster availability required for test execution
- Container runtime limitations affect test fidelity
- Storage system performance impacts test execution duration

Future Development
------------------

Potential enhancements under consideration:

- Automated deployment to dedicated test nodes post-container validation
- Integration with production monitoring systems for deployment verification
- Historical test result tracking for trend analysis
- Expanded test coverage for specialized hardware configurations

Implementation of these enhancements depends on operational priorities and available resources.

Conclusion
==========

Automated PXE image testing establishes documented validation procedures while reducing manual testing burden. Container-based tests provide rapid software validation, deferring expensive bare-metal validation until software integrity is confirmed. This approach balances automation benefits with practical recognition of container testing limitations, maintaining manual validation for deployment-critical verification.

The test suite grows organically through operational experience, documenting institutional knowledge as executable specifications. While automation does not eliminate manual validation requirements, it enables more efficient resource allocation by deferring human effort until automated validation confirms basic software functionality.

Related Documentation
=====================

- :doc:`../software-ecosystem/os-software-stack` - Base OS software testing methodology
- :doc:`../software-ecosystem/scientific-software-stack` - Spack stack validation
- :doc:`case-study-spack-stack` - Scientific software build automation
