Software Environment
====================

.. meta::
    :description: Quick-start guide to software modules, edge Spack activation, Python environments, compilers, MPI, and uv on HPC4.
    :keywords: HPC4, Spack, Lmod, Python, anaconda3, uv, compiler, openmpi, modules

.. rst-class:: header

    | Last updated: 2026-06-04

This page introduces the basic module commands on HPC4 and shows a few common environment setup patterns for new users.

Environment
-----------

    - Users who can already log in to HPC4
    - Shell access on a login node or inside a job session
    - Basic familiarity with terminal commands

Background
----------

HPC4 provides software environments through environment modules.
The software stack in hkust-hpc uses Spack and Lmod, so available modules depend on the active software environment.
For new work on HPC4, use the edge Spack instance instead of relying on the deprecated default instance.
In particular, a fresh login shell may not show the software you want with a direct filtered query such as ``module avail python`` until edge Spack is activated.

Practical Notes
---------------

- For new quick-start workflows, begin with ``source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y``.
- On the default login-node environment, ``module avail python`` may return no match before edge Spack is activated.
- After edge activation, direct modules such as ``python/<version>``, ``anaconda3/<version>``, and ``intel-oneapi-compilers/<version>`` become available.
- On the edge Spack instance, ``openmpi`` is not a core module; load a compiler first and then load ``openmpi`` from the hierarchical Lmod tree.
- For MPI jobs on HPC4, prefer ``srun`` in quick-start workflows.

Basic Commands
--------------

The following commands are the minimum set most users need when starting on HPC4.

Start from a clean shell and activate edge Spack:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module avail

Then use Lmod's broader search command when you need to find software:

.. code-block:: bash

    module spider python

For example, load a tested edge Python module:

.. code-block:: bash

    module load python/3.13.2

Unload all currently loaded modules:

.. code-block:: bash

    module purge

Useful follow-up checks:

.. code-block:: bash

    module list
    which python
    python --version

The exact module names and versions on your account may differ from the examples here.
On HPC4, ``module avail python`` may print ``No module(s) or extension(s) found!`` on a fresh login session.
After activating edge Spack, the module tree changes and direct Python or compiler modules become available.
The command examples below include outputs observed during testing on one HPC4 account.
Treat them as practical references rather than guaranteed output for every account.

Common Environments
-------------------

Python Environment
~~~~~~~~~~~~~~~~~~

For new quick-start workflows, use the edge Spack instance first and then load an explicit Python module.
Do not assume that ``module avail python`` will work before the correct software instance is active.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module spider python
    module load python/3.13.2
    python --version
    module list
    which python

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.13.2``.
- ``which python`` points into ``/opt/shared/.spack-edge/.../python-3.13.2.../bin/python``.
- ``module list`` shows ``python/3.13.2`` loaded.

If you prefer a Conda-based Python distribution on edge, use ``anaconda3`` after activating the same instance:

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module spider anaconda3
    module load anaconda3/2025
    python --version
    conda --version
    module list
    which python

Example output from one HPC4 login-node session:

- ``module list`` shows an ``anaconda3`` module from ``/opt/shared/.spack-edge`` loaded.
- ``which python`` points into the shared Spack Anaconda installation under ``/opt/shared/.spack-edge/.../anaconda3.../bin/python``.

Do not run ``module avail spider python``. That is not valid syntax.
Use ``module spider python`` as a standalone command.

If you specifically need another Python version, activate edge Spack first and then load an explicit versioned module.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module spider python
    module load python/3.12.9
    python --version
    which python
    module list

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.12.9``.
- ``which python`` points into ``/opt/shared/.spack-edge/.../python-3.12.9.../bin/python``.
- ``module list`` shows ``python/3.12.9`` loaded.

Using uv for Pure-Python Workflows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For pure-Python projects, ``uv`` is a fast alternative to creating a Conda environment.
This works well when you only need a Python interpreter plus packages from PyPI.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module load python/3.13.2
    uv venv myenv
    source myenv/bin/activate
    uv pip install numpy pandas matplotlib
    python --version

Use Conda-based modules when you specifically want a bundled scientific Python distribution.
For more complete Python workflow guidance, including ``uv``, see :doc:`/software/python/python`.

Compiler and MPI Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use this pattern when you need a compiler toolchain and MPI libraries.
The following sequence is a practical example for the edge Spack environment.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module spider intel-oneapi-compilers
    module load intel-oneapi-compilers/2025.0.4
    module spider openmpi
    module load openmpi/5.0.6
    module list

Example output from one HPC4 login-node session:

- ``module list`` shows both ``intel-oneapi-compilers/2025.0.4`` and ``openmpi/5.0.6`` loaded.

.. important::

    On the edge Spack instance, ``openmpi`` becomes visible after you load a compiler module.
    On HPC4, this OpenMPI build warns that ``mpirun``/``mpiexec`` should not be treated as the default launcher path.
    For quick-start job scripts and routine MPI runs, prefer ``srun``.

Clean Environment Reset
~~~~~~~~~~~~~~~~~~~~~~~

If your shell environment becomes confusing, start from a clean module state.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module avail

Edge Spack Environment
~~~~~~~~~~~~~~~~~~~~~~

The hkust-hpc documentation recommends the edge Spack instance for new work.
Activate it explicitly, verify the active variant, and then load the software you need.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    echo $SPACK_VARIANT
    module avail
    module spider python
    module load python/3.12.9
    python --version
    which python
    module list

Example output from one HPC4 login-node session:

- ``echo $SPACK_VARIANT`` reports ``edge``.
- ``python --version`` reports ``Python 3.12.9``.
- ``which python`` points into ``/opt/shared/.spack-edge/.../python-3.12.9.../bin/python``.
- ``module list`` shows ``python/3.12.9`` loaded.

For new quick-start workflows, prefer the edge instance instead of the deprecated default instance.

.. warning::

   Do not add Spack activation blindly to your shell startup files until you confirm that this is the recommended HPC4 practice for your account and workflow.

Verification Checklist
----------------------

- Run ``module avail`` successfully.
- Activate edge Spack with ``source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y``.
- If a filtered lookup fails, run ``module spider <name>`` before loading a module.
- Load one module and verify the related executable is found.
- Verify ``$SPACK_VARIANT`` if you need to confirm the active software instance.
- Load ``openmpi`` only after loading a compiler module on the edge instance.
- For MPI jobs on HPC4, prefer ``srun`` over ``mpirun`` in quick-start workflows.
- Run ``module list`` to confirm the expected module is active.
- Use ``module purge`` and confirm the environment resets cleanly.

References
----------

- :doc:`/software/software-support-overview`
- :doc:`/software/python/anaconda3`

See Also
--------

- :doc:`/software/python/python`
- :doc:`How to Request Interactive Sessions </kb/slurm/slurm-how-to-request-interactive-sessi-HV7WS9>`
- :doc:`How to Submit and Run Batch Jobs with SLURM </kb/slurm/slurm-how-to-submit-and-run-batch-jobs-G75o-i>`
