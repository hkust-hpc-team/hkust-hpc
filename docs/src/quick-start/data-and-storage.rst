Data and Storage Guide
======================

.. meta::
    :description: Quick-start guide to choosing storage locations and transferring files on HPC4 and SuperPOD.
    :keywords: HPC4, SuperPOD, storage, data transfer, home, scratch, project, scp, sftp, rsync

.. rst-class:: header

    | Last updated: 2026-06-04

This page helps new users decide where to place files on HPC4 or SuperPOD and how to transfer files to and from the system.

Environment
-----------

    - Users who have already obtained HPC4 or SuperPOD access
    - Windows 10/11, macOS, or Linux
    - SSH client or file transfer tool with SSH support

Directory Structure
-------------------

Both HPC4 and SuperPOD provide three main storage tiers.
The directory layout is similar, but quotas and retention policies differ.

.. list-table::
   :header-rows: 1
   :widths: 20 40 40

   * - Path
     - HPC4
     - SuperPOD
   * - ``/home/<username>``
     - 200 GB quota · backed up (14-day window)
     - persistent · see welcome email
   * - ``/scratch/<username>``
     - 500 GB quota · auto-purged after 60 days of inactivity
     - ``/scratch/<groupname>`` · 5 TB group quota · auto-purged after 30 days
   * - ``/project/<groupname>``
     - 10 TB per research group · not backed up
     - shared group storage · see welcome email

.. note::

   ``/scratch`` is **temporary** high-speed storage.  Do not rely on it for
   long-term retention.  Files without read or write access for the
   retention period are automatically deleted.

Recommended Placement
~~~~~~~~~~~~~~~~~~~~~

- **``/home/<username>``** — login scripts, dotfiles, small source trees, personal Python/Conda environments, container images.
- **``/scratch/<username>``** (HPC4) or **``/scratch/<groupname>``** (SuperPOD) — large temporary datasets, intermediate results, short-term job output.
- **``/project/<groupname>``** — shared datasets, shared source code, shared software stacks for your research group.

Check Disk Usage
~~~~~~~~~~~~~~~~

Use ``df -h`` to inspect available space:

.. code-block:: bash

     df -h /home /scratch /project

File Transfer
-------------

**rsync is the recommended tool** for most file transfers.
It supports directory sync, resume on failure, and delta transfers (only changed files).

.. tip::

   Use ``rsync`` for all transfers.  It is more reliable than ``scp`` for
   directories and large files, and it can resume interrupted transfers.

Use the same hostname and username format as your SSH login:

- Use your HKUST username only (do not append ``@ust.hk``).
- If you are off campus, connect through VPN before starting file transfer.

Rsync Example (Recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Upload a local directory to your home directory on the cluster:

.. code-block:: bash

    rsync -av local-folder/ <username>@hpc4.ust.hk:~/rsync-test/

The ``-a`` flag preserves permissions and timestamps; ``-v`` shows progress.
Add ``--progress`` for per-file transfer details.

Download a directory from the cluster:

.. code-block:: bash

    rsync -av <username>@hpc4.ust.hk:~/rsync-test/ ./local-folder/

Preview what would be transferred without copying:

.. code-block:: bash

    rsync -avn local-folder/ <username>@hpc4.ust.hk:~/rsync-test/

For real project use:

- Upload small personal scripts to ``/home/<username>``
- Upload large temporary job input and output under ``/scratch/<username>`` (HPC4) or ``/scratch/<groupname>`` (SuperPOD)
- Upload team-shared files under ``/project/<groupname>``

SCP Example
~~~~~~~~~~~

Upload a single file:

.. code-block:: bash

    scp local-file.txt <username>@hpc4.ust.hk:~/

Download a single file:

.. code-block:: bash

    scp <username>@hpc4.ust.hk:~/local-file.txt ./downloaded-file.txt

SFTP Example
~~~~~~~~~~~~

Open an interactive SFTP session:

.. code-block:: bash

    sftp <username>@hpc4.ust.hk

Example SFTP commands:

.. code-block:: text

    pwd
    ls
    put local-file.txt
    get local-file.txt downloaded-via-sftp.txt
    bye

Verify the Transfer
-------------------

After uploading or syncing files, verify that they exist on the cluster.

For rsync verification:

.. code-block:: bash

    ssh <username>@hpc4.ust.hk 'ls -R ~/rsync-test'
    ssh <username>@hpc4.ust.hk 'cat ~/rsync-test/test.txt'

For SCP verification:

.. code-block:: bash

    ssh <username>@hpc4.ust.hk 'ls -l ~/local-file.txt'

Transfer Checklist
------------------

- Confirm the target directory before uploading.
- Use ``rsync`` instead of repeated ``scp`` when updating many files.
- Verify that the transfer completed successfully before starting a job.
- Remember that ``/scratch`` is automatically purged after inactivity — it is not a backup location.

References
----------

- Official login guide: https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/login
- Official VPN setup page: https://itso.hkust.edu.hk/services/cyber-security/vpn
- Official storage types page: https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/fileandstorage
