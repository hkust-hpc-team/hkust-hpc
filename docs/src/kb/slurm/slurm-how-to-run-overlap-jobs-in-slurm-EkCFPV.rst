How to Run Overlap Jobs in SLURM
================================

.. rst-class:: header

    | Last updated: 2024-12-06
    | *Solution verified 2024-12-06*

.. meta::
    :description: How to run overlap jobs within an existing SLURM allocation
    :keywords: slurm, overlap, job, srun, hpc
    :author: chtaihei <chtaihei@ust.hk>

Environment
-----------

    - ITSO HPC clusters

Issue
-----

    - Users need to run overlap jobs within an existing SLURM allocation (e.g. monitoring, debugging, etc.)
    - Standard job submission may not allow sharing resources with existing jobs

Resolution
----------

To run an overlap job within an existing SLURM allocation:

- Find your current job ID:

.. code-block:: bash

    squeue -u $USER

- Use srun with the --overlap flag:

.. code-block:: bash

    srun -A <account> --overlap --jobid <jobid> --pty bash

Example usage:

.. code-block:: shell-session

    $ srun -A myproject --overlap --jobid 12345 --pty bash

.. note::

    The --overlap flag allows the new job to share resources with the existing job specified by --jobid

.. warning::

    Ensure you have sufficient resources in your original allocation to run the overlap job

Root Cause
----------

SLURM by default prevents multiple jobs from using the same resources simultaneously. The --overlap flag explicitly
allows resource sharing between jobs when needed for workflow efficiency.

References
----------

- `Slurm srun Guide <https://slurm.schedmd.com/srun.html>`_
- `HKUST HPC4 Slurm Guide
  <https://ITSO.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/slurm>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://ITSO.ust.hk

    **Article Info**
      | Issued: 2024-12-06
      | Issued by: chtaihei@ust.hk
