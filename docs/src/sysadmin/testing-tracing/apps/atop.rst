====
Atop
====

Atop is an advanced system and process monitor for Linux providing comprehensive resource utilization tracking. This document describes atop's role in HPC system validation and diagnostic workflows.

.. contents::
   :local:
   :depth: 2

Learning Curve
==============

**Difficulty: Medium**

Atop's setup is straightforward - package installation and service activation complete within minutes. The learning challenge lies elsewhere: mastering the extensive command set for different diagnostic scenarios. Atop provides dozens of interactive commands for view switching, process filtering, resource sorting, and time navigation. Becoming proficient with these options requires hands-on practice and reference to documentation.

System administrators may initially feel overwhelmed by the interface density and command variety. This is normal. Start with basic real-time observation (``atop`` with default view), then gradually explore historical log analysis (``atop -r``) and view switching (``m`` for memory, ``d`` for disk, ``n`` for network). Competency develops through repeated use across actual diagnostic scenarios rather than memorizing all available commands upfront.

Overview
========

Atop is a full-screen performance monitor combining real-time resource observation with persistent logging capabilities. Unlike traditional monitoring tools such as ``top``, atop records all process activity to disk, enabling post-mortem analysis of historical system states.

**Key capabilities:**

- **Comprehensive resource tracking:** CPU, memory, swap, disk I/O, network utilization at system and per-process granularity
- **Finished process accounting:** Records resource consumption of processes that completed during measurement intervals
- **Persistent logging:** Daily compressed logs enable historical analysis (default 28-day retention)
- **Per-process network statistics:** With optional ``netatop`` kernel module, tracks TCP/UDP packets and bandwidth per process
- **cgroup-aware monitoring:** Displays resource utilization and pressure (PSI) at cgroup level
- **Visual indicators:** Color-coded highlighting of critical resource saturation

Advantages over ``top``
------------------------

Atop provides significant operational advantages compared to traditional process monitors:

**Historical analysis capability:**
  Traditional tools like ``top`` display only current state. Atop's persistent logging enables post-mortem investigation: "What consumed resources during yesterday's job failure?"

**Complete process accounting:**
  Short-lived processes often complete between ``top`` refresh intervals, remaining invisible. Atop records all process activity within each interval, including finished processes.

**Multi-resource coverage:**
  ``top`` primarily focuses on CPU and memory. Atop integrates disk I/O, network statistics, and per-process network tracking (with ``netatop``), providing comprehensive system observability.

**Flexible aggregation:**
  Atop supports runtime aggregation by user or program name, simplifying multi-user HPC system analysis.

Purpose in Validation Framework
================================

Atop serves the **Logging** category in HPC validation workflows (see :doc:`../index`). It provides persistent records enabling post-mortem analysis of system behavior during operational issues.

**Position in diagnostic workflow:**

1. **User reports issue:** "My job was slow yesterday at 14:30"
2. **Atop backtracking:** Review 10-minute interval logs from 14:20-14:40
3. **Subsystem identification:** Determine resource saturation (CPU/memory/disk/network)
4. **Targeted investigation:** Use identified subsystem to guide deeper tracing (see :doc:`../tracing`)

**What atop provides:**

  Atop is an ASCII full-screen performance monitor for Linux that is capable of reporting the activity of all processes (even if processes have finished during the interval), daily logging of system and process activity for long-term analysis, highlighting overloaded system resources by using colors, etc. At regular intervals, it shows system-level activity related to the CPU, memory, swap, disks (including LVM) and network layers, and for every process (and thread) it shows e.g. the CPU utilization, memory growth, disk utilization, priority, username, state, and exit code.
  In combination with the optional kernel module netatop, it even shows network activity per process/thread.

  The command atop has some major advantages compared to other performance monitoring tools:**What atop provides:**

- **10-minute interval snapshots (configurable):** Default 600-second interval (``LOGINTERVAL`` in ``/usr/share/atop/atop.daily``) provides sufficient granularity for most operational diagnostics without excessive storage overhead. Adjustable to finer resolution at the cost of increased system overhead and storage consumption.
- **Subsystem localization:** Identifies which resource (CPU/memory/disk/network) exhibits anomalous behavior
- **User attribution:** Tracks resource consumption per user, enabling identification of problematic workloads
- **Crash-surviving logs:** Persistent storage ensures data availability even after system failures

**What atop doesn't provide:**

- **Sub-interval resolution:** Transient issues lasting seconds may not appear in interval snapshots (default 10 minutes). Finer intervals can be configured but introduce trade-offs: increased system intrusiveness, higher storage requirements, and more CPU overhead for data collection and compression.
- **Code-level detail:** Identifies resource saturation but not specific functions or system calls - use tracing tools (strace, perf) for deeper analysis
- **Real-time alerting:** Historical logging tool, not monitoring - use Prometheus/Grafana for real-time alerts

Installation and Configuration
===============================

Atop consists of two components: the core monitoring tool and the optional ``netatop`` kernel module for per-process network statistics.

Package Installation
--------------------

**RHEL/Rocky/AlmaLinux:**

.. code-block:: bash

   # Install core atop package
   dnf install atop

**Debian/Ubuntu:**

.. code-block:: bash

   # Install core atop package
   apt install atop

Persistent Logging Configuration
---------------------------------

Atop requires systemd service activation to enable persistent logging. Without this configuration, atop functions only as a real-time monitoring tool.

.. code-block:: bash

   # Enable and start atop logging service
   systemctl enable --now atop
   
   # Verify service status
   systemctl status atop
   
   # Check log directory
   ls -lh /var/log/atop/

**Log retention configuration:**

**Log retention and interval configuration:**

Default retention is 28 days with 600-second (10-minute) intervals. Modify ``/usr/share/atop/atop.daily`` to adjust:

.. code-block:: bash

   # Retention period (number of daily logs to retain)
   LOGGENERATIONS=28
   
   # Sampling interval in seconds (default 600 = 10 minutes)
   LOGINTERVAL=600       # Reduce for finer granularity, increase for lower overhead

**Configuration trade-offs:**

- **Lower intervals (e.g., 60s, 120s):** Capture transient issues, but increase CPU overhead, storage consumption, and system intrusiveness
- **Higher intervals (e.g., 900s, 1800s):** Reduce overhead and storage, but risk missing short-duration anomalies

The default 10-minute interval balances diagnostic utility with operational overhead for most HPC environments.

**Log storage requirements:**

Compressed atop logs typically consume 10-50 MB per day per system, varying with system activity and process count. For a 28-day retention period, allocate approximately 1-2 GB per system.

netatop Kernel Module (Optional)
---------------------------------

**Note:** The ``netatop`` kernel module enables per-process network statistics - showing which process sends/receives network traffic. This requires kernel module compilation and loading, making it more involved than base atop installation. Most HPC diagnostic scenarios don't require per-process network attribution; system-level and per-interface network statistics (available without netatop) suffice for identifying network saturation or interface issues.

**Skip netatop unless:**

- You need to identify which specific process generates network traffic
- Per-process network I/O attribution is critical for your use case
- System-level network statistics prove insufficient for diagnostics

If per-process network accounting is required, installation proceeds as follows.

**RHEL/Rocky/AlmaLinux:**

.. code-block:: bash

   # Install kernel development prerequisites
   dnf install kernel-devel kernel-headers dkms gcc make
   
   # Install netatop (if available in repositories)
   dnf install netatop
   
   # Alternatively, build from source
   git clone https://github.com/Atoptool/netatop.git
   cd netatop
   make
   make install
   
   # Load kernel module
   modprobe netatop
   
   # Enable automatic module loading at boot
   echo "netatop" > /etc/modules-load.d/netatop.conf

**Verification:**

.. code-block:: bash

   # Verify netatop kernel module is loaded
   lsmod | grep netatop
   
   # Launch atop and press 'n' for network view
   # Per-process network columns (packets, bandwidth) should populate
   atop -n 1

Real-time System Monitoring
============================

Atop's interactive mode provides real-time system observation with customizable views and filtering. Launch atop without arguments for default view:

.. code-block:: bash

   atop

Interactive Philosophy
-----------------------

**Use atop like vim, not like sed/awk.** While command-line flags preset the initial view, atop's power lies in runtime interactivity. You don't specify all view parameters upfront - instead, launch atop with basic options and navigate views dynamically through keyboard commands.

**Example workflow:**

.. code-block:: bash

   # Start with general memory-focused view
   atop -f -m -A -1 1
   
   # Then interactively modify:
   # Press 'p' -> aggregates by program name (changes from -m memory detail to program view)
   # Press 'u' -> aggregates by user (switches to per-user resource totals)
   # Press 'C' -> sorts by CPU instead of activity (overrides -A)
   # Press 'd' -> switches to disk view (replaces -m memory focus)

This approach enables exploratory analysis: start broad, then drill into specific resources, users, or processes as patterns emerge. Command-line flags establish initial orientation; interactive commands adapt views to evolving diagnostic needs.

Command-Line Options by Category
---------------------------------

Command-line options establish the initial view and behavior. All can be overridden interactively at runtime.

**Activity focus (select resource view):**

.. code-block:: bash

   atop -f      # Full system panel (all subsystems visible)
   atop -m      # Memory-focused view
   atop -d      # Disk I/O-focused view
   atop -n      # Network-focused view (requires netatop kernel module)
   atop -s      # Scheduling information (priority, nice, state)
   atop -v      # Various details (PPID, user/group, timestamps)
   atop -c      # Full command lines

**Sorting (process ordering):**

.. code-block:: bash

   atop -C      # Sort by CPU consumption (default)
   atop -M      # Sort by memory consumption
   atop -D      # Sort by disk I/O activity
   atop -N      # Sort by network I/O (requires netatop)
   atop -A      # Automatic sorting by most active resource

**Aggregation and filtering:**

.. code-block:: bash

   atop -u      # Aggregate by user (show per-user totals)
   atop -p      # Aggregate by program name (group identical commands)

**Display options:**

.. code-block:: bash

   atop -1      # Show per-second averages instead of interval totals
   atop -a      # Show all processes (including inactive)
   atop -y      # Show threads within processes
   
   atop 5       # Update every 5 seconds (last argument = interval)

**Common combinations:**

.. code-block:: bash

   # Memory investigation with per-second updates
   atop -f -m -A -1 1
   
   # Per-user CPU usage
   atop -u -C 2
   
   # Disk activity by program
   atop -p -D -1 1

Interactive Commands
--------------------

Atop supports runtime view switching via keyboard shortcuts:

**Resource view selection:**

- ``g``: Generic (default) - CPU and memory overview
- ``m``: Memory details - detailed memory consumption
- ``d``: Disk details - per-disk I/O statistics
- ``n``: Network details - network interface and per-process network (if netatop loaded)
- ``s``: Scheduling information - priority, policy, state
- ``v``: Various details - PPID, user/group, timestamps
- ``c``: Command line - full process command lines

**Process sorting:**

- ``C``: Sort by CPU consumption
- ``M``: Sort by memory consumption
- ``D``: Sort by disk I/O
- ``N``: Sort by network I/O (requires netatop)
- ``A``: Sort by overall activity (automatic)

**Process filtering:**

- ``u``: Aggregate by user - show per-user resource totals
- ``p``: Aggregate by program name - show per-application totals
- ``U``: Filter by specific user (prompts for username)
- ``P``: Filter by specific program (prompts for program name)

**Navigation:**

- ``t``: Forward in time (when viewing logs)
- ``T``: Backward in time (when viewing logs)
- ``b``: Jump to specific timestamp (when viewing logs)
- ``q``: Quit

Understanding the System Resource Panel
========================================

The system resource panel (upper portion of atop's display) provides subsystem-level metrics critical for HPC diagnostics. This section explains each line using real output from a production system. Understanding these metrics enables rapid identification of resource bottlenecks and system behavior anomalies.

Example Output
--------------

The following output demonstrates a typical system snapshot (condensed for clarity):

.. code-block:: text

   PRC | sys    0.79s | user   4.57s | #proc   2136 | #trun      6 | #tslpi  4431 | 
       | #tslpu   542 | #zombie    2 | clones  18/s | no  procacct |
   
   CPU | sys      83% | user    459% | irq       9% | idle   9139% | wait      1% | 
       | steal     0% | guest     0% | curf 1.41GHz | numcpu    96 |
   
   CPL | avg1    7.28 | avg5    7.82 | avg15   7.72 | csw  50710/s | intr 37527/s | 
       | numcpu    96 |
   
   MEM | tot   251.4G | free   19.3G | cache  74.8G | dirty  28.7M | buff   17.9M | 
       | slab  118.0G | slrec 109.6G | shmem 409.8M | shrss   0.0M | shswp   0.0M | 
       | numnode    2 |
   
   SWP | tot   242.1G | free  153.8G | swcac   1.6G | vmcom 486.9G | vmlim 367.8G |
   
   PAG | scan     0/s | steal    0/s | stall    0/s | compact  0/s | numamig  0/s | 
       | migrate  0/s | swin     0/s | swout    0/s | oomkill  0/s |
   
   DSK | nvme0n1     | busy      0% | read     0/s | write    0/s | KiB/r      0 | 
       | KiB/w      0 | MBr/s    0.0 | MBw/s    0.0 | avq     0.00 | avio  0.0 ns |
   
   NFM | /hpc4project| srv sc-hpc4- | read   23K/s | write  39K/s | nread  19K/s | 
       | nwrit 3.0M/s | dread 0.0K/s | dwrit 0.0K/s | mread  24K/s | mwrit  40K/s |
   
   NFC | rpc   5905/s | read     2/s | write    1/s | retxmit  0/s | autref 6e3/s |
   
   NET | transport   | tcpi  7609/s | tcpo  7108/s | udpi     0/s | udpo     0/s | 
       | tcpao    1/s | tcppo    1/s | tcprs    0/s | tcpie    0/s | tcpor    0/s | 
       | udpnp    0/s | udpie    0/s |
   
   NET | network     | ipi   7609/s | ipo   7101/s | ipfrw    0/s | deliv 7609/s | 
       | icmpi    0/s | icmpo    0/s |
   
   NET | enp161s  0% | pcki  5912/s | pcko  5931/s | sp  100 Gbps | si 8809 Kbps | 
       | so 9324 Kbps | coll     0/s | mlti     0/s | erri     0/s | erro     0/s | 
       | drpi     0/s | drpo     0/s |
   
   IFB | mlx5_0/1 0% | pcki     0/s | pcko     0/s | sp  100 Gbps | si    0 Kbps | 
       | so    0 Kbps | lanes      4 |

Process Information (PRC Line)
-------------------------------

The PRC line reports process lifecycle metrics:

- ``sys 0.79s``: Total system (kernel) CPU time consumed during interval
- ``user 4.57s``: Total user-space CPU time consumed during interval
- ``#proc 2136``: Total number of processes tracked (includes finished processes)
- ``#trun 6``: Currently running processes (actively executing on CPU)
- ``#tslpi 4431``: Interruptible sleep - processes waiting for I/O, events, or timers (normal idle state)
- ``#tslpu 542``: Uninterruptible sleep - processes blocked on disk I/O or other kernel operations (high values may indicate I/O bottlenecks)
- ``#zombie 2``: Zombie processes - terminated but parent hasn't collected exit status (usually harmless unless persistent)
- ``clones 18/s``: Process/thread creation rate per second
- ``no procacct``: Process accounting disabled (``procacct`` would show if enabled for tracking finished processes)

**Diagnostic hints:**

- High ``#tslpu`` suggests disk I/O saturation - investigate DSK lines
- Persistent zombies may indicate misbehaving parent processes
- High clone rates with low CPU utilization might suggest excessive process creation overhead

CPU Utilization (CPU Line)
---------------------------

The CPU line shows aggregate CPU activity across all cores (percentages sum to ``numcpu * 100``):

- ``sys 83%``: System/kernel time - 83% of one CPU (0.83 cores) in kernel mode
- ``user 459%``: User-space application time - 459% means 4.59 cores actively running user code
- ``irq 9%``: Hardware interrupt handling - 0.09 cores servicing interrupts
- ``idle 9139%``: Idle time - 91.39 cores doing nothing (96-core system mostly idle)
- ``wait 1%``: I/O wait - 0.01 cores waiting for disk I/O (negligible)
- ``steal 0%``: Stolen time in virtualized environments (CPU cycles taken by hypervisor) - not applicable to bare metal
- ``guest 0%``: Time spent running guest VMs (if this machine is a hypervisor)
- ``curf 1.41GHz``: Current average CPU frequency - shows power management state (max frequency might be 2.5-3.0 GHz)
- ``numcpu 96``: Total logical CPUs (cores × threads/core)

**Diagnostic hints:**

- Low ``curf`` with high idle suggests CPU power management - may affect latency-sensitive workloads
- High ``sys%`` relative to ``user%`` indicates kernel overhead (context switching, system calls, interrupt handling)
- Non-zero ``wait%`` with high DSK busy suggests I/O bottleneck
- For this example: 5.5 cores utilized (4.59 user + 0.83 sys + 0.09 irq) out of 96 = ~6% utilization

CPU Load and Context (CPL Line)
--------------------------------

The CPL line provides load averages and context switching metrics:

- ``avg1 7.28``, ``avg5 7.82``, ``avg15 7.72``: Load averages over 1/5/15 minutes - number of processes in run queue (running + waiting to run). On a 96-core system, load of 7-8 indicates light utilization.
- ``csw 50710/s``: Context switches per second - kernel switching between threads/processes
- ``intr 37527/s``: Hardware interrupts per second - device interrupt rate
- ``numcpu 96``: Total logical CPUs (repeated from CPU line)

**Diagnostic hints:**

- Load average interpretation: divide by ``numcpu`` for utilization estimate (7.72/96 = 8% utilized) - though this is crude approximation
- Extremely high ``csw`` (>100k/s on lightly loaded systems) may indicate excessive thread contention, lock contention, or scheduler thrashing - but "extremely high" is workload-dependent. Some applications naturally exhibit high context switching rates.
- High ``intr`` rates (>1M/s) might suggest network packet processing load or device interrupt storms - though precise thresholds vary by hardware
- For HPC: Load averages lose meaning during batch job scheduling - instantaneous CPU utilization (CPU line) more informative. Load average thresholds developed for interactive systems don't translate directly to HPC batch environments.

Memory Utilization (MEM Line)
------------------------------

The MEM line reports physical memory allocation:

- ``tot 251.4G``: Total physical RAM installed
- ``free 19.3G``: Unused memory (neither allocated nor cached) - truly idle RAM
- ``cache 74.8G``: Page cache - filesystem data cached in RAM (reclaimable if applications need memory)
- ``dirty 28.7M``: Dirty pages - modified file data awaiting writeback to disk
- ``buff 17.9M``: Buffer cache - block device metadata cached
- ``slab 118.0G``: Kernel slab allocator - kernel data structures and caches (huge value suggests extensive kernel caching)
- ``slrec 109.6G``: Reclaimable slab memory - kernel caches that can be freed under pressure
- ``shmem 409.8M``: Shared memory (``tmpfs`` mounts, POSIX shared memory)
- ``shrss 0.0M``, ``shswp 0.0M``: Shared memory RSS and swapped (typically zero without heavy ``tmpfs`` usage)
- ``numnode 2``: NUMA nodes in system

**Diagnostic hints:**

- Low ``free`` is normal - Linux caches aggressively. Check ``cache + slrec`` for reclaimable memory.
- High ``dirty`` (multiple GB) may indicate write-heavy workload or slow disk writeback
- Large ``slab`` with small ``slrec`` suggests kernel memory pressure or memory leaks in kernel modules - though interpretation depends on workload. Some applications (databases, scientific computing with large datasets) legitimately cause extensive kernel caching.
- Memory accounting arithmetic can be confusing: ``slrec`` is a subset of ``slab``, not additive. Available memory roughly equals ``free + cache + slrec``, though precise calculation involves additional kernel accounting details we haven't fully enumerated here.

Swap Utilization (SWP Line)
----------------------------

The SWP line shows swap space usage:

- ``tot 242.1G``: Total configured swap space
- ``free 153.8G``: Unused swap space
- ``swcac 1.6G``: Swap cache - previously swapped pages read back but kept in swap (allows fast re-swapping)
- ``vmcom 486.9G``: Committed virtual memory - total memory applications *could* use if fully allocated (overcommit allowed)
- ``vmlim 367.8G``: Virtual memory limit - maximum committable memory based on overcommit policy

**Diagnostic hints:**

- Swap usage (88.3G = 242.1 - 153.8) indicates memory pressure at some point
- ``vmcom > vmlim`` shows overcommit policy allows applications to request more memory than physically available
- Active swapping (tracked in PAG line) causes severe performance degradation - swap usage alone doesn't indicate current problems, but swap *activity* does

Paging Activity (PAG Line)
---------------------------

The PAG line tracks memory management operations:

- ``scan 0/s``, ``steal 0/s``: Memory reclamation activity - kernel scanning for reclaimable pages
- ``stall 0/s``: Direct reclaim stalls - processes blocked waiting for memory reclamation (severe performance impact)
- ``compact 0/s``: Memory compaction attempts to create contiguous memory regions
- ``numamig 0/s``, ``migrate 0/s``: NUMA page migration - kernel moving pages between NUMA nodes for optimization
- ``swin 0/s``, ``swout 0/s``: Swap in/out rates - pages read from/written to swap
- ``oomkill 0/s``: Out-of-memory killer invocations - processes terminated due to memory exhaustion

**Diagnostic hints:**

- Non-zero ``scan/steal/stall`` indicates memory pressure - system struggling to allocate memory
- Active ``swin/swout`` causes severe performance degradation (swap is ~1000x slower than RAM)
- ``oomkill > 0`` means kernel killed processes to free memory - critical memory exhaustion
- All zeros (as shown) indicates healthy memory state despite swap usage

Disk I/O (DSK Lines)
---------------------

Each DSK line reports per-device I/O metrics:

- ``nvme0n1``: Device name
- ``busy 0%``: Percentage of time device had outstanding I/O requests
- ``read 0/s``, ``write 0/s``: I/O operations per second
- ``KiB/r 0``, ``KiB/w 0``: Average KB per read/write operation
- ``MBr/s 0.0``, ``MBw/s 0.0``: Read/write throughput in MB/s
- ``avq 0.00``: Average queue length - pending I/O requests
- ``avio 0.0 ns``: Average I/O service time in nanoseconds

**Diagnostic hints:**

- ``busy 100%`` indicates disk saturation - I/O bound workload
- High ``avq`` (>2-3) with high ``busy`` confirms queuing delays
- High ``avio`` (>10ms for SSD, >10ms for HDD) suggests slow device or contention
- Example shows idle disks (all metrics zero)

NFS Metrics (NFM, NFC, NFS Lines)
----------------------------------

NFS lines appear when NFS mounts are active:

**NFM (NFS mount)** - per-mount statistics:

- ``/hpc4project``: Mount point
- ``srv sc-hpc4-``: NFS server hostname (truncated)
- ``read 23K/s``, ``write 39K/s``: Application-level read/write rates
- ``nread 19K/s``, ``nwrit 3.0M/s``: Normal (buffered) I/O rates
- ``dread 0.0K/s``, ``dwrit 0.0K/s``: Direct I/O bypass page cache
- ``mread 24K/s``, ``mwrit 40K/s``: Metadata operations (stat, lookup, etc.)

**NFC (NFS client)** - aggregate client statistics:

- ``rpc 5905/s``: Total RPC calls per second to all NFS servers
- ``read 2/s``, ``write 1/s``: NFS read/write operations (not bytes - operations)
- ``retxmit 0/s``: RPC retransmissions - network issues or server timeout
- ``autref 6e3/s``: Authentication refresh operations (Kerberos ticket renewal, etc.)

**NFS (NFS server)** - appears if this machine exports NFS:

- Similar structure to NFM but from server perspective

**Diagnostic hints:**

- High ``retxmit`` indicates network problems or server unresponsiveness
- Large discrepancy between ``read/write`` and ``nread/nwrit`` might indicate caching effectiveness
- High ``autref`` rates can impact performance if authentication infrastructure is slow

Network Traffic (NET Lines)
----------------------------

Multiple NET lines show different network layers:

**Transport layer (tcp/udp)**:

- ``tcpi 7609/s``, ``tcpo 7108/s``: TCP packets in/out per second
- ``udpi 0/s``, ``udpo 0/s``: UDP packets in/out per second
- ``tcpao 1/s``, ``tcppo 1/s``: TCP active/passive connection opens (new connections)
- ``tcprs 0/s``: TCP retransmit segments - indicates network packet loss
- ``tcpie 0/s``, ``tcpor 0/s``: TCP errors (input errors, output resets)
- ``udpnp 0/s``, ``udpie 0/s``: UDP errors (no port listening, input errors)

**Network layer (ip/icmp)**:

- ``ipi 7609/s``, ``ipo 7101/s``: IP packets in/out per second
- ``ipfrw 0/s``: IP forwarded packets (routing/forwarding)
- ``deliv 7609/s``: IP packets delivered to upper layer protocols
- ``icmpi 0/s``, ``icmpo 0/s``: ICMP packets in/out (ping, errors)

**Per-interface statistics**:

- ``enp161s 0%``: Interface name and utilization percentage
- ``pcki 5912/s``, ``pcko 5931/s``: Packets in/out per second
- ``sp 100 Gbps``: Interface speed (link capacity)
- ``si 8809 Kbps``, ``so 9324 Kbps``: Bandwidth in/out - ~9 Mbps on 100 Gbps link = 0.009% utilization
- ``coll 0/s``: Collisions (obsolete for switched networks)
- ``mlti 0/s``: Multicast packets
- ``erri 0/s``, ``erro 0/s``: Input/output errors
- ``drpi 0/s``, ``drpo 0/s``: Dropped packets (buffer overflow, filtering)

**Diagnostic hints:**

- Non-zero ``tcprs`` indicates packet loss - check network infrastructure
- High ``erri/erro`` suggests hardware issues (cable, NIC)
- Packet drops (``drpi/drpo``) might indicate insufficient buffers or firewall dropping
- Compare ``si/so`` to ``sp`` for utilization - this interface is nearly idle

InfiniBand/RDMA (IFB Lines)
----------------------------

**Critical for HPC:** IFB lines show InfiniBand/RDMA network activity, which carries most HPC inter-node communication. Unlike TCP/IP (NET lines), RDMA bypasses kernel networking stack for lower latency and higher throughput.

**IFB line fields**:

- ``mlx5_0/1 0%``: InfiniBand device and port, utilization percentage
- ``pcki 0/s``, ``pcko 0/s``: Packets in/out per second
- ``sp 100 Gbps``: Port speed
- ``si 0 Kbps``, ``so 0 Kbps``: Bandwidth in/out
- ``lanes 4``: Physical lanes (4x EDR = 100 Gbps, 4x HDR = 200 Gbps, etc.)

**Diagnostic importance:**

In HPC clusters, MPI communication uses RDMA (IFB lines) rather than TCP/IP (NET lines). When diagnosing MPI job performance issues, check IFB utilization - saturated RDMA links appear as high ``si/so`` bandwidth and high utilization percentage. NET lines may show minimal activity while IFB carries heavy MPI traffic.

**Example shows idle RDMA:** Zero packet rates and bandwidth indicate no active MPI communication during this snapshot.

Process Panel (Lower Section)
------------------------------

Below the system resource panel, atop displays per-process or aggregated resource consumption. Column interpretation depends on active view (``-m`` for memory, ``-d`` for disk, ``-n`` for network, etc.).

**Example process output (memory view):**

.. code-block:: text

       PID    TID  MINFLT  MAJFLT  VSTEXT  VSLIBS   VDATA  VSTACK   VSIZE   RSIZE  PSIZE  VGROW  RGROW  SWAPSZ   RUID    EUID   CPU%  CMD
   2250991      -     0/s     0/s   2.3M   76.5M   14.8G   152K    15.0G    2.7G     0B     0B     0B      0B  hemraj  hemraj   101%  python3
   2253815      -     0/s     0/s   2.3M   76.5M   14.8G   152K    15.0G    2.7G     0B     0B     0B      0B  hemraj  hemraj   101%  python3
   1508752      -     0/s     0/s   2.0M  655.0M    4.6G   180K     7.5G  680.4M     0B     0B     0B      0B  kezdy   kezdy      0%  tensorboard

**Column explanations:**

- ``PID``: Process ID
- ``TID``: Thread ID (``-`` for process-level aggregation, specific number when ``-y`` shows threads)
- ``MINFLT``: Minor page faults per second - access to swapped-out page cache (no disk I/O)
- ``MAJFLT``: Major page faults per second - requires disk I/O to load pages
- ``VSTEXT``: Virtual memory for executable code
- ``VSLIBS``: Virtual memory for shared libraries
- ``VDATA``: Virtual memory for heap and data segments
- ``VSTACK``: Virtual memory for thread stacks
- ``VSIZE``: Total virtual memory (sum of above + other mappings)
- ``RSIZE``: Resident set size - physical RAM actually used
- ``PSIZE``: Proportional set size - shared memory divided among processes (if ``-R`` flag enabled)
- ``VGROW``, ``RGROW``: Virtual/resident memory growth since last interval
- ``SWAPSZ``: Memory swapped to disk for this process
- ``RUID``, ``EUID``: Real and effective user IDs
- ``CPU%``: CPU utilization - 101% means 1.01 cores utilized
- ``CMD``: Command name

**Diagnostic examples:**

- ``python3`` processes: Each uses ~2.7G RAM (``RSIZE``), 15G virtual space (``VSIZE``), consuming ~1 CPU core (``101%``)
- ``tensorboard``: Using 680M RAM, mostly idle (``0%`` CPU), large library footprint (655M ``VSLIBS``)

Understanding these process-level metrics helps identify potential issues like memory leaks (increasing ``RSIZE`` over time) or excessive memory allocation (high ``VSIZE`` with low ``RSIZE``). However, interpretation requires understanding application behavior - some patterns that appear anomalous reflect legitimate workload characteristics. When uncertain, correlate atop observations with application-specific knowledge or developer consultation.

Example: Memory-Focused System Observation
-------------------------------------------

For investigating memory pressure, launch memory-focused view and observe MEM/SWP/PAG lines:

.. code-block:: bash

   atop -f -m -A -1 1

.. code-block:: bash

   atop -m -A -1 1

Output interpretation:

.. code-block:: console

   MEM | tot   251.4G | free   19.3G  | cache  74.8G | dirty  28.7M | ...
   SWP | tot   242.1G | free  153.8G  | swcac   1.6G | ...
   
       PID       VSIZE    RSIZE    PSIZE    VGROW    RGROW    SWAPSZ    CMD
   1234567       15.0G     2.7G       0B       0B       0B        0B    python3
   1234568       15.0G     2.7G       0B       0B       0B        0B    python3

**Key observations:**

- ``MEM free 19.3G``: 19.3 GB unused memory available
- ``cache 74.8G``: 74.8 GB used for filesystem cache
- ``VSIZE``: Virtual memory size (address space allocated)
- ``RSIZE``: Resident memory size (physical RAM in use)
- ``SWAPSZ``: Memory swapped to disk

Historical Backtracking
========================

Atop's primary operational value lies in post-mortem analysis of past system states. When the ``atop.service`` is enabled, logs are written to ``/var/log/atop/atop_YYYYMMDD`` at 10-minute intervals.

Accessing Historical Logs
--------------------------

**Basic log replay:**

.. code-block:: bash

   # View logs from specific date
   atop -r /var/log/atop/atop_20260117
   
   # Navigate: press 't' to advance forward, 'T' to go backward
   # Each press advances/retreats one 10-minute interval

**Time-range queries:**

.. code-block:: bash

   # View specific time range (24-hour format)
   atop -r /var/log/atop/atop_20260117 -b 14:20 -e 14:40
   
   # Alternative timestamp format
   atop -r /var/log/atop/atop_20260117 -b 2026011714:20 -e 2026011714:40

**With view flags:**

.. code-block:: bash

   # Memory-focused backtracking
   atop -r /var/log/atop/atop_20260117 -b 14:20 -e 14:40 -m -A -1
   
   # Disk I/O backtracking
   atop -r /var/log/atop/atop_20260117 -b 14:20 -e 14:40 -d -1

Post-Mortem Analysis Workflow
------------------------------

**Typical diagnostic scenario:**

1. **User reports issue:** "Job failed yesterday at 14:30 with out-of-memory error"

2. **Identify relevant time window:** Job likely encountered problems 10-20 minutes before failure

3. **Review atop logs for time range:**

   .. code-block:: bash

      atop -r /var/log/atop/atop_20260117 -b 14:10 -e 14:40 -m -A -1

4. **Navigate through intervals:** Press ``t`` to advance through 10-minute snapshots

5. **Identify resource saturation patterns:**
   
   - Memory: Look for declining ``free`` memory, increasing swap usage
   - CPU: Sustained high ``sys`` or ``user`` percentages
   - Disk: High ``busy%`` or large ``avq`` (average queue length)
   - Network: Packet loss (``drpi/drpo``), interface saturation

6. **Identify problematic processes:**
   
   - Sort by resource type (``M`` for memory, ``D`` for disk, ``N`` for network)
   - Note PID, username, command for investigation
   - Check ``VGROW/RGROW`` columns for memory growth patterns

7. **Correlate with other logs:**
   
   .. code-block:: bash

      # Check kernel logs for OOM events or hardware errors
      journalctl --since "2026-01-17 14:10:00" --until "2026-01-17 14:40:00"
      
      # Check SLURM logs for job termination reason
      sacct -j <jobid> --format=JobID,JobName,State,ExitCode,Comment

Aggregation for Multi-User Systems
-----------------------------------

For HPC systems with many concurrent users, per-user aggregation simplifies analysis:

**During log replay, press ``u`` to aggregate by user:**

This consolidates all processes for each user into single rows, showing cumulative resource consumption.

**Filter by specific user (press ``U``, then enter username):**

Displays only processes belonging to specified user, removing noise from other users' workloads.

**Aggregate by program name (press ``p``):**

Groups all instances of same program (e.g., all ``python`` processes), useful for identifying resource-intensive applications.

Practical Workflows
===================

Diagnosing Job Performance Issues
----------------------------------

**Scenario:** User reports "My MPI job ran slower than expected yesterday"

**Workflow:**

1. Identify job runtime from SLURM logs:

   .. code-block:: bash

      sacct -j <jobid> --format=JobID,Start,End,Elapsed,NCPUS,NNodes

2. Review atop logs for job duration with CPU focus:

   .. code-block:: bash

      atop -r /var/log/atop/atop_<date> -b <start_time> -e <end_time> -1

3. Check for resource contention indicators:

   - **CPU:** High ``wait%`` suggests I/O blocking - investigate disk subsystem
   - **Memory:** Increasing swap activity suggests memory pressure - check process ``RSIZE``
   - **Network:** High latency or retransmits - investigate network fabric
   - **Disk:** High ``busy%`` or ``avio`` (average I/O time) - storage bottleneck

4. If atop shows normal resource utilization, investigate application-level issues (MPI scaling, algorithm efficiency)

Investigating System Crashes
-----------------------------

**Scenario:** Node crashed overnight, need to identify cause

**Workflow:**

1. Determine crash time from system logs:

   .. code-block:: bash

      # Find last boot time
      who -b
      
      # Check previous boot's final messages
      journalctl --boot=-1 --reverse | head -50

2. Review atop logs from 10-30 minutes before crash:

   .. code-block:: bash

      atop -r /var/log/atop/atop_<date> -b <crash_time-30min> -e <crash_time>

3. Look for crash indicators:

   - **Memory exhaustion:** ``free`` memory approaching zero, swap fully utilized, ``oomkill`` counter incrementing
   - **Thermal issues:** CPU frequency throttling (``curf`` significantly below nominal)
   - **Runaway processes:** Single process or user consuming disproportionate resources
   - **Kernel thread activity:** Excessive ``kworker`` CPU consumption suggests driver or hardware issues

4. Correlate with kernel logs:

   .. code-block:: bash

      journalctl --boot=-1 --since "<crash_time-30min>" | grep -E "(oom|panic|hardware|critical)"

Capacity Planning
-----------------

**Scenario:** Determine if node upgrade needed based on utilization trends

**Workflow:**

1. Extract system utilization statistics over time:

   .. code-block:: bash

      # Generate daily reports for past week
      for date in $(seq -w 11 17); do
        atopsar -r /var/log/atop/atop_202601${date} -C -M -D -N > utilization_202601${date}.txt
      done

2. Analyze patterns:

   - **CPU:** Sustained >80% utilization indicates compute saturation
   - **Memory:** Consistent swap activity indicates memory insufficiency  
   - **Disk:** High latency or queue depth suggests I/O upgrade needed
   - **Network:** Interface saturation or consistent drops indicate bandwidth limitation

   **Caveat:** These thresholds are rules of thumb, not absolute. Upgrade decisions require cost-benefit analysis considering: workload growth projections, budget constraints, alternative optimizations (code efficiency improvements, workload scheduling adjustments), and organizational priorities. Atop data informs capacity planning but doesn't make decisions - human judgment integrating multiple factors remains essential.

Integration with Monitoring and Tracing
========================================

Atop complements other validation tools as the bridge between monitoring and tracing:

**Monitoring (Prometheus/Grafana) → Atop:**
  - Monitoring dashboards identify real-time issues
  - Atop provides detailed process-level attribution for observed resource spikes
  - Example: Prometheus alerts on high memory usage → atop identifies which user/process consumed memory

**Atop → Tracing (strace/perf/gdb):**
  - Atop localizes issue to specific subsystem (CPU/memory/disk/network)
  - Tracing tools provide code-level detail for identified process
  - Example: Atop shows process with excessive disk I/O → strace reveals specific syscalls causing I/O

**Decision tree:**

1. Real-time issue: Start with monitoring dashboards
2. Historical issue: Start with atop logs
3. Atop identifies problematic process: Use tracing tools (strace, perf, gdb) for code-level analysis
4. System-wide issue (all processes affected): Investigate hardware/kernel (journalctl, dmesg)

References
==========

Official Documentation and Resources
-------------------------------------

The atoptool.nl website provides comprehensive reference materials, examples, and download information:

- **Screenshots and visual guide:** https://atoptool.nl/screenshots.php - Demonstrates various atop views with annotated explanations. Useful for understanding what different resource states look like visually.

- **System reports and usage examples:** https://atoptool.nl/systemreports.php - Real-world examples of atop output interpretation, including typical patterns and anomaly identification.

- **Installation and downloads:** https://atoptool.nl/downloadatop.php - Distribution-specific packages, source code, and netatop kernel module downloads.

- **Main documentation:** https://atoptool.nl/ - Official project site with manpages, feature descriptions, and configuration guides.

- **Source repository:** https://github.com/Atoptool/atop - Issue tracking, development history, and contribution guidelines.

Additional Reading
------------------

- **Man pages:** ``man atop``, ``man atopsar`` (included with package installation) - Authoritative reference for all command-line options and output format details.

- **Related diagnostic tools:** :doc:`../index` - Overview of complementary validation and tracing tools in this documentation.

**Note on documentation completeness:** While we've attempted to cover common diagnostic scenarios and panel interpretations, atop's extensive feature set exceeds what can be reasonably documented in a single article. The official documentation at atoptool.nl provides exhaustive coverage. When encountering unfamiliar metrics or seeking advanced features (custom output formats via ``-P``, thread-level analysis via ``-y``, etc.), consult the upstream documentation rather than relying solely on this guide.
