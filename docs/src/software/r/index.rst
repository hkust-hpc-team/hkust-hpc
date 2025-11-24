R and RStudio Support
======================

R is available through the Spack package manager with support for 
statistical computing, CRAN package management, and RStudio IDE.

.. contents:: Table of Contents
   :local:
   :depth: 2

R Quick Start
-------------

.. code-block:: bash

   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-envs.sh -y
   
   # Check available R versions
   module avail r
   
   # Load R
   module load r/4.4
   
   # Verify installation
   R --version
   
   # Start R
   R                           # Interactive mode
   R --quiet --no-save        # Quiet mode
   
   # Run a script
   Rscript my_script.R

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``r/4.4.2-4pchx4a``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``4.4``) is sufficient.

RStudio Quick Start
-------------------

.. code-block:: bash

   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-envs.sh -y
   
   # Load RStudio (will automatically load R 4.x)
   module load rstudio
   
   # Or explicitly specify R version (recommended)
   module load r/4.4
   module load rstudio
   
   # Launch RStudio (requires GUI/X11)
   rstudio

.. note::
   RStudio will automatically load a compatible R 4.x backend if you don't 
   specify one. However, it's recommended to explicitly load your preferred 
   R version first to ensure consistency.

Tutorials
---------

.. toctree::
   :maxdepth: 1
   :titlesonly:

Features Availability
---------------------

.. list-table::
   :header-rows: 1
   :widths: 30 20 20 30

   * - Feature / Version
     - R 3.x
     - R 4.x
     - RStudio 2024
   * - **Installed**
     - ✗
     - ✓
     - ✓
   * - **R Interpreter**
     - Not supported
     - ✓
     - R 4.x only
   * - **Rscript Command**
     - ✗
     - ✓
     - N/A
   * - **CRAN Package Manager**
     - ✗
     - ✓
     - ✓
   * - **SLURM Compatibility**
     - ✗
     - ✓
     - ✗

Environment Variables
---------------------

When loading the R module, the following environment variables are set automatically.

R_HOME
^^^^^^
Points to the R installation directory.

**Default:** ``<install-prefix>/rlib/R``

R_LIBS_USER
^^^^^^^^^^^
Specifies the user-specific library directory for R packages. Packages installed via ``install.packages()`` are stored here.

**Default:** ``$HOME/.R/R-<version>-<compiler>-<target>/library``

.. note::
   These environment variables are automatically configured when you load the R module. 
   You typically don't need to modify them manually. 

Support and Resources
---------------------

**R Documentation**

- `R Documentation <https://www.r-project.org/other-docs.html>`_
- `CRAN (Comprehensive R Archive Network) <https://cran.r-project.org/>`_
- `renv Documentation <https://rstudio.github.io/renv/>`_
- `Bioconductor <https://www.bioconductor.org/>`_

**RStudio Documentation**

- `RStudio Documentation <https://docs.posit.co/ide/user/>`_
- `RStudio IDE Guide <https://support.posit.co/hc/en-us/sections/200107586-Using-the-RStudio-IDE>`_
