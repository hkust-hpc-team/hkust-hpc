How to Prevent SSH Session Disconnects and Timeouts
===================================================

.. meta::
    :description: Prevent SSH session disconnects and timeouts due to network inactivity
    :keywords: ssh, timeout, keepalive, screen, tmux, connection, putty, mobaxterm
    :author: chtaihei <chtaihei@ust.hk>

.. rst-class:: header

    | Last updated: 2024-12-06
    | *Solution verified: 2024-12-06*

Environment
-----------

    - SSH client software:

      - OpenSSH (Linux/macOS)
      - PuTTY (Windows)
      - MobaXterm (Windows)

    - ITSO HPC clusters

Issue
-----

    - SSH sessions disconnect during long operations due to network inactivity timeouts (e.g., 15-30 minutes).

Resolution
----------

Configure SSH Keep-Alive Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For OpenSSH (Linux/macOS)
+++++++++++++++++++++++++

Add these settings to your SSH config file:

.. code-block:: shell

    # Edit ~/.ssh/config
    Host server_name           # e.g., ust-hpc4
        HostName hostname      # e.g., hpc4.ust.hk
        User username
        ServerAliveInterval 60
        ServerAliveCountMax 3

Then connect using:

.. code-block:: shell

    ssh server_name

For PuTTY (Windows)
+++++++++++++++++++

#. Open PuTTY configuration
#. Navigate to Connection
#. Set "Seconds between keepalives" to 60
#. Save the session settings

For MobaXterm (Windows)
+++++++++++++++++++++++

#. Open Session Settings
#. Go to SSH tab
#. Enable "SSH keepalive"
#. Set interval to 60 seconds

Use Terminal Multiplexers
~~~~~~~~~~~~~~~~~~~~~~~~~

GNU Screen:

.. code-block:: shell

    # Start new session
    screen

    # Reconnect to existing session
    screen -r

Tmux:

.. code-block:: shell

    # Start new session
    tmux

    # Reconnect to existing session
    tmux attach

Best Practices for Long Operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Use batch job submission systems instead of interactive sessions
- Always run important interactive session in terminal multiplexer sessions
- For background processes, use nohup:

.. code-block:: shell

    nohup long_running_command &

Root Cause
----------

ITSO HPC clusters drop inactive SSH connections after a certain period to free up resources. This is a security measure
to prevent unauthorized access to idle sessions.

Diagnosis
---------

Check if you're experiencing timeouts by:

- Monitoring connection duration
- Testing with different keepalive intervals
- Checking system/client logs for disconnect messages

References
----------

- OpenSSH Configuration Manual: https://man.openbsd.org/ssh_config
- GNU Screen Manual: https://www.gnu.org/software/screen/manual/
- Tmux Documentation: https://github.com/tmux/tmux/wiki
- PuTTY Documentation: https://tartarus.org/~simon/putty-snapshots/htmldoc/
- MobaXterm Documentation: https://mobaxterm.mobatek.net/documentation.html

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://ITSO.ust.hk

    **Article Info**
      | Issued: 2024-12-06
      | Issued by: chtaihei@ust.hk
