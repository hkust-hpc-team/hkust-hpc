How to Prevent SSH Session Disconnects and Timeouts
===================================================

.. meta::
    :description: Prevent SSH session disconnects and timeouts due to network inactivity
    :keywords: ssh, timeout, keepalive, screen, tmux, connection, putty, mobaxterm
    :author: chtaihei <chtaihei@ust.hk>

.. container:: header

    | Last updated: 2024-12-06
    | *Solution verified: 2024-12-06*

Environment
-----------

    - SSH client software:

      - OpenSSH (Linux/macOS)
      - PuTTY (Windows)
      - MobaXterm (Windows)

    - ITSC HPC clusters

Issue
-----

    - SSH sessions disconnect during long operations due to network inactivity timeouts
      (e.g., 15-30 minutes).

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

1. Open PuTTY configuration
2. Navigate to Connection
3. Set "Seconds between keepalives" to 60
4. Save the session settings

For MobaXterm (Windows)
+++++++++++++++++++++++

1. Open Session Settings
2. Go to SSH tab
3. Enable "SSH keepalive"
4. Set interval to 60 seconds

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

ITSC HPC clusters drop inactive SSH connections after a certain period to free up
resources. This is a security measure to prevent unauthorized access to idle sessions.

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

----

.. container:: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2024-12-06
      | Issued by: chtaihei@ust.hk
