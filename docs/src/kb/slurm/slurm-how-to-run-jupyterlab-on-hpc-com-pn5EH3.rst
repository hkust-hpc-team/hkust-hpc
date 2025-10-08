How to Run JupyterLab on HPC Compute Nodes
==========================================

.. rst-class:: header

    | Last updated: 2024-12-06
    | *Solution verified 2024-12-06*

.. meta::
    :description:
    :keywords: jupyterlab, jupyter, slurm, HPC4, SuperPOD, interactive, notebook
    :author: chtaihei <chtaihei@ust.hk>

Environment
-----------

    - ITSO HPC clusters
    - SLURM workload manager
    - Python/Conda environment with JupyterLab installed
    - SSH client

Issue
-----

    - Users need to run JupyterLab on compute nodes for interactive data analysis
    - Direct access to compute nodes is not allowed for security reasons
    - Need to establish proper port forwarding to access the JupyterLab interface

Resolution
----------

The process involves four main steps:

#. Requesting Compute Resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Request an interactive session on a compute node:

.. code-block:: bash

    srun --account=<account> --partition=<partition> --nodes=1 \
         --ntasks-per-node=1 --cpus-per-task=16 --time=01:00:00 --pty bash

.. note::

    Interactive jobs have a maximum walltime of 4 hours on HPC4 and 2 hours on SuperPOD.

#. Starting JupyterLab Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After allocation is granted, activate your environment and launch JupyterLab:

.. code-block:: bash

    conda activate myenv
    jupyter-lab --no-browser --ip=0.0.0.0 --port=8888

.. note::

    Save the token or URL from the output. It will be needed for authentication.

#. Creating SSH Tunnel
~~~~~~~~~~~~~~~~~~~~~~

On your local machine, establish an SSH tunnel:

.. code-block:: bash

    ssh -N -L 8888:<compute_node>:8888 username@<hpcname>.ust.hk

.. note::

    - Replace <hpcname> with your target HPC cluster name (e.g., hpc3, hpc4, superpod)
    - Replace <compute_node> with the allocated compute node name from step 1
    - Replace username with your HKUST HPC Cluster username

#. Accessing JupyterLab Interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Open a web browser on your local machine
- Navigate to http://127.0.0.1:8888
- Enter the token from step 2 if prompted

.. warning::

    Choose a unique port number if 8888 is already in use

Cleanup
-------

When finished:

#. Close your browser
#. Terminate the SSH tunnel (Ctrl+C)
#. Exit the Slurm session

Root Cause
----------

Direct access to compute nodes is restricted for security. SSH tunneling provides a secure way to access services
running on compute nodes through the login node.

References
----------

- `Slurm Documentation <https://slurm.schedmd.com/documentation.html>`_
- `HKUST HPC4 Slurm Guide
  <https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/slurm>`_
- `HKUST SuperPOD Website
  <https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/superpod>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2024-12-06
      | Issued by: chtaihei@ust.hk
