How to Efficiently Download Files from Cluster
==============================================

.. meta::
    :description: Efficiently downloading large datasets from HPC clusters using SSHFS and fpsync
    :keywords: sshfs, fpsync, dataset, download, hpc, cluster
    :author: kftse <kftse@ust.hk>

.. container:: header

    | Last updated: 2025-07-02
    | *Solution under review*

Environment
-----------

    - macOS, Linux/Unix, or Windows with WSL
    - SSH access to HPC cluster

Issue
-----

    - Need to download large datasets from HPC cluster
    - Cannot establish an outgoing SSH connection to transfer file
    - Dataset may contain many small files
    - Need efficient and reliable transfer method

Resolution
----------

Use ``sshfs`` to mount remote directory locally, then use ``fpsync`` for parallel
downloads.

Install Required Packages
~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Install ``sshfs`` and ``fpart``:

    For Ubuntu/Debian:

    .. code-block:: shell-session

        sudo apt install sshfs fpart

    For macOS:

    .. code-block:: shell-session

        brew install sshfs fpart

    For CentOS/RHEL:

    .. code-block:: shell-session

        sudo dnf install fuse-sshfs fpart

Mount Remote Directory
~~~~~~~~~~~~~~~~~~~~~~

1.  Create local mount point:

.. code-block:: shell-session

    mkdir -p ~/cluster_data

2.  Mount remote directory:

.. code-block:: shell-session

    sshfs username@hpc.ust.hk:/path/to/dataset ~/cluster_data

Download Using fpsync
~~~~~~~~~~~~~~~~~~~~~

1.  Create local destination directory:

.. code-block:: shell-session

    mkdir -p ~/local_dataset

2.  Transfer files using parallel processes:

.. code-block:: shell-session

    fpsync -t $HOME/.fpsync -n 8 -vv ~/cluster_data/ ~/local_dataset/

3.  Unmount after transfer.

    For Linux:

    .. code-block:: shell-session

        fusermount -u ~/cluster_data

    For macOS:

    .. code-block:: shell-session

        umount ~/cluster_data

.. note::

    - Choose appropriate number of parallel processes (``-n``) based on your system
    - Verify transfer completion before unmounting

.. warning::

    - Ensure sufficient local disk space before starting transfer
    - Do not interrupt transfer process to avoid incomplete files
    - Large parallel transfers may impact system performance

Root Cause
----------

Outbound SSH is not permitted. Use ``sshfs`` to mount a local directory using an inbound
SSH connection to HPC cluster.

For parallel transfer, use fpsync to efficiently download files.

References
----------

- `SSHFS Documentation <https://github.com/libfuse/sshfs>`_
- `fpsync Documentation <https://github.com/martymac/fpart>`_

----

.. container:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-02-17
      | Issued by: kftse <kftse@ust.hk>
