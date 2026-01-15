=======================
Performance Benchmarks
=======================

This page presents the performance benchmarks of our HPC systems using SPEC HPC 2021, demonstrating the computational capabilities and scalability of our infrastructure.

Overview
========

We provide two types of benchmark results:

1. **Single-Node Performance (SPEC HPC 2021 Tiny)**: Demonstrates the performance characteristics of individual compute nodes across different hardware vendors and configurations, ensuring consistent performance regardless of vendor choice.

2. **Multi-Node Scalability (SPEC HPC 2021 Small)**: Shows the scaling efficiency of our primary compute platform across multiple nodes, illustrating how performance scales with additional resources.

All benchmark results include detailed hardware specifications, software stack information, and the exact command-line parameters used to achieve these results, enabling reproducibility and transparency.


Benchmark Results
=================

.. toctree::
   :maxdepth: 1

   single-node
   multi-node


About These Benchmarks
======================

Reproducing Results
-------------------

All PDF reports contain the complete configuration details needed to reproduce these results, including:

- Exact command-line invocations
- Environment variables and module configurations
- SLURM job scripts and parameters
- Compiler and linker flags
- MPI process and OpenMP thread configurations

Users can reference these reports to optimize their own applications or validate expected performance on our systems.


Notes
-----

- All benchmarks were conducted under production system conditions
- Results represent typical performance users can expect
- Performance may vary based on workload characteristics, I/O patterns, and system load
- For questions about these benchmarks or performance optimization assistance, please contact our HPC support team
