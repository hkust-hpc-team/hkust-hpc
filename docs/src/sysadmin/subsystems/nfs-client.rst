Linux NFS Client
================

Network File System (NFS) is commonly used in HPC environments for shared storage.
Proper configuration is essential for optimal performance and reliability.

.. contents:: Table of Contents
    :local:
    :depth: 2

NFS Versions
------------

Understanding NFS version differences:

- **NFSv3**: Widely supported and stable, but has limitations with locking mechanisms
- **NFSv4.0**: Introduces improved locking mechanisms and supports ACLs, but may have
  compatibility issues with older servers
- **NFSv4.1**: Supports pNFS (parallel NFS), enabling parallel access across multiple
  servers for better performance
- **NFSv4.2**: Adds features like server-side copy, sparse files, and application data
  block support

Mount Options
~~~~~~~~~~~~~

Example options for HPC workloads (NFSv3):

.. code-block::

    your.nfs.server:/export /mount/point nfs defaults,vers=3,rsize=1048576,wsize=1048576,nconnect=16,hard,timeo=50,retrans=2,acregmin=10,acdirmin=30,lookupcache=all,_netdev 0 0

Option Explanations:

- ``rw``: Read-write access
- ``relatime``: Update access times relative to modify time (reduces I/O)
- ``vers=3``: Use NFSv3 (change to ``vers=4.1`` for pNFS environments)
- ``rsize=1048576,wsize=1048576``: 1MB read/write buffer sizes for better throughput
- ``acregmin=10``: Minimum time to cache file attributes (seconds)
- ``acdirmin=30``: Minimum time to cache directory attributes (seconds)
- ``hard``: Hard mount - operations will retry indefinitely on failure. The ``intr``
  option is obsolete on modern kernels, as operations on ``hard`` mounts can be
  interrupted by signals.
- ``nconnect=16``: Sets the maximum number of TCP connections (up to 16 in this case)
  that the client can establish to the server. The actual number is negotiated.
- ``timeo=50``: Timeout for RPC requests in tenths of a second (5 seconds), reduced for
  faster failure detection
- ``retrans=2``: Number of retransmissions before timeout
- ``lookupcache=all``: Cache all lookups for better performance
- ``_netdev``: Wait for network before mounting (essential for cluster environments)
- ``local_lock=none``: Disable local locking. This is often recommended for NFSv3 to
  avoid issues with its legacy locking mechanism, especially in read-only or
  single-writer scenarios.

Directory Listing
~~~~~~~~~~~~~~~~~

- ``rdirplus`` (Default): Recommended for general use. Efficiently fetches file names
  and their metadata together, which benefits most common operations (e.g., ``ls -l``).
- ``nordirplus``: A niche optimization for specific workloads, such as a read-only
  software mount where applications frequently scan for filenames only.

.. warning::

    Only use ``nordirplus`` after thorough testing with your specific NFS server
    implementation and workload to confirm a performance benefit. This option will
    degrade performance for most other operations.

RDMA Support
~~~~~~~~~~~~

For InfiniBand or RoCE networks with RDMA-capable NFS servers:

.. code-block::

    proto=rdma,port=20049

.. note::

    The default RDMA port for NFS is 20049, but verify your server configuration. For
    NFSv4.1 with pNFS and RDMA, you may need additional configuration.

.. tip::

    - Verify that both client and server support NFS over RDMA
    - Ensure your HCA (Host Channel Adapter) drivers and RDMA stack are properly
      configured
    - Test connectivity with ``rping`` before mounting NFS over RDMA

Sysctl Parameters
-----------------

For optimal performance, especially in high-throughput environments, tune the kernel's
sysctl parameters. Create a sysctl config file, such as ``/etc/sysctl.d/99-nfs.conf``
with the content

.. code-block:: ini

    # Increase RPC slot table for high concurrency
    sunrpc.tcp_slot_table_entries = 128
    sunrpc.udp_slot_table_entries = 128

    # Settings for NFS over RDMA (InfiniBand/RoCE)
    sunrpc.rdma_slot_table_entries = 256
    sunrpc.rdma_pad_optimize = 1
    # Set slightly below MTU to account for headers (e.g., 4096 - 256)
    # Recommended for 4096 MTU environments (both IB and RoCEv2)
    sunrpc.rdma_max_inline_read = 3840
    sunrpc.rdma_max_inline_write = 3840

    # Additional RDMA performance tunings
    sunrpc.rdma_memreg_strategy = 4
    net.core.rmem_default = 16777216
    net.core.rmem_max = 134217728
    net.core.wmem_default = 16777216
    net.core.wmem_max = 134217728

To apply the settings without rebooting, run ``sysctl --system``.

Parameter Explanations:

- ``sunrpc.tcp_slot_table_entries``: Controls the maximum number of simultaneous TCP RPC
  requests. Increasing this value can prevent "NFS server busy" errors in
  high-concurrency environments.
- ``sunrpc.rdma_slot_table_entries``: Specifies the maximum number of outstanding RDMA
  requests. For 100Gbps networks, 256 or higher is recommended to avoid bottlenecks.
- ``sunrpc.rdma_pad_optimize``: Enables padding optimization for RDMA messages, which
  can improve throughput. Generally recommended to enable.
- ``sunrpc.rdma_max_inline_read/write``: Sets the maximum size for inline data
  transfers, avoiding costly remote memory registration for smaller I/O operations. For
  4096 MTU environments (both InfiniBand and RoCEv2), 3840 bytes provides optimal
  performance while accounting for protocol headers.
- ``sunrpc.rdma_memreg_strategy``: Memory registration strategy (4 = FRMR - Fast
  Registration Memory Regions, recommended for modern HCAs).
- ``net.core.rmem/wmem_*``: Increase socket buffer sizes to handle high-bandwidth,
  low-latency RDMA traffic effectively.

Client-Side Caching
-------------------

Cachefilesd enables local caching of NFS files, significantly improving performance for
frequently accessed and infrequently changed data.

.. code-block:: bash

    systemctl enable --now cachefilesd

To enable caching for an NFS mount, add the ``fsc`` option to the mount command in
``/etc/fstab``.

.. code-block::

    your.nfs.server:/export /mount/point nfs defaults,fsc 0 0

Tuning Cachefilesd
~~~~~~~~~~~~~~~~~~

For demanding HPC workloads, the default ``cachefilesd`` configuration may be
insufficient. One common limitation is the maximum number of open file descriptors.

To increase this limit, create a systemd override file
``/etc/systemd/system/cachefilesd.service.d/limits.conf`` with the following content to
raise the open files limit

.. code-block:: ini

    [Service]
    LimitNOFILE=65536

Reload the systemd configuration and restart ``cachefilesd`` to apply the changes.

Proprietary NFS Client
----------------------

Commercial NFS implementations may offer additional features

- **Client-side buffered write**: Improves write performance through intelligent caching
- **Multi-path read**: Load balances reads across multiple network paths
- **Advanced caching**: More sophisticated caching algorithms than standard FS-Cache
- **Quality of Service**: Traffic prioritization and bandwidth management

Compatibility Considerations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When using proprietary NFS solutions

- Verify ``fsc`` compatibility with vendor-specific caching mechanisms
- Test interoperability with standard NFS clients
- Understand licensing implications for compute nodes
- Plan for failover and redundancy scenarios

Best Practices
--------------

NFS can be effective for HPC workloads when properly configured, however, always
consider alternatives like Lustre, BeeGFS, or CephFS for large-scale parallel I/O
workloads, or object storage systems like S3 for unstructured data.

If you choose NFS for HPC, follow these best practices

- Use separate mounts for different workload types (home directories, application data,
  scratch space)
- For read-only software stacks, use ``ro,noatime`` and longer attribute cache times to
  improve caching effectiveness
- Implement mount timeouts and retry logic in job scripts to handle network
  interruptions
- Monitor NFS statistics with ``nfsstat`` and ``iostat`` to identify bottlenecks
- Ensure the network MTU is configured consistently end-to-end. For InfiniBand fabrics,
  an MTU of 4096 bytes is standard. For RoCE/Ethernet fabrics, while jumbo frames (e.g.,
  9000 bytes) are common, an MTU of 4096 bytes is also frequently used with RoCEv2 to
  align with InfiniBand infrastructure.
- Use multiple NFS servers with load balancing for better aggregate performance
- Consider NFS server tuning (e.g., increasing ``nfsd`` threads, tuning export options)
