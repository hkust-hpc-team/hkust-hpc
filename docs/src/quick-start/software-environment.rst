Software Environment
====================

.. meta::
    :description: Quick-start guide to software modules, edge Spack activation, Python environments, compilers, MPI, and uv on HPC4 (SuperPOD: see container workflow).
    :keywords: HPC4, SuperPOD, Spack, Lmod, Python, anaconda3, uv, compiler, openmpi, modules

.. rst-class:: header

    | Last updated: 2026-06-04

This page covers module-based software setup for HPC4.
SuperPOD users typically use containers (Enroot/Pyxis) but can also use the Spack instance at ``/scratch/spack/2025``.

Environment
-----------

    - Users who can already log in to HPC4 (or SuperPOD)
    - Shell access on a login node or inside a job session

Quick Reference: Common Environments
-------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Environment
     - Modules to load
     - Use case
   * - Python (standalone)
     - ``python/3.13.2``
     - Pure-Python scripts, uv-based workflows
   * - Python (Conda)
     - ``anaconda3/2025``
     - Packages from conda ecosystem, mixed Python + C/C++
   * - Compiler + MPI
     - ``intel-oneapi-compilers/2025.0.4`` then ``openmpi/5.0.6``
     - MPI parallel jobs, compiled code

.. note::

   All examples below require **edge Spack activation** first.
   On a fresh login, ``module avail python`` may show nothing until edge is active.

Basic Commands
--------------

Every session starts the same way — activate edge Spack, then load what you need:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y

Then use these commands as needed:

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Command
     - Purpose
   * - ``module avail``
     - List all available modules
   * - ``module spider <name>``
     - Search for a module (broader search)
   * - ``module load <name/version>``
     - Load a specific module
   * - ``module list``
     - Show currently loaded modules
   * - ``module purge``
     - Unload all modules

Python Environment
------------------

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.13.2
    python --version        # Python 3.13.2
    which python            # /opt/shared/.spack-edge/.../bin/python

For Conda-based Python:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load anaconda3/2025
    python --version
    conda --version

For a different Python version:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.12.9

Using uv for Pure-Python Workflows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`uv <https://docs.astral.sh/uv/>`__ is a fast, modern package manager that works in user space.

Install once:

.. code-block:: bash

    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

Basic workflow:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.13.2
    uv venv
    source .venv/bin/activate
    uv pip install numpy pandas matplotlib

In a SLURM job script:

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=my-python-job
    #SBATCH --output=py-%j.out
    #SBATCH --time=01:00:00
    #SBATCH --nodes=1
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=4
    #SBATCH --account=<your-account>
    #SBATCH --partition=amd

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.13.2
    source /path/to/project/.venv/bin/activate
    python my_script.py

For more complete Python workflow guidance, see :doc:`/software/python/python`.

Compiler and MPI Environment
-----------------------------

Load a compiler first, then MPI — ``openmpi`` is only visible after a compiler is loaded on the edge instance.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load intel-oneapi-compilers/2025.0.4
    module load openmpi/5.0.6
    module list

.. important::

    On HPC4, prefer ``srun`` over ``mpirun`` / ``mpiexec`` for MPI jobs.

Verification Checklist
----------------------

- ``module avail`` shows available modules after edge activation
- ``module spider <name>`` finds the module you want
- ``module load <name/version>`` loads successfully
- ``which <command>`` points to the expected path
- ``module list`` confirms loaded modules
- ``$SPACK_VARIANT`` reports ``edge`` (optional check)

References
----------

- :doc:`/software/software-support-overview`
- :doc:`/software/python/anaconda3`

See Also
--------

- :doc:`/software/python/python`
- :doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
