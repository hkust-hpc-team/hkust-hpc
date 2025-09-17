Error when downloading NVIDIA NGC Containers
============================================

.. meta::
    :description: Solution for NGC container registry unauthorized access error
    :keywords: container, slurm, nvidia, ngc, enroot, pyxis
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-02-12
    | *Solution under review*

Environment
-----------

    - Slurm with Enroot container runtime
    - NVIDIA NGC containers

Issue
-----

    - When trying to run NGC containers, you see this error:

      .. code-block:: console

          $ srun --container-image docker://nvcr.io/nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04
          # or
          $ srun --container-image nvcr.io/nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04

          slurmstepd: error: pyxis: [ERROR] URL https://registry-1.docker.io/v2/nvcr.io/nvidia/nvhpc/manifests/24.3-devel-cuda12.3-ubuntu22.04 returned error code: 401 Unauthorized

Resolution
----------

Replace forward slash (/) with hash (#) in the container path:

Instead of:

.. code-block:: console

    --container-image nvcr.io/nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04

Use:

.. code-block:: console

    --container-image nvcr.io#nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04

Example working command:

.. code-block:: console

    $ srun --account=YOUR_ACCOUNT \
        --nodes=1 \
        --gpus-per-node=1 \
        --container-image nvcr.io#nvidia/nvhpc:24.3-devel-cuda12.3-ubuntu22.04 \
        nvidia-smi

.. note::

    This applies to all NGC containers, not just NVHPC

Root Cause
----------

Pyxis container runtime requires different URL formatting than Docker: - Docker uses: nvcr.io/nvidia/... - Pyxis
requires: nvcr.io#nvidia/...

References
----------

- `NGC container repositoryt <https://catalog.ngc.nvidia.com/>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://ITSO.ust.hk

    **Article Info**
      | Issued: 2025-02-12
      | Issued by: kftse (at) ust.hk
