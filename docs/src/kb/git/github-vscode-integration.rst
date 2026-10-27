Run VS Code on the cluster with Remote-SSH
==========================================

.. meta::
    :description: Install and use VS Code Remote-SSH to work on the HPC cluster, set Git identity, and clone a GitHub repository.
    :keywords: VS Code, Remote-SSH, Git, GitHub, clone, HPC
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2026-10-27
    | *Guide verified: 2026-10-27*

Use the **Remote - SSH** extension to edit files and run Git commands directly on the cluster from your local VS Code window.

Install Remote-SSH
------------------

On your local machine:

1. Open VS Code.
2. Open the Extensions view (``Ctrl+Shift+X`` on Windows/Linux, ``Cmd+Shift+X`` on macOS).
3. Search for ``Remote - SSH`` (published by Microsoft) and click **Install**.

Connect to the cluster
----------------------

1. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P`` on macOS).
2. Run ``Remote-SSH: Connect to Host...``.
3. Enter ``<username>@hpc4.ust.hk``, replacing ``<username>`` with your HPC account name.
4. If prompted for the remote platform, select **Linux**.
5. Enter your password or passphrase when prompted and wait for the new window to connect.

Check the bottom-left corner of the window. Once connected, the status bar shows ``SSH: hpc4.ust.hk``. Any terminal or folder you open in this window runs on the cluster.

Set your Git identity in VS Code
--------------------------------

Git needs your name and email before you can create commits on the cluster. You can set both in VS Code Settings while connected to the remote host.

**In VS Code Settings**

1. Open Settings (``Ctrl+,`` or ``Cmd+,`` on macOS).
2. Search for ``git user``.
3. Fill in **Git: User Name** and **Git: User Email**. These write ``user.name`` and ``user.email`` to your Git configuration.

If you leave these blank, VS Code prompts for them the first time you commit.

**Optional: from the terminal**

You can also set your identity in the remote integrated terminal:

.. code-block:: bash

    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"

Clone a GitHub repository
-------------------------

Make sure you are in the ``SSH: hpc4.ust.hk`` window so the repository clones to your cluster storage instead of your local disk.

1. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P`` on macOS).
2. Run ``Git: Clone``.
3. Paste the repository URL (such as ``https://github.com/hkust-hpc-team/hkust-hpc.git``) and press Enter.
4. Pick a target directory on the cluster, such as ``~/projects``.
5. Click **Open** when prompted to open the cloned repository.

You can also run ``git clone <url>`` in the remote terminal and open the directory with **File > Open Folder**.

References
----------

- `VS Code Remote - SSH <https://code.visualstudio.com/docs/remote/ssh>`_
- `VS Code Version Control <https://code.visualstudio.com/docs/sourcecontrol/overview>`_
- `Connecting to GitHub with SSH <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`_
