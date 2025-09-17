How to speed up Spack package installation
==========================================

.. meta::
    :description: Speed up Spack package build and installation.
    :keywords: spack, parallel, build, installation, performance, package
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2024-12-05
    | *Solution under review*

Environment
-----------

    - Spack
    - Linux
    - Network filesystem (NFS) storage

Issue
-----

    - Spack package build is slow
    - Spack does not parallelize configure phase
    - Spack install independent packages in serial
    - NFS is slow during Spack installation

Resolution
----------

Cluster spack instance by default uses ``-j $(nproc)`` each time ``spack install`` is invoked, and use ``/dev/shm`` as
temporary directory for build artifacts to speed up builds.

You may find these optimizations useful to further improve Spack build speed when installing packages with large number
of dependencies.

Parallel Package Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install multiple packages simultaneously using background processes

.. code-block:: bash

    # spack env activate ...
    spack install &
    spack install &
    spack install &

.. warning::

    We do no recommend having > 4 concurrent installations to avoid deadlock or system overload.

Local Lock File
~~~~~~~~~~~~~~~

Replace NFS lock with a lock on local filesystem to reduce I/O bottleneck

.. note::

    The local lock file needs to be recreated after system reboot

1. Create local lock directory

       .. code-block:: bash

           mkdir -p /run/$(id -u)/spack-app

2. Create local lock file

       .. code-block:: bash

           touch /run/$(id -u)/spack-app/prefix_lock

3. Link local lock to Spack directory

       .. code-block:: bash

           rm -f $HOME/.spack/apps/.spack-db/prefix_lock
           ln -s /run/$(id -u)/spack-app/prefix_lock $HOME/.spack/apps/.spack-db/prefix_lock

Root Cause
----------

Spack's default behavior has several performance limitations:

- Package installations are in serial, parallelization only occurs during the build phase of each package.
- Configure scripts run serially and are not parallelizable.
- NFS lock operations can become a bottleneck when handling many concurrent range locks

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://ITSO.ust.hk

    **Article Info**
      | Issued: 2024-12-05
      | Issued by: kftse (at) ust.hk
