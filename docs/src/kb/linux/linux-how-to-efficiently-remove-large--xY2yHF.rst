How to Efficiently Remove Large Number of Files
===============================================

.. meta::
    :description: Efficiently remove large number of files using parallel deletion
    :keywords: file deletion, parallel, fd, xargs, rm, nfs
    :author: kftse <kftse@ust.hk>

.. container::
    :name: header

    | Last updated: 2024-12-13
    | *Solution under review*

Environment
-----------

    - Linux/Unix systems
    - NFS Storage

Issue
-----

    When dealing with large directories containing numerous files or subdirectories,
    standard removal commands like `rm -rf` or `conda env remove` can be extremely slow.

    This is particularly noticeable when

        - Removing conda environments
        - Deleting virtual environments
        - Cleaning up directories with many small files
        - Removing large datasets with numerous files

Resolution
----------

Use parallel file deletion to significantly speed up the removal process

.. code-block:: bash

    nohup bash -c "fd -uua0 --one-file-system . /path/to/delete | xargs -r0 -P $(nproc) -n 128 rm -rf" &

.. note::

    For Ubuntu systems, the command is ``fdfind`` instead of ``fd``. You may alias
    ``fdfind`` to ``fd`` for compatibility if needed.

Command Details
~~~~~~~~~~~~~~~

``nohup ... &``

- Runs the command in background, continues even if terminal closes

``fdfind`` flags

- ``-uu`` : Unrestricted search (includes hidden files)
- ``-a0`` : Print absolute paths, null-terminated output
- ``--one-file-system`` : Stay within the same filesystem

``xargs`` flags:

- ``-r`` : Don't run command if input is empty
- ``-0`` : Input items are terminated by null character
- ``-P $(nproc)`` : Run up to number-of-CPUs processes in parallel
- ``-n 128`` : Use at most 128 arguments per command line

.. note::

    Running deletion in parallel can significantly impact I/O performance. Consider
    running during off-peak hours for large deletions.

.. warning::

    Double-check the target directory path before execution - this operation cannot be
    undone.

Root Cause
----------

Sequential file deletion becomes inefficient when dealing with large numbers of files.
There are several contributing factors:

- File system metadata updates for each deletion
- Single-threaded operation in standard removal commands
- Directory entry updates
- Inode management overhead

By parallelizing the deletion process and using efficient file finding, we can
significantly reduce the total time required for bulk file removal.

References
----------

- ``fd`` help or manual: ``fd --help`` or ``man fd``
- ``fd`` Github Repository: https://github.com/sharkdp/fd
- ``xargs`` help or manual: ``xargs --help`` or ``man xargs``

----

.. container::
    :name: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2024-12-13
      | Issued by: kftse@ust.hk
