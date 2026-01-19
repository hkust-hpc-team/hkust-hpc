===============================
Intel MPI Benchmarks (IMB-MPI1)
===============================

Intel MPI Benchmarks (IMB) is a suite of MPI performance benchmarks measuring communication patterns fundamental to parallel applications. IMB-MPI1, the most widely used component, evaluates point-to-point and collective communication operations across message sizes and process counts. This document describes practical approaches for using IMB-MPI1 in HPC system validation and optimization.

.. contents::
   :local:
   :depth: 2

Overview
========

IMB-MPI1 benchmarks MPI communication performance through systematic testing of standard MPI operations. Unlike application-level benchmarks (SPEC HPC), IMB focuses on MPI library and network fabric performance characteristics, providing infrastructure-level validation.

Value Proposition
-----------------

**Ease of execution:**
  - Most MPI distributions include pre-compiled IMB binaries
  - Minimal configuration required - simple ``mpirun`` invocation starts benchmarking
  - No external dependencies, licensing, or complex setup procedures
  - Rapid iteration enables quick validation during system tuning

**Internal baselining excellence:**
  - Ideal for comparing performance across hardware generations within an organization
  - Tracks performance evolution as infrastructure changes (network upgrades, MPI library updates, kernel patches)
  - Provides quantitative evidence of system tuning impact
  - Example: "Old InfiniBand EDR achieved 90% of theoretical bandwidth at 4MB message size - does new HDR200 maintain or exceed this?"

**Subsystem identification:**
  - Pinpoints which message size ranges exhibit performance anomalies
  - Distinguishes between latency-bound (small messages) and bandwidth-bound (large messages) issues
  - Reveals unexpected performance cliffs suggesting configuration problems
  - Isolates collective vs point-to-point communication bottlenecks

**Limitations acknowledged:**
  - Minimal external validation: Published results are scarce, making cross-facility comparisons difficult
  - Result interpretation requires expertise: Understanding what constitutes "good" performance demands hardware knowledge and historical context
  - Statistical rigor needed: Raw output requires careful analysis to identify meaningful deviations from expected behavior

Learning Curve
--------------

**Difficulty: Easy to Run, Hard to Interpret**

IMB-MPI1 presents an inverted learning curve. Execution is straightforward - administrators can typically run initial tests within minutes of reviewing basic documentation. The complexity emerges during result interpretation and system optimization.

**Easy aspects (hours to basic competency):**

- Running benchmarks: Standard mpirun invocation with intuitive flags
- Output format: Tabular results are human-readable
- Iteration: Quick turnaround (minutes per test) enables rapid experimentation

**Hard aspects (weeks to months for proficiency):**

- **Statistical analysis:** Distinguishing noise from meaningful performance differences requires understanding measurement uncertainty
- **Hardware knowledge:** Interpreting why certain message sizes show anomalies demands familiarity with network architecture (switch fabric topology, MTU settings, RDMA thresholds)
- **Historical context:** Recognizing abnormal behavior requires baseline experience - "Is 15 µs latency good for this interconnect?" depends on knowing what similar systems achieve
- **Algorithm awareness:** Some performance discontinuities reflect MPI library algorithm switching (e.g., eager vs rendezvous protocols), not hardware issues

**Recommendation:** Begin with simple runs comparing known-good systems against newly deployed hardware. Build intuition through repeated measurements before attempting fine-grained optimization. Maintain historical baselines for each major platform to establish organizational performance expectations.

Benchmark Structure
===================

IMB-MPI1 organizes tests into two categories with distinct communication patterns:

Point-to-Point Operations
--------------------------

Measure direct communication between pairs of MPI ranks:

- **PingPong:** Bidirectional latency between two ranks (classic ping-pong pattern)
- **PingPing:** Bidirectional bandwidth with simultaneous sends (full-duplex test)
- **Sendrecv:** MPI_Sendrecv operation testing
- **Exchange:** MPI_Sendrecv with crossed communication (rank 0 ↔ rank 1)

Point-to-point tests stress network link characteristics: latency, bandwidth, and bidirectional utilization.

Collective Operations
---------------------

Measure communication patterns involving multiple ranks:

**Synchronization:**

- **Barrier:** MPI_Barrier synchronization overhead

**Data distribution:**

- **Bcast:** Broadcast from root to all ranks
- **Scatter:** Distribute unique data from root to all ranks
- **Gather:** Collect data from all ranks to root
- **Allgather:** All ranks receive data from all others

**Reduction operations:**

- **Reduce:** Combine data from all ranks to root
- **Allreduce:** Combine data and distribute result to all ranks
- **Reduce_scatter:** Combine and scatter results

**All-to-all communication:**

- **Alltoall:** Personalized all-to-all exchange
- **Alltoallv:** Variable-size all-to-all exchange

Collective operations test MPI library algorithm efficiency, switch fabric performance under many-to-many traffic, and network topology effectiveness.

Message Size Scanning
---------------------

Each benchmark (except Barrier) sweeps message sizes from 0 bytes to 4 MB by default, capturing performance across:

- **Latency regime (0-128 bytes):** Dominated by protocol overhead and network latency
- **Transition regime (256 bytes - 8 KB):** Protocol switching (eager to rendezvous), CPU-copy vs RDMA thresholds
- **Bandwidth regime (16 KB - 4 MB):** Network bandwidth saturation, large-message efficiency

Performance discontinuities at specific message sizes often reveal MPI library tuning opportunities or hardware configuration issues.

Installation and Setup
======================

IMB is included with most MPI distributions or available as a standalone package.

Finding Bundled IMB
-------------------

Most MPI distributions include IMB in their installation directory. Common locations:

.. code-block:: bash

   # Intel MPI
   /opt/intel/oneapi/mpi/*/benchmarks/IMB-MPI1
   
   # Mellanox/NVIDIA OpenMPI (from RPM)
   /usr/mpi/gcc/openmpi-*/tests/imb/IMB-MPI1
   
   # System OpenMPI
   /usr/lib64/openmpi/tests/imb/IMB-MPI1

Regardless of MPI implementation, usage is consistent: ``mpirun -np <processes> IMB-MPI1 [options]``

Building from Source
--------------------

If IMB is not bundled with your MPI distribution:

.. code-block:: bash

   # Download Intel MPI Benchmarks
   git clone https://github.com/intel/mpi-benchmarks.git
   cd mpi-benchmarks
   
   # Set compiler wrapper and build
   export CC=mpicc   # or mpiicc for Intel MPI
   make IMB-MPI1
   
   # Additional components (optional)
   # make IMB-EXT    # One-sided communications
   # make IMB-IO     # I/O benchmarks
   # make IMB-NBC    # Non-blocking collectives
   # make IMB-RMA    # RMA benchmarks
   
   # Run the built benchmark
   mpirun -n <processes> ./IMB-MPI1 [options]

For detailed build options, refer to the GitHub repository README.

Verifying Installation
----------------------

Confirm IMB runs successfully:

.. code-block:: bash

   # Simple 2-process test
   mpirun -np 2 IMB-MPI1 PingPong
   
   # Should output latency measurements
   # If it fails, check MPI environment setup

Basic Usage
===========

IMB-MPI1 accepts benchmark names as arguments, along with flags controlling execution parameters.

Minimal Invocation
------------------

Run specific benchmarks with default settings:

.. code-block:: bash

   # Single benchmark
   mpirun -np 256 IMB-MPI1 Allreduce
   
   # Multiple benchmarks
   mpirun -np 256 IMB-MPI1 PingPong Bcast Allreduce Barrier

Common Execution Flags
----------------------

Control benchmark behavior through IMB-specific flags:

**Process configuration:**

- ``-npmin <N>``: Minimum number of processes to use (useful when oversubscribing ranks)

**Resource limits:**

- ``-mem <size>``: Maximum memory per process (e.g., ``-mem 2G``)
- ``-time <seconds>``: Maximum runtime per benchmark

**Measurement control:**

- ``-iter <count>``: Number of iterations per message size (default varies by benchmark)
- ``-iter_policy off``: Disable automatic iteration adjustment

**Message size control:**

- ``-msglen <file>``: Read custom message size list from file (one size per line)

Example: Comprehensive Collective Test
---------------------------------------

From our operational validation, a typical collective communication test:

.. code-block:: bash

   # Test key collective operations with controlled parameters
   mpirun -np 256 IMB-MPI1 \\
       -npmin 256 \\
       -mem 2G \\
       -time 60 \\
       -iter 1000 \\
       -iter_policy off \\
       -msglen /path/to/message_sizes.txt \\
       Bcast Reduce Reduce_scatter Gather Scatter Barrier

**Output excerpt:**

.. code-block:: text

   Benchmarking Bcast 
          #bytes #repetitions  t_min[usec]  t_max[usec]  t_avg[usec]
               0         1000         0.03         0.79         0.04
               8         1000         0.90        41.66        22.70
             128         1000         1.13        41.69        22.99
            4096         1000         4.73        67.33        42.87
          131072         1000       588.53       920.17       835.79
          524288         1000      2903.33      3689.43      3491.15

   Benchmarking Reduce 
          #bytes #repetitions  t_min[usec]  t_max[usec]  t_avg[usec]
               0         1000         0.03         0.45         0.04
               8         1000         9.14        39.38        24.57
             128         1000        16.29        34.71        26.09
            4096         1000        46.40        49.80        48.32
          131072         1000       183.24       202.52       191.50
          524288         1000       386.93       424.22       401.85

**Interpretation notes:**

- ``t_min``: Minimum time across iterations (best-case performance)
- ``t_max``: Maximum time across iterations (worst-case, may indicate contention)
- ``t_avg``: Average time (typical performance)

Large ``t_max`` / ``t_min`` ratios suggest performance variability warranting investigation.

Message Size Files
------------------

Custom message size files enable focused testing:

.. code-block:: text

   # Example: collective_sizes.txt
   # Focus on latency and bandwidth-critical sizes
   0
   8
   128
   4096
   131072
   524288

Use with ``-msglen collective_sizes.txt`` to test only specified sizes.

Interpreting Results
====================

IMB output requires understanding MPI communication characteristics and network hardware behavior.

Understanding Output Columns
-----------------------------

Each benchmark reports:

- ``#bytes``: Message size in bytes
- ``#repetitions``: Iterations averaged for this measurement
- ``t_min[usec]``: Best-case latency (microseconds)
- ``t_max[usec]``: Worst-case latency (microseconds)
- ``t_avg[usec]``: Average latency (microseconds)

**For bandwidth-oriented interpretation:**

Bandwidth (MB/s) ≈ (Message Size in bytes) / (t_avg in microseconds)

Example: 524288 bytes in 835.79 µs → ~627 MB/s

Performance Patterns to Expect
-------------------------------

**Latency-bound region (0-128 bytes):**

- Dominated by protocol overhead, not message transfer time
- Typical ranges: 0.5-2 µs for RDMA-capable fabrics, 5-20 µs for Ethernet
- Small variations (< 20%) generally acceptable

**Transition region (256 bytes - 8 KB):**

- MPI library protocol switching (eager vs rendezvous)
- Expect discontinuities as algorithms change
- Performance may not scale smoothly with message size

**Bandwidth region (> 16 KB):**

- Should approach network theoretical bandwidth
- Typical targets: 90-95% of link speed for well-tuned systems
- Linear scaling with message size indicates good bandwidth utilization

Identifying Anomalies
----------------------

**Red flags requiring investigation:**

1. **Extreme variability:** ``t_max`` > 3× ``t_min`` suggests contention or interference
2. **Performance cliffs:** Sharp drops at specific message sizes may indicate misconfiguration
3. **Unexpected plateaus:** Bandwidth not increasing with message size suggests bottlenecks
4. **Collective vs point-to-point divergence:** Collectives significantly slower than expected from point-to-point results indicates MPI algorithm issues

**Measurement repetitions:**

IMB-MPI1 runs each message size multiple times (default 1000 iterations, decreasing for larger messages) and reports averaged results. For archival and comparison purposes, save complete logs containing t_min, t_max, and t_avg values. Run benchmarks multiple times (3-5 repetitions) when comparing configurations to account for system variability.

Use Case: Internal Baseline & Regression Detection
===================================================

IMB-MPI1 excels at internal performance tracking within organizations despite limited external validation.

Why Internal Baselining Works
------------------------------

**Controlled comparisons:**

Unlike published benchmarks comparing heterogeneous systems, internal baselines compare:

- Same workload
- Same software stack
- Same operational environment
- Only varying the specific component under test (network hardware, MPI library version, kernel)

This control eliminates confounding variables, making performance differences attributable to known changes.

**Historical context:**

Maintaining IMB baselines across system generations builds institutional knowledge:

*"Our previous-generation InfiniBand EDR fabric achieved:*
- *1.2 µs PingPong latency*
- *11.5 GB/s Allreduce bandwidth at 1MB*
- *25 µs Barrier time for 256 ranks"*

When deploying new hardware, these baselines answer: "Is the new system at least as good?"

Example: Generational Comparison
---------------------------------

When deploying new hardware, compare against documented baselines from previous generations. Focus on key metrics across message size ranges relevant to your applications.

Example comparison table structure:

- PingPong latency (0-128 bytes): Network/protocol baseline
- Allreduce bandwidth (128K-4M): Collective operation efficiency  
- Barrier synchronization time: Multi-rank coordination overhead

Document baseline conditions (MPI library version, process binding, network topology) to ensure valid comparisons.

.. tip::

   **Maintain separate baselines for intra-node and inter-node configurations.**
   
   Communication performance characteristics differ significantly between single-node (intra-node, shared memory) and multi-node (inter-node, network fabric) execution:
   
   - Intra-node baselines: Validate shared memory transports, NUMA effects, process binding
   - Inter-node baselines: Validate network fabric, switch topology, multi-node scaling
   
   Comparing single-node results to multi-node results may lead to incorrect regression conclusions. Establish and maintain distinct baseline sets for each configuration type.

Lack of External Validation
----------------------------

Unlike SPEC HPC (https://www.spec.org/hpc2021/results/), IMB lacks a centralized results repository. Published IMB results are scattered across vendor whitepapers and academic papers, making cross-facility comparisons difficult.

**Mitigation strategies:**

- Build internal baselines early in system lifecycle
- Document baseline conditions (network topology, MPI library, process binding)
- Compare against theoretical limits (link bandwidth, minimal protocol overhead)
- Consult vendor-provided reference results for your specific hardware

Even without extensive external validation, IMB provides actionable performance data for internal optimization.

Use Case: Configuration Change Validation
==========================================

IMB-MPI1 serves as a diagnostic tool during system tuning, revealing the impact of configuration changes on MPI performance.

Configuration A/B Testing Example
---------------------------------

The following example demonstrates the procedure for evaluating kernel module impact on intra-node communication performance. This methodology can be adapted to assess other system configuration changes.

**Test Objective:**

Evaluate the impact of enabling the XPMEM kernel module on MPI communication performance.

**Procedure:**

1. Ensure xpmem is not loaded:

.. code-block:: bash

   lsmod | grep xpmem
   # If loaded, unload it
   sudo rmmod xpmem

2. Establish baseline measurement:

.. code-block:: bash

   # Baseline: default kernel configuration
   mpirun --map-by core --rank-by numa --bind-to core -np <processes> IMB-MPI1 \
       -iter 100 -time 30 -mem 4G -npmin <processes> \
       Allreduce Reduce Allgather Alltoall

3. Apply configuration change and re-measure:

.. code-block:: bash

   # Test configuration: enable XPMEM kernel module
   modprobe xpmem
   # Execute identical benchmark command
   
4. Analyze performance differences:

.. code-block:: text

   Example comparison: Baseline vs Modified Configuration
   Performance shown as speed multiplier (higher = faster, 1.00x = baseline)
   
   Benchmark     | 0-32 bytes | 64-4K bytes | 8K-256K    | 512K-4M
   ------------------------------------------------------------------
   PingPong      | 1.00x      | 0.97x       | 0.85x      | 2.28x
   Exchange      | 1.04x      | 1.00x       | 5.02x      | 1.07x
   Reduce        | 0.30x      | 0.93x       | 4.03x      | 3.56x
   Allreduce     | 0.76x      | 1.00x       | 5.44x      | 10.60x

**Sample Interpretation**

Analyze results across message size ranges to identify performance trade-offs. In this example:

- Large message operations (> 8KB) show substantial improvements (3-10x)
- Small message operations (< 32 bytes) exhibit regressions (0.30x-0.76x)
- Point-to-point operations show mixed results across size ranges
- Decided to enable XPMEM due to significant large-message gains, investigate small-message regressions further

.. note::
  
   Specific performance values are system-dependent. The methodology demonstrated here applies regardless of absolute performance numbers obtained on different hardware platforms.

Best Practices
==============

Operational guidelines for effective IMB-MPI1 usage:

Measurement Protocols
---------------------

**Establish baseline conditions:**

- Quiescent system (no competing workloads)
- Consistent process binding (document ``mpirun`` flags)
- Multiple repetitions (3-5 runs) for configuration comparisons

**Result archival:**

Maintain historical IMB results for long-term tracking:

.. code-block:: bash

   # Archive complete logs with metadata
   SYSTEM=hpc4-node001
   DATE=$(date +%Y%m%d)
   CONFIG=baseline-openmpi4.1
   
   mpirun ... IMB-MPI1 ... | tee imb-${SYSTEM}-${DATE}-${CONFIG}.log

Store logs with system documentation for future reference.

Limitations and Caveats
-----------------------

**Scope limitations:**

- IMB measures MPI library and network fabric performance in isolation
- Application performance depends on additional factors: computation patterns, memory access patterns, I/O behavior
- IMB employs regular, predictable communication patterns; real applications may exhibit irregular behavior
- IMB results provide infrastructure-level validation but do not replace application-level performance analysis

References and Resources
=========================

Official Documentation
----------------------

- **Intel MPI Benchmarks User Guide:** https://www.intel.com/content/www/us/en/docs/mpi-library/user-guide-benchmarks/2021-8/overview.html
- **GitHub Repository:** https://github.com/intel/mpi-benchmarks

Related Benchmarks
------------------

IMB-MPI1 complements other communication benchmarks:

- **OSU Microbenchmarks:** Alternative MPI performance suite with additional test patterns
- **HPCC (HPC Challenge):** Includes RandomAccess, which stresses irregular communication
- **SPEC HPC 2021:** Application-level benchmarks with realistic communication patterns (:doc:`spec-hpc`)

For comprehensive HPC system validation, use IMB alongside application benchmarks rather than in isolation.
