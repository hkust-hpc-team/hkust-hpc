Running Interactive Container Sessions on HPC
=============================================

.. meta::
    :description: Guide for running interactive container sessions on HPC clusters
    :keywords: container, development, interactive, nvidia, enroot
    :author: kftse <kftse@ust.hk>

.. container:: header

    | Last updated: 2025-02-12
    | *Solution under review*

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

Start an interactive container session using the following command:

.. code-block:: console

    $ srun --account=YOUR_ACCOUNT \
        --nodes=1 \
        --gpus-per-node=1 \
        --container-writable \
        --container-remap-root \
        --no-container-mount-home \
        --container-image nvcr.io#nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04 \
        --container-save $HOME/my-container.sqsh \
        --pty bash

.. note::

    - Changes will be lost without ``--container-save``, see
      :doc:`enroot-saving-enroot-container-failed-tdQCrl` for more details.
    - Root access requires ``--container-remap-root`` and ``--container-writable``

.. hint::

    Alternatively, use ``--container-image /path/to/container/image.sqsh`` to start with
    a previously saved container image.

To update and install packages:

.. code-block:: console

    root@node:/# apt update
    root@node:/# apt install -y [package-name]

References
----------

- `Pyxis/Enroot Usage <https://github.com/NVIDIA/pyxis?tab=readme-ov-file#usage>`_

----

.. container::
    :name: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-02-12
      | Issued by: kftse (at) ust.hk
