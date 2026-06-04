Data and Storage Guide
======================

.. meta::
    :description: Quick-start guide to choosing storage locations and transferring files to and from HPC4.
    :keywords: HPC4, storage, data transfer, home, scratch, project, scp, sftp, rsync

.. rst-class:: header

    | Last updated: 2026-06-04

This page helps new users decide where to place files on HPC4 and how to transfer files to and from the system.

Environment
-----------

    - Users who have already obtained HPC4 access
    - Windows 10/11, macOS, or Linux
    - SSH client or file transfer tool with SSH support

Directory Differentiation
-------------------------

Before uploading or generating files on HPC4, identify the correct destination directory.

- ``/home/<username>``: Personal home directory for configuration files, small scripts, executables, container images, Conda environments, and small datasets. Default quota is 200 GB. Official HPC4 storage summary states that home directories have a 14-day backup window.
- ``/scratch/<username>``: Per-user high-speed scratch space for temporary job input, intermediate files, and short-term job output. Default quota is 500 GB. Scratch is not backed up, and files without read or write access for 60 days are automatically purged.
- ``/project/<groupname>``: Shared group storage for members of a PI research group. Default quota is 10 TB per research group. Use this for shared datasets, shared source code, and shared software packages.

.. note::

    Do not assume all directories have the same quota, retention policy, or backup policy.
    On the official HPC4 storage page, home storage is backed up, while project and scratch storage are not.

Recommended placement
~~~~~~~~~~~~~~~~~~~~~

- Put login scripts, dotfiles, small source trees, and personal Python environments in ``/home/<username>``.
- Put large temporary datasets, intermediate results, and short-term job output in ``/scratch/<username>``.
- Put shared project data, shared code, and shared software stacks in ``/project/<groupname>``.
- Do not rely on ``/scratch/<username>`` for long-term retention.

Useful capacity check
~~~~~~~~~~~~~~~~~~~~~

The official HPC4 storage page recommends this command to inspect the three major storage types:

.. code-block:: bash

     df -h /home /project /scratch

File Transfer
-------------

HPC4 file transfer is typically done over SSH-based tools.
**File transfers should be initiated from the login node;**
do not run ``rsync`` or ``scp`` from inside a compute job unless your
workflow specifically requires it.

The examples below were tested with a user home directory on 2026-06-04.
They are suitable as smoke tests before you start transferring project data.

Use the same HPC4 login hostname and username format as your SSH login:

- use your HKUST username only
- do not append ``@ust.hk`` or ``@connect.ust.hk`` to the username
- if you are off campus, connect through VPN before starting file transfer

SCP Example
~~~~~~~~~~~

Upload a local file to your home directory on HPC4:

.. code-block:: bash

    scp local-file.txt <username>@hpc4.ust.hk:~/

Download the same file back to your local machine:

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

Rsync Example
~~~~~~~~~~~~~

Use ``rsync`` when transferring directories or repeatedly syncing updated files.

Create a small local test directory first:

.. code-block:: bash

    mkdir -p local-folder
    echo "rsync test" > local-folder/test.txt

Preview the transfer without copying files:

.. code-block:: bash

    rsync -avn local-folder/ <username>@hpc4.ust.hk:~/rsync-test/

Run the actual transfer:

.. code-block:: bash

    rsync -av local-folder/ <username>@hpc4.ust.hk:~/rsync-test/

For real project use after the smoke test:

- upload small personal scripts to ``/home/<username>``
- upload large temporary job input and output under ``/scratch/<username>``
- upload team-shared files under ``/project/<groupname>``

Verify the Transfer
-------------------

After uploading or syncing files, verify that they exist on HPC4.

For SCP upload verification:

.. code-block:: bash

    ssh <username>@hpc4.ust.hk 'ls -l ~/local-file.txt'

For SCP download verification:

.. code-block:: bash

    cat downloaded-file.txt

For rsync verification:

.. code-block:: bash

    ssh <username>@hpc4.ust.hk 'ls -R ~/rsync-test'
    ssh <username>@hpc4.ust.hk 'cat ~/rsync-test/test.txt'

Transfer Checklist
------------------

- Confirm the target directory before uploading.
- Avoid writing large temporary files into the wrong location.
- Verify that the transfer completed successfully before starting a job.
- Use ``rsync`` instead of repeated manual copies when updating many files.
- Remember that ``/scratch/<username>`` is automatically purged after inactivity and is not a backup location.

References
----------

- Official login guide: https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/login
- Official VPN setup page: https://itso.hkust.edu.hk/services/cyber-security/vpn
- Official storage types page: https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/fileandstorage
