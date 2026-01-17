========================================
Upstream Software Issues and Workarounds
========================================

This document catalogs known issues in upstream software components (operating systems, vendor compilers, hardware drivers) affecting HPC system operation. These issues originate from vendors or open-source projects and are outside direct administrative control. Where available, workarounds enable functionality until upstream resolution.

RHEL 9: Binutils Incompatibility with Modern Instruction Sets
==============================================================

**Issue:** System-provided binutils 2.35 (frozen throughout RHEL 9 lifecycle) lacks support for instruction sets available in binutils 2.36+, including AMD Zen4 optimizations and Intel VNNI instructions. Prevents proper code generation for modern processors.

**Affected versions:** RHEL 9.0-9.7+ (all releases - binutils version frozen at 2.35)

**Upstream status:** No upstream fix available. Red Hat policy freezes binutils version for RHEL major releases. `Red Hat KB article 7049696 <https://access.redhat.com/solutions/7049696>`_ documents VNNI instruction incompatibility.

**Workaround:** Rebuild GCC and binutils from source with binutils 2.36+ support. See Spack configuration for compiler rebuilds with appropriate architecture targets.

**Operational impact:** Affects compilation of architecture-optimized code for AMD Zen4, Intel Sapphire Rapids, and newer processors. Scientific applications may fail to compile or miss performance optimizations without updated toolchain. Workaround requires maintaining custom compiler builds outside distribution package management.

RHEL 9: DMA Driver Unavailable for AMD Zen4
============================================

**Issue:** Direct Memory Access (DMA) driver support missing for AMD Zen4 platforms in earlier RHEL 9 releases. Required drivers ``ptdma`` and ``ae4dma`` unavailable.

**Affected versions:** RHEL 9.0-9.6 (resolved in 9.7)

**Upstream status:** Resolved in RHEL 9.7. While ``ptdma`` module appears in RHEL 9.5 kernel, driver does not function correctly on Zen4 (``/sys/class/dma`` absent despite module load). Functional ``ptdma`` and ``ae4dma`` drivers available in RHEL 9.7 kernel 5.14.0-611+. See `RHEL 9.7 Release Notes - New Drivers <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/9.7_release_notes/index#new_drivers>`_ for driver availability timeline.

**Workaround:** Update to RHEL 9.7 or newer. No workaround available for earlier versions.

**Operational impact:** Potential performance degradation for I/O-intensive workloads on Zen4 hardware running RHEL 9.0-9.6. Issue resolved through normal OS update cycle.

AOCC 5.0: Fortran Compiler Configuration Regression
====================================================

**Issue:** AMD Optimizing C/C++ Compiler (AOCC) 5.0 Fortran compiler (flang) does not read ``flang.cfg`` configuration file, representing a regression from AOCC 4.2 behavior. C/C++ compilers (clang) correctly read ``clang.cfg``.

**Affected versions:** AOCC 5.0.0 (Build #1377, September 2024)

**Upstream status:** Reported to AMD compiler team. No fix or timeline provided by vendor as of January 2026.

**Demonstration:**

.. code-block:: console

   $ clang --version
   AMD clang version 17.0.6 (CLANG: AOCC_5.0.0-Build#1377 2024_09_24)
   Configuration file: .../aocc-5.0.0/bin/clang.cfg          # ✓ Reads config
   
   $ clang -print-libgcc-file-name
   .../gcc-11.5.0/lib/gcc/x86_64-pc-linux-gnu/11.5.0/libgcc.a  # ✓ Correct path
   
   $ flang --version
   AMD clang version 17.0.6 (CLANG: AOCC_5.0.0-Build#1377 2024_09_24)
   # No configuration file loaded                             # ✗ Ignores flang.cfg
   
   $ flang -print-libgcc-file-name
   /usr/lib/gcc/x86_64-redhat-linux/11/libgcc.a               # ✗ Wrong path (system GCC)

Flang falls back to system GCC path (``/usr/lib/gcc``) instead of Spack-provided GCC, causing compilation failures if system GCC is incomplete or incompatible.

**Mitigation:** Ensure detected GCC installation is fully functional. AOCC may fall back to partially installed, non-functional GCC toolchains (e.g., RHEL ``gcc-toolset-12`` incomplete installations), resulting in compilation failures. Verify GCC detection:

.. code-block:: bash

   # Verify flang's detected GCC is functional
   flang -print-libgcc-file-name
   ls -la $(flang -print-libgcc-file-name)  # Should exist and be readable

**Operational impact:** Fortran compilation may fail with non-obvious errors if GCC fallback is misconfigured. Verify GCC functionality before deploying AOCC 5.0 for Fortran workloads. Issue complicates compiler deployment requiring additional validation steps compared to AOCC 4.2.
