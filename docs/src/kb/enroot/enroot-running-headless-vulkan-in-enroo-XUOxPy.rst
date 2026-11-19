Running Headless Vulkan in Enroot Containers
============================================

.. meta::
   :description: Guide to mounting NVIDIA Vulkan ICD and EGL vendor files for headless GPU rendering in Enroot/Pyxis containers
   :keywords: vulkan, headless, rendering, icd, egl, enroot, pyxis, container, nvidia, simulation, superpod
   :author: chtaihei <chtaihei@ust.hk>

.. rst-class:: header

   | Last updated: 2026-11-17
   | *Solution verified: 2026-11-17*

Environment
-----------

   - HKUST SuperPOD or HPC4 GPU compute nodes (e.g., NVIDIA H800)
   - Slurm workload manager with Enroot/Pyxis container runtime
   - GPU-accelerated headless rendering and simulation workloads (e.g., SAPIEN, ManiSkill, RoboTwin, Isaac Sim, MuJoCo)

Issue
-----

   - Running robotics simulations or offscreen GPU rendering workloads inside an Enroot container fails to initialize
     Vulkan on headless GPU nodes with errors such as:

     .. code-block:: text

        Error: vk::createInstanceUnique: ErrorIncompatibleDriver

   - ``vulkaninfo --summary`` inside the container fails with ``ERROR_INCOMPATIBLE_DRIVER`` or falls back to a CPU
     software rasterizer (such as Mesa ``llvmpipe``) instead of the NVIDIA GPU.
   - Even after installing ``libvulkan1`` and mounting the host ICD file, Python or Conda simulation environments still
     fail to select the NVIDIA Vulkan driver at runtime.

Resolution
----------

To enable headless GPU Vulkan rendering in an Enroot/Pyxis container, bind-mount the host NVIDIA Vulkan ICD and GLVND
EGL vendor manifests into the container, install the userspace Vulkan/EGL loader packages, and set
``VK_ICD_FILENAMES`` to restrict ICD discovery to the mounted NVIDIA manifest.

1. Launch a Container with Host ICD and EGL Mounts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a directory on ``/scratch`` (or ``/project``) for storing the container image, then launch an interactive GPU
session from a CUDA Ubuntu base image with ``nvidia_icd.json`` and ``10_nvidia.json`` mounted from the compute node:

.. code-block:: bash

   mkdir -p <your_scratch_dir>/containers

   srun \
     --account=<your_account> \
     --partition=<your_partition> \
     --nodes=1 \
     --ntasks-per-node=1 \
     --gpus-per-node=1 \
     --container-writable \
     --container-remap-root \
     --no-container-mount-home \
     --container-image=nvidia/cuda:12.8.1-devel-ubuntu22.04 \
     --container-save=<your_scratch_dir>/containers/vulkan_cuda_12.8.sqsh \
     --container-mounts=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json,/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json,<your_scratch_dir>:<your_scratch_dir> \
     --pty bash

.. note::

   - Replace ``<your_account>`` and ``<your_partition>`` with your Slurm project account and GPU partition.
   - Replace ``<your_scratch_dir>`` with your scratch or project storage path — ``/scratch/<groupname>`` on SuperPOD,
     ``/scratch/<username>`` on HPC4, or ``/project/<groupname>``. Note that the directory owner or group name need not
     match your Slurm ``--account`` name; see :doc:`/quick-start/data-and-storage`.
   - Store saved ``.sqsh`` container images and large simulation assets under ``/scratch`` or ``/project`` rather than
     ``$HOME`` to avoid exceeding home quota limits, and mount that directory via ``--container-mounts``.
   - The parent directory passed to ``--container-save`` must exist before launching ``srun``; see
     :doc:`enroot-saving-enroot-container-failed-tdQCrl`.
   - If pulling an image from NVIDIA NGC (``nvcr.io``), use ``nvcr.io#nvidia/...`` syntax; see
     :doc:`enroot-error-when-downloading-nvidia-ng-k1c4Rs`.

2. Install Userspace Vulkan and EGL Libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Inside the interactive container session, install the Vulkan loader, diagnostic tools, and EGL/X11 runtime libraries:

.. code-block:: bash

   apt-get update
   apt-get install -y libvulkan1 vulkan-tools libegl1 libxext6

3. Restrict ICD Discovery to NVIDIA and Verify GPU Detection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set ``VK_ICD_FILENAMES`` to restrict Vulkan loader discovery exclusively to the mounted NVIDIA ICD manifest (so
software ICDs such as Mesa ``llvmpipe`` are not enumerated and Conda-bundled Vulkan loaders locate the system
manifest), then verify with ``vulkaninfo --summary``:

.. code-block:: shell-session

   root@gpu-node:/# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
   root@gpu-node:/# vulkaninfo --summary
   ==========
   VULKANINFO
   ==========

   Vulkan Instance Version: 1.3.204
   ...
   Devices:
   ========
   GPU0:
           apiVersion         = 1.4.303
           driverVersion      = 570.158.01.0
           vendorID           = 0x10de
           deviceID           = 0x2324
           deviceType         = PHYSICAL_DEVICE_TYPE_DISCRETE_GPU
           deviceName         = NVIDIA H800
           driverID           = DRIVER_ID_NVIDIA_PROPRIETARY
           driverName         = NVIDIA

Once ``vulkaninfo --summary`` lists the NVIDIA GPU instead of an error, run your headless simulation workload in the
same environment:

.. code-block:: bash

   export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
   python your_simulation_script.py

Exit the shell when setup is complete so Pyxis saves the container filesystem to
``<your_scratch_dir>/containers/vulkan_cuda_12.8.sqsh``:

.. code-block:: bash

   exit

4. Reuse the Saved Container in Interactive or Batch Jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   Files passed via ``--container-mounts`` are bind-mounted at runtime and are **not** stored inside the saved
   ``.sqsh`` image. When reusing ``vulkan_cuda_12.8.sqsh``, you must continue to pass ``--container-mounts`` for
   ``nvidia_icd.json`` and ``10_nvidia.json`` and export ``VK_ICD_FILENAMES`` in each session or job script.

**Interactive session with the saved image:**

.. code-block:: bash

   srun \
     --account=<your_account> \
     --partition=<your_partition> \
     --nodes=1 \
     --ntasks-per-node=1 \
     --gpus-per-node=1 \
     --no-container-mount-home \
     --container-image=<your_scratch_dir>/containers/vulkan_cuda_12.8.sqsh \
     --container-mounts=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json,/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json,<your_scratch_dir>:<your_scratch_dir> \
     --pty bash -c "export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json && exec bash"

**Batch job script** (``sbatch``):

For non-interactive training or rendering jobs (see :doc:`enroot-running-container-in-batch-mode--Ha3k6x`), export
``VK_ICD_FILENAMES`` and keep the ICD/EGL bind mounts in your Slurm script:

.. code-block:: bash
   :caption: vulkan_headless_job.sh

   #!/bin/bash
   #SBATCH --account=<your_account>
   #SBATCH --partition=<your_partition>
   #SBATCH --job-name=vulkan_sim
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=1
   #SBATCH --gpus-per-node=1
   #SBATCH --cpus-per-task=16
   #SBATCH --time=04:00:00
   #SBATCH --output=%x-%j.out
   #SBATCH --error=%x-%j.err

   export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

   srun \
     --no-container-mount-home \
     --container-image=<your_scratch_dir>/containers/vulkan_cuda_12.8.sqsh \
     --container-mounts=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json,/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json,<your_scratch_dir>:<your_scratch_dir> \
     python <your_scratch_dir>/project/train_rgb.py

Diagnosis
---------

If Vulkan rendering still fails inside the container, check the following inside an allocated GPU container session:

#. **Verify the mounted JSON manifests are non-empty:**

   If ``--container-mounts`` was omitted when reusing a saved ``.sqsh`` container, an empty mount-point placeholder file
   may remain at ``/usr/share/vulkan/icd.d/nvidia_icd.json``. Confirm both files contain valid JSON:

   .. code-block:: bash

      cat /usr/share/vulkan/icd.d/nvidia_icd.json
      cat /usr/share/glvnd/egl_vendor.d/10_nvidia.json

#. **Check ICD discovery paths and enumerated software devices:**

   Inspect ``/usr/share/vulkan/icd.d/`` and ``/etc/vulkan/icd.d/`` (and ``$CONDA_PREFIX/share/vulkan/icd.d/`` if using
   Conda) for software ICDs such as ``lvp_icd.*.json``, and confirm ``VK_ICD_FILENAMES`` is exported in the shell
   running your script:

   .. code-block:: bash

      ls -l /usr/share/vulkan/icd.d/
      echo "$VK_ICD_FILENAMES"

#. **Confirm NVIDIA graphics libraries are injected into the container:**

   Verify that ``libGLX_nvidia.so.0`` and ``libEGL_nvidia.so.0`` are visible to the dynamic linker (injected by Enroot
   when ``NVIDIA_DRIVER_CAPABILITIES`` is ``all`` or includes ``graphics``):

   .. code-block:: bash

      ldconfig -p | grep -E "libGLX_nvidia|libEGL_nvidia"

Root Cause
----------

- **No usable Vulkan ICD discovered** (``ErrorIncompatibleDriver``): On headless compute nodes (such as NVIDIA H800 nodes
  on SuperPOD), Enroot's NVIDIA container hook injects the host driver shared libraries (``libGLX_nvidia.so.*``,
  ``libEGL_nvidia.so.*``) into the container, but standard ``nvidia/cuda`` base images only ship CUDA compute packages.
  They omit the userspace Vulkan/EGL loaders (``libvulkan1``, ``libegl1``) as well as the JSON vendor manifests
  (``nvidia_icd.json`` and ``10_nvidia.json``) required by the Vulkan loader and GLVND to locate the NVIDIA driver
  implementation. Similarly, Conda environments that bundle their own ``vulkan-loader`` search under
  ``$CONDA_PREFIX/share/vulkan/icd.d`` by default rather than ``/usr/share/vulkan/icd.d``. When the loader finds no
  working ICD across its search paths, instance creation fails with ``VK_ERROR_INCOMPATIBLE_DRIVER``
  (``vk::createInstanceUnique: ErrorIncompatibleDriver``).
- **Software device selection when multiple ICDs are installed**: The Vulkan loader supports multiple ICDs and skips
  individual drivers that report incompatibility during enumeration rather than failing instance creation. However, if
  Mesa Vulkan packages (such as ``lvp_icd`` for CPU ``llvmpipe``) are installed via ``apt`` or Conda, the loader
  exposes those software ``VkPhysicalDevice`` entries alongside (or instead of) the NVIDIA GPU. Simulation frameworks
  may then select ``llvmpipe`` or fail later during logical device creation when required NVIDIA GPU extensions are
  missing. Exporting ``VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json`` restricts ICD discovery strictly to
  the host-mounted NVIDIA manifest across both system and Conda Vulkan loaders.

References
----------

- :doc:`enroot-running-interactive-container-se-L58_Wq`
- :doc:`enroot-running-container-in-batch-mode--Ha3k6x`
- :doc:`enroot-saving-enroot-container-failed-tdQCrl`
- `Pyxis Container Runtime Usage <https://github.com/NVIDIA/pyxis#usage>`_
- `Khronos Vulkan Loader Driver Discovery <https://github.com/KhronosGroup/Vulkan-Loader/blob/main/docs/LoaderDriverInterface.md>`_

.. rst-class:: footer

   **HPC Support Team**
     | ITSO, HKUST
     | Email: cchelp@ust.hk
     | Web: https://itso.hkust.edu.hk/

   **Article Info**
     | Issued: 2026-11-17
     | Issued by: chtaihei@ust.hk
