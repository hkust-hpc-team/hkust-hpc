How can I share spack compiled program in a project group?
==========================================================

.. meta::
    :description: Sharing Spack compiled programs and libraries with other group members
    :keywords: spack, module, shared libraries
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2024-11-28
    | *Solution under review*

Environment
-----------

    - HPC4
    - Spack (All versions)

Issue
-----

    - How to share libraries and program compiled using Spack with other group members?

Resolution
----------

If you have compiled the libraries and program in the default user's Spack directory, you must recompile program and
libraries in a shared Spack directory, and have other group members to use the same shared Spack instance.

Managing shared Spack directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To relocate Spack onto a shared directory, you need to set the environment variables ``SPACK_USER_CONFIG_PATH`` and
``SPACK_USER_CACHE_PATH`` and reload the spack environment.

.. warning::

    Please assign a member as the **owner (writable)** of the shared Spack instance.Having multiple users to modify
    software in the same shared Spack directory may cause conflicts.

    If there is need for multiple users to modify the software, consider sharing ``spack env`` yaml definition instead.

Create a shared Spack instance
++++++++++++++++++++++++++++++

Create a directory for Spack under ``/project`` of your group.

.. code-block:: bash

    mkdir -p /project/my-research-group/spack

Set the environment variables and reload the spack environment

.. code-block:: bash

    export SPACK_USER_CONFIG_PATH="/project/my-research-group/spack"
    export SPACK_USER_CACHE_PATH="/project/my-research-group/spack"
    . /opt/shared/spack/share/spack/setup-env.sh

This will initialize the shared Spack instance in ``/project/my-research-group/spack``

Recompile program and libraries
+++++++++++++++++++++++++++++++

You should set and reload the spack environment whenever you need to modify this shared Spack instance, instead of the
default user's Spack instance.

.. code-block:: bash

    export SPACK_USER_CONFIG_PATH="/project/my-research-group/spack"
    export SPACK_USER_CACHE_PATH="/project/my-research-group/spack"
    . /opt/shared/spack/share/spack/setup-env.sh

After setting the environment variables, any spack command can be used as usual.

.. code-block:: bash

    # spack install cmake

Using shared executables and libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All spack executables and libraries can be accessed via ``module`` command.

.. code-block:: bash

    module use /project/my-research-group/spack/lmod/Core

You should find the installed software listed under the shared Spack instance's path.

.. code-block:: shell-session

    user@host:~ ]$ module avail
    ------------------- /project/my-research-group/spack/lmod/Core --------------------
    cmake/3.xx.x-abcdefg

    ------------------------ /opt/shared/modulefiles/Core -----------------------------
    ...

Use ``module load`` to load software and libraries as usual.

.. note::

    In case another version is available at other module locations, you should specify the ``version`` and ``hash`` to
    ensure the correct software is loaded.

.. code-block:: bash

    module load cmake/3.xx.x-abcdefg

Root Cause
----------

The default location of Spack user installation is ``$HOME/.spack`` directory.

It is not possible to share anything inside ``$HOME`` directory with your group members.

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2024-12-03
      | Issued by: kftse (at) ust.hk
