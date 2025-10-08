Running Container in Batch Mode on HPC
======================================

.. meta::
    :description: Guide for running container jobs in batch mode on HPC clusters with Slurm
    :keywords: container, batch, slurm, sbatch, nvidia, enroot
    :author: kftse <kftse@ust.hk>

.. container:: header

    | Last updated: 2025-06-13
    | Keywords: container, batch, slurm, sbatch, nvidia, enroot
    | *Solution under review*

Environment
-----------

    - Slurm workload manager
    - GPU-enabled nodes
    - Enroot/Pyxis container runtime

Issue
-----

    - Run long-running container workloads without interactive sessions
    - Execute batch jobs using containerized applications
    - Schedule container-based computations on HPC clusters
    - Submit jobs to the queue for efficient resource utilization

Resolution
----------

.. important::

    **Before running batch jobs, we strongly recommend testing your container and
    commands in interactive mode.** This helps ensure your container works correctly and
    your commands are properly configured.

    For detailed instructions on running containers interactively, see:
    :doc:`enroot-running-interactive-container-se-L58_Wq`

1. Batch Job with Custom Container
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you need to use a customized container (created during interactive testing), save it
first and then use it in batch mode:

.. code-block:: bash
    :caption: custom_container_job.sh

    #!/bin/bash
    #SBATCH --account=[YOUR_ACCOUNT]
    #SBATCH --partition=normal
    #SBATCH --job-name=custom_container
    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=1
    #SBATCH --gpus-per-node=1
    #SBATCH --cpus-per-task=28
    #SBATCH --time=24:00:00
    #SBATCH --output=%x-%j.out
    #SBATCH --error=%x-%j.err

    # Use your custom container
    srun --container-writable \
        --container-remap-root \
        --no-container-mount-home \
        --container-image $HOME/containers/my-custom-container.sqsh \
         python3 ...

3. Multi-Node Container Jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For parallel applications that span multiple nodes:

.. code-block:: bash
    :caption: multinode_container_job.sh

    #!/bin/bash
    #SBATCH --account=[YOUR_ACCOUNT]
    #SBATCH --partition=large
    #SBATCH --job-name=multinode_container
    #SBATCH --nodes=4
    #SBATCH --ntasks-per-node=1
    #SBATCH --gpus-per-node=8
    #SBATCH --cpus-per-task=224
    #SBATCH --time=24:00:00
    #SBATCH --output=%x-%j.out
    #SBATCH --error=%x-%j.err

    # Use your custom container
    srun --container-writable \
        --container-remap-root \
        --no-container-mount-home \
        --container-image $HOME/containers/my-custom-container.sqsh \
         python3 ...

Best Practices
~~~~~~~~~~~~~~

- **Resource Planning**: Request appropriate time limits for batch jobs (can be longer
  than interactive limits)
- **Output Files**: Use descriptive output file names with ``%x`` (job name) and ``%j``
  (job ID) placeholders
- **Container Storage**: Store containers in ``$HOME/containers/`` for organization
- **Error Handling**: Always specify both ``--output`` and ``--error`` files for
  debugging

References
----------

- `CUDA Containers for Deep Learning
  <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda-dl-base>`_
- `NGC Container Registry <https://catalog.ngc.nvidia.com/>`_
- `Pyxis/Enroot Usage <https://github.com/NVIDIA/pyxis?tab=readme-ov-file#usage>`_
- `Slurm srun Documentation <https://slurm.schedmd.com/srun.html>`_
- `Container Best Practices
  <https://docs.nvidia.com/deeplearning/frameworks/user-guide/index.html>`_

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
