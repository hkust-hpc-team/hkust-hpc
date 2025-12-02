Python Support
==============

Python is available through the Spack package manager with support for 
multiple versions, package managers, and development tools.

.. contents:: Table of Contents
   :local:
   :depth: 2

Python Quick Start
--------------------

.. note::

  For the value of ``${SPACK_ROOT}``, Please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Check available Python versions
   module avail python
   
   # Load Python
   module load python/3.12
   
   # Verify installation
   python --version
   pip --version

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``python/3.12-7r5y3as``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``3.12``) is sufficient.

Anaconda Quick Start
----------------------

.. note::

  For the value of ``${SPACK_ROOT}``, Please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load Anaconda
   module load anaconda3
   
   # Initialize conda for your shell (required once)
   conda init
   
   # Restart your shell or source your profile
   source ~/.bashrc
   
   # Verify installation
   conda --version
   python --version

Features Availability
---------------------

.. list-table::
   :header-rows: 1
   :widths: 25 15 15 15 15 15

   * - Feature / Version
     - 3.9
     - 3.10
     - 3.11
     - 3.12
     - 3.13
   * - **Installed**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **pip/wheel**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **venv**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **pdm**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **poetry**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **uv**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓
   * - **Cython**
     - ✓
     - ✓
     - ✓
     - ✓
     - ✓

Support and Resources
---------------------

**Python Documentation**

- `Python Documentation <https://docs.python.org/3/>`_
- `pip Documentation <https://pip.pypa.io/>`_
- `PyPI (Python Package Index) <https://pypi.org/>`_
- `venv Documentation <https://docs.python.org/3/library/venv.html>`_
- `PDM Documentation <https://pdm.fming.dev/>`_
- `Poetry Documentation <https://python-poetry.org/docs/>`_
- `uv Documentation <https://github.com/astral-sh/uv>`_

**Anaconda Documentation**

- `Anaconda Documentation <https://docs.anaconda.com/>`_
- `Conda Documentation <https://docs.conda.io/>`_
- `Anaconda Repository <https://repo.anaconda.com/>`_
