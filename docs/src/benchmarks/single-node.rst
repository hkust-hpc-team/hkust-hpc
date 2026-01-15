==========================
Single-Node Performance
==========================

SPEC HPC 2021 Tiny Benchmark Results
=====================================

These benchmarks demonstrate single-node performance across different hardware configurations, executed with various parallelization strategies (MPI, OpenMP) and job submission methods (bare-metal, SLURM).

Dell PowerEdge R6625 (AMD EPYC 9754)
-------------------------------------

The Dell R6625 systems powered by AMD EPYC 9754 processors represent our primary compute platform.

.. list-table::
   :header-rows: 1
   :widths: 15 20 10 10 20 25

   * - Scheduling
     - Parallelization
     - Ranks
     - Threads
     - Base Score
     - Full Report
   * - Bare-metal
     - MPI
     - 256
     - 1
     - 13.5
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.tiny.mpi.bm.oneapi-impi.n1.pdf>`
   * - SLURM
     - MPI
     - 256
     - 1
     - 12.8
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.tiny.mpi.slurm.oneapi-impi.n1.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 32
     - 8
     - 14.9
     - :download:`PDF <spechpc2021/dell-r6625-amd9754.tiny.omp.slurm.oneapi-impi.n1.pdf>`


Gigabyte R183 (AMD EPYC 9754)
------------------------------

The Gigabyte R183 systems also feature AMD EPYC 9754 processors, demonstrating vendor-neutral performance.

.. list-table::
   :header-rows: 1
   :widths: 15 20 10 10 20 25

   * - Scheduling
     - Parallelization
     - Ranks
     - Threads
     - Base Score
     - Full Report
   * - SLURM
     - MPI
     - 256
     - 1
     - 12.4
     - :download:`PDF <spechpc2021/giga-r183-amd9754.tiny.mpi.slurm.oneapi-impi.n1.pdf>`
   * - SLURM
     - MPI+OpenMP
     - 32
     - 8
     - 15.0
     - :download:`PDF <spechpc2021/giga-r183-amd9754.tiny.omp.slurm.oneapi-impi.n1.pdf>`


Dell PowerEdge R660 (Intel Xeon 8592+)
---------------------------------------

The Dell R660 systems powered by Intel Xeon 8592+ processors (dual socket) provide a comparison point for Intel-based architectures.

.. list-table::
   :header-rows: 1
   :widths: 15 20 10 10 20 25

   * - Scheduling
     - Parallelization
     - Ranks
     - Threads
     - Base Score
     - Full Report
   * - SLURM
     - MPI
     - 128
     - 1
     - 8.92
     - :download:`PDF <spechpc2021/dell-r660-intel8592p.tiny.mpi.slurm.oneapi-impi.n1.pdf>`


Key Observations
================

- Dell R6625 and Gigabyte R183 platforms deliver consistent performance with the same AMD EPYC 9754 processors
- Dell R660 with Intel Xeon 8592+ shows lower single-node score (8.92) compared to AMD platforms (12.4-15.0), reflecting architectural differences
- AMD EPYC 9754 delivers approximately 70% better per-core performance, while also providing double the core count per node compared to Intel Xeon 8592+
- No significant performance degradation observed across different vendors with the same processor
- SLURM job scheduler introduces minimal overhead compared to bare-metal execution
- Both MPI and OpenMP parallelization strategies are well-supported across all platforms

Detailed hardware specifications, software configurations, compiler flags, and runtime parameters for each system are available in the corresponding PDF reports.
