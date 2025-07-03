NUMA Aware Scheduling
=====================

(Work in progress)

Understanding and optimizing for Non-Uniform Memory Access (NUMA) is critical for
achieving good performance on modern multi-socket systems.

NUMA Topology
-------------

First, inspect the NUMA topology of your system.

.. code-block:: bash

    numactl --hardware
    lscpu | grep NUMA

This will show you the NUMA nodes, the CPUs and memory associated with each node, and
the distances between nodes.

Kernel Parameters
-----------------

For most HPC workloads, it is recommended to disable automatic NUMA balancing and let
the application or MPI runtime handle memory placement.

.. code-block::

    numa_balancing=disable

Performance Tuning
------------------

- **Process and Memory Affinity**: Use tools like `numactl` to bind processes to
  specific NUMA nodes and ensure memory is allocated on the local node.

  .. code-block:: bash

      # Run a command on a specific CPU and memory node
      numactl --cpunodebind=0 --membind=0 my_application

- **Check NUMA placement**: Use `numastat` to see how memory is distributed across NUMA
  nodes for a running process.

  .. code-block:: bash

      # Show NUMA statistics for a process
      numastat -p <pid>

References
----------

- NUMA Deep Dive Series
  https://frankdenneman.nl/2016/07/07/numa-deep-dive-part-1-introduction/
