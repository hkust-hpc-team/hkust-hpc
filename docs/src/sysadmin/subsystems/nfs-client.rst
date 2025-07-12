Linux NFS Client
================

Network File System (NFS) is commonly used in HPC environments for shared storage.
Proper configuration is essential for optimal performance and reliability.

.. contents:: Table of Contents
    :local:
    :depth: 2

Performance Optimization Methodology
------------------------------------

This section provides a systematic approach to NFS performance tuning. Rather than
applying all optimizations blindly, follow this methodology to identify and address
specific bottlenecks in your environment.

Baseline Performance Assessment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before making any changes, establish baseline measurements:

**1. Network Performance Testing**

Test raw network performance between client and server:

.. code-block:: bash

    # Test network bandwidth (run on client, targeting NFS server)
    iperf3 -c nfs.server.address -t 60 -P 4

    # Test network latency
    ping -c 100 nfs.server.address

    # For RDMA-capable networks, test RDMA performance
    ib_write_bw -D 60 nfs.server.address
    ib_read_lat nfs.server.address

**2. Disk I/O Performance Testing**

Test local disk performance for comparison:

.. code-block:: bash

    # Test sequential read performance
    dd if=/dev/zero of=/tmp/testfile bs=1M count=1024 oflag=direct
    
    # Test sequential read performance
    dd if=/tmp/testfile of=/dev/null bs=1M iflag=direct
    
    # Test random I/O with fio
    fio --name=random-rw --ioengine=libaio --iodepth=16 --rw=randrw \
        --bs=4k --direct=1 --size=1G --numjobs=4 --runtime=60 \
        --group_reporting --filename=/tmp/fiotest

**3. NFS Baseline Testing**

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
    fio --name=small-files --ioengine=sync --rw=write --bs=4k \
        --direct=1 --size=4k --numjobs=100 --filename_format='f.$jobnum' \
        --directory=/mnt/nfs/smallfiles --create_serialize=0

Performance Profiling and Bottleneck Identification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use these tools to identify where bottlenecks occur:

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

Iterative Optimization Process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Follow this systematic approach to optimize performance:

**Phase 1: Network and Transport Optimization**

1. **Increase buffer sizes** - Start with larger rsize/wsize
2. **Enable multiple connections** - Use nconnect for parallel streams
3. **Optimize timeouts** - Reduce timeout values for faster failure detection
4. **Test RDMA** - If available, compare TCP vs RDMA performance

**Phase 2: Caching and Attribute Optimization**

1. **Tune attribute caching** - Increase cache times for stable workloads
2. **Enable client-side caching** - Add fsc option and tune cachefilesd
3. **Optimize directory operations** - Test rdirplus vs nordirplus

**Phase 3: Kernel and System Tuning**

1. **Increase RPC slots** - Tune sunrpc parameters for high concurrency
2. **Optimize memory** - Increase socket buffers for high-bandwidth workloads
3. **CPU affinity** - Pin NFS processes to specific CPU cores if needed

**Phase 4: Workload-Specific Optimization**

1. **Read-heavy workloads** - Focus on read-ahead and caching
2. **Write-heavy workloads** - Optimize write buffers and sync behavior
3. **Metadata-intensive** - Tune attribute caching and directory operations
4. **Mixed workloads** - Balance read/write optimizations

Validation and Testing
~~~~~~~~~~~~~~~~~~~~~~

After each optimization phase:

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

Common Optimization Patterns by Workload
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Large File Sequential I/O (Data Processing)**

- Increase rsize/wsize to 1MB or larger
- Use nconnect=4-16 depending on server capability
- Enable read-ahead: ``echo 15360 > /sys/class/bdi/0:\*/read_ahead_kb``
- Consider disabling attribute caching for write-heavy: ``actimeo=0``

**Small File Metadata Operations (Compilation, Scripts)**

- Increase attribute cache times: acregmin=60,acdirmin=60
- Enable aggressive caching: lookupcache=all
- Test nordirplus for filename-only scanning workloads
- Enable client-side caching with fsc

**Mixed HPC Workloads**

- Use moderate buffer sizes: rsize=262144,wsize=262144
- Balance attribute caching: acregmin=10,acdirmin=30
- Enable multiple connections: nconnect=8
- Monitor and adjust based on dominant operation type

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

Benchmarking Tools
------------------

This section provides comprehensive benchmarking methodologies to evaluate NFS performance
and validate optimization efforts.

Performance Monitoring Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Automated Performance Tracking**

Create monitoring scripts to track NFS performance over time:

.. code-block:: bash

    #!/bin/bash
    # /usr/local/bin/nfs-monitor.sh
    
    LOGFILE="/var/log/nfs-performance.log"
    MOUNTPOINT="/mnt/nfs"
    
    # Function to log with timestamp
    log_metric() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> $LOGFILE
    }
    
    # Test sequential read performance
    read_perf=$(dd if=$MOUNTPOINT/testfile of=/dev/null bs=1M count=100 2>&1 | \
                grep -o '[0-9.]* MB/s')
    log_metric "sequential_read: $read_perf"
    
    # Test metadata operations
    meta_time=$(time (ls -la $MOUNTPOINT/large_dir > /dev/null) 2>&1 | \
                grep real | awk '{print $2}')
    log_metric "metadata_ops: $meta_time"
    
    # Check NFS statistics
    nfsstat -c | grep -E "read|write|getattr" | while read line; do
        log_metric "nfs_stat: $line"
    done
    
    # Check for errors
    error_count=$(dmesg | grep -c "nfs.*error\|rpc.*error")
    log_metric "error_count: $error_count"

Comprehensive Benchmark Suite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a standardized benchmark to compare configurations:

.. code-block:: bash

    #!/bin/bash
    # /usr/local/bin/nfs-benchmark.sh
    
    TESTDIR="/mnt/nfs/benchmark"
    RESULTS="/tmp/nfs-benchmark-$(date +%Y%m%d-%H%M%S).log"
    
    echo "NFS Benchmark Results - $(date)" > $RESULTS
    echo "Mount options: $(mount | grep $TESTDIR)" >> $RESULTS
    echo "=================================" >> $RESULTS
    
    # Test 1: Large file sequential I/O
    echo "Test 1: Sequential I/O" >> $RESULTS
    sync && echo 3 > /proc/sys/vm/drop_caches
    
    # Write test
    write_result=$(dd if=/dev/zero of=$TESTDIR/seq_write_test bs=1M count=1024 \
                   oflag=direct 2>&1 | grep -o '[0-9.]* MB/s')
    echo "Sequential write: $write_result" >> $RESULTS
    
    # Read test
    read_result=$(dd if=$TESTDIR/seq_write_test of=/dev/null bs=1M \
                  iflag=direct 2>&1 | grep -o '[0-9.]* MB/s')
    echo "Sequential read: $read_result" >> $RESULTS
    
    # Test 2: Random I/O with fio
    echo "Test 2: Random I/O" >> $RESULTS
    fio --name=random-rw --ioengine=libaio --iodepth=16 --rw=randrw \
        --rwmixread=70 --bs=4k --direct=1 --size=1G --numjobs=4 \
        --runtime=60 --group_reporting --directory=$TESTDIR \
        --output-format=normal,json --output=$TESTDIR/fio_results.json
    
    random_read=$(jq '.jobs[0].read.bw' $TESTDIR/fio_results.json)
    random_write=$(jq '.jobs[0].write.bw' $TESTDIR/fio_results.json)
    echo "Random read: ${random_read} KB/s" >> $RESULTS
    echo "Random write: ${random_write} KB/s" >> $RESULTS
    
    # Test 3: Metadata operations
    echo "Test 3: Metadata operations" >> $RESULTS
    mkdir -p $TESTDIR/metadata_test
    
    # File creation
    start_time=$(date +%s.%N)
    for i in {1..1000}; do touch $TESTDIR/metadata_test/file$i; done
    end_time=$(date +%s.%N)
    create_time=$(echo "$end_time - $start_time" | bc)
    echo "1000 file creates: ${create_time}s" >> $RESULTS
    
    # Directory listing
    start_time=$(date +%s.%N)
    ls -la $TESTDIR/metadata_test > /dev/null
    end_time=$(date +%s.%N)
    list_time=$(echo "$end_time - $start_time" | bc)
    echo "Directory listing: ${list_time}s" >> $RESULTS
    
    # Cleanup
    rm -rf $TESTDIR/metadata_test $TESTDIR/seq_write_test
    
    echo "Benchmark complete. Results in: $RESULTS"

Regression Testing
~~~~~~~~~~~~~~~~~~

Automate performance regression detection:

.. code-block:: bash

    #!/bin/bash
    # /usr/local/bin/nfs-regression-test.sh
    
    BASELINE_FILE="/var/lib/nfs-baseline.txt"
    THRESHOLD=10  # 10% performance degradation threshold
    
    # Run benchmark
    current_perf=$(/usr/local/bin/nfs-benchmark.sh | grep "Sequential read" | \
                   awk '{print $3}' | sed 's/MB\/s//')
    
    if [ -f "$BASELINE_FILE" ]; then
        baseline_perf=$(cat $BASELINE_FILE)
        degradation=$(echo "scale=2; (($baseline_perf - $current_perf) / $baseline_perf) * 100" | bc)
        
        if (( $(echo "$degradation > $THRESHOLD" | bc -l) )); then
            echo "ALERT: NFS performance degraded by ${degradation}%" | \
                 mail -s "NFS Performance Alert" admin@company.com
        fi
    else
        echo $current_perf > $BASELINE_FILE
        echo "Baseline established: ${current_perf} MB/s"
    fi

General Optimization Dimensions
-------------------------------

Understanding the various dimensions for NFS optimization is crucial before implementing
specific performance tuning strategies.

NFS Versions
~~~~~~~~~~~~

Understanding NFS version differences:

- **NFSv3**: Widely supported and stable, but has limitations with locking mechanisms
- **NFSv4.0**: Introduces improved locking mechanisms and supports ACLs, but may have
  compatibility issues with older servers
- **NFSv4.1**: Supports pNFS (parallel NFS), enabling parallel access across multiple
  servers for better performance
- **NFSv4.2**: Adds features like server-side copy, sparse files, and application data
  block support

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
~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~~~

Cachefilesd enables local caching of NFS files, significantly improving performance for
frequently accessed and infrequently changed data.

.. code-block:: bash

    systemctl enable --now cachefilesd

To enable caching for an NFS mount, add the ``fsc`` option to the mount command in
``/etc/fstab``.

.. code-block::

    your.nfs.server:/export /mount/point nfs defaults,fsc 0 0

Tuning Cachefilesd
*******************

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
~~~~~~~~~~~~~~~~~~~~~~

Commercial NFS implementations may offer additional features

- **Client-side buffered write**: Improves write performance through intelligent caching
- **Multi-path read**: Load balances reads across multiple network paths
- **Advanced caching**: More sophisticated caching algorithms than standard FS-Cache
- **Quality of Service**: Traffic prioritization and bandwidth management

Compatibility Considerations
****************************

When using proprietary NFS solutions

- Verify ``fsc`` compatibility with vendor-specific caching mechanisms
- Test interoperability with standard NFS clients
- Understand licensing implications for compute nodes
- Plan for failover and redundancy scenarios

Other Considerations
--------------------

This section covers additional factors that impact NFS performance and deployment in
production environments.

Performance and Security Trade-offs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Security measures can impact NFS performance. This section helps balance security
requirements with performance optimization.

**Kerberos Authentication**

Kerberos provides strong authentication but adds overhead:

.. code-block::

    # Basic Kerberos mount
    nfs.server:/export /mnt/secure nfs sec=krb5,rsize=1048576,wsize=1048576 0 0
    
    # Performance-optimized Kerberos mount
    nfs.server:/export /mnt/secure nfs \
        sec=krb5,rsize=1048576,wsize=1048576,nconnect=8, \
        acregmin=60,acdirmin=60,_netdev 0 0

Performance impact mitigation:

- Use ticket caching to reduce authentication overhead
- Increase attribute cache times to reduce authenticated metadata operations  
- Consider ``sec=krb5i`` only when data integrity is critical (adds ~15% overhead)
- Avoid ``sec=krb5p`` unless encryption in transit is required (adds ~25% overhead)

**TLS Encryption (NFSv4.2)**

For environments requiring encryption in transit:

.. code-block::

    # NFSv4.2 with TLS
    nfs.server:/export /mnt/encrypted nfs \
        vers=4.2,proto=tcp,port=2049,xprtsec=tls, \
        rsize=262144,wsize=262144,nconnect=4 0 0

Performance considerations:
- TLS adds CPU overhead for encryption/decryption
- Reduce buffer sizes to balance security and performance
- Monitor CPU utilization on both client and server
- Consider hardware acceleration for cryptographic operations

Best Practices for HPC Environments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Workload-Specific Configurations**

.. code-block::

    # Large File Processing (Genomics, Video, Scientific Data)
    # Optimized for >1GB files, sequential access
    nfs.server:/data /data nfs \
        rsize=1048576,wsize=1048576,nconnect=8,hard,timeo=50,retrans=2, \
        acregmin=300,acdirmin=300,lookupcache=all,fsc,_netdev 0 0

    # Software Development and Compilation
    # Optimized for many small files, metadata operations
    nfs.server:/src /src nfs \
        rsize=262144,wsize=262144,nconnect=4,hard,timeo=50,retrans=2, \
        acregmin=60,acdirmin=60,nordirplus,fsc,_netdev 0 0

    # Home Directories and User Data
    # Balanced configuration for mixed workloads
    nfs.server:/home /home nfs \
        rsize=262144,wsize=262144,nconnect=4,hard,timeo=50,retrans=2, \
        acregmin=30,acdirmin=30,lookupcache=all,_netdev 0 0

    # Read-Only Software and Reference Data
    # Optimized for read-only access with aggressive caching
    nfs.server:/software /software nfs \
        ro,rsize=1048576,nconnect=8,hard,timeo=50,retrans=2, \
        acregmin=3600,acdirmin=3600,lookupcache=all,fsc,noatime,_netdev 0 0

**Integration with Job Schedulers**

For Slurm and other job schedulers:

.. code-block:: bash

    # Example job script with NFS optimization
    #!/bin/bash
    #SBATCH --job-name=nfs_optimized_job
    #SBATCH --time=04:00:00
    #SBATCH --nodes=1
    
    # Verify NFS mount before job starts
    if ! mountpoint -q /shared/data; then
        echo "ERROR: NFS mount not available"
        exit 1
    fi
    
    # Pre-load data into local cache if using client-side caching
    if mount | grep -q "fsc"; then
        find /shared/data/input -type f -exec cat {} > /dev/null \;
    fi
    
    # Run application with optimized temporary directory
    export TMPDIR=/dev/shm
    ./my_application --input-dir=/shared/data/input --output-dir=/shared/data/output

**Capacity Planning and Scaling**

When performance limits are reached:

1. **Horizontal Scaling**:
   - Add multiple NFS servers with load balancing
   - Use different mounts for different workload types
   - Implement client-side load distribution

2. **Vertical Scaling**:
   - Upgrade network infrastructure (1GbE → 10GbE → 100GbE)
   - Increase server resources (CPU, memory, storage)
   - Optimize server-side NFS configuration

3. **Alternative Solutions**:
   - Consider parallel file systems (Lustre, BeeGFS)
   - Implement object storage for unstructured data
   - Use local caching solutions (bcache, dm-cache)

Common Pitfalls and Solutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Pitfall**: Applying all optimizations without testing
**Solution**: Use iterative optimization with performance measurement at each step

**Pitfall**: Using same mount options for all workloads
**Solution**: Create workload-specific mounts with appropriate optimizations

**Pitfall**: Ignoring server-side bottlenecks
**Solution**: Monitor both client and server performance; coordinate tuning efforts

**Pitfall**: Not monitoring for regression
**Solution**: Implement automated performance tracking and alerting

**Pitfall**: Over-optimizing for benchmarks vs. real workloads
**Solution**: Test with actual application workloads, not just synthetic benchmarks

Troubleshooting
---------------

This section provides comprehensive troubleshooting guidance for various NFS issues
beyond just performance problems.

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
       mount -o hard,timeo=50,retrans=3,intr nfs.server:/export /mnt/nfs

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~

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
