RoCE v2
=======

RoCE v2 (RDMA over Converged Ethernet version 2) runs over standard Ethernet
infrastructure but requires careful tuning to achieve optimal performance.

Unlike InfiniBand's dedicated fabric, RoCE v2 operates over IP networks and often shared
between multiple purposes. RoCE v2 RDMA requires a kernel copy of the Ethernet frame,
which can introduce additional latency compared to InfiniBand.

Performance Characteristics
---------------------------

- **Latency**: Generally higher than InfiniBand due to Ethernet overhead
- **Bandwidth**: Can achieve line-rate performance with proper tuning
- **CPU overhead**: Higher than InfiniBand, especially for small messages
- **Scalability**: Good for large-scale deployments when properly configured

Traffic Management
------------------

Quality of Service (QoS)
~~~~~~~~~~~~~~~~~~~~~~~~

Configure proper QoS to prevent packet loss:

.. code-block:: bash

    # Example: Configure DSCP marking for RoCE traffic
    echo 26 > /sys/class/infiniband/mlx5_0/tc/1/traffic_class

**Critical**: Ensure both RDMA traffic and verbs API traffic use the same QoS class
configured on your switches.

Flow Control
~~~~~~~~~~~~

Enable Priority Flow Control (PFC) on RoCE traffic classes:

.. code-block:: bash

    # Enable PFC on traffic class 3 (example)
    dcbtool sc mlx5_0 pfc e:1 a:1 w:1 p:00100000

Kernel Tuning
-------------

IRQ Handling
~~~~~~~~~~~~

Proper interrupt handling is critical for low latency:

.. code-block:: bash

    # Disable IRQ balancing daemon
    systemctl stop irqbalance
    systemctl disable irqbalance

    # Use Mellanox tuning script for optimal IRQ affinity
    mlnx_tune -p HIGH_THROUGHPUT

CPU Isolation
~~~~~~~~~~~~~

Reserve CPU cores for interrupt handling:

.. code-block:: bash

    # Example: Reserve cores 0-3 for interrupts, isolate 4-127 for applications
    # Add to kernel parameters:
    isolcpus=4-127 nohz_full=4-127 rcu_nocbs=4-127

Power Management
~~~~~~~~~~~~~~~~

Disable CPU power saving features during workloads:

.. code-block:: bash

    # Set performance governor
    cpupower frequency-set -g performance

    # Disable C-states
    cpupower idle-set -D 0

    # Or add to kernel parameters:
    processor.max_cstate=1 intel_idle.max_cstate=0

Network Buffer Tuning
~~~~~~~~~~~~~~~~~~~~~

Increase buffer sizes for high-throughput workloads:

.. code-block:: bash

    # Increase ring buffer sizes
    ethtool -G <interface> rx 8192 tx 8192

    # Example for Mellanox adapters
    ethtool -G mlx5_0 rx 8192 tx 8192

Advanced Tuning
---------------

RDMA-specific Parameters
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Increase completion queue depth
    echo 1024 > /sys/class/infiniband/mlx5_0/max_cq

    # Optimize queue pair parameters
    echo 1024 > /sys/class/infiniband/mlx5_0/max_qp

Memory Registration
~~~~~~~~~~~~~~~~~~~

For applications with large memory footprints:

.. code-block:: bash

    # Increase memory registration cache
    echo 1000000 > /sys/class/infiniband/mlx5_0/umr_rkey_timeout

PCIe Optimization
~~~~~~~~~~~~~~~~~

Ensure optimal PCIe configuration:

.. code-block:: bash

    # Set PCIe Max Read Request Size
    setpci -s <device_id> 68.w=5936

    # Verify PCIe link status
    lspci -vvv -s <device_id> | grep -E "(LnkCap|LnkSta)"

Monitoring and Diagnostics
--------------------------

Performance Monitoring
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Monitor RDMA counters
    rdma statistic show

    # Check for packet drops
    ethtool -S <interface> | grep -E "(drop|error)"

    # Monitor interrupt distribution
    cat /proc/interrupts | grep mlx5

Common Issues
~~~~~~~~~~~~~

- **Packet drops**: Usually due to incorrect QoS configuration
- **High latency**: Often caused by improper IRQ affinity or power management
- **Reduced bandwidth**: May indicate PCIe or memory bandwidth limitations
- **Connection timeouts**: Could be related to network fabric configuration
