How to enable X11 forwarding for remote access
==============================================

.. meta::
    :description: How to enable X11 forwarding for remote access using SSH
    :keywords: x11, ssh, display, forwarding, remote access
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2024-12-05
    | *Solution under review*

Environment
-----------

    - Linux/macOS/Windows with X11 server
    - OpenSSH client
    - X11 applications

Issue
-----

    - When trying to run X11 applications on remote systems, encountered error message

      .. code-block:: shell-session

          username@slogin-01:~$ xclock
          Error: Can't open display:

Resolution
----------

Enable X11 forwarding in SSH client when connecting to the remote system.

Enable X11 Forwarding
~~~~~~~~~~~~~~~~~~~~~

.. note::

    X11 forwarding must be enabled when connecting to the remote system via SSH. Please
    disconnect your current SSH session and reconnect after applying the changes.

X11 forwarding can be enabled ad-hoc at command-line or persistently by modifying SSH
client config.

One-time Connection
+++++++++++++++++++

Use ``-X`` flag when connecting via SSH

.. code-block:: bash

    ssh -X username@hpcname.ust.hk

Persistent Configuration
++++++++++++++++++++++++

Add X11 forwarding settings to your SSH config file

1. Create or edit ``~/.ssh/config``

       .. code-block:: bash

           mkdir -p ~/.ssh
           chmod 700 ~/.ssh
           nano ~/.ssh/config

2. Add the following configuration

       .. code-block:: text

           Host hpcname.ust.hk
               ForwardX11 yes
               ForwardX11Trusted yes

3. Set proper permissions

       .. code-block:: bash

           chmod 600 ~/.ssh/config

Verify X11 Connection
~~~~~~~~~~~~~~~~~~~~~

Test the connection by running a simple X11 application

.. warning::

    Ensure you have an X11 server installed and running on your local machine

    - Linux: Usually pre-installed (xorg)
    - macOS: Install XQuartz
    - Windows: Install VcXsrv or Xming

.. code-block:: bash

    xclock

Or check the ``DISPLAY`` environment variable

.. code-block:: bash

    echo $DISPLAY

Root Cause
----------

X11 forwarding requires client support, which is disabled by default.

----

.. rst-class:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2024-12-05
      | Issued by: kftse (at) ust.hk
