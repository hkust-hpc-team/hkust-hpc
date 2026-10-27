Run VS Code on the cluster with Remote-SSH
==========================================

.. meta::
    :description: Install and use VS Code Remote-SSH on HKUST HPC clusters, set Git identity, and clone a GitHub repository.
    :keywords: VS Code, Remote-SSH, Git, GitHub, clone, HPC, HPC4, SuperPOD
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2026-10-27
    | *Guide verified: 2026-10-27*

With the **Remote - SSH** extension, you can use VS Code on your own computer to edit files and run Git directly on a cluster login host. The same steps work for both HPC4 and SuperPOD (spod).

Install Remote-SSH
------------------

1. Open VS Code on your local computer.
2. Open the Extensions view (``Ctrl+Shift+X`` on Windows/Linux, ``Cmd+Shift+X`` on macOS).
3. Search for Microsoft's ``Remote - SSH`` extension and click **Install**.

Connect to the cluster
----------------------

1. Open the Command Palette (``Ctrl+Shift+P`` on Windows/Linux, ``Cmd+Shift+P`` on macOS).
2. Select ``Remote-SSH: Connect to Host...``.
3. Type your login address in the form ``<username>@<cluster-hostname>``:

   - HPC4 example: ``alice@hpc4.ust.hk``
   - SuperPOD (spod) example: ``alice@superpod.ust.hk``

4. If VS Code asks for the remote platform, choose **Linux**.
5. Enter your cluster password or SSH key passphrase when prompted.

Once you're connected, the bottom-left corner of the status bar will show ``SSH: <cluster-hostname>``. Any folders or terminals you open in this window are on the cluster.

If you don't want to type your password and approve a Duo prompt every time you connect, you can set up SSH keys instead. See :doc:`Login to HPC Cluster Without Using Password </kb/ssh/ssh-login-to-hpc-cluster-without-usi-ImiEj9>`.

Set your Git identity
---------------------

Before you can make commits, Git needs to know your name and email address. Open a terminal in the remote window and set them up, following the `VS Code source control quickstart <https://code.visualstudio.com/docs/sourcecontrol/quickstart#_prerequisites>`_:

1. In the remote VS Code window, go to **Terminal > New Terminal**.
2. Make sure Git is available on the login host:

   .. code-block:: bash

       git --version

3. Configure your name and email:

   .. code-block:: bash

       git config --global user.name "<your-name>"
       git config --global user.email "<your-email>"

The ``--global`` flag writes these settings to ``~/.gitconfig`` in your home directory on the cluster login host.

Clone a GitHub repository
-------------------------

Before cloning, glance at the bottom-left status bar and confirm it says ``SSH: <cluster-hostname>``—otherwise VS Code will clone the repository to your local machine instead of the cluster.

1. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P``).
2. Select ``Git: Clone``.
3. Paste the repository URL (for example, ``https://github.com/hkust-hpc-team/hkust-hpc.git``) and press Enter.
4. Pick a destination folder on the cluster, such as ``~/projects``.
5. Click **Open** when VS Code offers to open the cloned repository.

If you prefer the command line, run ``git clone <url>`` in the remote terminal and then open the folder through **File > Open Folder**.

References
----------

- `VS Code Remote - SSH <https://code.visualstudio.com/docs/remote/ssh>`_
- `VS Code source control quickstart <https://code.visualstudio.com/docs/sourcecontrol/quickstart#_prerequisites>`_
- `VS Code Version Control <https://code.visualstudio.com/docs/sourcecontrol/overview>`_
- `Connecting to GitHub with SSH <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`_
- :doc:`Login to HPC Cluster Without Using Password </kb/ssh/ssh-login-to-hpc-cluster-without-usi-ImiEj9>`
