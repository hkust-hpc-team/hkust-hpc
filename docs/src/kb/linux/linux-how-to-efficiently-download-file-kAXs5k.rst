How to Efficiently Download Files from Cluster
==============================================

.. meta::
    :description: Efficiently downloading large datasets from HPC clusters using SSHFS and fpsync
    :keywords: sshfs, fpsync, dataset, download, hpc, cluster
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-02-17
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

The recommended method is to use ``sshfs`` to mount the remote cluster directory locally, and then use ``fpsync`` to perform a parallel download. This approach is efficient, especially for datasets with many small files.

#. **Install Required Packages**

   Install ``sshfs`` for mounting and ``fpart`` (which includes ``fpsync``) for parallel file transfer.

   .. code-block:: shell-session

       # Ubuntu/Debian:
       $ sudo apt install sshfs fpart

       # macOS (using Homebrew):
       $ brew install sshfs fpart

       # CentOS/RHEL:
       $ sudo dnf install fuse-sshfs fpart

#. **Mount the Remote Directory**

   First, create a local directory that will serve as the mount point. Then, use `sshfs` to mount the remote directory from the cluster.

   Create a local mount point:

   .. code-block:: shell-session

       $ mkdir -p ~/cluster_data

   Mount the remote directory:

   .. code-block:: shell-session

       $ sshfs [username]@[hpc_hostname]:/path/to/remote/dataset ~/cluster_data

#. **Download Files Using fpsync**

   Once the remote directory is mounted, you can treat it like a local directory. Use `fpsync` to copy the files in parallel, which significantly speeds up the transfer.

   Create a local destination directory for your dataset:

   .. code-block:: shell-session

       $ mkdir -p ~/local_dataset

   Transfer files using 8 parallel processes. You can adjust the number with the ``-n`` option.

   .. code-block:: shell-session

       $ fpsync -t $HOME/.fpsync -n 8 -vv ~/cluster_data/ ~/local_dataset/

#. **Unmount the Directory**

   After the transfer is complete, unmount the directory to close the connection.

   .. code-block:: shell-session

       # For Linux
       $ fusermount -u ~/cluster_data

       # For macOS
       $ umount ~/cluster_data

   .. note::
      - Choose an appropriate number of parallel processes (``-n``) based on your local machine's capabilities and network conditions.
      - Always verify that the transfer has completed successfully before unmounting or deleting source files.

   .. warning::
      - Ensure you have sufficient local disk space before starting the transfer.
      - Do not interrupt the `fpsync` process, as this can result in an incomplete or corrupted dataset.
      - A high number of parallel transfers may impact the performance of your local machine.

Root Cause
----------

Direct outbound SSH connections from the cluster nodes are often restricted for security reasons. Using ``sshfs`` circumvents this by establishing an inbound SSH connection from your local machine to mount the remote filesystem.

Standard tools like `scp` or `rsync` transfer files serially. For datasets with thousands of small files, the overhead of establishing a connection for each file makes the process very slow. `fpsync` addresses this by using multiple parallel `rsync` or `cpio` workers to transfer files simultaneously, maximizing throughput.

References
----------

- `SSHFS Documentation <https://github.com/libfuse/sshfs>`_
- `fpart/fpsync Documentation <https://github.com/martymac/fpart>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-02-17
      | Issued by: kftse <kftse@ust.hk>
