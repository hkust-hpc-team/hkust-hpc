=============
Known Issues
=============

This document catalogs known software issues in HPC system components, providing workarounds where available. Issues are organized by affected software and include status, mitigation strategies, and operational impact.

RHEL 9: Binutils Incompatibility with AMD Zen4
===============================================

**Issue:** System-provided binutils lacks support for AMD Zen4 instruction sets, preventing proper code generation for Zen4 and newer processors.

**Status:** No upstream fix available in RHEL 9 base repository.

**Workaround:** Rebuild GCC and binutils from source with Zen4 support enabled. See Spack configuration for compiler rebuilds with appropriate architecture targets.

**Impact:** Affects compilation of architecture-optimized code. Scientific applications may fail to compile or miss performance optimizations without updated toolchain.

RHEL 9: DMA Driver Unavailable for AMD Zen4
============================================

**Issue:** Direct Memory Access (DMA) driver support missing for AMD Zen4 platforms in earlier RHEL 9 releases.

**Status:** Resolved in RHEL 9.7 and later.

**Workaround:** Update to RHEL 9.7 or newer. No workaround available for earlier versions.

**Impact:** Potential performance degradation for I/O-intensive workloads on Zen4 hardware running RHEL 9.0-9.6.

AOCC 5.0: Fortran Compiler Configuration Regression
====================================================

**Issue:** AMD Optimizing C/C++ Compiler (AOCC) 5.0 Fortran compiler (flang) does not read ``flang.cfg`` configuration file, representing a regression from AOCC 4.2 behavior.

**Status:** No fix or workaround available from vendor.

**Mitigation:** Ensure detected GCC installation is fully functional. AOCC may fall back to partially installed, non-functional GCC toolchains (e.g., RHEL ``gcc-toolset-12`` incomplete installations), resulting in compilation failures.

**Impact:** Fortran compilation may fail with non-obvious errors if GCC fallback is misconfigured. Verify GCC functionality before deploying AOCC 5.0 for Fortran workloads.
