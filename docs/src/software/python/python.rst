Native Python Module
====================

Native Python installations are available through the Spack package manager with support for multiple versions, virtual environments, and modern package managers.

.. contents:: Table of Contents
   :local:
   :depth: 2

Python Quick Start
------------------

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
   Module names may include a 7-digit hash suffix (e.g., ``python/3.12.9-abc1234``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``3.12``) is sufficient.

Creating Virtual Environments
------------------------------

Python virtual environments allow you to create isolated environments for different projects.

Using venv (Standard Library)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create a virtual environment
   python -m venv myenv
   
   # Activate the environment
   source myenv/bin/activate
   
   # Install packages
   pip install numpy pandas matplotlib
   
   # Deactivate when done
   deactivate

Using uv (Fast Alternative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create virtual environment with uv
   uv venv myenv
   
   # Activate the environment
   source myenv/bin/activate
   
   # Install packages (much faster than pip)
   uv pip install numpy pandas matplotlib
   
   # Deactivate when done
   deactivate

Using PDM (Modern Package Manager)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Initialize a new project
   pdm init
   
   # Add dependencies
   pdm add numpy pandas matplotlib
   
   # Install dependencies
   pdm install
   
   # Run commands in the project environment
   pdm run python script.py

Using Poetry (Dependency Management)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Initialize a new project
   poetry init
   
   # Add dependencies
   poetry add numpy pandas matplotlib
   
   # Install dependencies
   poetry install
   
   # Run commands in the project environment
   poetry run python script.py
   
   # Activate poetry shell
   poetry shell

Package Management
------------------

Using pip
^^^^^^^^^

.. code-block:: bash

   # Install a package
   pip install package_name
   
   # Install specific version
   pip install package_name==1.2.3
   
   # Install from requirements file
   pip install -r requirements.txt
   
   # Upgrade a package
   pip install --upgrade package_name
   
   # List installed packages
   pip list
   
   # Generate requirements file
   pip freeze > requirements.txt

Using uv (Faster Alternative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Install packages (10-100x faster than pip)
   uv pip install numpy pandas matplotlib
   
   # Install from requirements file
   uv pip install -r requirements.txt
   
   # Compile requirements (lock dependencies)
   uv pip compile requirements.in -o requirements.txt

Building C Extensions with Cython
----------------------------------

All Python versions include Cython for building C extensions.

.. code-block:: bash

   # Install Cython (if not already available)
   pip install cython
   
   # Compile a Cython file
   cython mymodule.pyx
   
   # Build with setup.py
   python setup.py build_ext --inplace

SLURM Integration
-----------------

Example batch script using Python virtual environment:

.. code-block:: bash

   #!/bin/bash
   
   ## Your SBATCH settings here
   #SBATCH ...
   
   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
   
   # Load Python
   module load python/3.12
   
   # Activate virtual environment
   source myenv/bin/activate
   
   # Run your Python script
   python my_script.py

Example using uv:

.. code-block:: bash

   #!/bin/bash

   ## Your SBATCH settings here
   #SBATCH ...
   
   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
   
   # Load Python
   module load python/3.12
   
   # Use uv to run in isolated environment
   uv run python my_script.py

Best Practices
--------------

**Virtual Environments**

- Always use virtual environments for projects
- Keep one environment per project
- Use ``requirements.txt`` or ``pyproject.toml`` for reproducibility
- Activate the correct environment before installing packages

**Package Management**

- Consider using ``uv`` for faster package installation
- Pin package versions in production
- Use ``pdm`` or ``poetry`` for dependency management
- Regularly update packages for security

**Performance**

- Use ``uv`` for significantly faster package operations
- Consider ``pdm`` for better dependency resolution
- Use Cython for performance-critical code

Support and Resources
---------------------

**Python Documentation**

- `Python Documentation <https://docs.python.org/3/>`_
- `pip Documentation <https://pip.pypa.io/>`_
- `venv Documentation <https://docs.python.org/3/library/venv.html>`_
- `PyPI (Python Package Index) <https://pypi.org/>`_

**Modern Package Managers**

- `uv Documentation <https://github.com/astral-sh/uv>`_
- `PDM Documentation <https://pdm.fming.dev/>`_
- `Poetry Documentation <https://python-poetry.org/docs/>`_

**Development Tools**

- `Cython Documentation <https://cython.readthedocs.io/>`_
- `Python Packaging Guide <https://packaging.python.org/>`_
