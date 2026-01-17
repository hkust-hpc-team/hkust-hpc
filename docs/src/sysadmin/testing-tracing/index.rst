======================
Testing and Validation
======================

This documentation describes operational validation methodology for HPC infrastructure. Testing serves multiple purposes across system lifecycle: establishing performance expectations, detecting regressions, monitoring operational health, and diagnosing issues.

Validation Philosophy
=====================

Testing follows data-driven operational principles (see :doc:`../index`):

- **Establish baselines:** Initial validation creates archived golden standards for later comparison
- **Detect regressions:** Automated comparison against baselines identifies performance degradation
- **Diagnose root causes:** Problem-specific tools with known limitations and use cases

Every validation result should be archived: performance figures, network topology snapshots, configuration states. Regression detection requires historical data - without baselines, "is this normal?" questions become unanswerable.

Tool Category Framework
========================

Validation tools organize into five operational categories. Effective HPC operations require coverage across all categories - not exhaustive tools in one category.

External Validation
-------------------

**Purpose:** Compare system performance to published results from other HPC centers

**Answers:** "Is our performance competitive with similar systems?"

**Tool characteristics:**
- Standardized benchmarks (HPL, SPEC HPC, MLPerf)
- Published results available from vendors, HPC centers, research papers
- Runtime varies: 1 minute (HPL quick check) to hours (SPEC HPC comprehensive)

**Subsystem coverage check:**
- Compute: HPL, SPEC HPC CPU benchmarks
- Network: SPEC HPC multi-node scaling, NCCL collective operations
- Storage: SPEC HPC I/O benchmarks, IOR
- Memory: STREAM, HPCG

**First-line tools:** HPL (CPU), HPL-MxP + NCCL (GPU), STREAM (memory)

See :doc:`external-validation` for benchmark selection, runtime trade-offs, and interpretation.

Internal Baseline & Regression Detection
-----------------------------------------

**Purpose:** Track system performance over time, detect degradation after changes

**Answers:** "Did system performance degrade after this change?"

**Tool characteristics:**
- Any reproducible benchmark - archive baseline, compare after changes
- Can reuse external validation benchmarks OR domain-specific applications
- Tolerance guidelines: ±5% acceptable variation, >10% investigate, >20% halt deployment

**Subsystem coverage check:**
- Compute: Any CPU/GPU benchmark with reproducible results
- Network: IMB-MPI1, NCCL, point-to-point bandwidth tests
- Storage: FIO, user I/O workloads
- Topology: ibnetdiscover diff, lstopo comparison

**First-line tools:** HPL (fast), SPEC HPC (comprehensive), user applications (relevant)

**When to run:** After OS/kernel/driver updates, firmware changes, hardware maintenance, monthly drift detection

See :doc:`baseline-regression` for baseline establishment, regression thresholds, and validation cadence.

Monitoring
----------

**Purpose:** Real-time observability of system health and resource utilization

**Answers:** "What's happening RIGHT NOW?"

**Tool characteristics:**
- Always-on, low overhead
- Real-time dashboards and alerting
- Time-series data with retention (typically 30 days)

**Subsystem coverage check:**
- Compute: CPU/GPU utilization, temperature, frequency scaling
- Network: Bandwidth utilization, packet drops, error rates
- Storage: I/O throughput, latency, queue depth
- Memory: Utilization, swap activity, NUMA balance

**First-line tools:** Prometheus + Grafana (time-series metrics), node exporters, GPU metrics

**Use case:** Capacity planning, real-time alerts, performance trending

See :doc:`monitoring` for metric selection, alerting strategies, and dashboard configuration.

Logging
-------

**Purpose:** Persistent records enabling post-mortem analysis of past events

**Answers:** "What happened yesterday?" / "Why did this fail overnight?"

**Tool characteristics:**
- Persistent storage surviving crashes
- Historical data with retention (typically 90 days)
- Subsystem-specific granularity (10-minute intervals to per-event)

**Subsystem coverage check:**
- System-wide resources: Atop (10-min intervals, all resources)
- Kernel events: journalctl (hardware faults, driver errors, OOM)
- Application execution: SLURM logs (job failures, scheduler issues)
- Network fabric: Switch logs (link flaps, congestion events)

**First-line tools:** Atop (resource backtracking), journalctl (system events), SLURM logs (job context)

**Requirement:** Configure persistent logging at system deployment - logs must survive crashes

See :doc:`logging` for log retention policies, backtracking workflows, and correlation strategies.

Tracing
-------

**Purpose:** Deep, code-level diagnosis of specific issues - targeted investigation tools

**Answers:** "Why exactly is this broken?" / "Which line of code caused this?"

**Tool characteristics:**
- NOT first-line tools - use after logs localize subsystem
- High overhead - targeted use only, not always-on
- Requires instrumentation (debug symbols, profiling enabled)

**Subsystem coverage check:**
- Application crashes: gdb + core dumps (stack traces)
- Application slowness: strace (system calls), perf (CPU profiling)
- Network issues: IMB-MPI1 (MPI patterns), rdma tools (physical layer)
- GPU bottlenecks: nsight (kernel profiling), nvidia-smi debug

**First-line tools:** gdb (crashes), strace (I/O slowness), perf (CPU slowness), IMB-MPI1 (network)

**When to use:** After monitoring/logging identified subsystem, need precise root cause

See :doc:`tracing` for tool selection by problem type, instrumentation requirements, and interpretation.

Tool Selection Strategy
=======================

First-Line Tool Coverage Matrix
--------------------------------

Effective validation requires at least one tool in each category covering each subsystem:

.. list-table::
   :header-rows: 1
   :widths: 20 20 20 20 20

   * - Subsystem
     - External Validation
     - Baseline/Regression
     - Monitoring
     - Logging
   * - **Compute (CPU)**
     - HPL (1 min)
     - HPL / SPEC HPC
     - Prometheus CPU metrics
     - Atop CPU utilization
   * - **Compute (GPU)**
     - HPL-MxP + NCCL
     - NCCL / MLPerf
     - GPU exporters
     - Atop GPU tracking
   * - **Network**
     - SPEC HPC scaling
     - IMB-MPI1
     - Network exporters
     - Atop network I/O
   * - **Storage**
     - IOR / SPEC I/O
     - FIO
     - Storage exporters
     - Atop disk I/O
   * - **Memory**
     - STREAM
     - STREAM
     - Memory exporters
     - Atop memory usage

**Note:** Tracing tools are problem-specific and added as needed (not always-on coverage).

Runtime Considerations
----------------------

Tool selection often depends on available runtime:

**Quick checks (< 5 minutes):**
- HPL: 1-minute configuration for boot validation
- STREAM: Memory bandwidth check
- FIO: Single-node storage validation
- Topology diff: ibnetdiscover comparison

**Use case:** Post-maintenance validation, quick regression check

**Comprehensive validation (> 1 hour):**
- SPEC HPC 2021: Multi-workload suite, subsystem isolation
- MLPerf Training: AI infrastructure validation
- User applications: Domain-specific validation

**Use case:** Major system changes, quarterly validation, external comparison

Diagnostic Depth Progression
-----------------------------

**Typical diagnostic workflow:**

1. **External validation** (initial deployment)
   
   - Compare HPL/SPEC HPC to published results
   - Establish baseline: "Is this system performing as expected?"

2. **Regression detection** (after changes)
   
   - Compare current run to archived baseline
   - Identify: "Did performance degrade? By how much?"

3. **Monitoring** (real-time)
   
   - Check dashboards: "What's happening now?"
   - Identify: "Which subsystem shows anomaly?"

4. **Logging** (post-mortem)
   
   - Atop backtracking: "What was system state yesterday?"
   - journalctl: "Any kernel errors or hardware faults?"
   - SLURM logs: "Did job fail due to scheduler issue?"

5. **Tracing** (targeted diagnosis)
   
   - Logs localized to network → IMB-MPI1 identifies latency/collective issue
   - Logs localized to application → strace/perf identifies code-level bottleneck

**Key principle:** Start broad (monitoring/logs), narrow to specific (traces). Tracing without log context wastes investigation time.

Setup Complexity Considerations
--------------------------------

**Low setup complexity** (ready in hours):
- HPL, STREAM, FIO: Pre-built binaries, minimal configuration
- Monitoring: Deploy exporters, configure retention
- Logging: Enable atop, configure journalctl persistence

**Medium setup complexity** (ready in days):
- IMB-MPI1: Requires MPI runtime configuration
- NCCL: Requires GPU/network fabric tuning
- User dashboards: Grafana dashboard development

**High setup complexity** (ready in weeks):
- SPEC HPC 2021: Multiple application builds, environment tuning, validation
- MLPerf: Dataset preparation, framework configuration
- User applications: Domain expertise, representative datasets

**Strategy:** Start with low-complexity coverage (HPL + monitoring + atop), add diagnostic depth as operational needs emerge.

Subsystem Coverage Gaps
------------------------

Some tools don't validate all subsystems:

**HPL coverage:**
- ✓ Compute: CPU/memory intensive
- ✓ Network: Point-to-point MPI (minimal)
- ✗ Storage: Reads 2MB binary (inadequate I/O test)
- ✗ MPI collectives: Doesn't stress Allreduce/Barrier patterns

**HPL-MxP + NCCL coverage:**
- ✓ Compute: GPU
- ✓ Network: Multi-GPU collective operations
- ✗ Storage: No I/O component
- ✗ CPU: Minimal CPU involvement

**SPEC HPC 2021 coverage:**
- ✓ Compute: Multiple CPU/memory workloads
- ✓ Network: Multi-node scaling, communication-intensive benchmarks
- ✓ Storage: I/O-intensive benchmarks (some)
- ✓ MPI collectives: Communication pattern diversity

**Gap analysis:** HPL alone doesn't validate storage or MPI collectives - need complementary tools (FIO for storage, IMB-MPI1 for collectives).

Validation Cadence
==================

**Continuous validation triggers:**

- **After every OS/kernel update:** Baseline regression check (HPL or SPEC HPC)
- **After driver updates:** Subsystem-specific validation (IMB-MPI1 for network, DCGMI for GPU)
- **After hardware maintenance:** Full validation suite + topology comparison
- **Monthly:** Drift detection (compare current to baseline)
- **After user reports issues:** Targeted diagnostics (logs → traces)

**Archive retention:**

- External validation results: Indefinite (reference data)
- Internal baselines: Indefinite (regression detection)
- Monitoring data: 30 days (capacity planning)
- Atop logs: 90 days (operational diagnostics)
- journalctl: 90 days (system events)
- Traces: On-demand only (targeted investigation)

Related Documentation
=====================

- :doc:`../index` - Guiding principles for data-driven operations
- :doc:`../system-config` - System configuration validated by testing
- :doc:`../numa-optimizations` - Performance tuning validated through benchmarking
- :doc:`../../benchmarks/multi-node` - SPEC HPC 2021 baseline results

Detailed Sections
=================

.. toctree::
   :maxdepth: 2

   external-validation
   baseline-regression
   monitoring
   logging
   tracing
