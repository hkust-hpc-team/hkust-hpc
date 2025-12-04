How to Request Interactive Sessions on Compute Nodes
=====================================================

.. meta::
    :description: Guide to requesting interactive SLURM sessions on HPC compute nodes for compilation and testing
    :keywords: slurm, interactive, srun, compute node, compilation, hpc
    :author: HPC Support Team <cchelp@ust.hk>

.. rst-class:: header

    | Last updated: 2025-12-04
    | Solution verified: 2025-12-04

Environment
-----------

    - HPC4 cluster
    - Superpod cluster
    - SLURM workload manager
    - Any resource-intensive task (compilation, testing, debugging)

Issue
-----

    - Compiling GPU code requires access to GPU hardware not available on login nodes
    - Resource-intensive tasks (compilation, large file operations, testing) should not run on login nodes
    - Login nodes have minimal resource limit allocated per user
    - Users need an interactive shell on compute nodes for development and testing work
    - Direct access to compute node resources is required for building software or debugging

Resolution
----------

Use the ``srun`` command with ``--pty bash`` to request an interactive session on a compute node.

Basic Interactive Session
~~~~~~~~~~~~~~~~~~~~~~~~~

For HPC4 cluster:

.. code-block:: bash

   # Request interactive session on AMD partition
   srun --account=exampleproj \
        --partition=amd \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=256 \
        --time=4:00:00 \
        --pty bash
   
   # Or request session on Intel partition
   srun --account=exampleproj \
        --partition=intel \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=128 \
        --time=4:00:00 \
        --pty bash

For Superpod cluster:

.. code-block:: bash

   # Request interactive session with GPU
   srun --account=exampleproj \
        --partition=gpu \
        --nodes=1 \
        --ntasks-per-node=1 \
        --cpus-per-task=32 \
        --gpus-per-task=1 \
        --time=4:00:00 \
        --pty bash

.. note::
   Replace ``exampleproj`` with your actual project account. You can check your available accounts with ``sacctmgr show assoc user=$USER format=account%20``.

Common Options
~~~~~~~~~~~~~~

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Option
     - Description
   * - ``--account=<project>``
     - Project account to charge for resource usage (required)
   * - ``--partition=<name>``
     - Partition to use (amd, intel, gpu, etc.)
   * - ``--nodes=<n>``
     - Number of nodes to allocate
   * - ``--ntasks-per-node=<n>``
     - Number of tasks (processes) per node
   * - ``--cpus-per-task=<n>``
     - Number of CPU cores per task
   * - ``--gpus-per-task=<n>``
     - Number of GPUs per task (GPU partitions only)
   * - ``--time=<HH:MM:SS>``
     - Maximum wall time for the session
   * - ``--pty bash``
     - Request a pseudo-terminal with bash shell

.. important::
   **Do not specify** ``--mem`` or ``--mem-per-cpu`` options. Memory is automatically allocated proportionally based on the number of CPUs or GPUs requested.

Use Cases
~~~~~~~~~

Compiling Software
^^^^^^^^^^^^^^^^^^

See :doc:`Application Compile Notes </software/compile-notes/index>` for detailed compilation instructions of some common applications.

GPU Development and Testing
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Request GPU resources for testing
   srun --account=myproject \
        --partition=gpu \
        --gpus-per-task=1 \
        --cpus-per-task=16 \
        --time=1:00:00 \
        --pty bash

   nvidia-smi

Exiting Interactive Sessions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To exit an interactive session and return to the login node:

.. code-block:: bash

   # Exit the interactive session
   exit

.. warning::
   Your session will automatically terminate when the time limit is reached. Reserve enough time for your work and save your work frequently.

Best Practices
~~~~~~~~~~~~~~

- **Use the correct partition**: Consider production CPU Model, GPU used when selecting development partition
- **Monitor resource usage**: Use ``hostname``, and ``nvidia-smi`` to verify you're using allocated resources
- **Clean up after yourself**: Exit sessions when done to stop billed resource usage
- **Use tmux/screen on login node**: These tools allow you to get back to your interactive session if your connection drops

Root Cause
----------

Login nodes are shared resources with limited CPU, memory, and I/O capacity. Running resource-intensive tasks on login nodes:

- **May trigger automatic process termination**
- **Violates cluster usage policies**
- Degrades performance for all users
- Can cause system instability

Compute nodes are designed for heavy computational workloads and provide:

- **Matched architecture** for optimized builds
- **Access to specialized hardware** (GPUs, high-core-count CPUs)
- **Dedicated resources** for your tasks
- Better performance for compilation and testing
- Isolation from other users' work

References
----------

**Example Scripts**

- `HPC4 SLURM Examples <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/hpc4-hello-world>`_

  - `HPC4 Interactive Sessions <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/superpod-hello-world/hpc4-interactive-helloworld.sh>`_

- `Superpod SLURM Examples <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/superpod-hello-world>`_

  - `Superpod Interactive Sessions <https://github.com/hkust-hpc-team/hkust-hpc/blob/main/examples/superpod-hello-world/superpod-interactive-helloworld.sh>`_

**SLURM Documentation**

- `SLURM srun Command <https://slurm.schedmd.com/srun.html>`_
- `SLURM Interactive Jobs <https://slurm.schedmd.com/faq.html#interactive>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-12-04
      | Issued by: kftse@ust.hk
