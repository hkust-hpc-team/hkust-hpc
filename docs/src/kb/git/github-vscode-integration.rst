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

This guide covers installing **Remote - SSH**, connecting to the cluster, setting your Git identity in the VS Code UI, and cloning a GitHub repository onto the HPC host.

Install Remote-SSH
------------------

On your **local** machine:

1. Open VS Code.
2. Open Extensions (``Ctrl+Shift+X`` or ``Cmd+Shift+X`` on macOS).
3. Search for ``Remote - SSH`` (publisher: Microsoft) and install it.

Connect to the cluster
----------------------

1. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P`` on macOS).
2. Run ``Remote-SSH: Connect to Host...``.
3. Enter ``<username>@hpc4.ust.hk`` (use your HPC username).
4. Choose the platform if asked (usually Linux) and wait for the remote window to open.

The status bar should show ``SSH: hpc4.ust.hk`` (or similar). New terminals and extensions in that window run on the cluster.

Set your Git identity in VS Code
--------------------------------

With the remote window open, set your name and email so commits on the cluster are attributed correctly.

**In the VS Code UI**

1. Open Settings (``Ctrl+,`` or ``Cmd+,`` on macOS).
2. Search for ``git user``.
3. Set **Git: User Name** and **Git: User Email** (these map to ``user.name`` and ``user.email``).

If those settings are empty, VS Code may also prompt for name and email the first time you commit.

**Optional: terminal**

In the remote integrated terminal you can still run:

.. code-block:: bash

    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"

Clone a GitHub repository
-------------------------

Stay connected over Remote-SSH so the clone lands on the cluster, not your laptop.

1. Open the Command Palette.
2. Run ``Git: Clone``.
3. Paste the repository URL (for example ``https://github.com/hkust-hpc-team/hkust-hpc.git``) and press Enter.
4. Choose a directory on the cluster (for example ``~/projects``).
5. Click **Open** when VS Code offers to open the folder.

From the remote terminal you can instead run ``git clone <url>`` and open the folder with **File → Open Folder**.

References
----------

- `VS Code Remote - SSH <https://code.visualstudio.com/docs/remote/ssh>`_
- `VS Code Version Control <https://code.visualstudio.com/docs/sourcecontrol/overview>`_
- `Connecting to GitHub with SSH <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`_
