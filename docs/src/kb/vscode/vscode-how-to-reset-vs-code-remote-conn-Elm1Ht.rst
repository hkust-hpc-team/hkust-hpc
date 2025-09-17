How to Reset VS Code Remote Connections
=======================================

.. meta::
    :description: Guide to resolve vscode remote connection issues by resetting tunnels
    :keywords: vscode, remote-ssh, remote-tunnel, connection, troubleshooting
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-01-07
    | *Solution under review*

Environment
-----------

    - Visual Studio Code

      - Remote SSH extension
      - Remote Tunnel extension

    - Linux/Unix remote systems

Issue
-----

    - Unable to establish VS Code tunnel connection with error

      - ``could not fetch remote environment``
      - ``Failed to connect to the remote extension host server (Error: WebSocket close
        with status code 1006)``

    - Fail to connect after updating local or remote VS Code version

Resolution
----------

.. tip::

    Try the quick clean-up steps below and retry establishing connection. If issues
    persist, follow the complete reset procedure.

Quick Clean-up
~~~~~~~~~~~~~~

.. note::

    You must terminate VS Code processes on all servers sharing the same ``$HOME``
    directory.

1. Terminate all VS Code server processes on the remote system

       .. code-block:: bash

           pgrep -u $USER -f '(code|node)\s' | xargs -r -t -i kill {}

2. Close VS Code on your local machine
3. Attempt to reestablish connection on remote as usual.

.. hint::

    It is best to separate tunnel connections by hostname or identifiers to avoid
    conflicts in case of having multiple server instances running.

    Here is an example of how to start a new tunnel with isolated configuration. You can
    replace ``$(hostname)`` with any unique identifier.

    .. code-block:: bash

        code --use-version stable \
          --user-data-dir ~/.vscode-server/vscode-$(hostname)/user-data \
          --disable-telemetry tunnel \
          --cli-data-dir ~/.vscode-server/vscode-$(hostname) \
          --server-data-dir ~/.vscode-server/vscode-$(hostname)/server-data \
          --extensions-dir ~/.vscode-server/vscode-$(hostname)/server-data/extensions

Complete Reset Procedure
~~~~~~~~~~~~~~~~~~~~~~~~

If the quick solution doesn't resolve the issue, follow these steps

.. warning::

    This procedure will remove all VS Code configuration files and extensions. Ensure
    you have a backup of your settings and extensions before proceeding.

    You will need to re-establish tunnels from scratch after following these steps.

1. Terminate all VS Code server processes on the remote system
2. Remove all VS Code configuration directories

       .. code-block:: bash

           rm -rf ~/.vscode*

3. Re-create tunnels using this best practice command

       .. code-block:: bash

           code --use-version stable \
             --user-data-dir ~/.vscode-server/vscode-$(hostname)/user-data \
             --disable-telemetry tunnel \
             --cli-data-dir ~/.vscode-server/vscode-$(hostname) \
             --server-data-dir ~/.vscode-server/vscode-$(hostname)/server-data \
             --extensions-dir ~/.vscode-server/vscode-$(hostname)/server-data/extensions

4. Attempt to reestablish connection on remote as usual.

Root Cause
----------

VS Code remote sessions can leave behind stale processes and configuration files when
connections fail. These remnants can interfere with new connection attempts.

It is also a known bug that updating VS Code can cause connection issues due to version
mismatch between local and remote instances.

.. rst-class:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-01-07
      | Issued by: kftse@ust.hk
