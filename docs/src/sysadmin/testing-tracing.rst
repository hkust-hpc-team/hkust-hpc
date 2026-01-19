======================
Testing and Validation
======================

This document describes operational validation methodology for HPC infrastructure. Testing serves three purposes: establishing performance baselines, detecting regressions, and diagnosing operational issues. Tool selection reflects practical operational experience - we document preferred tools for specific purposes rather than comprehensive tool catalogs.

**Validation Philosophy:**

Testing follows data-driven operational principles (see :doc:`index`):

- **Establish baselines:** Initial validation creates archived golden standards for later comparison
- **Detect regressions:** Automated comparison against baselines identifies performance degradation
- **Diagnose root causes:** Problem-specific tools with known limitations and use cases

Every validation result should be archived: performance figures, network topology snapshots, configuration states. Regression detection requires historical data - without baselines, "is this normal?" questions become unanswerable.

.. contents::
   :local:
   :depth: 2

Baseline Establishment
======================

Initial system validation creates archived reference data for regression detection. Baselines document expected behavior under known-good conditions.

Performance Baselines
---------------------

Baseline benchmarks serve two overlapping purposes: external validation (comparing to published results from other HPC centers) and internal regression detection (comparing current state to archived known-good baselines).

**External validation benchmarks** provide comparative context:

- Standardized benchmarks with published results from other HPC centers (HPL, HPCG, STREAM, SPEC suites)
- Validates system performance relative to comparable infrastructure elsewhere
- Answers: "Is our performance competitive with similar systems?"
- Limitation: May not reflect actual user workload characteristics

**Internal baseline benchmarks** enable regression detection:

- Any reproducible performance metric archived as known-good reference
- Enables comparison: current state vs. historical baseline
- Answers: "Did system performance degrade after this change?"
- Can use external validation benchmarks OR domain-specific applications OR user workloads

**Many benchmarks serve both purposes.** SPEC HPC 2021 provides external validation (published results available) and internal regression detection (archive your own baseline). User applications provide strong internal baselines but rarely offer external validation unless the application is widely used across commercial clusters.

**Benchmark selection by setup complexity and validation purpose:**

**Low-complexity validation** (minimal setup, often external validation available)

- **HPL / HPCG** (CPU systems)
  
  - **Setup effort:** Low - standardized benchmarks with established procedures
  - **External validation:** Yes - extensive published results from Top500, vendor benchmarks
  - **What it validates:** CPU/memory performance, basic point-to-point MPI
  - **Limitation:** Doesn't validate MPI collective operations, complex communication patterns, I/O subsystem, scheduler integration
  - **Use case:** Vendor acceptance (external comparison), quick post-maintenance validation (internal regression check)
  - **Archive baseline:** GFLOPS results, memory bandwidth (±5% tolerance)

- **HPL-MxP + NCCL** (GPU systems)
  
  - **Setup effort:** Low - well-documented, vendor-supported, standardized execution
  - **External validation:** Yes - vendor benchmarks, MLPerf results provide comparative context
  - **What it validates:** GPU compute performance, basic network throughput, multi-GPU collective operations
  - **Limitation:** Synthetic workload - validates hardware capability but not software stack integration or realistic application behavior
  - **Use case:** Vendor acceptance testing, quick regression checks, external performance claims
  - **Archive baseline:** TFLOPS/node, NCCL bandwidth results

- **STREAM** (memory bandwidth)
  
  - **Setup effort:** Very low - single executable, minimal configuration
  - **External validation:** Yes - widely published results for various CPU architectures
  - **What it validates:** Memory subsystem bandwidth and NUMA configuration
  - **Use case:** Quick single-node validation (~450 GB/s aggregate for dual-socket AMD EPYC 9754)
  - **Archive baseline:** Bandwidth per NUMA node

**High-complexity validation** (significant setup, diagnostic depth)

- **SPEC HPC 2021** (CPU HPC workloads)
  
  - **Setup effort:** High - requires building multiple applications, configuring MPI runtimes, extensive environment tuning
  - **External validation:** Yes - published results from HPC centers provide comparative baseline
  - **What it validates:** End-to-end integration (scheduler, MPI runtime, compilers, network fabric, filesystem), parallel scaling, cross-node communication patterns
  - **Diagnostic value:** Multi-workload suite identifies specific subsystem regressions - network issues manifest in communication-bound benchmarks, compiler issues in compute-bound benchmarks
  - **Execution requirement:** Run through SLURM (dogfooding - validates production infrastructure)
  - **Use case:** Comprehensive validation with external comparison + internal regression detection
  - **Archive baseline:** Full HTML reports, per-benchmark results, scaling efficiency (see :doc:`../benchmarks/multi-node` - 72% parallel efficiency across 32 nodes)

- **MLPerf Training** (AI/ML workloads)
  
  - **Setup effort:** High - requires dataset preparation, framework configuration, distributed training setup
  - **External validation:** Yes - standardized benchmark with published results from major AI infrastructure providers
  - **What it validates:** GPU training performance, gradient synchronization, data pipeline efficiency
  - **Diagnostic value:** Identifies data loading bottlenecks, communication inefficiencies in distributed training
  - **Use case:** AI-focused infrastructure validation with external comparison

- **LLM training benchmarks** (Llama2 7B FSDP training, TPS measurement)
  
  - **Setup effort:** Very high - requires model weights, distributed framework (FSDP/DeepSpeed), extensive tuning
  - **External validation:** Limited - some published results from research groups, but configurations vary significantly
  - **What it validates:** Large-scale model parallelism, optimizer state sharding, activation checkpointing
  - **Diagnostic value:** Real-world LLM training characteristics - memory management, communication patterns differ from MLPerf
  - **Use case:** Production LLM infrastructure validation, primarily internal baseline

- **Representative User Applications** (domain-specific)
  
  - **Setup effort:** Very high - requires domain expertise, representative datasets, validation procedures
  - **External validation:** Rarely - unless application widely used, users may provide comparison data from other clusters
  - **What it validates:** Actual user workload performance - most relevant but most expensive to maintain
  - **Examples:** Ocean models (ROMS), molecular dynamics (GROMACS), weather prediction (WRF)
  - **Challenge:** Dataset management, input sensitivity, versioning complexity
  - **Use case:** Production validation for domain-specific HPC centers, strong internal baseline

**Choosing validation approach:**

- **External comparison needed:** Use standardized benchmarks (HPL, SPEC HPC, MLPerf) with published results
- **Internal regression detection:** Any reproducible benchmark - archive baseline, compare after changes
- **Initial deployment:** Start with low-complexity external validation (HPL, STREAM) to establish baseline functionality
- **Production operations:** Add high-complexity benchmarks (SPEC HPC, user applications) enabling detailed diagnosis when issues arise
- **Limited resources:** Prioritize internal regression detection with simple benchmarks over comprehensive external validation

**Single-node validation:**

- **FIO:** Filesystem client validation without MPI complexity (internal baseline only - configurations vary too much for external comparison)

Hardware Topology Baselines
----------------------------

**Network topology snapshot:**

.. code-block:: bash

   # Archive network topology
   ibnetdiscover > /var/log/validation/ibnetdiscover-$(date +%Y%m%d).txt
   
   # Later: Detect topology changes
   diff /var/log/validation/ibnetdiscover-{baseline,current}.txt

**Use case:** Validates network fabric after maintenance (cable work, switch replacements)

**What it detects:** Missing links, incorrect cabling, switch port assignment errors

**NUMA topology verification:**

.. code-block:: bash

   # Archive NUMA topology
   lstopo --of txt > /var/log/validation/numa-topology.txt
   
   # Verify GPU-CPU affinity
   nvidia-smi topo -m > /var/log/validation/gpu-topology.txt

**Use case:** Validates consistent hardware configuration across compute nodes

**What it detects:** Asymmetric NUMA configurations, GPU NUMA placement issues

Regression Detection
====================

Regression detection compares current system state against archived baselines, identifying performance degradation or configuration drift after changes.

Automated Performance Validation
---------------------------------

**Post-change validation workflow:**

.. code-block:: bash

   # After major system changes (OS updates, driver updates, maintenance)
   
   # 1. Run validation benchmark
   sbatch --partition=validation run-spechpc-validation.sh
   
   # 2. Compare against baseline (±5% tolerance)
   compare-spechpc-results.sh \
       --baseline /var/log/validation/spechpc-baseline-2024.txt \
       --current /var/log/validation/spechpc-$(date +%Y%m%d).txt \
       --tolerance 5

**When to run regression tests:**

- After OS or kernel updates
- After driver updates (network, GPU, filesystem client)
- After firmware updates (BIOS, BMC)
- After hardware maintenance (cable work, cooling system work)
- Periodic validation (monthly/quarterly for drift detection)

**Tolerance guidelines:**

- **±5% performance:** Acceptable run-to-run variation
- **>10% degradation:** Investigate immediately - likely configuration issue
- **>20% degradation:** Severe regression - halt deployment, diagnose before production

Configuration Drift Detection
------------------------------

**System configuration snapshots:**

.. code-block:: bash

   # Archive system configuration
   cat /proc/cmdline > /var/log/validation/kernel-cmdline-$(date +%Y%m%d).txt
   sysctl -a > /var/log/validation/sysctl-$(date +%Y%m%d).txt
   
   # Compare after updates
   diff /var/log/validation/sysctl-{baseline,current}.txt

**Use case:** Detects configuration drift after package updates or manual changes

**Example regression:** Kernel parameter reverted to default after package update, causing performance degradation

Diagnostic Workflows
====================

Problem-specific diagnostic approaches using opinionated tool selection based on operational experience.

Diagnosing Performance Degradation
-----------------------------------

**Preferred tool: Atop** (system-wide resource monitoring with 10-minute interval backtracking)

.. code-block:: bash

   # Persistent atop logging (configured at system level)
   systemctl enable --now atop
   
   # Investigate past resource utilization
   atop -r /var/log/atop/atop_20260117  # View specific day
   
   # Press: 'm' (memory), 'd' (disk), 'n' (network), 'g' (GPU)

**What it catches:**

- Resource saturation (CPU, memory, I/O, network)
- Runaway processes consuming resources
- Historical resource utilization patterns before crashes

**What it doesn't catch:**

- Sub-10-minute transient issues
- Per-core CPU utilization detail (use ``htop`` for real-time detail)

**Use case:** User reports "job was slow yesterday" - Atop provides 10-minute granularity backtracking to identify resource contention or system load during job execution.

**Requirement:** Configure persistent Atop logging system-wide. Logs survive crashes, enabling post-mortem analysis.

Diagnosing Network Issues
--------------------------

**Preferred first-line tool: IMB-MPI1** (comprehensive MPI communication pattern validation)

.. code-block:: bash

   # Test all MPI communication patterns
   mpirun -np 2 --host node1,node2 IMB-MPI1 PingPong Exchange Allreduce Barrier

**What it catches:**

- Point-to-point latency issues (PingPong)
- Bandwidth degradation (Exchange)
- Collective operation performance (Allreduce, Barrier)
- Message size scaling anomalies (identify MTU issues, buffer tuning problems)

**What it doesn't catch:**

- Physical layer issues without MPI overhead (see alternative below)

**Use case:** Multi-node job exhibits poor scaling - IMB-MPI1 identifies whether issue is latency-bound (point-to-point) or collective-bound (Allreduce).

**Alternative tool consideration:** ``rdma-core`` utilities (``ib_read_bw``, ``ib_write_bw``)

Some network administrators prefer RDMA tools for isolated two-node testing, bypassing MPI runtime complexity. This validates physical connectivity and RDMA functionality without software stack overhead.

.. code-block:: bash

   # Point-to-point RDMA validation (two nodes)
   # Node 1 (server):
   ib_read_bw
   
   # Node 2 (client):
   ib_read_bw node1

**Trade-off:** RDMA tools provide lower-level validation but don't validate MPI runtime integration. Choose based on diagnostic hypothesis - physical layer issue vs. MPI runtime issue.

**Network topology validation:**

.. code-block:: bash

   # Validate fabric connectivity
   ibnetdiscover
   
   # Check link quality
   ibdiagnet

**Use case:** After cable maintenance, verify topology matches expected configuration and identify degraded links.

Diagnosing Application Crashes
-------------------------------

**Preferred approach: Core dumps with debug symbols**

**System configuration:**

.. code-block:: bash

   # Enable core dumps (configure in /etc/security/limits.conf)
   * soft core unlimited
   * hard core unlimited
   
   # Configure core dump location
   # /etc/sysctl.conf
   kernel.core_pattern = /var/crash/core.%e.%p.%t

**User workflow:**

.. code-block:: bash

   # Compile with debug symbols
   gcc -g -O2 myprogram.c -o myprogram
   
   # Run application (crash generates core dump)
   ./myprogram
   
   # Analyze crash
   gdb myprogram /var/crash/core.myprogram.12345.1234567890
   (gdb) bt          # Backtrace
   (gdb) frame 3     # Examine specific frame
   (gdb) print var   # Inspect variable state

**What it catches:**

- Segmentation faults with precise line number and stack trace
- Variable state at crash point
- Call chain leading to fault

**What it doesn't catch:**

- Non-crashing bugs (performance issues, incorrect results, deadlocks)

**Limitation:** Requires compiling with debug symbols (``-g``). Production-optimized code (``-O3`` without ``-g``) may lack sufficient debug information.

Diagnosing Application Slowness
--------------------------------

**Preferred tool: strace** (system call tracing)

.. code-block:: bash

   # Trace system calls to identify I/O bottlenecks
   strace -f -tt -T -o trace.log ./myprogram
   
   # Analyze: Look for slow system calls
   grep -E '<[0-9]+\.[0-9]+ ' trace.log | sort -t'<' -k2 -rn | head -20

**What it catches:**

- I/O bottlenecks (slow ``read()``, ``write()`` calls)
- File locking issues (blocking ``flock()``)
- Network latency (``connect()``, ``send()``, ``recv()``)

**What it doesn't catch:**

- CPU-bound computation slowness (use ``perf`` for CPU profiling)

**Alternative: perf** (CPU profiling)

.. code-block:: bash

   # CPU profiling with flame graph generation
   perf record -F 99 -g -- ./myprogram
   perf script | flamegraph.pl > flamegraph.svg

**Use case:** Application slower than expected - strace identifies if slowness is I/O-bound or CPU-bound.

Diagnosing MPI Deadlocks
-------------------------

**MPI runtime diagnostics:** Modern MPI implementations provide timeout-based stack traces

**OpenMPI example:**

.. code-block:: bash

   # Enable timeout-based stack trace (30 seconds)
   export OMPI_MCA_mpi_abort_print_stack=1
   mpirun --timeout 30 ./mpi_program

**What it catches:**

- Collective operation deadlocks (one rank never reaches collective call)
- Point-to-point deadlocks (circular wait on sends/receives)

**Limitation:** Requires MPI runtime support. Stack traces identify deadlock location but not root cause - manual code analysis required.

Tools for Specific Validation Contexts
=======================================

External Validation and Reference Comparisons
----------------------------------------------

Some benchmarks serve external validation rather than operational diagnostics - establishing that system performs comparably to published results rather than identifying specific tuning opportunities.

**HPL (High-Performance Linpack):**

- **Use case:** Vendor acceptance testing, external performance claims
- **Operational value:** Quick regression check (assert ±5% of baseline after hardware changes)
- **Limitation:** Synthetic workload - excellent for memory/CPU stress but doesn't validate MPI collective operations, I/O subsystem, or realistic workload characteristics
- **When to use:** Initial hardware acceptance, post-maintenance validation
- **When not to use:** Specific performance tuning (use domain-specific benchmarks instead)

**HPCG (High-Performance Conjugate Gradient):**

- **Use case:** Complementary to HPL - validates memory bandwidth under irregular access patterns
- **Operational value:** Alternative synthetic validation
- **Limitation:** Still synthetic - doesn't replace domain-specific testing

**When to archive these results:** Initial system deployment, major hardware changes. Use as sanity checks rather than primary validation.

GPU-Specific Diagnostics
-------------------------

**DCGMI (Datacenter GPU Management Interface):**

.. code-block:: bash

   # GPU health validation
   dcgmi diag -r 3  # Level 3 diagnostic

**Use case:** GPU-specific hardware validation

**When to use:** GPU hardware issues suspected (thermal throttling, memory errors, interconnect issues)

**Limitation:** GPU-only scope - doesn't validate CPU-GPU data transfer, PCIe performance, or application-level integration

Stress Testing
--------------

**Stress-ng:**

.. code-block:: bash

   # System stress test
   stress-ng --cpu 128 --io 4 --vm 2 --vm-bytes 512G --timeout 3600s

**Use case:** Hardware burn-in, thermal validation

**Operational value:** Validates cooling system, identifies marginal hardware

**Limitation:** Synthetic stress - doesn't validate application-realistic workloads. Use for hardware validation, not performance tuning.

User-Facing Diagnostic Capabilities
====================================

System configuration enabling user self-service diagnostics.

Performance Profiling Access
-----------------------------

**CPU hardware counters (perf):**

.. code-block:: bash

   # System configuration: Allow non-root perf access
   sysctl kernel.perf_event_paranoid=1

**User capability:** CPU profiling, cache miss analysis, instruction-level performance analysis

**GPU profiling (Nvidia Nsight):**

.. code-block:: bash

   # System configuration: Allow non-root profiling
   # /etc/modprobe.d/nvidia.conf
   options nvidia NVreg_RestrictProfilingToAdminUsers=0

**User capability:** GPU kernel profiling, memory transfer analysis, occupancy analysis

Core Dump Configuration
-----------------------

**System-wide configuration:**

.. code-block:: bash

   # /etc/security/limits.conf
   * soft core unlimited
   * hard core unlimited

**User capability:** Crash analysis with ``gdb``, stack trace inspection at fault location

**Rationale:** Aligns with guiding principle - users should have diagnostic tools to understand program failures without administrator intervention.

Validation Cadence and Triggers
================================

**Continuous validation triggers:**

- **After every OS/kernel update:** SPEC HPC validation, configuration diff
- **After driver updates:** Network (IMB-MPI1), GPU (DCGMI), filesystem (FIO)
- **After hardware maintenance:** Full validation suite + topology comparison
- **Monthly:** Drift detection (compare current to baseline)
- **After user reports issues:** Targeted diagnostics (Atop backtracking, specific benchmark)

**Validation workflow integration:**

All validation benchmarks execute through SLURM (dogfooding principle - validation uses production infrastructure). This ensures tests validate scheduler integration, resource allocation, and job environment rather than administrator-only configurations.

**Archive retention:**

- Performance baselines: Indefinite (reference data)
- Validation runs: 12 months (trend analysis)
- System topology: All snapshots (audit trail)
- Atop logs: 90 days (operational diagnostics)

Related Documentation
=====================

- :doc:`index` - Guiding principles for data-driven operations and dogfooding
- :doc:`system-config` - System configuration achieving documented performance
- :doc:`numa-optimizations` - Performance tuning validated through benchmarking
- :doc:`../benchmarks/multi-node` - SPEC HPC 2021 baseline results
