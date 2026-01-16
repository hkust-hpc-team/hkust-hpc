System Config
=============

.. contents::
   :local:
   :depth: 3

BIOS and Firmware
-----------------

.. TODO: Refactor common BIOS settings between AMD and Intel into a separate section to avoid duplication. E.g. NPS, Performance Determinism, C States, Turbo Mode, etc.

.. TODO: Memory related settings, e.g.
  - Memory Interleaving: auto
  - DRAM Refresh Rate: performance
  - Memory power down mode: disabled
  - Memory Patrol Scrub: performance / standard

AMD CPU specific
^^^^^^^^^^^^^^^^

Dell BIOS Settings for AMD EPYC

.. code-block:: xml

    <root>
      <Attribute Name="ApbDis">Enabled</Attribute>
      <Attribute Name="CcxAsNumaDomain">Enabled</Attribute>
      <Attribute Name="DeterminismSlider">PerformanceDeterminism</Attribute>
      <Attribute Name="DfCState">Enabled</Attribute>
      <Attribute Name="DfPstateFreqOptimizer">Enabled</Attribute>
      <Attribute Name="DfPstateLatencyOptimizer">Enabled</Attribute>
      <Attribute Name="DlwmForcedWidth">x16</Attribute>
      <Attribute Name="DramRefreshDelay">Performance</Attribute>
      <Attribute Name="DynamicLinkWidthManagement">Force</Attribute>
      <Attribute Name="FixedSocPstate">FixedSocPstate0</Attribute>
      <Attribute Name="Hsmp">Enabled</Attribute>
      <Attribute Name="IommuSupport">Enabled</Attribute>
      <Attribute Name="MemFrequency">MaxPerf</Attribute>
      <Attribute Name="MemPatrolScrub">Standard</Attribute>
      <Attribute Name="MemRefreshRate">1x</Attribute>
      <Attribute Name="NumaNodesPerSocket">2</Attribute>
      <Attribute Name="PcieAspmL1">Disabled</Attribute>
      <Attribute Name="PcieSpeedPmmControl">StaticLinkSpeedGen5</Attribute>
      <Attribute Name="PowerProfileSelect">HighPerformanceMode</Attribute>
      <Attribute Name="ProcCStates">Enabled</Attribute>
      <Attribute Name="ProcPwrPerf">OsDbpm</Attribute>
      <Attribute Name="ProcTurboMode">Enabled</Attribute>
      <Attribute Name="SysProfile">Custom</Attribute>
    </root>

APTIO BIOS Settings for AMD EPYC

.. list-table::
    :header-rows: 1
    :widths: 70 30

    - - Setting Name
      - Value
    - - **SMU Common Options**
      -
    - - Power Policy Quick Setting
      - Best Performance
    - - Determinism
      - Performance
    - - APBDIS
      - 1 (Enabled)
    - - DfPstateMin
      - 0
    - - DfPstateMax
      - 2
    - - DF PState Frequency Optimizer
      - Enabled
    - - DF Cstates
      - Enabled
    - - CPPC
      - Disabled
    - - HSMP Support
      - Enabled
    - - **NBIO Common Options**
      -
    - - IOMMU
      - Enabled
    - - **DF Common Options**
      -
    - - NUMA Nodes Per Socket
      - 2 (or NPS2)
    - - ACPI SRAT L3 Cache As NUMA Domain
      - Enabled
    - - Memory interleaving
      - Auto
    - - **CPU Common Options**
      -
    - - Prefetcher settings
      - All enabled
    - - Streaming Stores Control
      - Enabled
    - - Local APIC Mode
      - x2APIC
    - - Fast Short REP MOVSB
      - Enabled
    - - Enhanced REP MOVSB/STOSB
      - Enabled
    - - AVX512
      - Enabled
    - - MONITOR and MWAIT disable
      - Disabled
    - - Corrector Branch Predictor
      - Enabled
    - - PAUSE Delay
      - 16 cycles (minimal)
    - - CPU Speculative Store Modes
      - More Speculative
    - - Prefetch/Request Throttle
      - Enabled

Intel CPU specific
^^^^^^^^^^^^^^^^^^

.. TODO: Fetch from Intel machine

Drivers
-------

Kernel Built-in
^^^^^^^^^^^^^^^

AMD Zen4 Drivers
""""""""""""""""

Specific kernel version provides additional AMD-specific modules that enhance performance and functionality, below lists the modules available in different kernel versions.

- ``amd_atl``: AMD Address Translation Library for enhanced memory management
- ``ptdma``: Platform DMA driver for improved data movement
- ``ae4dma``: Advanced Enhanced DMA driver for next-generation AMD platforms

.. list-table::
    :header-rows: 1
    :widths: 25 25 50

    - - AMD Drivers
      - Kernel 6.x Version
      - | RHEL 9.x Backport
        | (Kernel 5.14)
    - - ``amd_atl``
      - 6.1
      - el9_4
    - - ``ptdma``
      - 6.8
      - el9_7
    - - ``ae4dma``
      - 6.14
      - Unknown

Mellanox Driver
^^^^^^^^^^^^^^^

Kernel-specific Build
"""""""""""""""""""""

.. code-block:: dockerfile
    
    # Containerfile for Mellanox Drivers Build, RHEL9.x
    FROM core-devel:latest

    ARG OS_RELEASE
    ARG KERNEL_VERSION
    ARG ARCH
    ARG MLNX_VERSION
    ARG MLNX_OFED_CHECKSUM_RHEL9_3
    ARG MLNX_OFED_CHECKSUM_RHEL9_4
    ARG MLNX_OFED_CHECKSUM_RHEL9_5

    # [dnf] makecache at first command
    RUN dnf --refresh makecache

    # [kernel] devel
    RUN dnf install -y kernel-{devel,tools{,-libs}}-${KERNEL_VERSION} kernel-{,s}rpm-macros
    RUN dnf versionlock kernel-{devel,tools{,-libs}}

    # [mlnx] rpm build dependencies
    RUN dnf install -y createrepo ethtool pciutils perl-sigtrap \
      lsof tcl tk gcc-gfortran nano tar vim wget gcc-toolset-13{,-*-devel} \
      "@Development Tools" "@RPM Development Tools"

    # [mlnx] Download Mellanox OFED Driver
    WORKDIR /root
    RUN echo -e "For latest update of the Mellanox OFED driver\nPlease visit https://network.nvidia.com/products/infiniband-drivers/linux/mlnx_ofed/"
    RUN ! [ "${OS_RELEASE}" == "rhel9.3" ] \
      || (wget https://content.mellanox.com/ofed/MLNX_OFED-${MLNX_VERSION}/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}.tgz -O mlnx-ofed.tgz \
        && (sha256sum -b mlnx-ofed.tgz | grep ${MLNX_OFED_CHECKSUM_RHEL9_3}) \
        && tar --transform="s/\.\/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}/.\/mlnx-ofed/g" -xvf mlnx-ofed.tgz)
    RUN ! [ "${OS_RELEASE}" == "rhel9.4" ] \
      || (wget https://content.mellanox.com/ofed/MLNX_OFED-${MLNX_VERSION}/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}.tgz -O mlnx-ofed.tgz \
        && (sha256sum -b mlnx-ofed.tgz | grep ${MLNX_OFED_CHECKSUM_RHEL9_4}) \
        && tar --transform="s/\.\/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}/.\/mlnx-ofed/g" -xvf mlnx-ofed.tgz)
    RUN ! [ "${OS_RELEASE}" == "rhel9.5" ] \
      || (wget https://content.mellanox.com/ofed/MLNX_OFED-${MLNX_VERSION}/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}.tgz -O mlnx-ofed.tgz \
        && (sha256sum -b mlnx-ofed.tgz | grep ${MLNX_OFED_CHECKSUM_RHEL9_5}) \
        && tar --transform="s/\.\/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-${ARCH}/.\/mlnx-ofed/g" -xvf mlnx-ofed.tgz)

    WORKDIR /root/mlnx-ofed

    # [mlnx] Build Mellanox OFED Driver (23.x branch)
    RUN ! [[ "${MLNX_VERSION}" =~ ^23\.* ]] \
      || (source /opt/rh/gcc-toolset-13/enable \
        && ./mlnxofedinstall -k ${KERNEL_VERSION}.${ARCH} --kmp --with-fabric-collector --with-nfsrdma \
          --without-mlnx-nvme --without-nvmf --without-srp --without-iser --without-isert --without-fw-update \
          --enable-affinity --enable-mlnx_tune --add-kernel-support-build-only -vvv \
        && rm -rf /root/mlnx-ofed \
        && mv /tmp/MLNX_OFED_LINUX-${MLNX_VERSION}-${KERNEL_VERSION}.${ARCH}/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-ext.tgz /root/mlnx-ofed.tgz)

    # [mlnx] Build Mellanox OFED Driver (24.x branch)
    RUN ! [[ "${MLNX_VERSION}" =~ ^24\.* ]] \
      || (source /opt/rh/gcc-toolset-13/enable \
        && ./mlnxofedinstall -k ${KERNEL_VERSION}.${ARCH} --kmp --with-fabric-collector --with-nfsrdma \
          --without-mlnx-nvme --without-nvmf --without-srp --without-iser --without-isert --without-fw-update \
          --enable-affinity --enable-mlnx_tune --fwctl --add-kernel-support-build-only -vvv \
        && rm -rf /root/mlnx-ofed \
        && mv /tmp/MLNX_OFED_LINUX-${MLNX_VERSION}-${KERNEL_VERSION}.${ARCH}/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-ext.tgz /root/mlnx-ofed.tgz)

    WORKDIR /root
    RUN tar --transform="s/MLNX_OFED_LINUX-${MLNX_VERSION}-${OS_RELEASE}-ext/mlnx-ofed/g" -xvf mlnx-ofed.tgz \
      && mv mlnx-ofed/RPMS /root/mlnx-ofed-rpms \
      && rm -rf mlnx-ofed mlnx-ofed.tgz \
      && tar zcf mlnx-ofed-rpms.tgz mlnx-ofed-rpms \
      && rm -rf mlnx-ofed-rpms

    FROM alpine:latest
    WORKDIR /root
    COPY --from=0 /root/mlnx-ofed-rpms.tgz /root/mlnx-ofed-rpms.tgz

Installation
""""""""""""

.. code-block:: dockerfile

    # Containerfile for Mellanox Drivers Install, RHEL9.x
    FROM substitute-base-image:latest

    ARG OS_RELEASE
    ARG KERNEL_VERSION
    ARG ARCH
    ARG MLNX_VERSION
    ARG OS_MLNX_OFED_INSTALL

    # [dnf] makecache at first command
    RUN dnf --refresh makecache

    # [mlnx-ofed] Mellanox ofed prerequisites
    RUN dnf install -y libusbx libnl3-devel boost-filesystem cmake-filesystem hwloc libgfortran libquadmath logrotate lsof pciutils python3-distro

    # [mlnx-ofed] Load Mellanox ofed driver rpms as repo: mlnx-ofed
    RUN mkdir -p /opt/repos/
    WORKDIR /opt/repos/
    COPY --from=mlnx-ofed-rpmbuild /root/mlnx-ofed-rpms.tgz /opt/repos/mlnx-ofed-rpms.tgz
    RUN tar -zxf mlnx-ofed-rpms.tgz \
      && mv mlnx-ofed-rpms /opt/repos/mlnx-ofed-${MLNX_VERSION} \
      && rm -rf /opt/repos/mlnx-ofed-rpms.tgz
    RUN echo -e "[mlnx-ofed-${MLNX_VERSION}]\nname=Mellanox OFED Driver ${MLNX_VERSION}\nbaseurl=file:///opt/repos/mlnx-ofed-${MLNX_VERSION}\nenabled=1\ngpgcheck=0\npriority=40" >/etc/yum.repos.d/mlnx-ofed.repo \
      && dnf config-manager --set-enabled mlnx-ofed-${MLNX_VERSION} \
      && dnf --refresh makecache

    # [mlnx-ofed] default mpi / collectives
    RUN ! [ "${OS_MLNX_OFED_INSTALL}" == "y" ] \
      || dnf --setopt keepcache=False --refresh install --repo mlnx-ofed-${MLNX_VERSION} -y hcoll mpitests_openmpi openmpi \
        ucx{,-rdmacm,-cma,-devel,-static}

.. note::
    
    Designate one Subnet Manager (openibd) instance for the whole IB network (subnet), multiple instances will conflict.

    Switch may offer a Highly-available implementation of the Subnet Manager, it is better to use that instead of designating it to headnode and use custom HA solution.

Module Tunables
"""""""""""""""

Tune this according to your communication pattern, or with a benchmark such as ``IMB-MPI1`` or ``osu-micro-benchmarks``.

.. code-block:: bash

    # /etc/modprobe.d/mlnx-ofed.conf
    options ib_core recv_queue_size=1024 send_queue_size=256

Nvidia GPU Driver
^^^^^^^^^^^^^^^^^

Installation
""""""""""""

.. code-block:: dockerfile

    # Containerfile for Nvidia GPU Driver Installation, RHEL9.x / Fedora

    # This assumes MLNX_OFED is already installed as per previous section
    # Otherwise, can skip the last [mlnx-ofed] tagged section if not needed
    FROM substitute-base-image:latest

    ARG OS_RELEASE
    ARG KERNEL_VERSION
    ARG ARCH
    ARG MLNX_VERSION
    ARG NVIDIA_CUDA_BRANCH
    ARG NVIDIA_DRIVER_BRANCH
    ARG NVIDIA_DRIVER_FM_INSTALL
    ARG OS_NVIDIA_DRIVER_INSTALL
    ARG OS_MLNX_OFED_INSTALL

    # [nvidia] nvidia driver, below is a version for 
    RUN ! ( [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] && [ "${NVIDIA_DRIVER_FM_INSTALL}" == "n" ] ) \
      || (dnf --refresh makecache \
        && dnf module reset -y nvidia-driver \
        && dnf module install -y nvidia-driver:${NVIDIA_DRIVER_BRANCH}-dkms/default)
        && dkms install -m nvidia -v $(modinfo -F version nvidia) -k ${KERNEL_VERSION}.${ARCH}

    # [nvidia] nvidia driver with Fabric Manager (DGX A100/H100 SXM with NVSwitch)
    RUN ! ( [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] && [ "${NVIDIA_DRIVER_FM_INSTALL}" == "y" ] ) \
      || (dnf --refresh makecache \
        && dnf module reset -y nvidia-driver \
        && dnf module install -y nvidia-driver:${NVIDIA_DRIVER_BRANCH}-dkms/fm)
        && dkms install -m nvidia -v $(modinfo -F version nvidia) -k ${KERNEL_VERSION}.${ARCH}

    # [nvidia] cuda minimal tools
    RUN ! [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] \
      || (dnf install -y nvfwupd nvdebug nvidia-container-toolkit cuda-runtime-${NVIDIA_CUDA_BRANCH})

   # [nvidia] system settings & utilities
    RUN ! [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] \
      || (dnf install -y nvidia-acs-disable nvidia-chardev-links nvidia-conf-cachefilesd \
        nvidia-conf-xconfig nvidia-kernel-defaults nvidia-lldpd-defaults nvidia-logrotate nvidia-mig-manager \
        nvidia-persistenced nvidia-redfish-config nvidia-relaxed-ordering nvidia-settings \
        nvidia-xconfig)

    # [nvidia] surfaceless EGL render provider
    RUN ! [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] \
      || (dnf install -y libglvnd-devel libglvnd)
    
    # [nvidia/cuda] devel
    RUN ! [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] \
      || (dnf --refresh makecache \
        && dnf --repo CUDA list -q --available *-devel *-devel-${NVIDIA_CUDA_BRANCH} *-devel-cuda-${NVIDIA_CUDA_MAJOR} \
        | tail -n +2 | cut -d " " -f 1 | grep "${ARCH}" | xargs -t dnf install -y)

    # [mlnx-ofed] libraries for cuda
    RUN ! [ "${OS_MLNX_OFED_INSTALL}" == "y" ] \
      || ! [ "${OS_NVIDIA_DRIVER_INSTALL}" == "y" ] \
      || (dnf --refresh makecache \
        && dnf --refresh install --repo mlnx-ofed-${MLNX_VERSION} --repo CUDA --repo nvidia-dgx-9 -y clusterkit hcoll-cuda ucx-cuda ucx-gdrcopy \
        && userdel geoclue)

Persistence Daemon
""""""""""""""""""

.. code-block:: bash

    # Enable persistence daemon to keep GPU initialized across jobs
    systemctl enable nvidia-persistenced.service

Non-root Nsight Profiling
"""""""""""""""""""""""""

This allow user to interact with GPU driver for profiling without having admin privileges.

.. code-block:: bash

    # /etc/modprobe.d/nvidia.conf
    options nvidia NVreg_RestrictProfilingToAdminUsers=0

GPUDirect RDMA
""""""""""""""

The old kernel module is called ``nv_peer_mem``, the new module is ``nvidia_peermem``, the following config is for the new module.

.. code-block:: bash

    # /etc/modules-load.d/nvidia_peermem.conf 
    nvidia_peermem
    # /etc/modprobe.d/nvidia_peermem.conf
    options nvidia_peermem peerdirect_support=1
 
Kernel
------

Kernel Selection
^^^^^^^^^^^^^^^^

.. TODO: Ubuntu vs RHEL key differences, particularly kernel 6 available in Ubuntu vs 5 in RHEL9.x, which crucially lack the ``ptdma`` driver for AMD.

Time Synchronization
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # Setup time synchronization
    # Config /etc/chrony.conf as per environment
    systemctl enable --now chronyd.service

Entropy Generation
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # Improve entropy availability for RNG use, e.g. for SSHD, SSL, etc.
    systemctl enable --now rngd

Swap
^^^^

Compute node don't need one, having one brings more problem than it solves.

If you have the disk space, you might want to use the disk space for Cachefilesd, job TMP or other purposes instead.

.. code-block:: bash

    # Disable swap
    swapoff -a
    sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

CGroup
^^^^^^^

CGroup v1: it does not work well with SLURM, and is deprecated in recent Linux kernel versions anyway.

Use CGroup v2 instead whenever possible. Some recent kernel defaults to CGroup v2 already.

.. code-block:: shell

    # Kernel Boot Parameter
    systemd.unified_cgroup_hierarchy=1

IRQ Handling
^^^^^^^^^^^^^^

 IRQ Balance service may interfere with programmatic IRQ affinity settings for IB/RoCEv2 performance tuning.

.. code-block:: bash

    # Disable irqbalance to enable manual control of IRQ affinity
    # Or alternatively use one-shot to set affinity on boot BEFORE running RoCEv2 tuning scripts
    # This prevent jitters every 10s or so
    systemctl disable --now irqbalance

CPU Power Management
^^^^^^^^^^^^^^^^^^^^^

Philosophy
- performant when needed
- power-saving when idle

A performance profile will

  - set CPU frequency governor to "performance"
  - set minimum CPU frequency to baseline frequency
  - set maximum CPU frequency to turbo frequency
  - disable deep C states with transition latency > 2 us

A power-saving profile will

  - set CPU frequency governor to "ondemand"
  - set minimum CPU frequency to lowest frequency
  - set maximum CPU frequency to baseline frequency
  - enable all C states

Example Implementation
""""""""""""""""""""""

Start from gathering node information

.. code-block:: shell

    # cat /sys/devices/system/cpu/cpu/cpufreq/cpuinfo_{min,max}_freq
    1500000
    3100341
    
    # cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    2250000 1800000 1500000
    
    # cpupower idle-info
    CPUidle driver: acpi_idle
    CPUidle governor: menu
    analyzing CPU 239:
    
    Number of idle states: 3
    Available idle states: POLL C1 C2
    POLL:
    Flags/Description: CPUIDLE CORE POLL IDLE
    Latency: 0
    ...
    C1:
    Flags/Description: ACPI FFH MWAIT 0x0
    Latency: 1
    ...
    C2:
    Flags/Description: ACPI IOPORT 0x414
    # This latency may be configured in BIOS, check BIOS C state settings
    Latency: 800
    ...

Example configuration files for ``cpupower`` systemd service

Note the systemd file is **modified** from the default shipped with ``cpupower`` package to support idle state management as well.

.. code-block:: systemd

    # /usr/lib/systemd/system/cpupower.service
    [Unit]
    Description=Configure CPU power related settings
    After=syslog.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    EnvironmentFile=/etc/sysconfig/cpupower
    ExecStart=/usr/bin/cpupower $CPUPOWER_START_OPTS
    ExecStart=/usr/bin/cpupower $CPUPOWER_START_IDLE_OPTS
    ExecStop=/usr/bin/cpupower $CPUPOWER_STOP_OPTS
    ExecStop=/usr/bin/cpupower $CPUPOWER_STOP_IDLE_OPTS

    [Install]
    WantedBy=multi-user.target

.. tip::
    
    For performance mode, it is better to test the maximum sustainable frequency given your data center cooling capability. (e.g. 2.7 GHz instead of full turbo 3.1 GHz)

    It is expected systems will run at sustained maximum load for all kinds of long-running AI/HPC workloads.
    
    Setting a too high maximum frequency may lead to thermal throttling under sustained load, which is counter-productive.

.. code-block:: shell

    # /etc/sysconfig/cpupower
    CPUPOWER_START_OPTS="frequency-set -g performance --min 2250000 --max 2700000"
    CPUPOWER_STOP_OPTS="frequency-set -g ondemand --min 1500000 --max 2250000"
    CPUPOWER_START_IDLE_OPTS="idle-set --disable 2"
    CPUPOWER_STOP_IDLE_OPTS="idle-set --enable-all"


This can then be integrated to SLURM as job prolog/epilog scripts (root portion) to set performance profile during job execution, and power-saving profile when idle.

.. important::
    
    The ``cpupower`` service should be configured such that

      - ``started`` state if ANY job is executing on node;
      - ``stopped`` state ONLY if no job is executing.

    You may use 
      
      - [recommended] checking ``slurmstepd.scope`` children 
      - ``squeue``
      - other method
      
    to check for other running jobs before stopping ``cpupower`` service in job epilog.

.. code-block:: bash

    # /etc/slurm/job-prolog.sh
    #!/bin/bash
    # Job starts, unconditionally start cpupower service to set performance profile
    systemctl start cpupower.service

    
.. code-block:: bash

    # /etc/slurm/job-epilog.sh
    #!/bin/bash

    # Using systemctl to check slurmstepd scope for children
    if [ "$(systemctl status slurmstepd.scope | grep job | wc -l)" -eq 0 ]; then
      systemctl stop cpupower.service
    fi

    # Using squeue to check for running jobs, may stress slurmctld at large scale / fast job turnover
    if [ "$(squeue -h -o '%T' -w $(hostname) | grep RUNNING | wc -l)" -eq 0 ]; then
      systemctl stop cpupower.service
    fi

General Tunables
^^^^^^^^^^^^^^^^

**Boot Parameters**

This is usually set in BOOT_CMDLINE variable in GRUB config file such as ``/etc/default/grub``, or your PXE bootloader config.

.. code-block:: shell

    clocksource=tsc
    default_hugepagesz=2M
    hugetlb_free_vmemmap=1
    iommu=pt
    numa_balancing=disable
    transparent_hugepage=always
    tsc=reliable
    workqueue.default_affinity_scope=numa
    # Note security implications
    audit=0
    crashkernel=no
    mitigations=off
    selinux=0
    # AMD specific
    amd_pstate=passive

**Sysctl Tunables**

.. TODO: Confirm source and values, some values seem off and missing

.. code-block:: shell

    # security
    kernel.dmesg_restrict=1
    kernel.kptr_restrict=1

    # filesystem/nfs performance/limits
    fs.aio-max-nr=1048576
    fs.file-max=9223372036854775807
    fs.nfs.nfs_congestion_kb=2097152
    fs.nr_open=1073741824
    kernel.io_delay_type=0
    kernel.io_uring_disabled=0
    sunrpc.tcp_max_slot_table_entries=65536
    vm.dirty_background_ratio=1
    vm.dirty_expire_centisecs=500
    vm.dirty_ratio=40
    vm.dirty_writeback_centisecs=25

    # user / admin debuggability
    kernel.hardlockup_panic=0
    kernel.panic_on_oops=0
    kernel.perf_event_max_sample_rate=32768
    kernel.perf_event_paranoid=-1
    kernel.yama.ptrace_scope=0
    kernel.hardlockup_all_cpu_backtrace=1
    kernel.hung_task_all_cpu_backtrace=1
    kernel.oops_all_cpu_backtrace=1
    kernel.softlockup_all_cpu_backtrace=1

    # performance
    fs.epoll.max_user_watches=460992000
    kernel.msgmni=32000
    kernel.numa_balancing=0
    kernel.randomize_va_space=0
    kernel.sched_autogroup_enabled=0
    kernel.sched_cfs_bandwidth_slice_us=5000
    kernel.sched_energy_aware=0
    kernel.threads-max=16777216
    vm.vfs_cache_pressure=20
    vm.swappiness=10
    vm.zone_reclaim_mode=0

    # operational safety
    vm.admin_reserve_kbytes=524288
    vm.min_free_kbytes=262144
    kernel.sysrq=0

Huge Page Management
^^^^^^^^^^^^^^^^^^^^

.. TODO: Extract config from current compute nodes

TCP/IP Stack
-------------

TCP/IP
^^^^^^

This benefits TCP/IP over IB/RoCEv2 tuning as well as general network stack tuning.

Additional Tunables
"""""""""""""""""""

.. code-block:: bash

    # These units in bytes
    net.core.optmem_max = 20480
    net.core.rmem_default = 16777216
    net.core.rmem_max = 268435456
    net.core.wmem_default = 16777216
    net.core.wmem_max = 268435456
    net.ipv4.tcp_rmem = 4096 131072 268435456
    net.ipv4.tcp_wmem = 4096 131072 268435456
    net.ipv4.udp_rmem_min = 8192
    net.ipv4.udp_wmem_min = 8192
    # These units in pages (4096 bytes)
    net.ipv4.tcp_mem = 1048576 2097152 4194304
    net.ipv4.udp_mem = 1048576 2097152 4194304

    net.core.somaxconn = 65535
    net.core.netdev_budget = 600
    net.core.netdev_budget_usecs = 4000
    net.core.netdev_max_backlog = 250000
    net.ipv4.tcp_max_syn_backlog = 8192
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_mtu_probing = 1
    net.ipv4.tcp_timestamps = 1
    net.ipv4.tcp_window_scaling = 1

    # Assumes highly dropless network
    net.ipv4.tcp_sack = 0
    net.ipv4.tcp_fack = 0
    net.ipv4.tcp_dsack = 0
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.tcp_fastopen = 3
    net.ipv4.tcp_slow_start_after_idle = 0
    # Sometimes latency is more important than throughput
    net.ipv4.tcp_low_latency = 1
    net.ipv4.tcp_notsent_lowat = 4294967295


.. seealso::

    https://wiki.archlinux.org/title/Sysctl#Networking

RoCEv2
^^^^^^

Baseline Tuning
"""""""""""""""

**Traffic Class and QoS**

This script waits for the Infiniband device driver to load, then set the traffic class for RoCEv2 traffic, configure Mellanox QoS settings and set CMA RoCE TOS value accordingly.

.. note::

    The value 106 for DSCP is an example only, please check with your networking team for DSCP values in your network switches, the settings has to match.

.. code-block:: systemd

    # /etc/systemd/system/mlx5-class-infiniband-mlx5_0.path
    [Unit]
    Description=Watch for Infiniband device driver to load

    [Path]
    PathExists=/sys/class/infiniband/mlx5_0/tc/1/traffic_class

    [Install]
    WantedBy=multi-user.target

    # /etc/systemd/system/mlx5-class-infiniband-mlx5_0.service
    [Unit]
    Description=Set RoCEv2 Infiniband traffic class 
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c "echo 106 > /sys/class/infiniband/mlx5_0/tc/1/traffic_class"
    RemainAfterExit=yes

**Dropless QoS**

.. note::

    The value are for example only, please check with your networking team for DSCP values, PFC settings in your network switches, the settings has to match.

.. code-block:: systemd

    # /etc/systemd/system/mlx5-tos.service
    [Unit]
    Description=Mellanox QoS config for dropless RoCEv2
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/mlnx_qos -i enp161s0np0 --trust dscp
    ExecStart=/usr/bin/mlnx_qos -i enp161s0np0 --pfc 0,0,0,1,0,0,0,0
    ExecStart=/usr/sbin/cma_roce_tos -d mlx5_0 -t 106
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target

**Use ECN for TCP**

.. code-block:: bash

    # /etc/sysctl.d/99-tcp-ecn.conf
    net.ipv4.tcp_ecn=1

**Additional Kernel Tunables**

.. code-block:: bash

    # /etc/sysctl.d/99-mlx5-ib.conf
    kernel.numa_balancing=0
    vm.max_map_count=1048576

Performance Tuning
""""""""""""""""""

.. code-block:: bash

    # Detect Mellanox MT28908 and set PCIe MaxPayloadSize to 5 (128 bytes >> 5 = 4096 bytes), maximizing throughput, default is 2 (128 bytes >> 2 = 512 bytes)
    # Be careful setting this value, the CAP_EXP byte depends on hardware model, this only applies to MT28908 ConnectX-6

    # /etc/systemd/system/mlx5-setpci.service
    [Unit]
    Description=Set Mellanox MT28908 read size to 4096 Byte
    After=network.target
    Requires=mlx5-class-infiniband-mlx5_0.path

    [Service]
    Type=oneshot
    ExecStart=/usr/sbin/mlx5-setpci
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    #!/bin/bash
    set -euo pipefail

    declare mlx5_pci="$(lspci | grep 'Mellanox Technologies MT28908 Family \[ConnectX-6\]' | awk '{ print $1 }')"

    if [[ "$mlx5_pci" =~ [0-9a-f]{2}:00\.0 ]]; then
      echo "Detected PCIe bus for MT28908: $mlx5_pci"
      declare old_pci_val=$(setpci -s $mlx5_pci CAP_EXP+8.w)
      declare new_pci_val=$(echo $old_pci_val | sed -E 's/^[0-9]([0-f]+)$/5\1/g')
      if [ -n "$old_pci_val" ] && [ -n "$new_pci_val" ]; then
        echo "Setting pci $mlx5_pci: [$old_pci_val] - >[$new_pci_val]"
        setpci -s $mlx5_pci CAP_EXP+8.w=$new_pci_val
        setpci -s $mlx5_pci CAP_EXP+8.w
      else
        echo "Failed to set PCIe: [$old_pci_val] -> [$new_pci_val]"
        exit 1
      fi
    else
      echo "No Mellanox PCIe device found"
      exit 1
    fi

    # /etc/systemd/system/mlx5-mlnx-tune.service
    # This is a Mellanox provided tool
    # Applies a NON-PERSISTENT profile on startup
    # - irqbalance is implicitly stopped as well
    # - IRQ affinity will be set to NUMA node of the IB device
    # - Other IB parameters will be set as per profile
    [Unit]
    Description=Set system settings according to Mellanox HIGH_THROUGHPUT profile
    After=network.target
    Requires=mlx5-setpci.service

    [Service]
    Type=oneshot
    ExecStart=/usr/sbin/mlnx_tune -p HIGH_THROUGHPUT
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target

    # These should be set AFTER the HIGH_THROUGHPUT profile to prevent overwriting, specific for RoCEv2
    # All these settings are non-persistent and need to be applied on each boot
    # /etc/systemd/system/mlx5-mlnx-ethtool.service
    [Unit]
    Description=Set ethtool settings according to private communication with Nvidia TAM 
    After=network.target
    Requires=mlx5-mlnx-tune.service

    [Service]
    Type=oneshot
    ExecStart=/usr/sbin/ethtool --set-ring enp161s0np0 rx 8192
    ExecStart=/usr/sbin/ethtool --set-ring enp161s0np0 tx 8192
    ExecStart=/usr/sbin/ethtool --set-priv-flags enp161s0np0 dropless_rq on
    ExecStart=/usr/sbin/ethtool --pause enp161s0np0 rx on
    ExecStart=/usr/sbin/ethtool --pause enp161s0np0 tx on
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target

File Systems
------------

.. important::
  
    It is very important that the time on the storage server and compute nodes are
    - synchronized to the same set of time servers
    - configured a compatible authentication and authorization scheme
    otherwise, file system operations may fail in unexpected ways.

Tuning the underlying network stack is as important as tuning the parallel filesystem client itself, as a slow network stack directly translates to slow filesystem performance.

NFS Client Tuning
^^^^^^^^^^^^^^^^^

.. code-block:: shell

    # read-only large amount of small program files (LD_LIBRARY_PATH, python etc.)
    ro,noatime,vers=3,rsize=1048576,wsize=1048576,acregmin=10,hard,forcerdirplus,proto=tcp,nconnect=16,timeo=600,retrans=2,sec=sys,fsc,local_lock=none,lookupcache=all

    # use attr cache cache=pos when there are frequent writes to files 
    rw,relatime,vers=3,rsize=1048576,wsize=1048576,hard,forcerdirplus,proto=tcp,nconnect=16,timeo=600,retrans=2,sec=sys,fsc,local_lock=none,lookupcache=pos

Cachefilesd
""""""""""""

If local fast SSD is available, we can enable cachefilesd for NFS client side caching of small files.

.. code-block:: shell

    # /etc/cachefilesd.conf 
    # dir should point to a local fast SSD, preferably RAID0 of multiple NVMe drives, mdraid can be used for this.
    dir /raid
    tag nvcache
    brun 30%
    bcull 25%
    bstop 15%
    frun 10%
    fcull 7%
    fstop 3%

.. code-block:: bash

    # Enable cachefilesd for NFS client side caching of small files
    systemctl enable --now cachefilesd.service

Lustre Client Tuning
^^^^^^^^^^^^^^^^^^^^

.. TODO: Lustre Persistent Client Cache, otherwise it is more straightforward, since it is via IB.

User Environment
----------------

Environment Defaults
^^^^^^^^^^^^^^^^^^^^

.. TODO: Extract from admin/login nodes
.. code-block:: shell

    # /etc/skel
    # /etc/profile.d/*.sh
    # /etc/bashrc

Resource Limits and Quotas
^^^^^^^^^^^^^^^^^^^^^^^^^^

Generally, unlock all quotas and limits on compute nodes, resource control is done by SLURM instead.

.. code-block:: shell

    # /etc/security/limits.d/*.conf
    * soft      memlock    unlimited
    * hard      memlock    unlimited
    * soft      stack      unlimited
    * hard      stack      unlimited
    # For AI workload you need a lot of open files for loading data using large number of threads
    * soft      nofile     1048576
    * hard      nofile     1048576

On login nodes, you may want to set reasonable limits to prevent abuse and improve system stability.


Philosophy: 
- Reserve some resources for system slices to protect system stability
- Set user quotas according to permitted usage pattern

System Quota
"""""""""""""

An example minimal guarantee for system slices.

.. code-block:: systemd

    # /usr/lib/systemd/system/system.slice.d/10-defaults.conf
    [Slice]
    CPUAccounting=true
    CPUQuota=infinity
    MemoryAccounting=true
    # Set aside ~16GB minimum memory
    MemoryMin=3%
    MemoryMax=infinity
    # If you have swap for login nodes, you may want it to be only for system slices
    MemorySwapMax=infinity

User Quotas
""""""""""""

An example permits visualization / GUI, but not too much to allow extensive computation or compiling on login nodes.

.. code-block:: systemd

    # /usr/lib/systemd/system/user-.slice.d/10-defaults.conf
    [Slice]
    CPUAccounting=true
    # 4 cores worth of CPU time
    CPUQuota=400%
    MemoryAccounting=true
    # 5% of total system memory
    MemoryMax=5%
    MemorySwapMax=0

SLURM
-----

SLURM Environment
^^^^^^^^^^^^^^^^^

Philosophy: have SLURM environment identical to user environment on login nodes, so that user won't have issue running jobs.

Resource Control
^^^^^^^^^^^^^^^^

Slurm uses slurmstepd to enforce per-job resource limits, the configuration is in /etc/slurm/cgroup.conf.

Regular ``/etc/security/limits`` does not apply, since the limit is inherited from slurmstepd. 

.. code-block:: systemd

    # /usr/lib/systemd/system/slurmd.service.d/override.conf
    [Service]
    LimitNOFILE=16777216
    LimitMEMLOCK=infinity
    LimitSTACK=infinity
    Delegate=yes
    TasksMax=infinity


.. code-block:: shell

    # cat /etc/slurm/cgroup.conf
    CgroupAutomount=yes
    ConstrainCores=yes
    ConstrainRAMSpace=yes
    # see note below about OOM handling
    ConstrainSwapSpace=no
    ConstrainDevices=yes
    AllowedRamSpace=94.40
    AllowedSwapSpace=0.00
    MaxRAMPercent=95.00

Restrict SSH Access
^^^^^^^^^^^^^^^^^^^

In a multi-tenant HPC cluster, it is best practice to forbid direct SSH access to compute nodes.

There is a SLURM plugin ``pam_slurm`` that can be used to restrict SSH access to only users with running jobs on the node, however it is not very reliable with some SLURM / cgroup version or configuration, in that user may intentionally or unintentionally escape from the resource control, potentially disrupting other user's jobs.

Completely forbidding direct SSH access to compute nodes is the most straightforward solution.

SSH Alternative
""""""""""""""""

To fulfill user's need to "peek at a running compute job", user can use ``srun --pty bash``. This is an essential operation concern of users to ensure their resources are being used correctly.

.. code-block:: bash

    srun --overlap --jobid <jobid> -w <node> --pty bash

.. code-block:: shell

    [kftse@login1 ~]$ sbatch -p gpu-rtx4090d -A itsc --ntasks-per-node=1 --cpus-per-task=32 --gpus-per-task=2 --wrap "sleep 3600"
    Submitted batch job 390361
    [kftse@login1 ~]$ srun --overlap --jobid 390361 --pty bash

    # User is now in the compute node allocated to job 390361
    # Visible resources are limited to those allocated to the job
    [kftse@gpu32 ~]$ nvidia-smi -l
    Fri Dec 19 10:10:25 2025       
    +-----------------------------------------------------------------------------------------+
    | NVIDIA-SMI 565.57.01              Driver Version: 565.57.01      CUDA Version: 12.7     |
    |-----------------------------------------+------------------------+----------------------+
    | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
    | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
    |                                         |                        |               MIG M. |
    |=========================================+========================+======================|
    |   0  NVIDIA GeForce RTX 4090 D      On  |   00000000:17:00.0 Off |                    0 |
    |  0%   44C    P0             41W /  425W |       2MiB /  23028MiB |      0%      Default |
    |                                         |                        |                  N/A |
    +-----------------------------------------+------------------------+----------------------+
    |   1  NVIDIA GeForce RTX 4090 D      On  |   00000000:2A:00.0 Off |                    0 |
    |  0%   43C    P0             46W /  425W |       2MiB /  23028MiB |      0%      Default |
    |                                         |                        |                  N/A |
    +-----------------------------------------+------------------------+----------------------+
                                                                                            
    +-----------------------------------------------------------------------------------------+
    | Processes:                                                                              |
    |  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
    |        ID   ID                                                               Usage      |
    |=========================================================================================|
    |  No running processes found                                                             |
    +-----------------------------------------------------------------------------------------+
    [kftse@gpu32 ~]$ nproc
    32

    [root@gpu32 ~]# systemctl status
    ● gpu32
    # In cgroup hierarchy, both root shell are spawned under slurmstepd.scope/job_390361
    │ ├─slurmstepd.scope
    │ │ ├─job_390361
    # - step_0/task_0: "peeking" processes 
    │ │ │ ├─step_0
    │ │ │ │ ├─slurm
    │ │ │ │ │ └─26095 "slurmstepd: [390361.0]"
    │ │ │ │ └─user
    │ │ │ │   └─task_0
    │ │ │ │     ├─26105 /usr/bin/bash
    │ │ │ │     └─26303 nvidia-smi -l
    # - step_batch/task_0: user's batch job
    │ │ │ └─step_batch
    │ │ │   ├─slurm
    │ │ │   │ └─26076 "slurmstepd: [390361.batch]"
    │ │ │   └─user
    │ │ │     └─task_0
    │ │ │       ├─26080 /bin/sh /var/spool/slurm/d/job390361/slurm_script
    │ │ │       └─26081 sleep 3600

OOM Handling
^^^^^^^^^^^^ 

OOM is one of the most disruptive events in a multi-tenant HPC cluster, as it may lead to node instability, job failures, and impact other users' jobs.

Some version of SLURM does not handle OOM properly, leading to breaching of resource limits and even node instability as slurmstepd itself is in the system slice, it can compete for protected system resources all other critical system services and processes.

Customize OOM Control
"""""""""""""""""""""

.. code-block:: bash

    #!/bin/bash
    # /usr/local/bin/slurm-cgroup-watcher.sh

    # Configuration
    WATCH_DIR="/sys/fs/cgroup/system.slice/slurmstepd.scope"
    LOG_TAG="slurm-oom-control"

    # Ensure the directory exists before watching
    while [[ ! -d "$WATCH_DIR" ]]; do
        sleep 5
    done

    logger -t "$LOG_TAG" "Starting monitoring on $WATCH_DIR"

    # Monitor for CREATE events on directories (-r for recursive if you need steps inside jobs)
    # We use --format to get just the filename
    inotifywait -m -r -e create --format '%w%f' "$WATCH_DIR" | while read -r NEW_CGROUP; do
        
        # Check if this is a job or step directory
        if [[ "$NEW_CGROUP" =~ job_[0-9]+ ]]; then
            
            # Run logic in background to not block the watcher loop
            (
                # Wait briefly for the directory structure to settle (cgroup v2 atomicity)
                # A tiny loop is better than a hard sleep
                for i in {1..10}; do
                    if [[ -f "$NEW_CGROUP/memory.oom.group" ]]; then
                        break
                    fi
                    sleep 0.01
                done

                # 1. Enable OOM Group Kill (Kill whole job if one task OOMs)
                echo 1 > "$NEW_CGROUP/memory.oom.group" 2>/dev/null
                
                # 2. Disable Swap (Force 0)
                echo 0 > "$NEW_CGROUP/memory.swap.max" 2>/dev/null
                
                logger -t "$LOG_TAG" "Applied OOM/Swap constraints to $NEW_CGROUP"
            ) &
        fi
    done

.. code-block:: systemd

    # /etc/systemd/system/slurm-cgroup-watcher.service
    [Unit]
    Description=Slurm Cgroup OOM/Swap Enforcer
    After=slurmd.service

    [Service]
    ExecStart=/usr/local/bin/slurm-cgroup-watcher.sh
    Restart=always
    RestartSec=3

    [Install]
    WantedBy=multi-user.target

Module System
^^^^^^^^^^^^^

To ensure we are using Lmod, we will install BOTH environment-modules and Lmod, and set the alternatives to point to Lmod.

This prevents later accidental installation of environment-modules overwriting Lmod as default.

.. code-block:: dockerfile

    RUN dnf install -y environment-modules Lmod \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && alternatives --install /usr/bin/modulecmd modulecmd /usr/share/lmod/lmod/libexec/lmod 40 \
    && alternatives --set modulecmd /usr/share/lmod/lmod/libexec/lmod \
    && alternatives --set modules.sh /usr/share/lmod/lmod/init/profile

Protective Measures
-------------------

Philosophy: Last line of defense built into each node.

Temperature Protection
^^^^^^^^^^^^^^^^^^^^^^

A simple temperature protection script can be easily implemented as your last defense against overheating induced hardware damage.

Exact metric depends on your hardware platform, below is an example for NVIDIA DGX systems using IPMI tool to read ambient temperature sensor.

.. code-block:: systemd

    # /lib/systemd/system/dgx-emergency-shutdown.service
    [Unit]
    Description=Check Ambient Temperature and Shutdown if Too High
    RequiresMountsFor=/dev/ipmi0

    [Service]
    Type=oneshot
    Environment=DEBUG_EXEC=
    Environment=MAX_AMBIENT_TEMP=30
    ExecStart=/bin/bash -c 'TEMP_AMBIENT_VAL="$(/usr/bin/ipmitool -c sdr get TEMP_AMBIENT | cut -d, -f 2)"; if [[ "$TEMP_AMBIENT_VAL" -gt $MAX_AMBIENT_TEMP ]]; then echo "Ambient Temperature $TEMP_AMBIENT_VAL > $MAX_AMBIENT_TEMP, emergency shutting down ..."; $DEBUG_EXEC /sbin/shutdown now; else echo TEMP_AMBIENT=$TEMP_AMBIENT_VAL; fi'

.. code-block:: systemd

    # /lib/systemd/system/dgx-emergency-shutdown.timer
    [Unit]
    Description=Run Temperature Check Every 2 Minutes
    RequiresMountsFor=/dev/ipmi0
    After=multi-user.target

    [Timer]
    OnBootSec=120
    OnUnitActiveSec=120
    Unit=dgx-emergency-shutdown.service

    [Install]
    WantedBy=timers.target

Kernel Lockup Recovery
^^^^^^^^^^^^^^^^^^^^^^^^

.. todo: Use hardware watchdog if available.

.. code-block:: shell

    # Install ipmitool and load modules

    modprobe ipmi_watchdog

    # Configure /etc/sysconfig/ipmi (RHEL specific)
    IPMI_WATCHDOG=yes
    IPMI_WATCHDOG_OPTIONS="timeout=300 action=reset nowayout=0"

    # Enable the service
    systemctl enable --now ipmi
