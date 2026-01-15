======================================================
Case Study: Automating PXE Image Builds and Testing
======================================================

Overview
========

This case study documents our journey automating PXE boot image builds for HPC compute nodes. It's an ongoing experiment - not a polished solution, but a real-world example of applying CI/CD concepts to traditional HPC infrastructure tasks.

**Status:** Experimental, continuously evolving

**Timeline:** Started with basic automation, grown organically over ~6 months

**Impact:** More willing to update OS packages; automated smoke tests catch obvious issues early


The Problem We Were Solving
============================

Manual Process Pain Points
--------------------------

Our PXE image build process was entirely manual:

**The workflow looked like this:**

1. SSH to build node
2. Update package lists, kernel, drivers manually
3. Build new image (mkfs, populate filesystem, configure)
4. Basic sanity check: "does it look right?"
5. Deploy to one test node via PXE
6. SSH to test node, manually verify:
   
   - Does it boot?
   - Are kernel modules present?
   - Do compilers work?
   - Can we load environment modules?
   - Does GPU driver initialize?

7. If something's wrong, fix it and repeat

**Problems with this approach:**

- **Time-consuming**: Manual testing took 2-3 hours for each iteration
- **Limited coverage**: Only tested what we remembered to test
- **Error-prone**: Easy to forget checks, especially for rarely-used features
- **Undocumented**: Testing procedure lived in admin's heads
- **Risk of regression**: No systematic way to ensure previous bugs stayed fixed
- **Hesitant to update**: Fear of breaking things made us delay OS updates

Real examples of issues we caught manually (sometimes late):

- Kernel module for specific hardware missing after kernel update
- Lmod reverting to environment-modules after package update
- Compiler paths broken after filesystem restructuring
- MPI failing to initialize due to missing system library
- GPU driver not loading due to kernel/driver version mismatch


Our Solution (Still Evolving)
==============================

We built a K8s workflow using Argo Workflows to automate the build-test-validate cycle. The workflow is continuously improving as we learn what matters.

High-Level Workflow
-------------------

.. code-block:: text

    Git Commit → Trigger Build → Build Image → Run Test Suite → Generate Report
                                                     ↓
                                            (if tests pass)
                                                     ↓
                                      Deploy to Test Nodes → Manual Validation
                                                     ↓
                                            (if manual tests pass)
                                                     ↓
                                           Progressive Rollout to Production

Automated Test Suite (Growing List)
------------------------------------

**Phase 1: Basic Image Integrity**

- Image file exists and has expected size
- Filesystem structure is correct
- Critical directories present (/bin, /lib, /etc, /usr, etc.)
- Symbolic links are intact

**Phase 2: Kernel and Modules**

- Kernel boots in container environment
- All required kernel modules are present:
  
  - Network drivers (Mellanox, Intel)
  - GPU drivers (NVIDIA, AMD)
  - Filesystem modules (XFS, NFS client)
  - InfiniBand/RoCE support

- Modules can be loaded without errors
- Kernel version matches expected

**Phase 3: Compiler Sanity**

For each compiler (GCC, Intel oneAPI, AOCC):

- Compiler binary exists and is executable
- Can compile simple C program
- Can compile and link C++ program
- Can find standard system libraries
- Produces working executable

**Phase 4: MPI Functionality**

For each MPI implementation (Intel MPI, OpenMPI):

- MPI installation is present
- mpirun/mpiexec exists
- Can initialize MPI environment
- Simple MPI hello world compiles and runs
- MPI can detect multiple "processes" (in container)

**Phase 5: System Libraries**

- Qt5 libraries present and linkable
- Python interpreter works
- System Python has expected modules
- OpenSSL libraries accessible
- X11 libraries present (for GUI apps)

**Phase 6: Module System**

- Lmod is installed (not environment-modules)
- Module command works
- Can load/unload modules
- Module hierarchy is intact
- No module errors on initialization

**Phase 7: GPU Support**

- NVIDIA/AMD driver kernel module present
- nvidia-smi / rocm-smi can run (in compatible container)
- CUDA/ROCm runtime libraries present
- Can query GPU properties (when GPU available in test environment)

**Phase 8: Integration Tests**

- Image tested against production Spack stack
- Spack-built software can execute
- Compiler can find OS-provided libraries
- MPI programs can link against system libraries


Important Caveats
-----------------

**What tests DON'T catch:**

- Subtle performance issues
- Hardware-specific problems on certain node types
- SLURM integration issues
- Cross-node MPI communication
- Network boot timing issues
- Real GPU workload compatibility

**What we still do manually:**

- Deploy image to small set of test nodes
- Run actual SLURM jobs
- Test cross-node MPI communication
- Verify GPU workloads run correctly
- Check for any unexpected behavior

**Test quality varies:**

- Some tests are well-refined
- Others are flaky and need improvement
- Container testing doesn't perfectly match bare-metal
- False positives occasionally occur


Implementation Details
======================

Workflow Structure (Simplified)
--------------------------------

.. code-block:: yaml

    # Simplified Argo WorkflowTemplate
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
              parameters:
              - name: image-path
                value: "{{steps.build-image.outputs.parameters.image-path}}"
        - - name: generate-report
            template: create-test-report
            arguments:
              parameters:
              - name: test-results
                value: "{{steps.test-image.outputs.parameters.results}}"
      
      - name: build-pxe-image
        container:
          image: rhel9-build-tools:latest
          command: ["/scripts/build-pxe-image.sh"]
          volumeMounts:
          - name: shared-storage
            mountPath: /output
        outputs:
          parameters:
          - name: image-path
            valueFrom:
              path: /output/image-path.txt
      
      - name: run-test-suite
        inputs:
          parameters:
          - name: image-path
        steps:
        - - name: test-kernel
            template: test-kernel-modules
          - name: test-compilers
            template: test-compiler-sanity
          - name: test-mpi
            template: test-mpi-functionality
          # ... more test steps
      
      # Individual test templates
      - name: test-kernel-modules
        script:
          image: "{{inputs.parameters.image-path}}"
          command: [bash]
          source: |
            #!/bin/bash
            # Test kernel modules are present
            for module in mlx5_core nvidia amdgpu; do
              if ! modinfo $module &>/dev/null; then
                echo "ERROR: Module $module not found"
                exit 1
              fi
            done
            echo "All kernel modules present"

Test Evolution Example
----------------------

**Initial test (Week 1):** Does image file exist?

.. code-block:: bash

    #!/bin/bash
    if [ -f "/output/pxe-image.img" ]; then
      echo "PASS: Image exists"
    else
      echo "FAIL: Image not found"
      exit 1
    fi

**After production issue (Week 3):** Check kernel modules

We deployed an image where network driver module was missing. Added test:

.. code-block:: bash

    #!/bin/bash
    # After manually discovering mlx5_core was missing...
    if ! modinfo mlx5_core &>/dev/null; then
      echo "FAIL: Network driver missing"
      exit 1
    fi

**After another issue (Week 5):** Check all required modules

.. code-block:: bash

    #!/bin/bash
    REQUIRED_MODULES="mlx5_core nvidia amdgpu xfs nfs ib_core"
    for mod in $REQUIRED_MODULES; do
      if ! modinfo $mod &>/dev/null; then
        echo "FAIL: Module $mod missing"
        exit 1
      fi
    done

**Current version (Month 6):** Comprehensive module verification

.. code-block:: python

    #!/usr/bin/env python3
    """
    Verify all required kernel modules are present and loadable.
    Grown from simple checks to comprehensive validation.
    """
    import subprocess
    import sys
    
    REQUIRED_MODULES = {
        'network': ['mlx5_core', 'mlx5_ib', 'i40e'],
        'gpu': ['nvidia', 'amdgpu'],
        'storage': ['xfs', 'nfs', 'nfsv4'],
        'infiniband': ['ib_core', 'ib_umad', 'rdma_cm'],
    }
    
    def check_module(module_name):
        """Check if kernel module is present."""
        try:
            result = subprocess.run(['modinfo', module_name],
                                  capture_output=True, text=True)
            return result.returncode == 0
        except Exception as e:
            print(f"Error checking module {module_name}: {e}")
            return False
    
    def main():
        all_passed = True
        for category, modules in REQUIRED_MODULES.items():
            print(f"\nChecking {category} modules:")
            for module in modules:
                if check_module(module):
                    print(f"  ✓ {module}")
                else:
                    print(f"  ✗ {module} - MISSING")
                    all_passed = False
        
        if not all_passed:
            print("\nFAILURE: Some required modules are missing")
            sys.exit(1)
        
        print("\nSUCCESS: All required modules present")
    
    if __name__ == '__main__':
        main()

This evolution happened organically - each production issue became a test case.


What We've Learned
==================

Writing Good Tests is Hard
---------------------------

**Challenge:** Tests need to be:

- Specific enough to catch real issues
- General enough to not break on minor changes
- Fast enough to run frequently
- Reliable (not flaky)

**Reality:** Many iterations needed. Early tests had false positives, missed real issues, or were too fragile.

**Lesson:** Start simple, refine based on real failures. Perfect is the enemy of good enough.

Even Basic Automation Has Value
--------------------------------

**Observation:** Even our earliest, simplest tests (Does image exist? Is it the right size?) caught mistakes immediately.

**Example:** Automated test caught a typo in build script that would have created a 0-byte image. Previously, we wouldn't have noticed until manual testing.

**Lesson:** Don't wait for comprehensive testing to start automating. Basic checks are better than no checks.

Test Suite Becomes Knowledge Base
----------------------------------

**Observation:** The test suite documents "things that broke before."

**Example:** When new admin asks "What needs to be verified in an image?", the test suite is the answer. It's living documentation of our operational knowledge.

**Lesson:** Tests are communication tools, not just validation tools.

Automated Testing Enables Boldness
-----------------------------------

**Behavioral change:** We're more willing to update OS packages, try new kernel versions, or refactor build procedures.

**Why:** Automated tests provide safety net. If we break something obvious, tests fail immediately.

**Caveat:** This is psychological confidence, not bulletproof guarantee. We still do manual testing before production.

Container Testing Has Limitations
----------------------------------

**Challenge:** Testing images in containers doesn't perfectly match bare-metal PXE boot.

**Gaps we've found:**

- Some kernel modules behave differently
- Network boot timing isn't replicated
- Hardware detection varies
- GPU testing requires compatible container runtime

**Workaround:** Automated tests catch 70-80% of issues. Manual testing on actual hardware catches the rest.

**Lesson:** Imperfect automated testing is still valuable. Don't let perfect be enemy of good.


Workflow Maintenance
====================

Ongoing Challenges
------------------

**Tests need updates:**

- When we add new software, tests need corresponding checks
- When OS changes (RHEL 8 → 9), test assumptions change
- When hardware changes (new GPUs), tests need new cases

**Infrastructure evolution:**

- Argo Workflows updates occasionally break our workflows
- Container images need regular updates
- Storage paths change, workflows need adjustment

**Time investment:**

- Initial setup: ~2 weeks
- Ongoing maintenance: ~2-4 hours/month
- Adding new tests: ~1 hour per test

Is It Worth It?
---------------

**Honest assessment:**

- Setup time was significant
- Maintenance is ongoing but manageable
- Time savings are real but hard to quantify precisely
- Main value is confidence and knowledge building, not raw time savings

**Would we do it again?** Yes, but with realistic expectations:

- It's a learning project, not a turnkey solution
- Benefits accumulate slowly over time
- Perfect for experimental low-risk learning
- Not ideal if you need immediate productivity gains


Current Status and Next Steps
==============================

Where We Are Now
----------------

- Test suite has 30+ automated checks (started with 5)
- Catches most trivial issues before manual testing
- Runs automatically on every image build
- Team is comfortable with workflow operation
- Documentation has improved significantly

What's Working Well
-------------------

- Automated smoke tests save manual testing time
- Test failures usually indicate real problems
- Team learned K8s concepts through practical application
- GitOps approach makes rebuilding straightforward

What Still Needs Work
----------------------

- Some tests are flaky, need refinement
- Container testing gaps require manual validation
- Test maintenance takes ongoing effort
- Integration with production deployment could be smoother

Future Improvements We're Considering
--------------------------------------

- Better test reporting and visualization
- Automatic notification on test failures
- More comprehensive Spack integration testing
- Automated deployment to test nodes (currently manual)
- Historical test result tracking

**Reality check:** These are aspirational. Given our time/resource constraints, we're improving incrementally as needs arise rather than pursuing ambitious roadmap.


Conclusion
==========

This PXE image automation project exemplifies our low-risk learning approach:

**What worked:**

- Starting simple and evolving organically
- Learning K8s through practical application
- Building institutional knowledge through tests
- Treating failures as learning opportunities

**What was harder than expected:**

- Writing reliable tests
- Container vs. bare-metal differences
- Ongoing maintenance requirements
- Balancing automation investment vs. manual processes

**Key takeaway:** This isn't a success story about eliminating manual work. It's a learning story about gradually building automation, institutional knowledge, and operational confidence while maintaining production stability.

If you're considering similar automation:

- ✅ Start with simple, obvious tests
- ✅ Expect significant learning curve
- ✅ Plan for ongoing evolution
- ✅ Keep manual validation for critical checks
- ❌ Don't expect immediate productivity gains
- ❌ Don't try to automate everything at once
- ❌ Don't treat this as production-critical infrastructure
