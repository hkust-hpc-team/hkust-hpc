==========
nvidia-smi
==========

nvidia-smi (NVIDIA System Management Interface) is the command-line utility for monitoring and managing NVIDIA GPU devices. This document describes practical approaches for using nvidia-smi in HPC environments for GPU health monitoring, topology verification, and resource allocation validation.

.. contents::
   :local:
   :depth: 2

Overview
========

nvidia-smi provides real-time monitoring and configuration capabilities for NVIDIA GPUs. Unlike application-level GPU profiling tools, nvidia-smi operates at the system administration level, providing device health status, resource utilization, and topology information.

Value Proposition
-----------------

**Instant GPU visibility:**
  - No installation required - ships with NVIDIA driver
  - Zero-overhead monitoring of GPU state
  - Real-time visibility into utilization, temperature, power consumption
  - Process-to-GPU mapping for resource attribution

**Topology verification:**
  - NUMA affinity validation for optimal GPU placement
  - PCIe connectivity visualization
  - NVLink topology detection
  - Multi-GPU configuration validation

**Operational diagnostics:**
  - GPU health checks (temperature, power, ECC errors)
  - Driver and CUDA version verification
  - Process isolation validation (MIG, compute mode)
  - Memory leak detection

**Limitations acknowledged:**
  - System-level metrics only - no kernel-level profiling
  - Coarse utilization sampling (not suitable for performance optimization)
  - Limited historical data (use DCGM or Prometheus for time-series)

Learning Curve
--------------

**Difficulty: Easy**

nvidia-smi requires minimal learning investment. Basic GPU status checking is intuitive (bare ``nvidia-smi`` command). Topology queries and advanced options require consulting help output but remain straightforward.

**Recommendation:** Start with basic status checks, then explore topology verification (``nvidia-smi topo -m``) for multi-GPU systems. Advanced query modes (``-q``) provide detailed information but verbose output requires filtering.

Basic Usage
===========

GPU Status Overview
-------------------

The default invocation displays all GPUs with current state:

.. code-block:: bash

   nvidia-smi

**Output interpretation:**

- **GPU Name:** Device model (e.g., NVIDIA A30, H100, V100)
- **Persistence-M:** Driver persistence mode (On recommended for HPC)
- **Bus-Id:** PCIe address for device identification
- **Temp:** Current temperature (°C)
- **Pwr:Usage/Cap:** Power consumption vs thermal design power
- **Memory-Usage:** Allocated GPU memory vs total capacity
- **GPU-Util:** GPU compute utilization percentage
- **Compute M.:** Compute mode (Default, Exclusive, Prohibited)
- **MIG M.:** Multi-Instance GPU mode status

**Process table:**

Bottom section lists processes using each GPU:

- **PID:** Process identifier
- **Type:** C (Compute) or G (Graphics)
- **Process name:** Executable name
- **GPU Memory Usage:** Per-process memory allocation

List GPUs with UUIDs
--------------------

For scripting and persistent device identification:

.. code-block:: bash

   nvidia-smi -L

**Output:**

.. code-block:: text

   GPU 0: NVIDIA A30 (UUID: GPU-6639cb8b-cdba-8bee-0c58-d79f796ce7d8)
   GPU 1: NVIDIA A30 (UUID: GPU-9d185f0e-dfe9-5503-81a6-9976792647cf)
   GPU 2: NVIDIA A30 (UUID: GPU-da08976e-e742-3ee7-9a86-2fbff67ab299)
   GPU 3: NVIDIA A30 (UUID: GPU-b87fd4cf-274a-9442-4e32-042b9126fea4)

**Use case:** UUIDs remain stable across reboots and driver updates. Prefer UUID-based device selection in production scripts to avoid index renumbering issues.

Topology Matrix
---------------

Visualize GPU interconnect topology:

.. code-block:: bash

   nvidia-smi topo -m

**Output interpretation:**

.. code-block:: text

     GPU0  GPU1  GPU2  GPU3  NIC0  CPU Affinity  NUMA Affinity
   GPU0   X    NV4   SYS   SYS   NODE  0,2,4,6,8,10      0
   GPU1  NV4    X    SYS   SYS   NODE  0,2,4,6,8,10      0
   GPU2  SYS   SYS    X    NV4   SYS   1,3,5,7,9,11      1
   GPU3  SYS   SYS   NV4    X    SYS   1,3,5,7,9,11      1

**Connection types (fastest to slowest):**

- **NV#:** NVLink connection (# indicates link count) - highest bandwidth
- **PIX:** Single PCIe bridge - direct PCIe connection
- **PXB:** Multiple PCIe bridges
- **PHB:** PCIe via host bridge (CPU)
- **NODE:** PCIe crossing NUMA interconnect within node
- **SYS:** PCIe crossing NUMA interconnect between nodes - slowest

**CPU/NUMA Affinity:**

- Lists CPU cores with local PCIe root complex
- Critical for NUMA-aware GPU workload placement

Use Case: GPU Health Monitoring
================================

Quick Health Check
------------------

Rapid validation of GPU operational status:

.. code-block:: bash

   # Basic health indicators
   nvidia-smi --query-gpu=index,name,temperature.gpu,power.draw,memory.used,utilization.gpu --format=csv

**Expected values:**

- **Temperature:** < 80°C under load (varies by model)
- **Power draw:** Near TDP under full utilization
- **Memory used:** Matches application expectations
- **Utilization:** High (>90%) for compute workloads

**Red flags:**

- Temperature approaching throttle threshold (typically 90-95°C)
- Power draw at 0W with processes running (indicates hung GPU)
- Memory allocation failures despite available capacity
- Zero utilization with active processes (driver/application issue)

Use Case: NUMA Topology Validation
===================================

Multi-GPU NUMA Placement
-------------------------

Validate GPU-to-NUMA alignment for optimal performance:

**Workflow:**

1. Identify GPU NUMA affinity:

.. code-block:: bash

   nvidia-smi topo -m | grep "NUMA Affinity"

2. Verify application CPU binding matches GPU NUMA node
3. Check GPU-to-GPU communication paths for multi-GPU training

**Example interpretation:**

.. code-block:: text

   GPU0 and GPU1: NUMA node 0
   GPU2 and GPU3: NUMA node 1

**Optimal placement:**

- Workload using GPU0 should bind to NUMA node 0 CPUs
- Multi-GPU spanning both NUMA nodes incurs SYS-level latency
- NVLink pairs (NV4) provide high-bandwidth intra-NUMA communication

NVLink Verification
-------------------

Confirm NVLink connectivity for multi-GPU workloads:

.. code-block:: bash

   nvidia-smi nvlink --status

**Expected:** All links show "Active" for systems with NVLink

**Warning:** "Inactive" links indicate hardware or configuration issues

Best Practices
==============

Diagnostic Guidelines
---------------------

**Quick health validation:**

- Use bare ``nvidia-smi`` for at-a-glance GPU status
- Monitor temperature and power consumption during workload execution
- Verify driver/CUDA version compatibility after updates
- Check ECC error counts periodically (non-zero indicates hardware degradation)

**Topology verification:**

- Run ``nvidia-smi topo -m`` during node commissioning
- Document GPU-to-GPU connectivity for multi-GPU job placement
- Verify NUMA affinity aligns with workload CPU binding
- Confirm NVLink status with ``nvidia-smi nvlink --status``

**Resource attribution:**

- Use process table to identify which jobs occupy GPUs
- Verify GPU memory usage matches application expectations
- Identify runaway processes consuming GPU resources unexpectedly

**Configuration management:**

GPU configuration (persistence mode, compute mode, clock speeds) should be managed via:

- System configuration files (``/etc/nvidia-persistenced/nvidia-persistenced.conf``)
- Systemd services for automatic initialization
- Configuration management tools (Ansible, Puppet, Chef)

Avoid ad-hoc configuration changes via nvidia-smi commands in production environments.

**Monitoring integration:**

For continuous monitoring and historical data, use:

- **DCGM:** Data Center GPU Manager for comprehensive GPU telemetry
- **Prometheus NVIDIA GPU Exporter:** Time-series metrics collection
- **Grafana dashboards:** Visualization of GPU utilization trends

nvidia-smi serves as a diagnostic tool, not a monitoring platform.

Limitations Awareness
---------------------

**Not a profiling tool:**

nvidia-smi provides system-level metrics, not kernel-level performance analysis. For GPU optimization, use NVIDIA Nsight Systems, Nsight Compute, or profiling APIs.

**Sampling limitations:**

Utilization metrics represent averages over sampling windows (typically 1 second). Short-lived kernel launches may not appear in utilization statistics.

**Historical data:**

nvidia-smi does not maintain historical metrics. For time-series analysis, use DCGM (Data Center GPU Manager) or Prometheus with NVIDIA exporter.

References and Resources
=========================

Official Documentation
----------------------

- **nvidia-smi manual:** https://docs.nvidia.com/deploy/nvidia-smi/index.html - Comprehensive command reference
- **DCGM documentation:** https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/index.html - Data Center GPU Manager for advanced monitoring
- **NVIDIA management tools:** https://developer.nvidia.com/management-tools - Overview of GPU management ecosystem

Additional Resources
--------------------

- **Man page:** ``man nvidia-smi`` (if installed) - Command-line reference
- **Help output:** ``nvidia-smi -h`` - Quick option reference
- **Related tools:** :doc:`../index` - Overview of HPC validation and monitoring tools
