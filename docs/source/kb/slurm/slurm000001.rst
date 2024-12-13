How to resolve QOSMinGRES error when submitting GPU jobs
========================================================

.. container:: header

    | Last updated: 2024-12-06
    | *Solution verified: 2024-12-06*

.. meta::
    :description: How to resolve QOSMinGRES error when submitting GPU jobs
    :keywords: gpu, slurm, error, qos, gres
    :author: chtaihei <chtaihei@ust.hk>

Environment
-----------

    - ITSC HPC4 or SuperPOD cluster

Issue
-----

    - When submitting jobs to GPU nodes without explicitly requesting GPU resources, users may encounter the following error:

      .. code-block:: shell-session

          sbatch: error: Batch job submission failed: Job violates accounting/QOS policy (job submit limit, user's size and/or time limits)

Resolution
----------

Specify the number of GPU needed using the ``--gpus-per-node`` option when submitting the job.

.. code-block:: shell-session

    $ sbatch --nodes=1 --gpus-per-node=4 --tasks-per-node=4 --cpus-per-task=16 --account=my-proj-name --partition=gpu-part-name job.sh
    Submitted batch job 12345

.. note::

    Most applications e.g. pytorch or Gromacs can detect and allocate GPU resources automatically.

    Explicitly specifying ``--gpus-per-task`` is only necessary in specific cases. - to bind GPU to process when program's auto-detection failed - to optimize NUMA locality when using multiple GPUs

    .. code-block:: bash

        $ sbatch --gpus-per-node=4 --gpus-per-task=1 --cpu-bind=ldom --tasks-per-node=4 --nodes=1 --cpus-per-task=16 --account=my-proj-name --partition=gpu-part-name job.sh

Root Cause
----------

The cluster's QOS (Quality of Service) policy requires requesting at least 1 GPU submitting jobs to GPU nodes. This helps ensure proper resource utilization and avoid unnecessary surcharge if applicable.

References
----------

- `Slurm GRES Guide <https://slurm.schedmd.com/gres.html>`_

----

.. container:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2024-12-06
      | Issued by: chtaihei@ust.hk
