Linux NFS Client
================

Network File System (NFS) is commonly used in HPC environments for shared storage. Proper configuration is essential for
optimal performance and reliability.

.. contents:: Table of Contents
    :local:
    :depth: 2

Performance Optimization Methodology
------------------------------------

This section provides a systematic approach to NFS performance tuning. Rather than applying all optimizations blindly,
follow this methodology to identify and address specific bottlenecks in your environment.

.. warning::

    The following section is summarized by LLM based on other original content. A comprehensive review is currently
    being conducted.

Assessment and Baseline Philosophy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before making any changes, establish a comprehensive understanding of your environment:

**1. Network Performance Baseline**
    - Measure raw network performance between client and server
    - Test both bandwidth and latency characteristics
    - For RDMA-capable networks, compare TCP vs RDMA performance
    - Document baseline measurements for comparison

**2. Local Storage Performance Reference**
    - Establish local disk performance as a reference point
    - Test both sequential and random I/O patterns
    - This helps distinguish NFS-specific issues from general I/O limitations

**3. NFS Performance Baseline**
    - Test with minimal mount options to establish baseline
    - Measure large file sequential I/O performance
    - Assess metadata operation performance
    - Test small file operations representative of your workload

Performance Profiling Strategy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Systematic identification of bottlenecks:

**Resource Utilization Analysis**
    - Monitor NFS client statistics to identify operation patterns
    - Track system resource utilization (CPU, memory, network)
    - Identify whether bottlenecks are client-side, network, or server-side

**Workload Characterization**
    - Determine dominant access patterns (sequential vs random)
    - Assess read/write ratio for your workloads
    - Identify metadata-intensive vs data-intensive operations
    - Understand file size distribution and access frequency

**Bottleneck Identification**
    - Use profiling tools to identify specific performance limitations
    - Correlate performance metrics with system behavior
    - Distinguish between throughput and latency issues

Iterative Optimization Strategy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Follow this systematic approach to optimize performance:

**Phase 1: Network and Transport Optimization**

Focus on basic connectivity and data transfer efficiency:
    - Optimize buffer sizes based on network characteristics and workload
    - Enable multiple connections for increased parallelism
    - Tune timeout values for your network conditions
    - Evaluate RDMA if available for high-performance networks

**Phase 2: Caching and Attribute Optimization**

Leverage caching mechanisms to reduce server round-trips:
    - Tune attribute caching based on data stability and consistency requirements
    - Enable client-side caching for appropriate workloads
    - Optimize directory operations based on access patterns

**Phase 3: Kernel and System Tuning**

Address system-level limitations:
    - Tune kernel RPC parameters for high-concurrency environments
    - Optimize memory management for large-scale I/O operations
    - Consider CPU affinity for NUMA systems

**Phase 4: Workload-Specific Optimization**

Tailor optimizations to specific use cases:
    - Optimize for read-heavy vs write-heavy workloads
    - Address metadata-intensive vs data-intensive patterns
    - Optimize for random I/O patterns
    - Balance multiple competing workload requirements

Validation and Testing Philosophy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After each optimization phase:

**Performance Verification Approach**
    - Re-run baseline tests using consistent methodology
    - Document all changes and their measured impact
    - Maintain a performance log for trend analysis

**Stability and Regression Testing**
    - Conduct extended stress testing to validate stability
    - Implement monitoring or regression testing for performance regression detection
    - Test under realistic load conditions, not just synthetic benchmarks

**Iterative Refinement**
    - Make incremental changes and measure impact
    - Avoid applying multiple optimizations simultaneously
    - Validate each change before proceeding to the next

Workload-Specific Optimization Patterns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Large File Sequential I/O (Data Processing)**
    - Prioritize large buffer sizes and connection parallelism
    - Minimize metadata overhead through extended caching
    - Consider disabling features that add overhead for large transfers

**Small File Metadata Operations (Compilation, Scripts)**
    - Focus on attribute caching and metadata operation efficiency
    - Optimize directory listing operations (e.g., ``nordirplus``)
    - Enable client-side caching (e.g., ``fsc``) to reduce server round-trips

**Random I/O (Databases, Checkpointing)**
    - Use smaller ``rsize`` and ``wsize`` values (e.g., 65536) to reduce latency
    - Disable read-ahead mechanisms if they cause performance degradation
    - Ensure ``sync`` or direct I/O is used for data integrity if required by the application

**Mixed HPC Workloads**
    - Balance competing requirements across different operation types
    - Use moderate settings that provide good overall performance
    - Monitor and adjust based on dominant workload characteristics

Benchmarking Tools
------------------

This section provides comprehensive benchmarking methodologies to evaluate NFS performance and validate optimization
efforts.

.. warning::

    The following section is summarized by LLM based on other original content. A comprehensive review is currently
    being conducted.

Baseline Performance Testing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Network Performance Testing**

Test raw network performance between client and server:

.. code-block:: bash

    # Test network bandwidth (run on client, targeting NFS server)
    iperf3 -c nfs.server.address -t 60 -P 4

    # Test network latency
    ping -c 100 nfs.server.address

    # For RDMA-capable networks, test RDMA performance
    ib_write_bw -D 60 nfs.server.address
    ib_read_lat nfs.server.address

**Local Disk I/O Performance Testing**

Test local disk performance for comparison:

.. code-block:: bash

    # Test sequential write performance
    dd if=/dev/zero of=/tmp/testfile bs=1M count=1024 oflag=direct

    # Test sequential read performance
    dd if=/tmp/testfile of=/dev/null bs=1M iflag=direct

    # Test random I/O with fio
    fio --name=random-rw --ioengine=libaio --iodepth=16 --rw=randrw \
        --bs=4k --direct=1 --size=1G --numjobs=4 --runtime=60 \
        --group_reporting --filename=/mnt/nfs/fiotest

**NFS Baseline Testing**

Establish NFS performance baseline with default settings:

.. code-block:: bash

    # Mount with minimal options first
    mount -t nfs nfs.server:/export /mnt/nfs

    # Test large file sequential I/O
    dd if=/dev/zero of=/mnt/nfs/testfile bs=1M count=1024 oflag=direct
    dd if=/mnt/nfs/testfile of=/dev/null bs=1M iflag=direct

    # Test metadata operations
    time (mkdir /mnt/nfs/test && cd /mnt/nfs/test && \
          for i in {1..1000}; do touch file$i; done && \
          ls -la > /dev/null && rm -rf /mnt/nfs/test)

    # Test many small files
    fio --name=small-files --ioengine=libaio --rw=write --bs=4k \
        --direct=1 --size=4k --numjobs=100 --filename_format='f.$jobnum' \
        --directory=/mnt/nfs/smallfiles --create_serialize=0
    rm -rf /mnt/nfs/smallfiles/*

Performance Profiling Tools
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**NFS Statistics Monitoring**

.. code-block:: bash

    # Monitor NFS client statistics
    nfsstat -c

    # Monitor specific NFS operations
    nfsstat -c -3  # NFSv3 client stats
    nfsstat -c -4  # NFSv4 client stats

    # Watch real-time statistics
    watch -n 1 'nfsstat -c | grep -E "(read|write|getattr|lookup)"'

**System Resource Monitoring**

.. code-block:: bash

    # Monitor I/O wait and system load
    iostat -x 1

    # Monitor network utilization
    iftop -i eth0

    # Monitor CPU usage by NFS processes
    top -p $(pgrep "nfs|rpc")

    # Check for RPC timeout errors
    dmesg | grep -i "nfs\|rpc"

**Advanced Profiling with perf**

.. code-block:: bash

    # Profile NFS client operations
    perf record -g -p $(pgrep nfsv4) sleep 30
    perf report

    # Monitor system calls during NFS operations
    strace -c -p $(pgrep nfs)

Validation Testing Scripts
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Performance Verification**

.. code-block:: bash

    # Re-run baseline tests and compare results
    # Document improvements in a performance log

    # Example performance tracking
    echo "$(date): rsize=1M,wsize=1M,nconnect=8" >> /var/log/nfs-tuning.log
    echo "Sequential write: $(dd if=/dev/zero of=/mnt/nfs/test bs=1M count=100 2>&1 | \
          grep MB/s)" >> /var/log/nfs-tuning.log

**Stability Testing**

.. code-block:: bash

    # Run extended stress tests
    fio --name=stability-test --ioengine=libaio --iodepth=32 \
        --rw=randrw --rwmixread=70 --bs=64k --direct=1 \
        --size=10G --numjobs=8 --runtime=3600 \
        --directory=/mnt/nfs/stress --create_serialize=0

    # Monitor for errors during stress testing
    watch -n 5 'dmesg | tail -20'

Performance Monitoring Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comprehensive Benchmark Suite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Regression Testing
~~~~~~~~~~~~~~~~~~

General Optimization Dimensions
-------------------------------

This section presents NFS optimization dimensions in a logical progression from macroscopic to detailed configuration.
The optimization hierarchy follows this order:

1. **Protocol and Transport** - Fundamental architectural choices that determine the performance envelope available to
   your deployment
2. **System-Wide Kernel Tuning** - Global parameters affecting all NFS operations
3. **System-Wide Caching** - Infrastructure-level caching solutions
4. **Per-Mount Configuration** - Mount-specific tuning based on workload characteristics
5. **Specialized Optimizations** - Targeted settings for specific operation types

This hierarchy ensures that broad, high-impact optimizations are applied first, followed by progressively more specific
tuning based on detailed workload analysis.

NFS Protocol and Transport Layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These choices fundamentally determine the performance envelope and capabilities available to your NFS deployment.

**NFS Version Selection**

The NFS version choice affects all subsequent optimization strategies:

- **NFSv3**: Widely supported and stable, but has limitations with locking mechanisms
- **NFSv4.0**: Introduces improved locking mechanisms and supports ACLs, but may have compatibility issues with older
  servers
- **NFSv4.1**: Supports pNFS (parallel NFS), enabling parallel access across multiple servers for better performance
- **NFSv4.2**: Adds features like server-side copy, sparse files, and application data block support

**High-Performance Network Transport**

For InfiniBand or RoCE networks with RDMA-capable NFS servers:

.. code-block:: bash

    proto=rdma,port=20049

.. note::

    The default RDMA port for NFS is 20049, but verify your server configuration. For NFSv4.1 with pNFS and RDMA, you
    may need additional configuration.

.. tip::

    - Verify that both client and server support NFS over RDMA
    - Ensure your HCA (Host Channel Adapter) drivers and RDMA stack are properly configured
    - Test connectivity with ``rping`` before mounting NFS over RDMA

Kernel Tuning
~~~~~~~~~~~~~

These parameters affect all NFS operations system-wide and should be tuned based on your overall infrastructure
characteristics.

**Understanding the SunRPC Subsystem**

NFS relies on the SunRPC (Remote Procedure Call) framework for all client-server communication. The kernel's ``sunrpc``
subsystem manages connection pools, request queuing, transport protocols, and memory registration for NFS operations.
Key performance aspects include:

- **RPC Slot Tables**: Control the maximum number of concurrent outstanding requests, directly affecting parallelism and
  preventing server overload
- **Transport Management**: Handles TCP, UDP, and RDMA connections with different performance characteristics and
  resource requirements
- **Memory Registration**: For RDMA transports, manages efficient memory region registration to minimize latency for
  high-speed networks
- **Flow Control**: Balances client request rates with server capacity and network bandwidth to prevent congestion

Understanding these subsystems helps explain why tuning RPC parameters can dramatically impact NFS performance,
especially in high-concurrency or high-bandwidth environments.

**RPC and Network Stack Parameters**

The following table summarizes the key SunRPC parameters for NFS performance tuning:

.. list-table:: SunRPC Parameters (sunrpc.*)
    :header-rows: 1
    :widths: 30 20 50

    - - Parameter
      - Value
      - Remarks
    - - ``tcp_slot_table_entries``
      - 128
      - |   Max concurrent TCP RPC requests.
        |   Increase request backlog for higher concurrency under heavy load scenarios.
    - - ``udp_slot_table_entries``
      - 128
      - |   Max concurrent UDP RPC requests.
        |   Less common in modern deployments.
    - - ``rdma_slot_table_entries``
      - 256
      - |   Max outstanding RDMA requests.
        |   Tune based on server-to-node ratio and workload concurrency requirements.
    - - ``rdma_pad_optimize``
      - 1
      - |   Enabled. RDMA message padding for better memory alignment.
    - - ``rdma_max_inline_read``
      - MTU - 256
      - |   Max inline RDMA read size.
        |   Set to MTU minus 256 bytes for headers (3840 for 4096 MTU).
    - - ``rdma_max_inline_write``
      - MTU - 256
      - |   Max inline RDMA write size.
        |   Should match inline read value.
    - - ``rdma_memreg_strategy``
      - 4
      - |   FRMR. Recommended for modern HCAs.

.. note::

    **RDMA Parameters**: The RDMA-specific parameters only apply when using NFS over RDMA transport. For TCP-only
    deployments, focus on the TCP slot table and network buffer settings.

**Example Configuration**

Create a sysctl config file, such as ``/etc/sysctl.d/99-nfs.conf``:

.. code-block:: ini

    # These should be ideally be already tuned at network subsystem
    # level, but included here for completeness
    net.core.rmem_default = 16777216
    net.core.rmem_max = 134217728
    net.core.wmem_default = 16777216
    net.core.wmem_max = 134217728

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

To apply the settings without rebooting, run ``sysctl --system``.

.. tip::

    **Incremental Tuning**: Start with conservative values and increase gradually while monitoring performance and
    memory usage. Higher slot table entries improve concurrency but increase memory consumption.

Caching Infrastructure
~~~~~~~~~~~~~~~~~~~~~~

Client-side caching provides system-wide performance benefits for frequently accessed data patterns.

**Standard Client-Side Caching**

Cachefilesd enables local caching of NFS files, significantly improving performance for frequently accessed and
infrequently changed data.

.. code-block:: bash

    systemctl enable --now cachefilesd

To enable caching for an NFS mount, add the ``fsc`` option to the mount command in ``/etc/fstab``.

.. code-block:: bash

    your.nfs.server:/export /mount/point nfs defaults,fsc 0 0

**Tuning Cachefilesd for HPC Workloads**

For demanding HPC workloads, the default ``cachefilesd`` configuration may be insufficient. One common limitation is the
maximum number of open file descriptors.

To increase this limit, create a systemd override file ``/etc/systemd/system/cachefilesd.service.d/limits.conf``:

.. code-block:: ini

    [Service]
    LimitNOFILE=65536

Reload the systemd configuration and restart ``cachefilesd`` to apply the changes.

**Advanced Caching Solutions**

Commercial NFS implementations may offer additional features:

- **Client-side buffered write**: Improves write performance through intelligent caching
- **Multi-path read**: Load balances reads across multiple network paths
- **Advanced caching**: More sophisticated caching algorithms than standard FS-Cache
- **Quality of Service**: Traffic prioritization and bandwidth management

**Compatibility Considerations for Proprietary Solutions**

When using proprietary NFS solutions:

- Verify ``fsc`` compatibility with vendor-specific caching mechanisms
- Test interoperability with standard NFS clients
- Understand licensing implications for compute nodes
- Plan for failover and redundancy scenarios

Per-Mount Configuration and Tuning
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After establishing protocol choices, system-wide kernel tuning, and caching infrastructure, these mount-specific
settings provide fine-grained control tailored to individual workload characteristics and requirements.

**Core NFS Mount Options**

The following table summarizes essential NFS mount options for HPC environments:

.. list-table:: NFS Mount Options
    :header-rows: 1
    :widths: 25 20 55

    - - Option
      - Recommended Value
      - Remarks
    - - ``vers``
      - 3 or 4.1
      - |   NFSv3 for stability and wide compatibility.
        |   NFSv4.1 for pNFS parallel access and improved locking.
    - - ``rsize``
      - 1048576
      - |   Read buffer size in bytes (1MB).
        |   Larger values improve throughput but increase memory usage.
    - - ``wsize``
      - 1048576
      - |   Write buffer size in bytes (1MB).
        |   Should match rsize for balanced performance.
    - - ``nconnect``
      - 4-16
      - |   Number of TCP connections to establish (NFSv3/4.x with TCP).
        |   Higher values improve parallelism but increase server load.
    - - ``hard``
      - hard
      - |   Hard mount ensures data integrity but may hang on server issues.
        |   Use ``soft`` only for non-critical, read-only data.
    - - ``timeo``
      - 50-100
      - |   RPC timeout in tenths of a second (5-10 seconds).
        |   Increase for high-latency or congested networks.
    - - ``retrans``
      - 2-3
      - |   Number of retransmissions before declaring timeout.
        |   Balance between resilience and responsiveness.
    - - ``acregmin``
      - 10-60
      - |   Minimum file attribute cache time in seconds.
        |   Higher values reduce metadata traffic but may impact consistency.
    - - ``acdirmin``
      - 30-300
      - |   Minimum directory attribute cache time in seconds.
        |   Directories change less frequently than files.
    - - ``lookupcache``
      - all
      - |   Cache lookup results for better metadata performance.
        |   Use ``pos`` for stricter consistency requirements.
    - - ``local_lock``
      - none or all
      - |   ``none`` disables local locking (NFSv3 read-only/single-writer).
        |   ``all`` uses local locking only (bypasses server locks).
    - - ``_netdev``
      - _netdev
      - |   Essential for network filesystems in cluster environments.
        |   Ensures network is available before mounting.

.. warning::

    **Kernel Version Compatibility**: These mount options are verified for Linux kernel 5.x NFS implementation.
    Proprietary NFS client drivers (e.g., vendor-specific solutions) may support additional options or have different
    defaults. Linux kernel 6.x introduces some new options like ``xprtsec`` for NFSv4.2 TLS support and enhanced RDMA
    capabilities.

.. note::

    **Performance vs Reliability Trade-offs**:

    - ``hard`` vs ``soft``: Hard mounts ensure data integrity but can hang; soft mounts fail faster but may cause data
      corruption
    - ``sync`` vs ``async``: Synchronous writes are safer but slower
    - Large ``rsize``/``wsize`` improve throughput but increase memory usage
    - Higher cache times reduce server load but may impact data consistency

**Example HPC Configuration**

Basic high-performance configuration for NFSv3:

.. code-block:: bash

    your.nfs.server:/export /mount/point nfs \
        vers=3,rsize=1048576,wsize=1048576,nconnect=16,hard,timeo=50,retrans=2, \
        acregmin=30,acdirmin=60,lookupcache=all,local_lock=none,nocto,_netdev 0 0

For NFSv4.1 with pNFS support:

.. code-block:: bash

    your.nfs.server:/export /mount/point nfs \
        vers=4.1,rsize=1048576,wsize=1048576,nconnect=16,hard,timeo=100,retrans=3, \
        acregmin=60,acdirmin=300,lookupcache=all,nocto,_netdev 0 0

Specialized Workload Optimizations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The final optimization layer targets specific operation types and access patterns. These optimizations should be applied
selectively based on detailed workload analysis and represent the most specialized tuning options available.

**Directory Listing Optimization**

Directory listing behavior significantly impacts metadata-intensive workloads.

**rdirplus vs nordirplus:**

- ``rdirplus`` (Default): Fetches file names and metadata together, efficient for operations like ``ls -l`` that need
  both names and attributes
- ``nordirplus``: Fetches only file names, optimized for filename-only scanning workloads such as read-only software
  mounts where applications frequently scan for filenames

**When to Use nordirplus:**

- Read-only software mounts with frequent directory scanning
- Workloads that primarily need filenames without attributes
- Large directories where metadata fetching is a bottleneck

.. warning::

    Only use ``nordirplus`` after thorough testing with your specific NFS server implementation and workload. This
    option will degrade performance for most operations that require file attributes.

Other Considerations
--------------------

This section covers additional factors that impact NFS performance and deployment in production environments.

Performance and Security Trade-offs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Security measures can impact NFS performance. This section helps balance security requirements with performance
optimization.

**Kerberos Authentication**

Kerberos provides strong authentication but adds overhead:

.. code-block:: bash

    # Basic Kerberos mount
    nfs.server:/export /mnt/secure nfs sec=krb5,rsize=1048576,wsize=1048576 0 0

    # Performance-optimized Kerberos mount
    nfs.server:/export /mnt/secure nfs \
        sec=krb5,rsize=1048576,wsize=1048576,nconnect=16, \
        acregmin=60,acdirmin=60,_netdev 0 0

Performance impact mitigation:

- Use ticket caching to reduce authentication overhead
- Increase attribute cache times to reduce authenticated metadata operations
- Consider ``sec=krb5i`` only when data integrity is critical (adds ~15% overhead)
- Avoid ``sec=krb5p`` unless encryption in transit is required (adds ~25% overhead)

**TLS Encryption (NFSv4.2)**

For environments requiring encryption in transit:

.. code-block:: bash

    # NFSv4.2 with TLS
    nfs.server:/export /mnt/encrypted nfs \
        vers=4.2,proto=tcp,port=2049,xprtsec=tls, \
        rsize=262144,wsize=262144,nconnect=16 0 0

Performance considerations:

- TLS adds CPU overhead for encryption/decryption
- Reduce buffer sizes to balance security and performance
- Monitor CPU utilization on both client and server
- Consider hardware acceleration for cryptographic operations

Troubleshooting
---------------

This section provides comprehensive troubleshooting guidance for various NFS issues beyond just performance problems.

.. warning::

    The following section is summarized by LLM based on other original content. A comprehensive review is currently
    being conducted.

Performance Issues
~~~~~~~~~~~~~~~~~~

**Symptom: Slow Sequential Read/Write Performance**

Diagnostic steps:

.. code-block:: bash

    # Check current mount options
    mount | grep nfs

    # Check actual buffer sizes being used
    nfsstat -m | grep -E "rsize|wsize"

    # Test different buffer sizes
    mount -o remount,rsize=1048576,wsize=1048576 /mnt/nfs

    # Compare with network bandwidth capacity
    iperf3 -c nfs.server -P 1

Common causes and solutions:

- **Small buffer sizes**: Increase rsize/wsize to 1MB
- **Single connection bottleneck**: Enable nconnect=4-16
- **Network congestion**: Check for packet loss with ``iperf3``
- **Server-side bottlenecks**: Monitor server CPU and disk I/O

**Symptom: High Metadata Operation Latency**

Diagnostic steps:

.. code-block:: bash

    # Monitor metadata operations
    nfsstat -c | grep -E "getattr|lookup|readdir"

    # Test directory listing performance
    time ls -la /mnt/nfs/large_directory/

    # Check attribute cache effectiveness
    echo 3 > /proc/sys/vm/drop_caches
    time ls -la /mnt/nfs/large_directory/  # First run
    time ls -la /mnt/nfs/large_directory/  # Second run (should be faster)

Common causes and solutions:

- **Insufficient attribute caching**: Increase ``acregmin`` and ``acdirmin``
- **Inefficient directory operations**: Test ``nordirplus`` for scan-heavy workloads
- **Network latency**: Consider client-side caching with ``fsc``
- **Too many small files**: Consolidate files or use archives when possible

Filesystem Soft Lockups
~~~~~~~~~~~~~~~~~~~~~~~

**Symptom: System becomes unresponsive, soft lockup messages in dmesg**

.. code-block:: bash

    # Check for soft lockup messages
    dmesg | grep -i "soft lockup\|hung task"

    # Monitor NFS-related kernel threads
    ps aux | grep "\[nfs\|rpc\]"

**Common Causes and Solutions**:

1. **Long-running metadata operations on large directories**:

   .. code-block:: bash

       # Reduce directory scan operations
       # Use find with -maxdepth to limit recursion
       find /mnt/nfs -maxdepth 2 -name "*.txt"

       # Break large operations into smaller chunks
       ls /mnt/nfs/large_dir | head -1000

2. **Uninterruptible I/O operations**:

   .. code-block:: bash

       # Use soft mounts for non-critical data
       mount -o soft,timeo=30,retrans=2 nfs.server:/export /mnt/nfs

       # For critical data, ensure proper timeout values
       mount -o hard,timeo=50,retrans=3 nfs.server:/export /mnt/nfs

3. **Memory pressure during large I/O operations**:

   .. code-block:: bash

       # Monitor memory usage during NFS operations
       watch -n 1 'cat /proc/meminfo | grep -E "MemFree|Cached|Dirty"'

       # Tune dirty memory thresholds
       echo 5 > /proc/sys/vm/dirty_background_ratio
       echo 10 > /proc/sys/vm/dirty_ratio

Process Deadlocks on NFS
~~~~~~~~~~~~~~~~~~~~~~~~

**Symptom: Processes hang indefinitely, cannot be killed**

.. code-block:: bash

    # Identify hung processes
    ps aux | grep " D "  # Processes in uninterruptible sleep

    # Check process stack traces
    cat /proc/PID/stack  # Replace PID with actual process ID

    # Monitor NFS operations
    cat /proc/PID/mountstats

**Common Scenarios and Solutions**:

1. **Lock conflicts in NFSv3**:

   .. code-block:: bash

       # Disable locking for read-only or single-writer scenarios
       mount -o nolock nfs.server:/export /mnt/nfs

       # Use local locking only
       mount -o local_lock=all nfs.server:/export /mnt/nfs

2. **Stale file handles**:

   .. code-block:: bash

       # Check for stale handles
       dmesg | grep -i "stale"

       # Remount the filesystem
       umount /mnt/nfs && mount /mnt/nfs

       # For persistent issues, restart applications accessing the mount

3. **Server-side lock manager issues**:

   .. code-block:: bash

       # Check lock manager status on server
       systemctl status nfs-lock.service

       # Clear lock state (server-side, use with caution)
       systemctl restart nfs-lock.service

NFS Data Inconsistency
~~~~~~~~~~~~~~~~~~~~~~

**Symptom: Different clients see different file contents or metadata**

.. code-block:: bash

    # Check mount options for caching behavior
    mount | grep nfs

    # Compare file checksums across clients
    md5sum /mnt/nfs/testfile  # Run on multiple clients

    # Check file timestamps and sizes
    stat /mnt/nfs/testfile

**Common Causes and Solutions**:

1. **Aggressive client-side caching**:

   .. code-block:: bash

       # Reduce attribute cache times for frequently changing data
       mount -o acregmin=3,acdirmin=3 nfs.server:/export /mnt/nfs

       # Disable attribute caching entirely (impacts performance)
       mount -o actimeo=0 nfs.server:/export /mnt/nfs

       # Force immediate synchronization
       sync && echo 3 > /proc/sys/vm/drop_caches

2. **Write caching issues**:

   .. code-block:: bash

       # Use synchronous writes for critical data
       mount -o sync nfs.server:/export /mnt/nfs

       # Force write-through for specific operations
       dd if=sourcefile of=/mnt/nfs/destfile oflag=sync

3. **Clock synchronization problems**:

   .. code-block:: bash

       # Check time synchronization
       chrony sources -v  # or ntpq -pn

       # Verify timezone consistency
       timedatectl status

4. **Multiple writers without coordination**:

   .. code-block:: bash

       # Implement file locking in applications
       # Use advisory locks with flock or fcntl

       # Example: exclusive access pattern
       (
           flock -x 200
           # Critical section with exclusive access
           echo "data" > /mnt/nfs/shared_file
       ) 200>/mnt/nfs/lockfile

Network and Connectivity Issues
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Symptom: Intermittent hangs, timeout errors**

.. code-block:: bash

    # Check for network errors
    dmesg | grep -i "nfs.*timeout\|rpc.*timeout"

    # Monitor network connectivity
    ping -c 1000 nfs.server | grep -E "packet loss|rtt"

    # Check for network interface errors
    cat /proc/net/dev | grep eth0

**Diagnostic Steps**:

1. **Network stability testing**:

   .. code-block:: bash

       # Long-term connectivity test
       mtr --report --report-cycles 100 nfs.server

       # Check for network congestion
       iperf3 -c nfs.server -t 300 -i 10

2. **RPC layer debugging**:

   .. code-block:: bash

       # Enable RPC debugging (use sparingly)
       echo 1 > /proc/sys/sunrpc/rpc_debug

       # Monitor RPC statistics
       nfsstat -r  # Client RPC statistics

       # Disable debugging after troubleshooting
       echo 0 > /proc/sys/sunrpc/rpc_debug

3. **Firewall and port issues**:

   .. code-block:: bash

       # Check NFS port accessibility
       telnet nfs.server 2049

       # For NFSv3, check additional ports
       rpcinfo -p nfs.server

       # Test UDP connectivity (NFSv3)
       nc -u nfs.server 2049

Server-Side Issues
~~~~~~~~~~~~~~~~~~

**Identifying Server-Side Bottlenecks**

.. code-block:: bash

    # Monitor server from client side
    nfsstat -s  # Server statistics (if accessible)

    # Check server response times
    time ls /mnt/nfs/ > /dev/null

    # Monitor for server busy errors
    dmesg | grep -i "server.*busy"

**Common Server Issues**:

1. **Insufficient nfsd threads**:

   .. code-block:: bash

       # Check current thread count (server-side)
       cat /proc/fs/nfsd/threads

       # Increase thread count (server-side)
       echo 64 > /proc/fs/nfsd/threads

2. **Export configuration problems**:

   .. code-block:: bash

       # Verify export visibility (server-side)
       exportfs -v

       # Test export accessibility
       showmount -e nfs.server

Recovery and Maintenance Procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Safe NFS Maintenance**

.. code-block:: bash

    # Graceful unmount procedure
    # 1. Stop applications using the mount
    lsof +D /mnt/nfs  # Identify processes using NFS

    # 2. Sync pending writes
    sync

    # 3. Unmount with force if necessary
    umount /mnt/nfs
    # If busy: umount -f /mnt/nfs
    # If still busy: umount -l /mnt/nfs  # Lazy unmount

.. warning::

    Using ``umount -f`` (force) or ``umount -l`` (lazy) can lead to data corruption if there are pending writes. These
    options should be used with extreme caution as a last resort when a graceful unmount is not possible.

**Emergency Recovery**

.. code-block:: bash

    # Clear stuck mount state
    # 1. Kill processes accessing NFS (last resort)
    fuser -km /mnt/nfs

    # 2. Force unmount
    umount -f /mnt/nfs

    # 3. Clear mount cache
    echo 3 > /proc/sys/vm/drop_caches

    # 4. Restart NFS client services if needed
    systemctl restart nfs-client.target

**Preventive Measures**

.. code-block:: bash

    # Regular health checks
    #!/bin/bash
    # /usr/local/bin/nfs-health-check.sh

    MOUNT_POINT="/mnt/nfs"

    # Test basic connectivity
    if ! timeout 10 ls $MOUNT_POINT > /dev/null 2>&1; then
        echo "ALERT: NFS mount $MOUNT_POINT not responsive"
        # Add notification logic here
    fi

    # Check for error conditions
    error_count=$(dmesg | grep -c "nfs.*error\|rpc.*error")
    if [ $error_count -gt 10 ]; then
        echo "ALERT: High NFS error count: $error_count"
    fi

    # Monitor performance degradation
    # Add performance threshold checks here
