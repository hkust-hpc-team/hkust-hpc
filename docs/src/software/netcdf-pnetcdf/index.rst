NetCDF / Parallel-NetCDF Support
================================

NetCDF (Network Common Data Form) and Parallel-NetCDF (PnetCDF) are available through the Spack package manager 
for scientific data storage and parallel I/O operations.

**NetCDF** provides comprehensive support for HDF5 backend, multiple compression formats, and both serial and parallel I/O. 
Both NetCDF-C and NetCDF-Fortran libraries are available.

**Parallel-NetCDF (PnetCDF)** is a high-performance I/O library optimized for parallel access to NetCDF files, 
featuring burst buffering and relaxed consistency semantics for improved performance in MPI applications.

.. contents:: Table of Contents
   :local:
   :depth: 2

NetCDF Quick Start
------------------

.. note::

  For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load a supported compiler and MPI
   module load intel-oneapi-compilers
   module load intel-oneapi-mpi
   
   # Check available NetCDF versions
   module avail netcdf
   
   # Load NetCDF-C
   module load netcdf-c
   
   # Load NetCDF-Fortran
   module load netcdf-fortran
   
   # Verify installation
   nc-config --version
   nf-config --version  # If Fortran loaded

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``netcdf-c/4.9.2-abc1234``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``4.9.2``) is sufficient.

Parallel NetCDF Quick Start
----------------------------

.. note::

  For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load a supported compiler and MPI
   module load intel-oneapi-compilers/2025
   module load intel-oneapi-mpi/2021
   
   # Check available Parallel NetCDF versions
   module avail parallel-netcdf
   
   # Load Parallel NetCDF
   module load parallel-netcdf
   
   # Verify installation
   pnetcdf-config --version

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``parallel-netcdf/1.14.0-abc1234``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``1.14.0``) is sufficient.

Building with NetCDF
---------------------

C Programs
^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export CC=mpicc
   export CFLAGS="$(nc-config --cflags)"
   export LDFLAGS="$(nc-config --libs)"
   
   # Direct compilation example
   $CC -o myprogram myprogram.c $CFLAGS $LDFLAGS

C++ Programs
^^^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export CXX=mpicxx
   export CXXFLAGS="$(nc-config --cflags)"
   export LDFLAGS="$(nc-config --libs)"
   
   # Direct compilation example
   $CXX -o myprogram myprogram.cpp $CXXFLAGS $LDFLAGS

Fortran Programs
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export FC=mpifort
   export FFLAGS="$(nf-config --fflags)"
   export LDFLAGS="$(nf-config --flibs)"
   
   # Direct compilation example
   $FC -o myprogram myprogram.f90 $FFLAGS $LDFLAGS

Using Makefile
^^^^^^^^^^^^^^

.. code-block:: makefile

   CC ?= mpicc
   CXX ?= mpicxx
   FC ?= mpifort
   
   # Set NetCDF related flags
   CFLAGS += $(shell nc-config --cflags)
   CXXFLAGS += $(shell nc-config --cflags)
   FFLAGS += $(shell nf-config --fflags)
   
   LDFLAGS += $(shell nc-config --libs)
   FLDFLAGS += $(shell nf-config --flibs)

   # Build rule for C source files
   .c.o:
   	$(CC) $(CFLAGS) -c $< -o $@
   
   # Build rule for C++ source files
   .cpp.o:
   	$(CXX) $(CXXFLAGS) -c $< -o $@
   
   # Build rule for Fortran source files
   .f90.o:
   	$(FC) $(FFLAGS) -c $< -o $@
   
   # Link example for a C program. For Fortran, use $(FC) and $(FLDFLAGS).
   myprogram: myprogram.o
   	$(CC) -o $@ $^ $(LDFLAGS)

Using CMake
^^^^^^^^^^^

Using FindNetCDF:

.. code-block:: cmake

   find_package(NetCDF REQUIRED)
   
   target_link_libraries(myprogram PRIVATE netCDF::netcdf)

Using pkg-config in CMake:

.. code-block:: cmake

   find_package(PkgConfig REQUIRED)
   pkg_check_modules(NETCDF REQUIRED IMPORTED_TARGET netcdf)
   
   target_link_libraries(myprogram PRIVATE PkgConfig::NETCDF)

Using pkg-config
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Query flags for NetCDF-C
   pkgconf --cflags --keep-system-cflags netcdf
   pkgconf --libs --keep-system-libs netcdf
   
   # Query flags for NetCDF-Fortran
   pkgconf --cflags --keep-system-cflags netcdf-fortran
   pkgconf --libs --keep-system-libs netcdf-fortran
   
   # Use in compilation
   export CC=mpicc
   export CFLAGS="$(pkgconf --cflags --keep-system-cflags netcdf)"
   export LDFLAGS="$(pkgconf --libs --keep-system-libs netcdf)"

Building with Parallel NetCDF
------------------------------

C Programs
^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export CC=mpicc
   export CFLAGS="$(pnetcdf-config --cflags)"
   export LDFLAGS="$(pnetcdf-config --libs)"
   
   # Direct compilation example
   $CC -o myprogram myprogram.c $CFLAGS $LDFLAGS

C++ Programs
^^^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export CXX=mpicxx
   export CXXFLAGS="$(pnetcdf-config --cflags)"
   export LDFLAGS="$(pnetcdf-config --libs)"
   
   # Direct compilation example
   $CXX -o myprogram myprogram.cpp $CXXFLAGS $LDFLAGS

Fortran Programs
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Export compiler and linker flags for Makefiles
   export FC=mpifort
   export FFLAGS="$(pnetcdf-config --fflags)"
   export LDFLAGS="$(pnetcdf-config --flibs)"
   
   # Direct compilation example
   $FC -o myprogram myprogram.f90 $FFLAGS $LDFLAGS

Using Makefile
^^^^^^^^^^^^^^

.. code-block:: makefile

   CC ?= mpicc
   CXX ?= mpicxx
   FC ?= mpifort
   
   # Set Parallel NetCDF related flags
   CFLAGS += $(shell pnetcdf-config --cflags)
   CXXFLAGS += $(shell pnetcdf-config --cflags)
   FFLAGS += $(shell pnetcdf-config --fflags)
   
   LDFLAGS += $(shell pnetcdf-config --libs)
   FLDFLAGS += $(shell pnetcdf-config --flibs)

   # Build rule for C source files
   .c.o:
   	$(CC) $(CFLAGS) -c $< -o $@
   
   # Build rule for C++ source files
   .cpp.o:
   	$(CXX) $(CXXFLAGS) -c $< -o $@
   
   # Build rule for Fortran source files
   .f90.o:
   	$(FC) $(FFLAGS) -c $< -o $@
   
   # Link example for a C program. For Fortran, use $(FC) and $(FLDFLAGS).
   myprogram: myprogram.o
   	$(CC) -o $@ $^ $(LDFLAGS)

Using pkg-config
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Query flags for Parallel NetCDF
   pkgconf --cflags --keep-system-cflags pnetcdf
   pkgconf --libs --keep-system-libs pnetcdf
   
   # Use in compilation
   export CC=mpicc
   export CFLAGS="$(pkgconf --cflags --keep-system-cflags pnetcdf)"
   export LDFLAGS="$(pkgconf --libs --keep-system-libs pnetcdf)"

Features Availability
---------------------

NetCDF-C Features
^^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 35 45 20

   * - Feature
     - Description
     - Enabled
   * - **Parallel I/O**
     - MPI-based parallel file access
     - ✓
   * - **NetCDF-4/HDF5 Format**
     - Full NetCDF-4 and HDF5 backend support
     - ✓
   * - **Parallel NetCDF (PnetCDF)**
     - High-performance parallel I/O library
     - ✓
   * - **Standard Filters**
     - Compression filters: deflate, bz2, blosc, zstd
     - ✓
   * - **ZSTD Compression**
     - Modern compression algorithm
     - ✓
   * - **SZIP Compression**
     - Lossless compression support
     - ✓
   * - **Multi-filters**
     - Multiple compression filters support
     - ✓
   * - **NetCDF-2 Classic Format**
     - Legacy classic format support
     - ✓
   * - **CDF-5 Format**
     - Large variable support (>2GB)
     - ✓
   * - **NCZarr**
     - Cloud-optimized Zarr format support
     - ✓
   * - **Logging**
     - Debug and diagnostic logging
     - ✓
   * - **HDF4 Format**
     - Legacy HDF4 format support
     - ✗
   * - **DAP2/DAP4 Protocol**
     - Remote data access protocols
     - ✗
   * - **Benchmarks**
     - Performance benchmarking tools
     - ✗

Parallel NetCDF Features
^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 35 45 20

   * - Feature
     - Description
     - Enabled
   * - **Burst Buffering**
     - Improved I/O performance via buffering
     - ✓
   * - **Erange Fill**
     - Fill values for out-of-range errors
     - ✓
   * - **Relax Coordinate Boundary**
     - Relaxed coordinate boundary checking
     - ✓
   * - **In-place Swap**
     - Automatic byte-swapping
     - Auto
   * - **NetCDF-4 Format**
     - NetCDF-4/HDF5 format support
     - ✗
   * - **Thread-safe**
     - Thread-safe operations
     - ✗
   * - **Subfiling**
     - Subfiling for improved parallel I/O
     - ✗
   * - **ADIOS Integration**
     - ADIOS I/O framework integration
     - ✗
   * - **Profiling**
     - Performance profiling support
     - ✗
   * - **Debug Mode**
     - Debug mode with additional checks
     - ✗
   * - **Null-byte Header Padding**
     - Header padding for alignment
     - ✗

Support and Resources
---------------------

**NetCDF Documentation**

- `NetCDF-C Documentation <https://docs.unidata.ucar.edu/netcdf-c/current/>`_
- `NetCDF-Fortran Documentation <https://docs.unidata.ucar.edu/netcdf-fortran/current/>`_

**Parallel-NetCDF Documentation**

- `Parallel-NetCDF Official Site <https://parallel-netcdf.github.io/>`_
- `PnetCDF C Programming Interface Reference <https://parallel-netcdf.github.io/doc/c-reference/pnetcdf-c/index.html>`_
