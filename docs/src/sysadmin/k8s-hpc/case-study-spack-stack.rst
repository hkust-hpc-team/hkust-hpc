=========================================================
Case Study: Automating Spack Software Stack Builds
=========================================================

Overview
========

This case study documents our experiment automating Spack-based hierarchical software stack builds. It showcases the challenges of managing complex software dependencies, multiple compilers, and MPI implementations in an HPC environment.

**Status:** Work in progress, continuously improving

**Timeline:** ~8 months of iterative development

**Impact:** More frequent software updates; parallel builds reduce wall-clock time; integration testing catches OS/software incompatibilities


The Problem We Were Solving
============================

Understanding Hierarchical Modules
-----------------------------------

Our software environment uses hierarchical modules (Lmod + Spack):

.. code-block:: text

    Core modules (always available)
    ├── Compilers: GCC, Intel oneAPI, AOCC
    └── When compiler loaded → MPI modules appear
        ├── Intel MPI, OpenMPI, MPICH (built with that compiler)
        └── When MPI loaded → Application modules appear
            └── GROMACS, LAMMPS, WRF, etc. (built with that compiler+MPI)

**Context:** See :doc:`../../software-ecosystem` for detailed explanation of hierarchical module systems.

**Example user workflow:**

.. code-block:: bash

    $ module av                    # Shows only core modules
    ----------- Core Modules -----------
    gcc/13.2.0    intel/2024.0    aocc/4.0.0
    
    $ module load gcc/13.2.0       # Load compiler
    $ module av                    # Now MPI modules appear
    ----------- GCC 13.2.0 -----------
    openmpi/5.0.0    intel-mpi/2021.11    mpich/4.1.2
    
    $ module load openmpi/5.0.0    # Load MPI
    $ module av                    # Now applications appear
    ----------- GCC 13.2.0 + OpenMPI 5.0.0 -----------
    gromacs/2024.1    lammps/2023.08.02    wrf/4.5

This creates a matrix:

- 3 compilers × 3 MPI implementations × ~50 applications = ~450 software builds

Manual Build Process Pain Points
---------------------------------

**The manual workflow:**

1. SSH to build node
2. Activate Spack environment
3. Build compiler toolchain:

   .. code-block:: bash

      spack install gcc@13.2.0
      spack install intel-oneapi-compilers@2024.0.0
      spack install aocc@4.0.0

4. For each compiler, build MPI implementations:

   .. code-block:: bash

      spack install openmpi@5.0.0 %gcc@13.2.0
      spack install intel-mpi@2021.11 %gcc@13.2.0
      spack install mpich@4.1.2 %gcc@13.2.0
      # Repeat for intel and aocc...

5. For each compiler+MPI combination, build applications:

   .. code-block:: bash

      spack install gromacs@2024.1 %gcc@13.2.0 ^openmpi@5.0.0
      # Repeat for all compiler+MPI+app combinations...

6. Regenerate module files
7. Regenerate Lmod cache
8. Test module hierarchy
9. Spot-check applications

**Time required:** 8-12 hours of build time, 2-3 hours of babysitting/manual steps

**Problems:**

- **Serial execution**: Builds run one after another
- **Long feedback cycles**: Won't know if something breaks until hours later
- **Manual intervention**: Have to start each build phase manually
- **Error recovery is painful**: If build fails at step 47, have to debug and restart
- **Limited testing**: Only test what we remember to test
- **Hesitant to update**: Fear of 12-hour debugging session makes us delay updates
- **Version proliferation**: Instead of updating software, we add versions with date suffixes to avoid risking existing installations

**Real example of date-suffix workaround:**

.. code-block:: bash

    $ module av gromacs
    gromacs/2023.3
    gromacs/2024.1-20241115    # "Probably newer, but old one still works"
    gromacs/2024.1-20241203    # "Fixed some issue, keeping old one just in case"
    gromacs/2024.1-20241215    # "Latest, but users might still use 20241203"

This accumulated clutter because we lacked confidence to replace versions.


Our Solution (Continuously Improving)
======================================

We built an Argo Workflows pipeline to automate the build-test-deploy cycle for Spack stacks. It's evolved significantly as we learn what matters.

High-Level Workflow
-------------------

.. code-block:: text

    Git Commit (Spack config) → Trigger Workflow
           ↓
    Parse Build Matrix (Compiler × MPI × Apps)
           ↓
    Parallel Build Phase:
       ├─ Build GCC + deps ─────┬─→ Build OpenMPI %gcc ─────┬─→ Build apps
       ├─ Build Intel + deps ───┼─→ Build Intel-MPI %intel ─┼─→ Build apps  
       └─ Build AOCC + deps ────┴─→ Build MPICH %aocc ──────┴─→ Build apps
           ↓
    Generate Module Files (Parallel)
           ↓
    Regenerate Module Caches
           ↓
    Integration Testing (Against Current OS Image)
       ├─ Compiler sanity tests
       ├─ MPI functionality tests
       └─ Application smoke tests
           ↓
    Generate Build Report
           ↓
    (Manual) Deploy to Production

Parallelization Strategy
-------------------------

**Sequential dependencies:**

- Compilers must build before MPI
- MPI must build before applications
- But within each tier, builds can run in parallel

**What runs in parallel:**

- All 3 compilers build simultaneously on different nodes
- Once GCC finishes, all GCC-based MPIs build simultaneously
- Once GCC+OpenMPI finishes, all GCC+OpenMPI apps build simultaneously

**Resource allocation:**

- K8s scheduler distributes builds across available nodes
- Heavy builds (compilers) get more CPU/memory
- Light builds (small applications) share nodes

**Time savings:**

- Serial: 8-12 hours
- Parallel: 2-3 hours (wall-clock time)
- Caveat: Still ties up K8s cluster for hours; can't run other workflows simultaneously

Implementation Sketch
---------------------

.. code-block:: yaml

    # Simplified workflow structure
    apiVersion: argoproj.io/v1alpha1
    kind: WorkflowTemplate
    metadata:
      name: spack-stack-build
    spec:
      entrypoint: main
      templates:
      - name: main
        steps:
        # Phase 1: Build compilers in parallel
        - - name: build-compilers
            template: build-compiler-matrix
        
        # Phase 2: Build MPI (depends on compilers)
        - - name: build-mpi
            template: build-mpi-matrix
            arguments:
              parameters:
              - name: compilers-ready
                value: "{{steps.build-compilers.outputs.result}}"
        
        # Phase 3: Build applications (depends on MPI)
        - - name: build-applications
            template: build-app-matrix
            arguments:
              parameters:
              - name: mpi-ready
                value: "{{steps.build-mpi.outputs.result}}"
        
        # Phase 4: Post-processing
        - - name: generate-modules
            template: generate-module-files
          - name: regenerate-caches
            template: rebuild-module-caches
        
        # Phase 5: Testing
        - - name: integration-tests
            template: run-integration-tests
      
      - name: build-compiler-matrix
        steps:
        - - name: build-gcc
            template: spack-install
            arguments:
              parameters:
              - name: spec
                value: "gcc@13.2.0"
          - name: build-intel
            template: spack-install
            arguments:
              parameters:
              - name: spec
                value: "intel-oneapi-compilers@2024.0.0"
          - name: build-aocc
            template: spack-install
            arguments:
              parameters:
              - name: spec
                value: "aocc@4.0.0"
      
      # Spack install task template
      - name: spack-install
        inputs:
          parameters:
          - name: spec
        container:
          image: spack-builder:latest
          command: ["/scripts/spack-install.sh"]
          args: ["{{inputs.parameters.spec}}"]
          volumeMounts:
          - name: spack-store
            mountPath: /spack
          resources:
            requests:
              memory: "16Gi"
              cpu: "8"
            limits:
              memory: "32Gi"
              cpu: "16"


What Works Well
===============

Spack Dependency Resolution
----------------------------

**Benefit:** Spack automatically handles complex dependency graphs.

**Example:** Installing GROMACS pulls in:

- FFTW (with appropriate optimization flags)
- BLAS/LAPACK (using optimized Intel MKL or OpenBLAS)
- CUDA/HIP support (if available)
- Various utilities and libraries

Manual dependency tracking would be nightmare. Spack handles this.

Parallel Builds Speed Things Up
--------------------------------

**Observation:** Wall-clock time reduced from 8-12 hours to 2-3 hours.

**Reality check:**

- Total CPU time is similar (maybe slightly higher due to overhead)
- Benefit is human time savings - don't have to wait 12 hours
- K8s cluster is tied up for 2-3 hours (can't run other workflows)

**When it helps most:** Rebuilding entire stack (rare). Incremental updates (common) see less dramatic improvement.

Build Logs Automatically Captured
----------------------------------

**Benefit:** Every build logs to persistent storage, organized by spec and timestamp.

**Structure:**

.. code-block:: text

    /logs/spack-builds/
    ├── 2024-12-15_143022/
    │   ├── gcc-13.2.0.log
    │   ├── openmpi-5.0.0-gcc-13.2.0.log
    │   ├── gromacs-2024.1-gcc-13.2.0-openmpi-5.0.0.log
    │   └── build-summary.json
    ├── 2024-12-16_091534/
    │   └── ...
    └── latest -> 2024-12-16_091534/

**Value:** When debugging "why did build fail?", logs are organized and searchable. Previously, logs were scattered across terminal sessions or lost.

Module Cache Regeneration Automated
------------------------------------

**Benefit:** Lmod module caches update automatically after builds.

**Previously:** Manual steps:

.. code-block:: bash

    $ /opt/apps/lmod/update_cache.sh
    $ spider-cache-rebuild /opt/modules

**Now:** Workflow handles this, one less thing to remember.


What's Still Challenging
========================

Debugging Remote Build Failures
--------------------------------

**Problem:** When Spack build fails in container, debugging is harder than interactive build.

**Interactive debugging workflow:**

.. code-block:: bash

    $ spack install gromacs@2024.1
    # Build fails
    $ cd $(spack location -b gromacs@2024.1)
    $ # Can inspect build directory, re-run commands, test fixes

**Container debugging workflow:**

.. code-block:: bash

    # Check logs
    $ kubectl logs workflow-pod-xyz
    # See error, but can't easily interactively debug
    # Have to:
    # 1. Edit workflow to add debugging steps
    # 2. Re-run workflow
    # 3. Check new logs
    # 4. Repeat

**Workaround:** For stubborn build issues, debug interactively on build node first, then update workflow once solution is known.

**Lesson:** Containers provide reproducibility but sacrifice interactivity. Trade-off worth it for routine builds, not for complex debugging.

Test Failures in Containers
----------------------------

**Problem:** Some tests pass in containers but fail on bare metal (or vice versa).

**Example issues:**

- MPI tests expect specific network interfaces
- GPU tests need actual GPUs (can't test in CPU-only containers)
- Filesystem tests behave differently in container vs. NFS mount

**Current approach:**

- Run basic sanity tests in containers (does it compile? does it link?)
- Run comprehensive tests on actual hardware after deployment
- Accept that container testing catches ~70% of issues

**Lesson:** Automated testing in containers is valuable but imperfect. Combine with manual testing on real hardware.

Keeping Workflows Updated
--------------------------

**Problem:** Spack evolves; our workflows need updates to stay compatible.

**Examples:**

- Spack changes how it handles compilers → workflow breaks
- New Spack version changes module file format → regeneration step needs update
- Build dependencies change → resource allocation needs adjustment

**Maintenance required:** ~2-4 hours per month to keep workflows current.

**Lesson:** Infrastructure as Code reduces but doesn't eliminate maintenance. Budget time for updates.

Integration Testing Complexity
-------------------------------

**Challenge:** Testing new Spack stack against current OS image is complex.

**What we want to test:**

- Do Spack-built compilers find OS libraries?
- Do applications link against OS-provided dependencies?
- Do module files work correctly?
- Does everything work with current kernel version?

**What's hard:**

- OS image and Spack stack are built in different workflows
- Coordinating testing between workflows is tricky
- Full integration test requires deploying both to real hardware

**Current solution:** Basic integration tests in containers, comprehensive testing on dedicated test nodes (manual).

**Lesson:** Cross-component integration testing is genuinely hard. We're still learning best practices here.


What We've Learned
==================

Time Savings Exist But Are Hard to Quantify
--------------------------------------------

**Observation:** Builds complete faster (wall-clock), but total effort is hard to measure.

**Factors:**

- Setup time was significant (2-3 weeks initial investment)
- Ongoing maintenance takes time (~2-4 hours/month)
- When builds work, they're "fire and forget"
- When builds break, debugging takes longer than interactive approach

**Honest assessment:** We save time on routine rebuilds but spend time on maintenance and debugging complex issues. Net benefit is positive but incremental, not dramatic.

Confidence is Partially Psychological
--------------------------------------

**Observation:** We're more willing to update software, but is this rational or emotional?

**Analysis:**

- Automated tests provide safety net (rational confidence)
- But we still do manual testing before production (reveals limits of automated tests)
- The real change is mindset: "I can try this update and tests will catch obvious issues"
- This reduces update anxiety, making us more willing to experiment

**Lesson:** Psychological confidence matters. Even imperfect automation makes us more willing to maintain software stack actively.

Workflows Evolved Significantly
--------------------------------

**Initial workflow (Month 1):**

- Simple: Build everything serially
- Minimal error handling
- No testing
- ~100 lines of YAML

**Current workflow (Month 8):**

- Complex: Parallel builds with dependency management
- Robust error handling and retry logic
- Comprehensive testing phases
- Integration with monitoring
- ~800 lines of YAML across multiple templates

**Evolution was organic:** Each pain point led to workflow improvements. Didn't start with complex solution; grew into it based on real needs.

**Lesson:** Start simple, evolve based on actual problems. Don't try to build perfect solution upfront.

Manual Intervention Still Required
-----------------------------------

**Reality:** Some things still need human judgment.

**Examples:**

- Deciding which software versions to offer users
- Interpreting ambiguous test failures
- Resolving conflicts between user requests and system constraints
- Handling edge cases that automation doesn't cover

**Acceptance:** This is okay. Goal isn't to eliminate all manual work, but to automate repetitive parts so humans can focus on interesting decisions.

**Lesson:** Automation augments human work, doesn't replace it. Embrace this reality rather than pursuing full automation.


Current Status and Next Steps
==============================

Where We Are Now
----------------

- Workflow builds 3 compilers × 3 MPIs × ~50 applications
- Parallel builds reduce wall-clock time significantly
- Basic integration testing catches many issues
- Team comfortable operating and modifying workflows
- Software stack updated monthly (previously quarterly)

What We're Happy With
----------------------

- Parallel execution works well
- Build logs are organized and searchable
- Routine rebuilds are mostly automated
- Learning K8s through practical application
- Confidence to update software more frequently

What Still Needs Improvement
-----------------------------

- Debugging workflow failures is cumbersome
- Integration testing could be more comprehensive
- Resource allocation could be smarter (currently static)
- Build time estimation is poor (hard to predict completion time)
- Workflow maintenance takes ongoing effort

Ideas We're Considering
------------------------

- **Binary cache optimization**: Reuse builds across workflows
- **Incremental builds**: Only rebuild what changed
- **Better monitoring**: Real-time build progress dashboards
- **Smarter scheduling**: Build high-priority software first
- **Historical analysis**: Track build times, failure patterns over time

**Reality check:** These are aspirational. Given time/resource constraints, we improve incrementally as specific needs arise.


Metrics and Observations
=========================

Build Time Comparison
---------------------

**Serial manual builds:**

- Compilers: 2 hours
- MPI implementations: 3 hours
- Applications: 6 hours
- Post-processing: 30 minutes
- **Total: 11.5 hours**

**Parallel automated builds:**

- Compilers: 45 minutes (parallel)
- MPI implementations: 1 hour (parallel after compilers)
- Applications: 1.5 hours (parallel after MPI)
- Post-processing: 15 minutes
- **Total: 3.5 hours**

**Caveats:**

- Times vary based on what's cached
- Incremental updates take less time
- Full rebuilds (rare) take full time
- Doesn't include debugging time when things break

Update Frequency
----------------

**Before automation:**

- Major updates: ~4 per year (quarterly)
- Minor updates: rarely (too much effort)
- User requests: often delayed months

**After automation:**

- Major updates: ~12 per year (monthly)
- Minor updates: as needed
- User requests: typically fulfilled within weeks

**Caveat:** Correlation isn't causation. Increased update frequency is partly due to automation, partly due to increased confidence, partly due to changing priorities.

Failure Modes
-------------

**Common build failures we've encountered:**

1. **Dependency conflicts** (30%): Spack can't resolve compatible versions
2. **Build system issues** (25%): Configure/CMake fails in unexpected ways
3. **Resource exhaustion** (20%): Container runs out of memory/disk
4. **Network issues** (15%): Can't fetch sources, timeout
5. **Weird edge cases** (10%): Everything else

**Recovery approaches:**

- Dependency conflicts: Adjust Spack config, relax constraints
- Build system issues: Debug interactively, then update workflow
- Resource exhaustion: Increase container limits
- Network issues: Retry with backoff
- Edge cases: Investigate case-by-case


Conclusion
==========

This Spack automation project illustrates both the potential and limitations of applying CI/CD to HPC software management:

**Successes:**

- Parallel builds reduce wall-clock time
- Automated testing catches many issues
- More frequent updates improve software stack currency
- Team learned valuable K8s skills
- Build process is now documented (in workflow) rather than tribal knowledge

**Ongoing challenges:**

- Debugging containerized builds is harder than interactive debugging
- Integration testing gaps require manual validation
- Workflow maintenance requires ongoing investment
- Perfect automation remains elusive

**Key insight:** This isn't about replacing manual work with automation. It's about:

1. Automating repetitive parts (building compiler matrices)
2. Adding systematic testing (catching regressions)
3. Building institutional knowledge (workflow as documentation)
4. Enabling more frequent updates (through confidence)

If you're considering similar automation:

- ✅ Expect significant learning curve
- ✅ Start with simple workflow, evolve organically
- ✅ Accept that debugging will sometimes be harder
- ✅ Keep manual testing for complex validation
- ✅ Budget time for ongoing maintenance
- ❌ Don't expect immediate productivity gains
- ❌ Don't try to automate everything at once
- ❌ Don't eliminate all manual processes

**Final thought:** The real value isn't in raw time savings (though they exist). It's in building operational confidence, institutional knowledge, and modern DevOps practices that will serve your team long-term.
