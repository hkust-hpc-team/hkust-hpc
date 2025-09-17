How to resolve X11 authentication error
=======================================

.. meta::
    :description: How to resolve X11 authentication error when running X11 applications over SSH
    :keywords: x11, authentication, xauthority, display, ssh
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2024-12-05
    | *Solution under review*

Environment
-----------

    - Linux/macOS/Windows with X11 server
    - OpenSSH client with X11 forwarding enabled
    - X11 applications

Issue
-----

    - When running X11 applications after enabling X11 forwarding, encountered authentication error

      .. code-block:: shell-session

          username@hpcname:~$ firefox
          X11 connection rejected because of wrong authentication
          Error: cannot open display: localhost:10.0

Resolution
----------

- Set the ``XAUTHORITY`` environment variable to point to the correct xauth file

  .. code-block:: bash

      export XAUTHORITY="$HOME/.Xauthority"

- Launch the application again

  .. code-block:: shell-session

      username@hpcname:~$ firefox

Root Cause
----------

X11 forwarding requires proper authentication between the client and server.

While some applications defaults to look for xauth file at ``~/.Xauthority``, some X11 applications may require setting
the XAUTHORITY environment variable explicitly.

.. rst-class:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2024-12-05
      | Issued by: kftse (at) ust.hk
