======================
Testing and Validation
======================

This documentation describes operational validation methodology for HPC infrastructure. Testing serves multiple purposes across system lifecycle: establishing performance expectations, detecting regressions, monitoring operational health, and diagnosing issues.

.. contents::
   :local:
   :depth: 2

Validation Philosophy
=====================

Testing follows data-driven operational principles (see :doc:`../index`):

**Establish baselines:**
  Initial validation creates archived golden standards for later comparison. Without baseline measurements, "is this normal?" questions become unanswerable.

**Detect regressions:**
  Automated comparison against baselines identifies performance degradation after system changes.

**Diagnose root causes:**
  Problem-specific tools with known limitations and use cases enable efficient troubleshooting.

Every validation result should be archived: performance figures, network topology snapshots, configuration states. Regression detection requires historical data - current measurements derive meaning only through comparison with established baselines.

Tool Categories
===============

Validation tools organize into five operational categories. Effective HPC operations require coverage across all categories - not exhaustive tools in one category. Each category serves distinct diagnostic purposes and complements others in the validation workflow.

External Validation
-------------------

External validation compares system performance against published results from other HPC centers using standardized benchmarks. This approach answers: "Is our performance competitive with similar systems?"

**Characteristics:**

- Standardized benchmarks with published results (HPL, SPEC HPC, MLPerf)
- Vendor datasheets and research papers provide comparison points
- Runtime varies from minutes (HPL quick check) to hours (SPEC HPC comprehensive)

**Subsystem coverage:**

- **Compute:** HPL (CPU), SPEC HPC CPU benchmarks
- **Network:** SPEC HPC multi-node scaling, NCCL collective operations
- **Storage:** SPEC HPC I/O benchmarks, IOR
- **Memory:** STREAM, HPCG

**First-line tools:** HPL (CPU compute), HPL-MxP + NCCL (GPU compute), STREAM (memory bandwidth)

Internal Baseline & Regression Detection
-----------------------------------------

Internal baseline tracking monitors system performance over time, detecting degradation after changes. This approach answers: "Did system performance degrade after this change?"

**Characteristics:**

- Any reproducible benchmark works - archive baseline, compare after changes
- Can reuse external validation benchmarks or domain-specific applications
- Tolerance guidelines: ±5% acceptable variation, >10% investigate, >20% halt deployment

**Subsystem coverage:**

- **Compute:** Any CPU/GPU benchmark with reproducible results
- **Network:** IMB-MPI1, NCCL, point-to-point bandwidth tests
- **Storage:** FIO, user I/O workloads
- **Topology:** ibnetdiscover diff, lstopo comparison

**First-line tools:** HPL (fast execution), SPEC HPC (comprehensive coverage), user applications (domain relevance)

**Execution cadence:** After OS/kernel/driver updates, firmware changes, hardware maintenance, monthly drift detection

Monitoring
----------

Monitoring provides real-time observability of system health and resource utilization. This approach answers: "What's happening right now?"

**Characteristics:**

- Always-on with low overhead
- Real-time dashboards and alerting
- Time-series data with retention (typically 30 days)

**Subsystem coverage:**

- **Compute:** CPU/GPU utilization, temperature, frequency scaling
- **Network:** Bandwidth utilization, packet drops, error rates
- **Storage:** I/O throughput, latency, queue depth
- **Memory:** Utilization, swap activity, NUMA balance

**First-line tools:** Prometheus + Grafana (time-series metrics), node exporters, GPU metrics

**Use cases:** Capacity planning, real-time alerts, performance trending

Logging
-------

Logging maintains persistent records enabling post-mortem analysis of past events. This approach answers: "What happened yesterday?" or "Why did this fail overnight?"

**Characteristics:**

- Persistent storage surviving crashes
- Historical data with retention (typically 90 days)
- Subsystem-specific granularity (10-minute intervals to per-event)

**Subsystem coverage:**

- **System-wide resources:** Atop (10-minute intervals, all resources)
- **Kernel events:** journalctl (hardware faults, driver errors, OOM)
- **Application execution:** SLURM logs (job failures, scheduler issues)
- **Network fabric:** Switch logs (link flaps, congestion events)

**First-line tools:** Atop (resource backtracking), journalctl (system events), SLURM logs (job context)

**Critical requirement:** Configure persistent logging at system deployment - logs must survive crashes to fulfill their diagnostic purpose.

Tracing
-------

Tracing provides deep, code-level diagnosis of specific issues through targeted investigation tools. This approach answers: "Why exactly is this broken?" or "Which line of code caused this?"

**Characteristics:**

- Not first-line tools - use after logs localize subsystem
- High overhead - targeted use only, not always-on
- Requires instrumentation (debug symbols, profiling enabled)

**Subsystem coverage:**

- **Application crashes:** gdb + core dumps (stack traces)
- **Application slowness:** strace (system calls), perf (CPU profiling)
- **Network issues:** IMB-MPI1 (MPI patterns), RDMA tools (physical layer)
- **GPU bottlenecks:** Nsight Systems (kernel profiling), nvidia-smi debug

**First-line tools:** gdb (crashes), strace (I/O slowness), perf (CPU slowness), IMB-MPI1 (network diagnosis)

**Usage pattern:** After monitoring/logging identified subsystem, use tracing for precise root cause identification.

Tool Selection Strategy
=======================

Coverage Matrix Approach
------------------------

Effective validation requires at least one tool in each category covering each subsystem. Tool selection depends on available infrastructure, operational needs, and resource constraints.

**Example coverage matrix:**

.. list-table::
   :header-rows: 1
   :widths: 20 16 16 16 16 16

   * - Subsystem
     - External
     - Baseline
     - Monitoring
     - Logging
     - Tracing
   * - CPU
     - HPL
     - HPL
     - node_exporter
     - atop
     - perf
   * - GPU
     - HPL-MxP
     - HPL-MxP
     - dcgm_exporter
     - atop
     - nsight
   * - Memory
     - STREAM
     - STREAM
     - node_exporter
     - atop
     - valgrind
   * - Network
     - NCCL
     - NCCL
     - IB counters
     - fabric logs
     - ibdiagnet
   * - Storage
     - IOR
     - FIO
     - node_exporter
     - journalctl
     - strace

This matrix represents one possible configuration. Actual tool selection varies based on hardware capabilities (InfiniBand vs Ethernet, NVIDIA vs AMD GPUs), workload characteristics, and operational priorities. Tracing tools are problem-specific and invoked as needed rather than providing always-on coverage.

Runtime Considerations
----------------------

Tool selection often depends on available runtime:

**Quick checks (< 5 minutes):**

- HPL: 1-minute configuration for boot validation
- STREAM: Memory bandwidth check
- FIO: Single-node storage validation
- Topology diff: ibnetdiscover comparison

Quick checks serve post-maintenance validation and rapid regression detection.

**Comprehensive validation (> 1 hour):**

- SPEC HPC 2021: Multi-workload suite, subsystem isolation
- MLPerf Training: AI infrastructure validation
- User applications: Domain-specific validation

Comprehensive validation suits major system changes, quarterly validation cycles, and external performance comparison.

Diagnostic Workflow
-------------------

Typical diagnostic progression follows increasing depth:

**1. External validation (initial deployment)**

Establish baseline performance against published results. Identifies gross misconfigurations or hardware issues before production deployment.

**2. Regression detection (after changes)**

Compare current performance against archived baselines. Detects degradation from updates, configuration changes, or hardware drift.

**3. Monitoring (real-time issues)**

Real-time dashboards identify ongoing resource saturation or anomalous behavior. Provides immediate visibility into current system state.

**4. Logging (post-mortem analysis)**

Historical logs enable backtracking: "What consumed resources during yesterday's job failure?" Localizes issues to specific subsystems and timeframes.

**5. Tracing (targeted diagnosis)**

Deep instrumentation reveals code-level root causes after logging identified problematic subsystem. Provides function-level detail for precise diagnosis.

**Key principle:** Start broad (monitoring/logs), narrow to specific (traces). Tracing without log context wastes investigation time wandering through irrelevant code paths.

Setup Complexity Considerations
--------------------------------

**Low setup complexity (hours):**

- HPL, STREAM, FIO: Pre-built binaries, minimal configuration
- Monitoring: Deploy exporters, configure retention
- Logging: Enable atop, configure journalctl persistence

Low-complexity tools provide immediate diagnostic capability.

**Medium setup complexity (days):**

- IMB-MPI1: Requires MPI runtime configuration
- NCCL: Requires GPU/network fabric tuning
- User dashboards: Grafana dashboard development

Medium-complexity tools require deeper system integration.

**High setup complexity (weeks):**

- SPEC HPC 2021: Multiple application builds, environment tuning, validation
- MLPerf: Dataset preparation, framework configuration
- User applications: Domain expertise, representative datasets

High-complexity tools provide comprehensive validation at cost of extended deployment time.

**Strategy:** Start with low-complexity coverage (HPL + monitoring + atop), add diagnostic depth as operational needs emerge.

Tool Documentation
==================

Detailed documentation for specific validation tools:

.. toctree::
   :maxdepth: 1
   :glob:

   apps/*

Each tool document follows consistent structure: Overview, Basic Usage, Use Cases, Best Practices, References.

References and Resources
=========================

Validation Methodology
----------------------

- **Baseline establishment:** :doc:`../index` - Data-driven operational principles
- **Regression detection:** Compare current measurements against archived baselines
- **Diagnostic workflows:** Progress from broad monitoring to targeted tracing

Tool Categories
---------------

- **External validation tools:** SPEC HPC, HPL, MLPerf benchmarks
- **Internal baseline tools:** User applications, reproducible benchmarks
- **Monitoring tools:** Prometheus, Grafana, node exporters
- **Logging tools:** Atop, journalctl, SLURM logs
- **Tracing tools:** gdb, strace, perf, Nsight Systems
