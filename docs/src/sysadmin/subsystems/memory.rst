Memory Subsystem
================

Capacity is important, but performance is critical for HPC workloads.

Key considerations include per-core memory bandwidth and latency, which are fundamental
performance metrics in HPC systems.

Performance Trends
------------------

With core counts growing faster than memory frequency and channel counts, combined with
increasing memory capacity, several challenges emerge:

- Time to access the entire memory space is increasing
- Bandwidth per core is decreasing
- Memory latency remains a critical bottleneck

These trends can lead to significant performance bottlenecks in memory-intensive HPC
applications.

Memory Configuration
--------------------

NUMA Topology
~~~~~~~~~~~~~

Understand your system's NUMA topology using:

.. code-block:: bash

    numactl --hardware
    lscpu | grep NUMA

Ensure memory allocation matches the NUMA domains where compute threads are running.

Huge Pages
~~~~~~~~~~

Configure huge pages for better memory performance:

.. code-block:: bash

    # Check current huge page configuration
    cat /proc/meminfo | grep -i huge

    # Configure 2MB huge pages (add to kernel parameters)
    default_hugepagesz=2M hugepagesz=2M hugepages=1024

For applications requiring very large memory allocations, consider 1GB huge pages.

Benchmarks
----------

Memory Bandwidth
~~~~~~~~~~~~~~~~

- **STREAM benchmark**: Industry standard for measuring memory bandwidth
- **Intel Memory Latency Checker (MLC)**: Comprehensive memory subsystem analysis
- **HPCG benchmark**: Measures memory performance in realistic HPC workloads across
  multiple nodes

Memory Latency
~~~~~~~~~~~~~~

- **LMbench**: Measures memory hierarchy latency
- **Intel MLC**: Provides detailed latency measurements across cache levels

Performance Analysis
~~~~~~~~~~~~~~~~~~~~

When comparing systems across different generations:

- Normalize bandwidth measurements by dividing total bandwidth by core count
- Consider both peak and sustained memory bandwidth
- Measure performance under realistic application memory access patterns
- Account for NUMA effects in multi-socket systems

Tuning Parameters
-----------------

Kernel Parameters
~~~~~~~~~~~~~~~~~

.. code-block::

    # Disable NUMA balancing for HPC workloads
    numa_balancing=disable

    # Enable huge pages
    default_hugepagesz=2M hugepagesz=2M

    # For memory-intensive workloads
    transparent_hugepage=always

Sysctl Parameters
~~~~~~~~~~~~~~~~~

.. code-block::

    # Allow overcommit of memory
    vm.overcommit_memory = 1

    # Set swappiness to a low value to avoid swapping
    vm.swappiness = 1

    # Increase the number of available file handles
    fs.file-max = 1048576

    # Zone reclaim mode
    vm.zone_reclaim_mode = 0
