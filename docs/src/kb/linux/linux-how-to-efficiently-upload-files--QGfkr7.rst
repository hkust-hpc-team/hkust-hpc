How to Efficiently Upload Files to HPC Cluster
==============================================

.. meta::
    :description: Comprehensive guide for efficient file transfers to HPC clusters using fpsync, rsync, and other parallel methods
    :keywords: fpsync, rsync, file transfer, parallel upload
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-06-13
    | Keywords: fpsync, rsync, file transfer, parallel upload
    | *Solution verified*

Environment
-----------

    - macOS, Linux/Unix, or Windows with WSL
    - SSH access to HPC cluster

Issue
-----

    How can I efficiently transfer files to HPC clusters:

    - Upload large datasets (GB/TB scale) to HPC cluster efficiently
    - Upload datasets with resume capability for interrupted transfers
    - Upload many small files quickly (thousands of files)
    - Upload files in parallel to maximize bandwidth utilization
    - Monitor transfer progress and handle errors gracefully
    - Choose the best transfer method for different scenarios

Resolution
----------

Use ``fpsync`` for parallel file transfers, which significantly improves transfer speed compared to traditional methods.

Installation
~~~~~~~~~~~~

1. Install fpart package on your local machine:

.. code-block:: shell-session

    # Ubuntu/Debian:
    $ sudo apt install fpart

    # macOS:
    $ brew install fpart

    # CentOS/RHEL:
    $ sudo yum install fpart

Basic Usage
~~~~~~~~~~~

1. Transfer a directory to cluster:

.. code-block:: shell-session

    $ fpsync -n 8 ~/local_directory username@hpc.university.edu:~/remote_directory

1. Transfer with specific options:

.. code-block:: shell-session

    $ fpsync -n 8 -v -x -o "-a" ~/local_directory username@hpc.university.edu:~/remote_directory

Options Explained:
    - ``-n 8``: Use 8 parallel transfer processes
    - ``-v``: Verbose output
    - ``-x``: Cross filesystem boundaries
    - ``-o "-a"``: Pass rsync archive option

.. note::

    Choose number of parallel processes (``-n``) based on your network connection and system capabilities

.. warning::

    - Large number of parallel processes may overload the network or system
    - Always test with small directories first

Root Cause
----------

Traditional file transfer tools process files sequentially. When transferring many small files, the overhead of
establishing connections and handshaking for each file becomes significant. Parallel transfer tools like fpsync divide
the workload among multiple processes, utilizing available bandwidth more efficiently.

References
----------

- `fpsync Documentation <https://github.com/martymac/fpart>`_

Related Articles
----------------

- `How to Efficiently Remove Large Directories <linux-how-to-efficiently-remove-large--xY2yHF>`_

.. rst-class:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-01-07
      | Issued by: kftse <kftse@ust.hk>
