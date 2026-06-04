Software Environment
====================

This page introduces the basic module commands on HPC4 and shows a few common environment setup patterns for new users.

Environment
-----------

    - Users who can already log in to HPC4
    - Shell access on a login node or inside a job session
    - Basic familiarity with terminal commands

Background
----------

HPC4 provides software environments through environment modules.
The software stack in hkust-hpc also references Spack and Lmod, so users should expect available modules to depend on the active software environment.
In particular, a fresh login shell may not show the software you want with a direct filtered query such as ``module avail python``.
From the current HPC4 login-node view, the default core modules already include software such as ``anaconda3``, ``miniconda3``, ``gcc``, ``intel-oneapi-compilers``, ``mpich``, and ``openmpi``.

Practical Notes
---------------

- On the default login-node environment, ``module avail python`` may return no match.
- On the default login-node environment, conda-based modules such as ``anaconda3`` and ``miniconda3`` are often the most direct Python entry points.
- The default module tree also exposes toolchains such as ``intel-oneapi-compilers`` and ``openmpi``.
- If you switch to the edge Spack instance, direct ``python/<version>`` modules become available.
- For MPI jobs on HPC4, prefer ``srun`` in quick-start workflows.

Basic Commands
--------------

The following commands are the minimum set most users need when starting on HPC4.

Start by checking the current module view:

.. code-block:: bash

    module avail

If a filtered ``module avail`` query returns no matches, use Lmod's broader search command:

.. code-block:: bash

    module spider python

If ``module spider python`` also fails, use one of the Python distributions already exposed in the core module tree instead:

.. code-block:: bash

    module load anaconda3/2023.09-0-biybti3

or:

.. code-block:: bash

    module load miniconda3/24.3.0-quc3pyu

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
The default core-module view can already show conda-based choices such as ``anaconda3/...`` and ``miniconda3/...``.
The command examples below include outputs observed during testing on one HPC4 account.
Treat them as practical references rather than guaranteed output for every account.

Common Environments
-------------------

Python Environment
~~~~~~~~~~~~~~~~~~

On the current HPC4 default module tree, the most direct Python entry points are the conda-based modules such as ``anaconda3`` and ``miniconda3``.
Do not assume that ``module avail python`` will work before the correct software instance is active.

.. code-block:: bash

    module purge
    module avail
    module load anaconda3/2023.09-0-biybti3
    python --version
    conda --version
    module list
    which python

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.11.5``.
- ``conda --version`` reports ``conda 23.7.4``.
- ``which python`` points into the shared Spack Anaconda installation under ``/opt/shared/spack/.../anaconda3-2023.09-0-biybti3.../bin/python``.

An alternative tested path is ``miniconda3``:

.. code-block:: bash

    module purge
    module load miniconda3/24.3.0-quc3pyu
    python --version
    module list
    which python

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.12.2``.
- ``which python`` points into the shared Spack Miniconda installation under ``/opt/shared/spack/.../miniconda3-24.3.0-quc3pyu.../bin/python``.

Do not run ``module avail spider python``. That is not valid syntax.
Use ``module spider python`` as a standalone command.

If you specifically need a non-conda Python module and both ``module avail python`` and ``module spider python`` return no matches, treat that as a site-specific limitation of the current default environment rather than a typo in your command.
On HPC4, the edge Spack path can expose direct ``python/<version>`` modules.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module spider python
    module load python/3.13.2-sbeg36d
    python --version
    which python
    module list

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.13.2``.
- ``which python`` points into ``/opt/shared/.spack-edge/.../python-3.13.2-sbeg36d.../bin/python``.
- ``module list`` shows ``python/3.13.2-sbeg36d`` loaded.

Compiler and MPI Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use this pattern when you need a compiler toolchain and MPI libraries.
The following sequence is a practical example for the current HPC4 environment.

.. code-block:: bash

    module purge
    module spider intel-oneapi-compilers
    module load intel-oneapi-compilers/2024.1.0-imjimv2
    module spider openmpi
    module load openmpi/5.0.3-65bzfqx
    module list

Example output from one HPC4 login-node session:

- ``module list`` shows both ``intel-oneapi-compilers/2024.1.0-imjimv2`` and ``openmpi/5.0.3-65bzfqx`` loaded.

.. important::

    On HPC4, this OpenMPI build warns that ``mpirun``/``mpiexec`` should not be treated as the default launcher path.
    For quick-start job scripts and routine MPI runs, prefer ``srun``.

Clean Environment Reset
~~~~~~~~~~~~~~~~~~~~~~~

If your shell environment becomes confusing, start from a clean module state.

.. code-block:: bash

    module purge
    module avail

Spack-Backed Software Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The hkust-hpc documentation shows that some software environments depend on the active Spack instance.
If your site requires activating a Spack instance before using modules, do that first and then load modules.
The following sequence is a practical example that worked on one HPC4 account.

.. code-block:: bash

    module purge
    source /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
    module avail
    module spider python
    module load python/3.12.9-3lxwd5b
    python --version
    which python
    module list

Example output from one HPC4 login-node session:

- ``python --version`` reports ``Python 3.12.9``.
- ``which python`` points into ``/opt/shared/.spack-edge/.../python-3.12.9-3lxwd5b.../bin/python``.
- ``module list`` shows ``python/3.12.9-3lxwd5b`` loaded.

For the default login-node environment, prefer the modules already visible in the core tree unless you specifically need software from the edge instance.

.. warning::

   Do not add Spack activation blindly to your shell startup files until you confirm that this is the recommended HPC4 practice for your account and workflow.

Verification Checklist
----------------------

- Run ``module avail`` successfully.
- Confirm which software is already visible in the default core tree.
- If a filtered lookup fails, run ``module spider <name>`` before loading a module.
- If both commands fail for Python, load ``anaconda3`` or ``miniconda3`` instead.
- Load one module and verify the related executable is found.
- If you activate edge Spack, verify ``$SPACK_VARIANT`` and load an explicit module version.
- For MPI jobs on HPC4, prefer ``srun`` over ``mpirun`` in quick-start workflows.
- Run ``module list`` to confirm the expected module is active.
- Use ``module purge`` and confirm the environment resets cleanly.

References
----------

- :doc:`/software/software-support-overview`
- :doc:`/software/python/anaconda3`
