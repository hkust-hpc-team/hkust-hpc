Running Interactive Container Sessions on HPC
=============================================

.. meta::
    :description: Guide for running interactive container sessions on HPC clusters
    :keywords: container, development, interactive, nvidia, enroot
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-06-13
    | Keywords: container, interactive, development, nvidia, enroot
    | *Solution verified*

Environment
-----------

    - Slurm workload manager
    - GPU-enabled nodes
    - Enroot/Pyxis container runtime

Issue
-----

    - Test or debug container environments
    - Install additional software
    - Develop container-based applications
    - Customize existing containers

Resolution
----------

#. **Basic Interactive Container Session**

    Start an interactive container session using the following command:

    .. code-block:: bash

        $ srun --account=[YOUR_ACCOUNT] \
            --partition=normal \
            --nodes=1 \
            --ntasks-per-node=1 \
            --gpus-per-node=1 \
            --cpus-per-task=28 \
            --container-writable \
            --container-remap-root \
            --no-container-mount-home \
            --container-image nvcr.io#nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04 \
            --container-save $HOME/my-container.sqsh \
            --pty bash

    .. note::

        - Changes will be lost without ``--container-save``, see :doc:`enroot-saving-enroot-container-failed-tdQCrl` for
          more details.
        - Root access requires ``--container-remap-root`` and ``--container-writable``
        - Interactive sessions have a maximum walltime of 4 hours on HPC4 and 2 hours on SuperPOD
        - Create the target directory first: ``mkdir -p $HOME/containers`` if saving to a subdirectory

#. **Container Customization and Package Installation**

    Once inside the container, update and install packages:

    .. code-block:: console

        root@node:/# apt update
        root@node:/# apt install -y [package-name]

    Common packages for development:

    .. code-block:: console

        root@node:/# apt install -y vim git wget curl build-essential python3-pip
        root@node:/# pip3 install numpy matplotlib jupyter

#. **Using Previously Saved Containers**

    To start with a previously saved container, use ``--container-image /path/to/container/image.sqsh`` instead
    of pulling from a registry:

    .. code-block:: console

        $ srun --account=[YOUR_ACCOUNT] \
            --partition=normal \
            --nodes=1 \
            --ntasks-per-node=1 \
            --gpus-per-node=1 \
            --cpus-per-task=28 \
            --container-writable \
            --container-remap-root \
            --no-container-mount-home \
            --container-image $HOME/my-container.sqsh \
            --container-save $HOME/my-container-updated.sqsh \
            --pty bash

Best Practices
~~~~~~~~~~~~~~

- **Container Storage**: Store containers in ``$HOME/containers/`` for organization
- **Naming Convention**: Use descriptive names: ``pytorch-24.03-custom.sqsh``
- **Version Control**: Save incremental versions during development
- **Resource Planning**: Request appropriate CPU/GPU/memory based on workload

References
----------

- `CUDA Containers for Deep Learning <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda-dl-base>`_
- `NGC Container Registry <https://catalog.ngc.nvidia.com/>`_
- `Pyxis/Enroot Usage <https://github.com/NVIDIA/pyxis?tab=readme-ov-file#usage>`_
- `Slurm srun Documentation <https://slurm.schedmd.com/srun.html>`_
- `Container Best Practices <https://docs.nvidia.com/deeplearning/frameworks/user-guide/index.html>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-06-13
      | Issued by: kftse (at) ust.hk
