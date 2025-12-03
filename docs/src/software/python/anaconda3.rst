Anaconda3 Python Distribution
=============================

Anaconda3 is a comprehensive Python distribution with conda package manager, pre-installed scientific libraries, and environment management capabilities.

.. contents:: Table of Contents
   :local:
   :depth: 2

Anaconda3 Quick Start
---------------------

Anaconda3 activation is a bit different from typical module loads, as setting up ``.bashrc`` is required, the process is automatic.

When you load the ``anaconda3`` module for the first time, it creates ``~/.bashrc.d/anaconda3.sh`` which will automatically activate conda on your next login.

For immediate use in the current session, ``source ~/.bashrc.d/anaconda3.sh`` manually.

.. note::

  For the value of ``${SPACK_ROOT}``, Please refer to :ref:`Spack Instances <spack-instances>` for the installation path.

.. code-block:: bash

   # Modify this path accordingly
   export SPACK_ROOT="/path/to/spack"

   # Activate Spack environment
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   
   # Load Anaconda3 module
   module load anaconda3
   
   # Activate conda for current session
   source ~/.bashrc.d/anaconda3.sh
   
   # Verify installation
   conda --version
   python --version



Creating and Managing Environments
-----------------------------------

Conda environments allow you to create isolated Python environments with specific package versions.

Create a New Environment
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Create environment with specific Python version
   conda create -n myenv python=3.11
   
   # Create environment with packages
   conda create -n myenv python=3.11 numpy pandas matplotlib
   
   # Create from environment file
   conda env create -f environment.yml

Activate and Deactivate Environments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Activate an environment
   conda activate myenv
   
   # Deactivate current environment
   conda deactivate
   
   # List all environments
   conda env list

Installing Packages
^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Install packages from conda
   conda install numpy scipy matplotlib
   
   # Install from specific channel
   conda install -c conda-forge package_name
   
   # Install using pip (when conda package not available)
   pip install package_name
   
   # Search for packages
   conda search package_name

Importing Environment from Another System
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you have an existing conda environment from another system (e.g., your local machine), you can recreate it on the HPC cluster.

**On your source system (e.g., local machine):**

.. code-block:: bash

   # Export environment to a YAML file
   conda env export > environment.yml
   
   # Or export with explicit package specifications only
   conda env export --from-history > environment.yml

**Transfer the file to HPC and recreate:**

.. code-block:: bash

   # On HPC cluster, after loading anaconda3
   module load anaconda3
   source ~/.bashrc.d/anaconda3.sh
   
   # Create environment from the exported file
   conda env create -f environment.yml
   
   # Activate the new environment
   conda activate myenv

.. tip::
   Using ``--from-history`` exports only explicitly installed packages, which is more portable across different platforms and operating systems.

Managing Environments
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # List all environments
   conda env list
   
   # Clone an environment
   conda create --name newenv --clone oldenv
   
   # Remove an environment
   conda env remove -n myenv
   
   # Update all packages in current environment
   conda update --all
   
   # List packages in current environment
   conda list

SLURM Integration
-----------------

Example batch script using Anaconda3 environment:

.. code-block:: bash

   #!/bin/bash

   ## Your SBATCH settings here
   #SBATCH ...
   
   # Activate your conda environment
   conda activate myenv
   
   # Run your Python script
   python my_script.py

Uninstall Anaconda
------------------

If you no longer wish to use the provided Anaconda3 module and prefer to use your own installation, follow these steps:

.. code-block:: bash

   # Remove the Anaconda3 activation script
   rm -f ~/.bashrc.d/anaconda3.sh
   
   # Log out and log back in for changes to take effect
   logout

After logging back in, the provided conda will no longer be automatically activated. You can then install your own Anaconda/Miniconda in your home directory.

.. note::
   Removing ``~/.bashrc.d/anaconda3.sh`` only stops the automatic activation. Your existing conda environments remain in ``~/.conda/envs``.

Best Practices
--------------

**Environment Management**

- Create separate environments for different projects
- Use ``environment.yml`` files for reproducibility
- Specify package versions in environment files
- Regularly update packages in your environments

**Package Installation**

- Prefer conda packages over pip when available
- Install all conda packages first, then pip packages
- Use specific channels (e.g., conda-forge) for specialized packages
- Keep a record of installed packages

**Storage Considerations**

- Conda environments can be large; monitor your home directory quota
- Consider cleaning package cache: ``conda clean --all``
- Remove unused environments to save space

Troubleshooting
---------------

**Environment activation fails**

.. code-block:: bash

   # Reinitialize conda
   source ~/.bashrc.d/anaconda3.sh
   conda activate myenv

**Package installation conflicts**

.. code-block:: bash

   # Switch to the newest Anaconda3 module
   export SPACK_ROOT="/path/to/spack"
   source "${SPACK_ROOT}/dist/bin/setup-env.sh" -y
   module load anaconda3
   
   # Logout then login again to refresh environment
   logout

   # Activate the environment and try installing again
   conda install package_name

   # If not working, try installing with --force-reinstall
   conda install --force-reinstall package_name

**Disk quota exceeded**

.. code-block:: bash

   # Clean package cache
   conda clean --all
   
   # Remove unused environments
   conda env remove -n unused_env

Support and Resources
---------------------

**Anaconda Documentation**

- `Anaconda Documentation <https://docs.anaconda.com/>`_
- `Conda Documentation <https://docs.conda.io/>`_
- `Conda Cheat Sheet <https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html>`_

**Package Channels**

- `Anaconda Repository <https://anaconda.org/anaconda/repo>`_
- `Conda-Forge Repository <https://anaconda.org/conda-forge/repo>`_
- `Bioconda <https://bioconda.github.io/>`_
- `PyPI (pip packages) <https://pypi.org/>`_

**Tutorials**

- `Getting Started with Conda <https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html>`_
- `Managing Environments <https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html>`_
