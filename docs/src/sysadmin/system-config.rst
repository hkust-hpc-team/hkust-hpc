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

Systemd Services
^^^^^^^^^^^^^^^^

Time Synchronization
"""""""""""""""""""""

.. code-block:: bash

    # Setup time synchronization
    # Config /etc/chrony.conf as per environment
    systemctl enable --now chronyd.service

Entropy Generation
""""""""""""""""""

.. code-block:: bash

    # Improve entropy availability for RNG use, e.g. for SSHD, SSL, etc.
    systemctl enable --now rngd

CPU Power Management
""""""""""""""""""""

We will config for a performance profile during compute jobs, and a power-saving profile when idle.

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

.. code-block:: systemd

    # Example config:
    # $ cat /sys/devices/system/cpu/cpu/cpufreq/cpuinfo_{min,max}_freq
    #   1500000
    #   3100341
    # $ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    #   2250000 1800000 1500000
    # $ sudo cpupower idle-info
    #   CPUidle driver: acpi_idle
    #   CPUidle governor: menu
    #   analyzing CPU 239:
    #   
    #   Number of idle states: 3
    #   Available idle states: POLL C1 C2
    #   POLL:
    #   Flags/Description: CPUIDLE CORE POLL IDLE
    #   Latency: 0
    #   ...
    #   C1:
    #   Flags/Description: ACPI FFH MWAIT 0x0
    #   Latency: 1
    #   ...
    #   C2:
    #   Flags/Description: ACPI IOPORT 0x414
    #   Latency: 800
    #   ...

    # /etc/sysconfig/cpupower
    # We have min freq of 1.5GHz, max freq of 3.1GHz, baseline freq of 2.25GHz
    CPUPOWER_START_OPTS="frequency-set -g performance --min 2250000 --max 3100341"
    CPUPOWER_STOP_OPTS="frequency-set -g ondemand --min 1500000 --max 2250000"
    # For idle state, we have C2 with 800us latency, so disable C2 and deeper states
    CPUPOWER_START_IDLE_OPTS="idle-set --disable 2"
    CPUPOWER_STOP_IDLE_OPTS="idle-set --enable-all"
    
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

This can then be integrated to SLURM as job prolog/epilog scripts (root portion) to set performance profile during job execution, and power-saving profile when idle.

.. code-block:: bash

    # /etc/slurm/job-prolog.sh
    #!/bin/bash
    # Job starts, unconditionally start cpupower service to set performance profile
    systemctl start cpupower.service

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

.. code-block:: console

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

.. code-block:: console

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

Network Stack
-------------

TCP/IP
^^^^^^

This benefits TCP/IP over IB/RoCEv2 tuning as well as general network stack tuning.

Disable IRQ Balance
"""""""""""""""""""
"
.. code-block:: bash

    # Disable irqbalance to enable manual control of IRQ affinity
    # Or alternatively use one-shot to set affinity on boot BEFORE running RoCEv2 tuning scripts
    # This prevent jitters every 10s or so
    systemctl disable --now irqbalance

Additional Tunables
"""""""""""""""""""

.. TODO: Check for wmem and optmem, these should be set, also the tcp parameters as listed here https://wiki.archlinux.org/title/Network_configuration

.. code-block:: bash

    # Legacy shm parameters, may not be needed
    kernel.shmall=4294967296
    kernel.shmmax=4294967296
    kernel.shmmni=20960

    # TCP parameters
    net.core.netdev_budget_usecs=8000
    net.core.optmem_max=81920
    net.core.rmem_default=262144
    net.core.rmem_max=262144


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

NFS client Tuning
^^^^^^^^^^^^^^^^^

.. code-block:: console

    # read-only large amount of small program files (LD_LIBRARY_PATH, python etc.)
    ro,noatime,vers=3,rsize=1048576,wsize=1048576,acregmin=10,hard,forcerdirplus,proto=tcp,nconnect=16,timeo=600,retrans=2,sec=sys,fsc,local_lock=none,lookupcache=all

    # use attr cache cache=pos when there are frequent writes to files 
    rw,relatime,vers=3,rsize=1048576,wsize=1048576,hard,forcerdirplus,proto=tcp,nconnect=16,timeo=600,retrans=2,sec=sys,fsc,local_lock=none,lookupcache=pos

Lustre Client Tuning
^^^^^^^^^^^^^^^^^^^^

.. TODO: Lustre Persistent Client Cache, otherwise it is more straightforward, since it is via IB.

User Environment
----------------

Environment Defaults
^^^^^^^^^^^^^^^^^^^^

.. TODO: Extract from admin/login nodes
.. code-block:: console

    # /etc/skel
    # /etc/profile.d/*.sh
    # /etc/bashrc

Resource Limits and Quotas
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. TODO: Extract from current Login Node setup
.. code-block:: console

    # /etc/security/limits.d/*.conf
    * soft      memlock    unlimited
    * hard      memlock    unlimited
    * soft      stack      unlimited
    * hard      stack      unlimited
    # For AI workload you need a lot of open files for loading data using large number of threads
    * soft      nofile     1048576
    * hard      nofile     1048576

    # /etc/sysconfig/systemd/system/user-.scope.d

SLURM Resource Limits
^^^^^^^^^^^^^^^^^^^^^

Slurm uses slurmstepd to enforce per-job resource limits via cgroup-v2, the configuration is in /etc/slurm/cgroup.conf.

Regular ``/etc/security/limits`` does not apply, since the limit is inherited from slurmstepd. 

.. TODO: Extract from current SLURM setup
.. code-block:: console

    # /etc/slurm/cgroup.conf
    # /etc/systemd/system/slurm-*.service.d/*.conf

.. TODO: SLURM resource limit is buggy even with cgroup-v2, we need a BPF-based script to enforce per-job resource limit, otherwise OOM killer does not work.

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

Temperature Protection
^^^^^^^^^^^^^^^^^^^^^^

A simple temperature protection script can be easily implemented as your last defense against overheating induced hardware damage.

Exact metric depends on your hardware platform, below is an example for NVIDIA DGX systems using IPMI tool to read ambient temperature sensor.

.. code-block:: systemd

    # systemctl cat dgx-emergency-shutdown.service 
    # /lib/systemd/system/dgx-emergency-shutdown.service
    [Unit]
    Description=Check Ambient Temperature and Shutdown if Too High
    RequiresMountsFor=/dev/ipmi0

    [Service]
    Type=oneshot
    Environment=DEBUG_EXEC=
    Environment=MAX_AMBIENT_TEMP=30
    ExecStart=/bin/bash -c 'TEMP_AMBIENT_VAL="$(/usr/bin/ipmitool -c sdr get TEMP_AMBIENT | cut -d, -f 2)"; if [[ "$TEMP_AMBIENT_VAL" -gt $MAX_AMBIENT_TEMP ]]; then echo "Ambient Temperature $TEMP_AMBIENT_VAL > $MAX_AMBIENT_TEMP, emergency shutting down ..."; $DEBUG_EXEC /sbin/shutdown now; else echo TEMP_AMBIENT=$TEMP_AMBIENT_VAL; fi'

    # systemctl cat dgx-emergency-shutdown.timer 
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

Hardware Watchdog for Kernel Lockups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    Enhancement ideas: Use hardware watchdog
    # Install ipmitool and load modules

    modprobe ipmi_watchdog

    # Configure /etc/sysconfig/ipmi (RHEL specific)
    IPMI_WATCHDOG=yes
    IPMI_WATCHDOG_OPTIONS="timeout=300 action=reset nowayout=0"

    # Enable the service
    systemctl enable --now ipmi
