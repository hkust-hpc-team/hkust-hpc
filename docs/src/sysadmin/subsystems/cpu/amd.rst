AMD 9004 CPU
============

AMD EPYC 9004 series (Genoa/Bergamo) introduces several key features that benefit HPC
workloads

- **Zen 4 cores**: Up to 128 cores per socket with improved IPC (Instructions Per Clock)
- **DDR5 support**: Up to DDR5-4800 with 12 memory channels per socket
- **Higher PCIe lane count**: 128 lanes of PCIe 5.0 for high-speed I/O and accelerators
- **Advanced Vector Extensions (AVX-512)**: Full AVX-512 support for vectorized
  workloads
- **3D V-Cache** (select models): Additional L3 cache for memory-intensive applications
- **Improved NUMA topology**: Better memory locality with configurable NUMA domains
- **Enhanced security**: Hardware-level security features without performance penalty

.. contents:: Table of Contents
    :local:
    :depth: 2

BIOS Config
-----------

Optimal BIOS configuration is crucial for achieving maximum performance from AMD EPYC
processors in HPC environments [1]_ [2]_ [3]_ .

The settings below are tuned for based on a variety of HPC/AI benchmarks, this should
serve as a good starting point for most workloads. For optimal performance on specific
workload, one may further finetune based on an application-specific benchmark.

After making changes, one should always perform a full power cycle to ensure all BIOS
settings are applied, then confirm the number of cores reported in BIOS and OS.

.. warning::

    There maybe a BIOS bug with some setting combinations where the reported number of
    cores is incorrect after **performing a full power cycle**.

Dell OpenManage BIOS
~~~~~~~~~~~~~~~~~~~~

Dell OpenManage provides XML-based configuration for Dell PowerEdge servers. For AMD
EPYC systems, you can use the following XML snippet to configure BIOS settings:

.. code-block:: xml

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

AMI Aptio BIOS
~~~~~~~~~~~~~~

.. note::

    Some settings show ``Auto`` may imply the same value as the explicit setting
    ``Enabled``. We list explicit values to ensure consistency across different BIOS
    versions.

**AMD CBS (Custom BIOS Settings)**:

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

Kernel Parameters
-----------------

To optimize the performance of AMD EPYC processors, you can use specific kernel
parameters [2]_ . These parameters can be added to the kernel command line in your
bootloader configuration (e.g., GRUB).

.. code-block::

    amd_pstate=active iommu=pt

- ``amd_pstate=active``: Enables the AMD P-State driver, which provides OS-level control
  over CPU frequency and power management.
- ``iommu=pt``: Enables pass-through mode for better performance with virtual machines
  and containers.

AMD-specific Kernel Modules
---------------------------

Specific kernel version provides additional AMD-specific modules that enhance
performance and functionality, below lists the modules available in different kernel
versions.

- ``amd_atl``: AMD Address Translation Library for enhanced memory management
- ``ptdma``: Platform DMA driver for improved data movement
- ``ae4dma``: Advanced Enhanced DMA driver for next-generation AMD platforms

.. list-table::
    :header-rows: 1
    :widths: 25 25 50

    - - AMD Kernel Modules
      - Required Kernel Version
      - RHEL 9 Backport (Kernel 5.14)
    - - ``amd_atl``
      - 6.8
      - el9_4
    - - ``ptdma``
      - 6.8 (TBC)
      - el9_7 (TBC)
    - - ``ae4dma``
      - 6.14
      - Unknown

References
----------

.. [1] AMD EPYC 9004 Tuning Guide.
    https://www.amd.com/content/dam/amd/en/documents/epyc-technical-docs/tuning-guides/58011-epyc-9004-tg-bios-and-workload.pdf

.. [2] AMD EPYC 9004 HPC Tuning Guide.
    https://www.amd.com/content/dam/amd/en/documents/epyc-technical-docs/tuning-guides/58002_amd-epyc-9004-tg-hpc.pdf

.. [3] NVIDIA NGC Multi-node Performance Tuning.
    https://github.com/Mellanox/ngc_multinode_perf?tab=readme-ov-file#tuning-instructions-and-hwfw-requirements

.. [4] https://www.phoronix.com/news/AMD-Address-Translation-Library

.. [5] kernel-headers-5.14.0-585.el9 From CentOS Stream 9 AppStream.
    https://fr.rpmfind.net/linux/RPM/centos-stream/9/appstream/x86_64/kernel-headers-5.14.0-585.el9.x86_64.html
