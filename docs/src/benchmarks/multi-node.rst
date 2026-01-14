==========================
Multi-Node Scalability
==========================

SPEC HPC 2021 Small Benchmark Results
======================================

These benchmarks demonstrate the scaling characteristics of our primary compute platform (Dell R6625 with AMD EPYC 9754) using hybrid MPI+OpenMP parallelization across multiple nodes.

Scaling Results by Node Count
------------------------------

.. list-table::
   :header-rows: 1
   :widths: 12 15 8 10 10 20 25

   * - Scheduling
     - Parallelization
     - Nodes
     - Ranks
     - Threads
     - Base Score
     - Full Report
   * - SLURM
     - MPI+OpenMP
     - 1
     - 32
     - 8
     - 1.47
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n1.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 2
     - 64
     - 8
     - 2.84
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n2.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 4
     - 128
     - 8
     - 5.53
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n4.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 8
     - 256
     - 8
     - 11.6
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n8.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 16
     - 512
     - 8
     - 21.2
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n16.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 32
     - 1024
     - 8
     - 33.9
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.small.omp.slurm.oneapi-ompi.n32.pdf>`


Scalability Analysis
====================

The following plots compare our system's scalability against published results from other HPC centers.

Core Count Scaling
-------------------

.. image:: spechpc2021/spechpc2021-scaling-core-count.svg
   :alt: SPEC HPC 2021 Scaling by Core Count
   :align: center
   :width: 100%

This plot shows how performance scales as the number of CPU cores increases within our system, compared to published results from other facilities.


Node Count Scaling
-------------------

.. image:: spechpc2021/spechpc2021-scaling-node-count.svg
   :alt: SPEC HPC 2021 Scaling by Node Count
   :align: center
   :width: 100%

This plot demonstrates scaling efficiency as additional compute nodes are added to the job, illustrating the effectiveness of our interconnect and parallel I/O infrastructure.


Hardware and Software Specifications
=====================================

The multi-node benchmarks were conducted on the following system configuration:

**Hardware**

- System: Dell PowerEdge R6625 with Immersion Cooling (Direct Liquid Cooling)
- Processor: 2x AMD EPYC 9754 128-Core (256 cores/node, 2.25-3.10 GHz, HT Disabled)
- Memory: 768 GB DDR5-4800 per node (24x 32GB DIMMs)
- Interconnect: Mellanox ConnectX-6 HDR (200 Gbit/s RoCE v2)
- Storage: Dell OneFS via NFS v3

**Software Stack**

- Compiler: Intel oneAPI DPC++/C++ Compiler 2025.0.4
- MPI Library: Open MPI 5.0.6
- Operating System: Rocky Linux 9.5 (kernel 5.14.0-503.40.1.el9_5)
- Job Scheduler: SLURM Workload Manager

**Compiler Flags**

- C/C++: ``-march=common-avx512 -Ofast -flto -ffast-math -mprefer-vector-width=512 -qopenmp -ansi-alias``
- Fortran: ``-march=common-avx512 -Ofast -flto -ffast-math -mprefer-vector-width=512 -qopenmp -nostandard-realloc-lhs -align array64byte``

Detailed configuration including runtime environment variables, build logs, and tuning parameters are available in the PDF reports.
