Saving Enroot container failed
==============================

.. meta::
    :description: Solution for Enroot container export failure due to missing directory
    :keywords: enroot, container, export, error, hpc, slurm, squashfs
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-02-12
    | *Solution under review*

Environment
-----------

    - Slurm workload manager
    - Enroot container runtime
    - NVIDIA GPU compute nodes
    - Container-enabled cluster

Issue
-----

    When using pyxis/enroot container, saving fails with errors such as

        - ``slurmstepd: error: pyxis: [ERROR] No such file or directory: /home/username/example/nvhpc:24.3.sqsh``
        - ``slurmstepd: error: pyxis: failed to export container pyxis_174632.0 to
          /home/username/example/nvhpc:24.3.sqsh``

Resolution
----------

1. Create container directory:

.. code-block:: console

    $ mkdir -p $HOME/containers

1. Run container with correct save path:

.. code-block:: console

    $ srun --account=YOUR_ACCOUNT \
        --nodes=1 \
        --gpus-per-node=1 \
        --container-writable \
        --container-save $HOME/containers/nvhpc.sqsh \
        --container-image nvcr.io#nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04 \
        --pty bash

.. warning::

    - Ensure sufficient disk quota before saving large containers
    - Container names should not contain special characters

1. Verify saved container:

.. code-block:: console

    $ ls -l $HOME/containers/nvhpc.sqsh

.. note::

    - Parent directory must exist before running container
    - Use absolute paths for --container-save
    - Saved container can be used with --container-image /path/to/container.sqsh

Root Cause
----------

Export can fail when

- Target directory doesn't exist
- Path contains illegal characters
- Insufficient permissions or disk space / quota

References
----------

- `Pyxis/Enroot Usage <https://github.com/NVIDIA/pyxis?tab=readme-ov-file#usage>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-02-12
      | Issued by: kftse (at) ust.hk
