Linux Kernel
============

The Linux kernel configuration is crucial for optimal HPC performance. Proper kernel
selection, boot parameters, and runtime configuration can significantly impact
application performance.

Considerations
--------------

- **Hardware/driver compatibility**: Ensure kernel version supports your hardware
- **User familiarity**: Balance cutting-edge features with operational stability
- **OS features**: Consider security requirements vs. performance trade-offs
- **Long-term support**: Choose kernels with appropriate support lifecycles

Kernel Boot Parameters
----------------------

Core HPC Parameters
~~~~~~~~~~~~~~~~~~~

These parameters are generally beneficial for HPC workloads:

.. code-block::

    cgroup_no_v1=all clocksource=tsc default_hugepagesz=2M hugetlb_free_vmemmap=1 numa_balancing=disable tsc=reliable workqueue.default_affinity_scope=numa

Explanation:

- ``cgroup_no_v1=all``: Forces use of cgroup v2, which has better performance
- ``clocksource=tsc``: Uses TSC as clocksource for better performance
- ``default_hugepagesz=2M``: Sets default huge page size to 2MB
- ``hugetlb_free_vmemmap=1``: Reduces memory overhead for huge pages
- ``numa_balancing=disable``: Disables automatic NUMA balancing (HPC apps should handle
  this)
- ``tsc=reliable``: Assumes TSC is reliable, avoiding unnecessary checks
- ``workqueue.default_affinity_scope=numa``: Improves workqueue locality

Memory Management
~~~~~~~~~~~~~~~~~

Choose based on your workload characteristics:

.. code-block::

    # For large matrix operations and regular memory access patterns
    transparent_hugepage=always

    # For mixed workloads or object-oriented applications
    transparent_hugepage=madvise

Security vs Performance Trade-offs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note**: These parameters reduce security but may improve performance. Use only in
appropriate environments:

.. code-block::

    audit=0 mitigations=off selinux=0

- ``audit=0``: Disables kernel auditing
- ``mitigations=off``: Disables CPU vulnerability mitigations
- ``selinux=0``: Disables SELinux

Debugging
~~~~~~~~~

Enable only for troubleshooting:

.. code-block::

    crashkernel=256M

Kernel Sysctl Parameters
------------------------

Network Tuning
~~~~~~~~~~~~~~

.. code-block::

    # Increase network buffer sizes for high-throughput networks
    net.core.rmem_max = 134217728
    net.core.wmem_max = 134217728
    net.core.rmem_default = 87380
    net.core.wmem_default = 65536
    net.ipv4.tcp_rmem = 4096 87380 134217728
    net.ipv4.tcp_wmem = 4096 65536 134217728

    # Improve network stack performance
    net.core.netdev_max_backlog = 30000
    net.core.netdev_budget = 600
    net.ipv4.tcp_congestion_control = bbr

Memory Management
~~~~~~~~~~~~~~~~~

.. code-block::

    # Reduce swappiness for HPC workloads
    vm.swappiness = 1

    # Optimize dirty page handling
    vm.dirty_ratio = 40
    vm.dirty_background_ratio = 10
    vm.dirty_expire_centisecs = 3000
    vm.dirty_writeback_centisecs = 500

    # Improve memory allocation
    vm.zone_reclaim_mode = 0
    vm.vfs_cache_pressure = 50

Scheduler Tuning
~~~~~~~~~~~~~~~~

.. code-block::

    # Improve scheduler performance for HPC
    kernel.sched_migration_cost_ns = 5000000
    kernel.sched_autogroup_enabled = 0

    # For NUMA systems
    kernel.numa_balancing = 0

File System
~~~~~~~~~~~

.. code-block::

    # Increase file handle limits
    fs.file-max = 2097152

    # Improve directory cache
    fs.dentry-state = 0 0 45 0 0 0

Process Limits
~~~~~~~~~~~~~~

.. code-block::

    # Increase process limits for large-scale jobs
    kernel.pid_max = 4194304
    kernel.threads-max = 4194304

AMD-Specific Parameters
~~~~~~~~~~~~~~~~~~~~~~~

For AMD EPYC systems, add these parameters (see :doc:`cpu/amd` for details):

.. code-block::

    iommu=pt amd_iommu=on

Note that ``amd_iommu=on`` is only effective on kernel 6.x and later.
