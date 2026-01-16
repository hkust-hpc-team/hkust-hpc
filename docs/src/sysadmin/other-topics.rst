===========================
Other Administration Topics
===========================

This document covers operational knowledge that does not fit cleanly into specific infrastructure domains: known software issues requiring workarounds and performance optimization techniques for HPC workloads.

Known Issues
============

RHEL 9: Binutils Incompatibility with AMD Zen4
-----------------------------------------------

**Issue:** System-provided binutils lacks support for AMD Zen4 instruction sets, preventing proper code generation for Zen4 and newer processors.

**Status:** No upstream fix available in RHEL 9 base repository.

**Workaround:** Rebuild GCC and binutils from source with Zen4 support enabled. See Spack configuration for compiler rebuilds with appropriate architecture targets.

**Impact:** Affects compilation of architecture-optimized code. Scientific applications may fail to compile or miss performance optimizations without updated toolchain.

RHEL 9: DMA Driver Unavailable for AMD Zen4
--------------------------------------------

**Issue:** Direct Memory Access (DMA) driver support missing for AMD Zen4 platforms in earlier RHEL 9 releases.

**Status:** Resolved in RHEL 9.7 and later.

**Workaround:** Update to RHEL 9.7 or newer. No workaround available for earlier versions.

**Impact:** Potential performance degradation for I/O-intensive workloads on Zen4 hardware running RHEL 9.0-9.6.

AOCC 5.0: Fortran Compiler Configuration Regression
----------------------------------------------------

**Issue:** AMD Optimizing C/C++ Compiler (AOCC) 5.0 Fortran compiler (flang) does not read ``flang.cfg`` configuration file, representing regression from AOCC 4.2 behavior.

**Status:** No fix or workaround available from vendor.

**Mitigation:** Ensure detected GCC installation is fully functional. AOCC may fall back to partially installed, non-functional GCC toolchains (e.g., RHEL ``gcc-toolset-12`` incomplete installations), resulting in compilation failures.

**Impact:** Fortran compilation may fail with non-obvious errors if GCC fallback is misconfigured. Verify GCC functionality before deploying AOCC 5.0 for Fortran workloads.

Performance Optimization
========================

NUMA Topology Verification
---------------------------

HPC systems should exhibit balanced NUMA topology with equal resource distribution across NUMA nodes (CPUs, memory, GPUs). Verify topology using hwloc:

.. code-block:: bash

   # Visualize NUMA topology
   lstopo
   
   # Text-based output
   lstopo --no-graphics

Asymmetric NUMA configurations introduce performance unpredictability for MPI applications with process placement sensitivity.

NUMA-Aware Memory Allocation
-----------------------------

Memory allocation strategy significantly impacts application performance on NUMA systems. The ``numactl`` command controls NUMA policy for processes, managing both CPU affinity and memory placement.

**Common memory allocation policies:**

- ``numactl --interleave=all`` (``-i all``): Interleave memory allocation across all NUMA nodes
- ``numactl --localalloc`` (``-l``): Allocate memory on the local NUMA node where thread executes
- ``numactl --membind=<nodes>`` (``-m``): Bind memory allocation to specific NUMA nodes
- ``numactl --preferred=<node>`` (``-p``): Prefer specific NUMA node, fall back to others if unavailable

Non-MPI Applications
^^^^^^^^^^^^^^^^^^^^^

Threading-based applications (OpenMP, TBB) often benefit from interleaved memory allocation, distributing memory across all NUMA nodes rather than concentrating on NUMA node 0:

.. code-block:: bash

   numactl --interleave=all ./application

This prevents single-node memory bandwidth saturation. Without explicit policy, Linux default allocation concentrates memory on the node where the parent thread allocates, creating potential bottlenecks for applications using all CPU cores.

MPI Applications
^^^^^^^^^^^^^^^^

MPI runtimes provide NUMA-aware process placement. Combine MPI CPU pinning with local memory allocation - each MPI rank allocates memory on its local NUMA node.

**Intel MPI example:**

.. code-block:: bash

   # Configure Intel MPI process pinning
   export I_MPI_PIN=1
   export I_MPI_PIN_CELL=core
   export I_MPI_PIN_PROCESSOR_LIST=all
   
   # Launch with local memory allocation
   mpirun -np ${ranks} numactl -l ${command}

**OpenMPI example:**

.. code-block:: bash

   # OpenMPI handles binding via command-line options
   mpirun -np ${ranks} --bind-to core --map-by numa \
          numactl -l ${command}

The ``-l`` (``--localalloc``) flag ensures each MPI rank allocates memory on its pinned NUMA node, minimizing cross-NUMA memory access during execution.

**Best practice:** Verify MPI runtime NUMA binding behavior before adding manual ``numactl`` directives. Modern MPI implementations typically provide topology-aware placement; conflicting policies may degrade performance. Consult MPI runtime documentation for native NUMA support capabilities.

RoCEv2 CPU Core Reservation for Network Processing
--------------------------------------------------

**Background:** RoCEv2 (RDMA over Converged Ethernet v2) and InfiniBand both support RDMA for direct memory access but differ in kernel CPU involvement. InfiniBand offloads protocol processing to dedicated HCA hardware, while RoCEv2 requires kernel CPU cycles for Ethernet packet processing, flow control, and congestion management, competing with application threads for CPU resources.

**Performance optimization:** MPI applications on RoCEv2 fabrics benefit from reserving CPU cores on the NIC's NUMA node for kernel networking operations, preventing network protocol processing from competing with application threads.

**Example configuration** (AMD 256-core system):

.. code-block:: bash

   # Total number of cores
   declare -r total_cores=256
   # Reserve cores for network I/O processing
   # These core IDs should match the NUMA node of your RoCE NIC
   declare -r roce_core_start=192
   declare -r roce_core_end=199
   declare -r num_reserved_cores=$(($roce_core_end - $roce_core_start + 1))

   function set_binding() {
     local ntasks_per_node=$(($total_cores - $num_reserved_cores))
     local ntasks=$(($SLURM_NNODES * $ntasks_per_node))
     
     if [[ $ntasks_per_node -lt $total_cores ]]; then
       # Map tasks to non-reserved cores
       local cpu_bind="verbose,map_cpu:$(seq --sep=, 0 $(($roce_core_start - 1))),$(seq --sep=, $(($roce_core_end + 1)) $(($total_cores - 1)))"
     else
       local cpu_bind="verbose,core"
     fi
     
     local mem_bind="verbose,local"
     export SRUN_NTASKS=$ntasks
     export SRUN_TASK_ARGS="--ntasks=$ntasks --ntasks-per-node=$ntasks_per_node --cpu-bind=$cpu_bind --mem-bind=$mem_bind"
     
     echo "SRUN_NTASKS: $SRUN_NTASKS"
     echo "SRUN_TASK_ARGS: $SRUN_TASK_ARGS"
   }

.. important::
   
   Core ID ranges for reservation are hardware-specific and must match the NUMA node containing your RoCE NIC. Use ``lstopo`` to identify NIC NUMA locality and consult system documentation for appropriate core ranges. The example above (cores 192-199) represents one specific system configuration and will differ across hardware platforms.

**Typical configuration:** 248 application tasks on 256-core system, with 8 cores reserved for network processing on NIC NUMA node.

**Performance impact:** Communication-intensive MPI applications (halo exchanges, collective operations) typically observe 10-20% performance improvement with core reservation on RoCEv2 networks.

GPU-Aware NUMA Affinity
------------------------

Job schedulers should assign NUMA-local CPU and GPU resources together. GPU-CPU affinity mismatches introduce PCIe traffic across NUMA boundaries, degrading GPU-accelerated workload performance.

**Verification:**

.. code-block:: bash

   # Verify GPU-CPU NUMA affinity
   nvidia-smi topo -m
   
   # Check SLURM GPU GRES configuration
   scontrol show node <nodename> | grep Gres

Proper SLURM GRES (Generic RESource) configuration ensures scheduler awareness of GPU NUMA locality, enabling topology-aware scheduling.

**Configuration:** Define explicit GPU-CPU NUMA node associations in ``gres.conf`` to enable topology-aware scheduling.
