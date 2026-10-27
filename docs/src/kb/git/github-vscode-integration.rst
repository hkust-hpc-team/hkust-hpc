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

Use the **Remote - SSH** extension to edit files and run Git on a cluster login host from VS Code. The steps work on both HPC4 and SuperPOD (spod).

Install Remote-SSH
------------------

1. Open VS Code on your computer.
2. Open Extensions (``Ctrl+Shift+X`` on Windows/Linux, ``Cmd+Shift+X`` on macOS).
3. Search for ``Remote - SSH`` from Microsoft and click **Install**.

Connect to the cluster
----------------------

1. Open the Command Palette (``Ctrl+Shift+P`` on Windows/Linux, ``Cmd+Shift+P`` on macOS).
2. Run ``Remote-SSH: Connect to Host...``.
3. Enter ``<username>@<cluster-hostname>``.

   - HPC4 example: ``alice@hpc4.ust.hk``
   - SuperPOD (spod) example: ``alice@superpod.ust.hk``

4. Select **Linux** if VS Code asks for the remote platform.
5. Enter your password or SSH key passphrase.

When connected, the bottom-left status bar shows ``SSH: <cluster-hostname>``. All terminals and folders in this window now run on the cluster.

Set your Git identity
---------------------

Git requires a name and email before you can commit. Set them in the remote terminal as shown in the `VS Code source control quickstart <https://code.visualstudio.com/docs/sourcecontrol/quickstart#_prerequisites>`_.

1. In the remote VS Code window, select **Terminal > New Terminal**.
2. Check that Git is installed:

   .. code-block:: bash

       git --version

3. Set your name and email:

   .. code-block:: bash

       git config --global user.name "<your-name>"
       git config --global user.email "<your-email>"

``--global`` saves these values to ``~/.gitconfig`` on the cluster login host.

Clone a GitHub repository
-------------------------

Check that the status bar still shows ``SSH: <cluster-hostname>`` so the repository clones to the cluster, not your computer.

1. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P``).
2. Run ``Git: Clone``.
3. Paste the repository URL (for example, ``https://github.com/hkust-hpc-team/hkust-hpc.git``) and press Enter.
4. Select a folder on the cluster, such as ``~/projects``.
5. Click **Open** to open the cloned folder.

You can also run ``git clone <url>`` in the remote terminal, then open the folder with **File > Open Folder**.

References
----------

- `VS Code Remote - SSH <https://code.visualstudio.com/docs/remote/ssh>`_
- `VS Code source control quickstart <https://code.visualstudio.com/docs/sourcecontrol/quickstart#_prerequisites>`_
- `VS Code Version Control <https://code.visualstudio.com/docs/sourcecontrol/overview>`_
- `Connecting to GitHub with SSH <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`_
