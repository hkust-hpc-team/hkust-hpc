Libxc (Exchange-Correlation Functionals Library)
================================================

Libxc is a library of exchange-correlation functionals for density-functional theory (DFT). 
It provides a comprehensive collection of local and semi-local functionals, hybrid functionals, 
and meta-GGA functionals, widely used in quantum chemistry and solid-state physics applications.

Libxc is available through the Spack package manager with support for multiple compiler toolchains 
including AMD AOCC, Intel OneAPI, and Intel Classic compilers.

.. contents:: Table of Contents
   :local:
   :depth: 2

Quick Start
-----------

.. note::

  For the value of ``${SPACK_ROOT}``, please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load a supported compiler
   module load intel-oneapi-compilers
   
   # Check available Libxc versions
   module avail libxc
   
   # Load Libxc
   module load libxc
   
   # Verify installation
   module list | grep libxc

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``libxc/7.0.0-abc1234``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``7.0.0``) is sufficient.

Building Applications with Libxc
---------------------------------

Using CMake
^^^^^^^^^^^

**Using find_package:**

.. code-block:: cmake

   # Libxc provides CMake config files
   find_package(Libxc REQUIRED)
   
   # For C/C++ programs
   target_link_libraries(myprogram PRIVATE Libxc::xc)
   
   # For Fortran programs
   target_link_libraries(myfortranprogram PRIVATE Libxc::xcf03)

**Using pkg-config in CMake:**

.. code-block:: cmake

   find_package(PkgConfig REQUIRED)
   pkg_check_modules(LIBXC REQUIRED IMPORTED_TARGET libxc)
   
   # For C/C++ programs
   target_link_libraries(myprogram PRIVATE PkgConfig::LIBXC)
   
   # For Fortran programs
   pkg_check_modules(LIBXCF03 REQUIRED IMPORTED_TARGET libxcf03)
   target_link_libraries(myfortranprogram PRIVATE PkgConfig::LIBXCF03)

Using pkg-config
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Query flags for Libxc (C/C++)
   pkg-config --cflags libxc
   pkg-config --libs libxc
   
   # Query flags for Libxc Fortran interface
   pkg-config --cflags libxcf03
   pkg-config --libs libxcf03
   
   # Use in compilation
   export CC=gcc
   export CFLAGS="$(pkg-config --cflags libxc)"
   export LDFLAGS="$(pkg-config --libs libxc)"
   
   # Compile
   $CC -o myprogram myprogram.c $CFLAGS $LDFLAGS

Integration with DFT Codes
---------------------------

Libxc is commonly integrated with various density-functional theory codes. Below are examples 
for popular scientific computing applications.


Features and Capabilities
--------------------------

Exchange-Correlation Functionals
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Libxc provides a comprehensive collection of exchange-correlation functionals:

.. list-table::
   :header-rows: 1
   :widths: 35 45 20

   * - Category
     - Description
     - Available
   * - **LDA Functionals**
     - Local Density Approximation functionals
     - ✓
   * - **GGA Functionals**
     - Generalized Gradient Approximation functionals
     - ✓
   * - **Hybrid Functionals**
     - Hybrid functionals (e.g., B3LYP, PBE0)
     - ✓
   * - **Meta-GGA Functionals**
     - Meta-GGA functionals (e.g., TPSS, SCAN)
     - ✓
   * - **3rd Order Derivatives**
     - Third-order functional derivatives
     - ✓
   * - **4th Order Derivatives**
     - Fourth-order functional derivatives
     - ✓

Supported Interfaces
^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 35 45 20

   * - Interface
     - Description
     - Available
   * - **C Interface**
     - Native C API
     - ✓
   * - **C++ Interface**
     - C++ wrapper (uses C interface)
     - ✓
   * - **Fortran 2003 Interface**
     - Modern Fortran 2003 API
     - ✓
   * - **Python Interface**
     - Python bindings
     - pylibxc

Library Variants
^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1
   :widths: 35 45 20

   * - Variant
     - Description
     - Available
   * - **Shared Libraries**
     - Dynamic linking support (.so files)
     - ✓
   * - **Static Libraries**
     - Static linking support (.so files)
     - ✗
   * - **MPI Support**
     - Direct MPI integration
     - Not required


Compiling from Source
---------------------

For users who need specific build options or want to compile Libxc from source, 
please refer to the compilation guide:

:doc:`Libxc Compilation Guide </compile-guides/libxc>`

The compilation guide provides detailed instructions for building Libxc with various 
compiler toolchains (AMD AOCC, Intel OneAPI, Intel Classic) and custom configurations.

Support and Resources
---------------------

**Official Documentation**

- `Libxc Website <https://libxc.gitlab.io/>`_
- `Libxc GitLab Repository <https://gitlab.com/libxc/libxc>`_
- `API Documentation <https://libxc.gitlab.io/manual/>`_

**Citations**

If you use Libxc in your research, please cite the following papers:

- S. Lehtola, C. Steigemann, M.J.T. Oliveira, and M.A.L. Marques, *Software X* **7**, 1 (2018)
  DOI: `10.1016/j.softx.2017.11.002 <https://doi.org/10.1016/j.softx.2017.11.002>`_
