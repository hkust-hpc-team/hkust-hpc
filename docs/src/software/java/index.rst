Java
====

Java (OpenJDK) is available through the Spack package manager with support for 
compiling and running Java applications across multiple Java versions.

.. contents:: Table of Contents
   :local:
   :depth: 2

Quick Start
-----------

.. note::

  For the value of ``${SPACK_ROOT}``, Please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Check available Java versions
   module avail openjdk
   
   # Load Java (default is Java 17)
   module load openjdk
   
   # Or load a specific version
   module load openjdk/11
   
   # Verify installation
   java -version
   javac -version
   
   # Compile and run a Java program
   javac HelloWorld.java
   java HelloWorld

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``openjdk/17.0.11_9-ythui6n``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``17`` or ``11``) is sufficient.

Tutorials
---------

.. toctree::
   :maxdepth: 1
   :titlesonly:

Features Availability
---------------------

.. list-table::
   :header-rows: 1
   :widths: 30 20 20 20 20

   * - Feature / Version
     - Java 8
     - Java 11
     - Java 17
     - Others :sup:`[1]`
   * - **Installed**
     - ✓
     - ✓
     - ✓ (Default)
     - ✗ :sup:`[1]`
   * - **Provider**
     - OpenJDK
     - OpenJDK
     - OpenJDK
     - OpenJDK / Oracle JDK
   * - **Java Compiler (javac)**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Java Runtime (java)**
     - ✓
     - ✓
     - ✓
     - ✓
   * - **SLURM Compatibility**
     - ✓
     - ✓
     - ✓
     - ✓

**Notes:**

:sup:`[1]` **Others (Java versions):** Can be installed on your own via Spack (not pre-installed as module). Self-installed versions have not been tested by HPC team.

Environment Variables
---------------------

When loading the OpenJDK module, the following environment variables are set automatically.

JAVA_HOME
^^^^^^^^^
Points to the Java installation directory.

**Default:** ``<install-prefix>``

.. note::
   These environment variables are automatically configured when you load the OpenJDK module. 
   You typically don't need to modify them manually.

Support and Resources
---------------------

**Java Documentation**

- `OpenJDK Documentation <https://openjdk.org/>`_
- `Java SE Documentation <https://docs.oracle.com/en/java/javase/>`_
