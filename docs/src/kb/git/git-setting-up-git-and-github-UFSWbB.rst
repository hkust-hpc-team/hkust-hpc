.. _git-setup:

Setting Up Git and GitHub
=========================

.. meta::
    :description: Set up Git and connect to GitHub over SSH
    :keywords: git, github, setup, configuration, ssh, hpc

.. container::
    :name: header

    | Last updated: 2026-10-27
    | *Solution verified: 2026-10-27*

This guide covers installing Git, setting basic configuration, and connecting to GitHub over SSH on a local workstation or an HPC cluster.

Install Git
-----------

Most HPC login nodes already provide Git in the base environment or through an environment module (for example, ``module load git``). Check the installed version first:

.. code-block:: bash

    git --version

Use Git 2.28 or newer so ``init.defaultBranch`` is supported. If you are setting up a local machine, install Git for your operating system:

Linux (Debian/Ubuntu)
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git

macOS
~~~~~

Install Git with `Homebrew <https://brew.sh/>`_:

.. code-block:: bash

    brew install git

Windows
~~~~~~~

Use WSL, or download the installer from `Git for Windows <https://git-scm.com/download/win>`_ (includes Git Bash).

Configure Git
-------------

Set your name, email address, default branch name, and pull behavior. If you enabled email privacy in your `GitHub email settings <https://github.com/settings/emails>`_, use your ``@users.noreply.github.com`` address.

.. code-block:: bash

    git config --global user.name "Your Name"
    git config --global user.email "youremail@example.com"
    git config --global init.defaultBranch main
    git config --global pull.rebase false

Check the saved identity:

.. code-block:: bash

    git config --get user.name
    git config --get user.email

On macOS, ignore ``.DS_Store`` globally:

.. code-block:: bash

    echo .DS_Store >> ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global

Connect to GitHub with SSH
--------------------------

1.  **Check for or generate an Ed25519 SSH key**

    Check whether a public key already exists:

    .. code-block:: bash

        ls ~/.ssh/id_ed25519.pub

    If the file does not exist, generate a new key pair:

    .. code-block:: bash

        ssh-keygen -t ed25519

    Press Enter to accept the default path (``~/.ssh/id_ed25519``) and optionally set a passphrase.

2.  **Add the public key to GitHub**

    Print the public key:

    .. code-block:: bash

        cat ~/.ssh/id_ed25519.pub

    Copy the output line starting with ``ssh-ed25519``. In GitHub, open **Settings** -> **SSH and GPG keys** -> **New SSH key**, give the key a label (such as the cluster or workstation hostname), paste the key, and click **Add SSH key**.

3.  **Test the SSH connection**

    Run:

    .. code-block:: bash

        ssh -T git@github.com

    A working setup prints:

    .. code-block:: text

        Hi username! You've successfully authenticated, but GitHub does not provide shell access.

    See `Testing your SSH connection <https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection>`_ for troubleshooting details.

Use SSH Over Port 443 on Restricted Networks
--------------------------------------------

.. important::

    Some networks, including HPC clusters, block outbound SSH on port 22. If ``ssh -T git@github.com`` times out or is refused, route GitHub SSH traffic over port 443.

1.  Test connectivity on port 443:

    .. code-block:: bash

        ssh -T -p 443 git@ssh.github.com

2.  Add the following block to ``~/.ssh/config`` (create the file if needed) so Git uses port 443 automatically for ``github.com``:

    .. code-block:: text

        Host github.com
            Hostname ssh.github.com
            Port 443
            User git

    See the `GitHub documentation on SSH over the HTTPS port <https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port>`_.
