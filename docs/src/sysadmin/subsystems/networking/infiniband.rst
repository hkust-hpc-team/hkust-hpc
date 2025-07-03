InfiniBand
==========

InfiniBand (IB) provides high-bandwidth, low-latency networking optimized for HPC and
high-performance computing environments. While generally working well out of the box,
proper configuration can significantly improve performance.

Advantages
----------

- **Low latency**: Typically 1-2 microseconds for small messages
- **High bandwidth**: Up to 400 Gb/s (HDR) and beyond
- **Low CPU overhead**: Hardware-based RDMA operations
- **Reliable delivery**: Built-in error detection and correction
- **Scalability**: Excellent for large-scale cluster deployments

Basic Configuration
-------------------

Driver Installation
~~~~~~~~~~~~~~~~~~~

Most modern Linux distributions include InfiniBand drivers:

.. code-block:: bash

    # Install OFED drivers (if not included in kernel)
    yum install infiniband-diags perftest

    # Or for Ubuntu/Debian
    apt-get install infiniband-diags perftest

Verify Installation
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Check for IB devices
    ibstat

    # Verify link status
    ibstatus

    # Check subnet manager
    ibping -S

Subnet Manager
--------------

Every InfiniBand subnet requires a Subnet Manager (SM):

Built-in Options
~~~~~~~~~~~~~~~~

.. code-block:: bash

    # OpenSM (most common for smaller clusters)
    systemctl enable opensm
    systemctl start opensm

    # Check SM status
    sminfo

For larger deployments, consider commercial subnet managers like UFM.

Performance Tuning
------------------

Kernel Parameters
~~~~~~~~~~~~~~~~~

.. code-block::

    # Optimize for InfiniBand
    kernel.numa_balancing = 0
    vm.zone_reclaim_mode = 0

CPU Affinity
~~~~~~~~~~~~

.. code-block:: bash

    # Use mlnx_tune for optimal CPU affinity
    mlnx_tune -p HIGH_THROUGHPUT

Memory Management
~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Increase locked memory limits for RDMA
    echo "* soft memlock unlimited" >> /etc/security/limits.conf
    echo "* hard memlock unlimited" >> /etc/security/limits.conf

Fabric Configuration
--------------------

Link Configuration
~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Check link width and speed
    ibstatus | grep -E "(Rate|Width)"

    # Verify optimal configuration (should show 4x for most modern adapters)
    # and appropriate speed (25, 50, 100+ Gb/s depending on generation)

Topology Discovery
~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Discover fabric topology
    ibnetdiscover

    # Check for routing issues
    ibroute

    # Verify all paths are active
    ibdiagnet

Benchmarking
------------

Latency Testing
~~~~~~~~~~~~~~~

.. code-block:: bash

    # MPI latency test
    mpirun -np 2 -host node1,node2 osu_latency

    # RDMA latency test
    ib_send_lat -d mlx5_0

Bandwidth Testing
~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # MPI bandwidth test
    mpirun -np 2 -host node1,node2 osu_bw

    # RDMA bandwidth test
    ib_send_bw -d mlx5_0 -D 10

All-to-All Performance
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Intel MPI Benchmarks
    mpirun -np <total_procs> IMB-MPI1 alltoall

    # OSU Micro-benchmarks
    mpirun -np <total_procs> osu_alltoall

Troubleshooting
---------------

Common Issues
~~~~~~~~~~~~~

Link Problems
+++++++++++++

.. code-block:: bash

    # Check for link errors
    ibqueryerrors

    # Reset error counters after fixing issues
    ibclearerrors

Performance Issues
++++++++++++++++++

.. code-block:: bash

    # Monitor port counters
    ibstat -l | xargs -I {} sh -c 'echo "=== {} ==="; perfquery -x {}'

    # Check for congestion
    ibdiagnet -pc

Subnet Manager Issues
+++++++++++++++++++++

.. code-block:: bash

    # Check SM logs
    journalctl -u opensm

    # Verify SM priority and state
    sminfo

Advanced Configuration
----------------------

SR-IOV Configuration
~~~~~~~~~~~~~~~~~~~~

For virtualized environments:

.. code-block:: bash

    # Enable SR-IOV
    echo 8 > /sys/class/infiniband/mlx5_0/device/sriov_numvfs

    # Configure virtual functions
    ibdev2netdev -v

Large Scale Deployments
~~~~~~~~~~~~~~~~~~~~~~~

For clusters with hundreds or thousands of nodes:

- Use hierarchical subnet managers
- Implement proper cable management and labeling
- Monitor fabric health continuously
- Plan for redundant subnet managers

Quality of Service
~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Configure service levels for different traffic types
    # (Usually handled by subnet manager configuration)

    # Check current SL configuration
    ibaddr
