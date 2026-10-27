Cloning GitHub with VS Code
===============================

.. meta::
    :description: Clone GitHub repositories directly onto the HPC cluster using VS Code Remote-SSH.
    :keywords: VS Code, Git, GitHub, clone, Remote-SSH, HPC
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-07-03
    | *Guide verified: 2025-07-03*

.. tip::
   Connect to the cluster with the **Remote - SSH** extension (``<username>@hpc4.ust.hk``) before cloning. This clones the repository directly onto the HPC host instead of your local machine.

Prerequisites
-------------

Set your Git identity on the cluster if you have not done so:

.. code-block:: bash

    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"

Cloning a Repository
--------------------

1. Connect to ``<username>@hpc4.ust.hk`` in VS Code via **Remote - SSH**.
2. Open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P`` on macOS).
3. Run ``Git: Clone``.
4. Paste the repository URL (for example, ``https://github.com/hkust-hpc-team/hkust-hpc.git``) and press Enter.
5. Select a target directory on the cluster (such as ``~/projects``).
6. Click **Open** when prompted to open the cloned repository.

If you prefer the integrated terminal, run ``git clone https://github.com/hkust-hpc-team/hkust-hpc.git`` and open the folder with ``code hkust-hpc``.

References
----------

- `VS Code Version Control Documentation <https://code.visualstudio.com/docs/editor/versioncontrol>`_
- `Connecting to GitHub with SSH <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`_
