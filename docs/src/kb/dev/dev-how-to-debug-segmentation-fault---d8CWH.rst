How to Debug Segmentation Fault in C/C++/Fortran Applications
=============================================================

.. meta::
    :description: A comprehensive guide to debug segmentation fault errors in C/C++/Fortran applications on HPC clusters
    :keywords: segmentation fault, debugging, gdb, coredump, C, C++, Fortran, HPC, MPI
    :author: kftse <kftse@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-09-29
    | *Solution under review*

Environment
-----------

- Linux Computing Cluster
- Applications written in C/C++/Fortran
- Including MPI applications

Issue
-----

Your program crashes with "Segmentation fault (core dumped)" error message, which
typically appears as:

.. code-block:: shell-session

    [cpu11:3595716:0:3595716] Caught signal 11 (Segmentation fault: invalid permissions for mapped object at address 0x150478021008)
    ==== backtrace (tid:3595716) ====
    0  .../lib/libucs.so.0(+0x4821e) [0x15048a54f21e]
    1  .../lib/libucs.so.0(+0x473b4) [0x15048a54e3b4]
    2  /lib64/libc.so.6(+0x3e730) [0x15048a776730]
    3  build/segfault-debug(+0x1eb0) [0x5578f6512eb0]
    4  build/segfault-debug(+0x1da1) [0x5578f6512da1]
    5  /lib64/libc.so.6(+0x295d0) [0x15048a7615d0]
    6  /lib64/libc.so.6(__libc_start_main+0x80) [0x15048a761680]
    7  build/segfault-debug(+0x1c65) [0x5578f6512c65]
    =================================
    srun: error: cpu11: task 1: Segmentation fault (core dumped)
    srun: error: cpu11: task 3: Segmentation fault (core dumped)
    srun: error: cpu11: task 2: Segmentation fault (core dumped)

Resolution
----------

Segmentation fault errors in C/C++/Fortran applications can be caused by various issues,
such as dereferencing null or invalid pointers, accessing memory out of bounds, or stack
overflows.

Here are the recommended steps to diagnose and resolve the issue:

Step 1: Reduce Complications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here are some common issues that can be checked quickly

- Check system limits with ``ulimit -a`` to ensure stack size and locked memory size are
  adequate

  .. code-block:: shell-session

      $ ulimit -a
      max locked memory       (kbytes, -l) unlimited
      stack size              (kbytes, -s) unlimited

- Run the application with smaller input or fewer processes to simplify the potential
  error
- Run the application with single node to rule out network-related problems
- Recompile the application with lower optimization levels (e.g., ``-O1`` instead of
  ``-O3``) to eliminate compiler optimization issues

Step 2: Enable Core Dump Collection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Clean and rebuild your program with debug symbols and lower optimization

  .. note::

      The build command needed depends on your application.

  .. code-block:: shell-session

      $ make clean
      $ make CFLAGS="-O1 -g" CXXFLAGS="-O1 -g" FFLAGS="-O1 -g"

- Request an interactive job for debugging, for example, requesting 4 mpi ranks only

  .. code-block:: shell-session

      $ srun ... --ntasks-per-node=4 --cpus-per-task=32 --pty bash

- Enable core dump generation:

  .. code-block:: shell-session

      $ ulimit -c unlimited
      $ ulimit -a
      core file size              (blocks, -c) unlimited

- Run your application with overlap mode, your app would reproduce the segmentation
  fault.

  .. note::

      Do not press ``ctrl+c`` to terminate the job immediately, otherwise the coredump
      file may not be generated.

  .. code-block:: shell-session

      $ srun --overlap ./your_app
      [cpu11:3595716:0:3595716] Caught signal 11 (Segmentation fault: invalid permissions for mapped object at address 0x150478021008)
      ==== backtrace (tid:3595716) ====
      0  .../lib/libucs.so.0(+0x4821e) [0x15048a54f21e]
      1  .../lib/libucs.so.0(+0x473b4) [0x15048a54e3b4]
      2  /lib64/libc.so.6(+0x3e730) [0x15048a776730]
      3  build/segfault-debug(+0x1eb0) [0x5578f6512eb0]
      4  build/segfault-debug(+0x1da1) [0x5578f6512da1]
      5  /lib64/libc.so.6(+0x295d0) [0x15048a7615d0]
      6  /lib64/libc.so.6(__libc_start_main+0x80) [0x15048a761680]
      7  build/segfault-debug(+0x1c65) [0x5578f6512c65]
      =================================
      srun: error: cpu11: task 1: Segmentation fault (core dumped)
      srun: error: cpu11: task 3: Segmentation fault (core dumped)
      srun: error: cpu11: task 2: Segmentation fault (core dumped)

Step 3: Retrieve and Analyze Core Dump
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Locate your core dump files in the system directory

  .. code-block:: shell-session

      $ ls -lh /var/lib/systemd/coredump/
      -rw-r----- 1 root root 421K Sep 29 10:30 core.your_app.1001.f82f362e60834791838dad4c3e378781.3595715.1759132168000000.zst
      -rw-r----- 1 root root 419K Sep 29 10:30 core.your_app.1001.f82f362e60834791838dad4c3e378781.3595716.1759132168000000.zst
      -rw-r----- 1 root root 419K Sep 29 10:30 core.your_app.1001.f82f362e60834791838dad4c3e378781.3595717.1759132168000000.zst

- Decompress one of the core dumps to your working directory

  .. code-block:: shell-session

      $ zstd -d /var/lib/systemd/coredump/core.your_app.......zst -o core.your_app

- Load the core dump into GDB for analysis

  .. code-block:: shell-session

      $ gdb ./your_application core.your_app

Step 4: Debug with GDB
~~~~~~~~~~~~~~~~~~~~~~

Here showcase some common gdb commands to analyze the core dump.

- Get the backtrace to see the function call stack at the crash point

  .. code-block:: shell-session

      (gdb) bt
      #0  initialize_array (array=0x153635fff010, rank=3) at src/mpi_impl.c:14
      #1  process_array_and_calculate_sum (rank=3) at src/mpi_impl.c:27
      #2  0x000055c955b2cda1 in main (argc=1, argv=0x7ffc29621628) at src/main.c:21

- Examine the source code around the crash location

  .. code-block:: shell-session

      (gdb) list
      9     const unsigned long base = (unsigned long)rank * PER_RANK_ARRAY_SIZE;
      10    for (int i = 0; i < PER_RANK_ARRAY_SIZE; i++)
      11    {
      12      // BUG: should be array[i] = base + i;
      13      // This causes segmentation fault when rank > 1
      14      array[i * (rank + 1)] = base + i;
      15    }
      16  }

- Inspect variable values at the time of crash

  .. code-block:: shell-session

      (gdb) print i
      $1 = <optimized out>
      (gdb) print rank
      $2 = 3
      (gdb) print array
      $3 = (unsigned long *) 0x153635fff010

  .. note::

      If variables show ``<optimized out>``, rebuild with ``-O0 -g`` flags for complete
      debugging information.

Root Cause
----------

Common causes of segmentation faults include:

- **Null pointer dereference**: Accessing memory through uninitialized or null pointers
- **Buffer overflow**: Writing beyond allocated memory boundaries
- **Use after free**: Accessing memory that has been deallocated
- **Stack overflow**: Excessive recursion or large local variables exceeding stack
  limits
- **Invalid memory access**: Accessing memory outside the program's address space

Try It Yourself
---------------

To practice the debugging techniques described in this guide, you can work with our
example segmentation fault program:

**Example Repository**:
https://github.com/hkust-hpc-team/hkust-hpc/tree/main/examples/debug-segmentation-fault/

This example includes:

- A simple MPI C program that intentionally contains a segmentation fault bug
- Build instructions and compilation flags for debugging

Clone the repository and follow the instructions to reproduce the segmentation fault,
then use the techniques from this guide to identify and fix the bug.

----

.. container::
    :name: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-09-29
      | Issued by: kftse@ust.hk
