.. _git-setup:

Setting Up Git and GitHub
=========================

.. meta::
    :description: A simple guide on how to set up Git and connect it to your GitHub account
    :keywords: git, github, setup, configuration, ssh

This guide will walk you through the basic setup for Git and connecting it to your GitHub account, based on the instructions from The Odin Project.

Environment
-----------

This guide is applicable to various environments, including:

-   **Operating Systems**: Windows, macOS, and Linux (including WSL).
-   **HPC Environments**: Instructions are adaptable for clusters using environment modules.
-   **Shells**: Commands are primarily for Bash-like shells, but concepts apply to others like PowerShell.


Step 1: Install Git
-------------------

First, you need to have Git installed on your computer. We recommend installing it from the official source to get the latest version. After installing, please verify that the version is at least 2.28 by running ``git --version``.

Linux
~~~~~

To ensure you have the latest version of Git, it is recommended to use the official PPA (Personal Package Archive).

.. code-block:: bash

    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git

.. note::
    When you use ``sudo``, you may be prompted for your password. As you type, you won't see any characters on the screen; this is a security measure. Just type your password and press Enter.

macOS
~~~~~

The easiest way to install Git on macOS is with `Homebrew <https://brew.sh/>`_, a popular package manager.

1.  **Install Homebrew** (if you don't have it):

    .. code-block:: bash

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    .. important::
        For **Apple Silicon** Macs (M1/M2/M3), Homebrew will output "Next steps" after installation. Follow these instructions to add Homebrew to your ``PATH``.

2.  **Install Git**:

    .. code-block:: bash

        brew install git

Windows
~~~~~~~

Download and run the official installer from the Git website.

-   `Download Git for Windows <https://git-scm.com/download/win>`_

The installer will guide you through the process. The default options are suitable for most users. This installation also includes **Git Bash**, a terminal that is highly recommended for using Git.

.. note::
    **Chrome OS users**: You can enable the Linux development environment in your settings and follow the **Linux** instructions.

Step 2: Create a GitHub Account
-------------------------------

If you don't have one already, head over to `GitHub <https://github.com/>`_ and sign up for a free account. During the account setup, you will be asked for an email address. This needs to be a real email, and will be used by default to identify your contributions.

If you are privacy conscious, you can choose to keep your email address private on the `Email Settings <https://github.com/settings/emails>`_ page after you have signed in. 
To prevent exposing your personal email, ensure both "Keep my email addresses private" and "Block command line pushes that expose my email" are checked. 
You can use the private GitHub email address provided on that page when configuring Git in the next step.

Step 3: Setup Git
---------------------

After installing Git, you need to tell it who you are. This information will be used in every commit you create.

Open your terminal and run the following commands, replacing "Your Name" and "youremail@example.com" with your own information. If you chose to keep your email private on GitHub, use your special private GitHub email.

.. code-block:: bash

    git config --global user.name "Your Name"
    git config --global user.email "youremail@example.com"

GitHub recently changed the default branch on new repositories from `master` to `main`. Change the default branch for Git using this command:

.. code-block:: bash

    git config --global init.defaultBranch main

You’ll also likely want to set your default branch reconciliation behavior to merging.

.. code-block:: bash

    git config --global pull.rebase false

To verify that things are working properly, enter these commands and verify whether the output matches your name and email address.

.. code-block:: bash

    git config --get user.name
    git config --get user.email

For macOS Users
~~~~~~~~~~~~~~~

Run these two commands to tell Git to ignore `.DS_Store` files, which are automatically created when you use Finder to look into a folder.

.. code-block:: bash

    echo .DS_Store >> ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global

Step 4: Connect to GitHub with SSH
----------------------------------

To securely connect to GitHub from your computer, it's best to use SSH (Secure Shell). This allows you to push and pull code without having to enter your username and password every time.

1.  **Generate a new SSH key**

    First, check if you already have an Ed25519 SSH key.

    .. code-block:: bash

        ls ~/.ssh/id_ed25519.pub

    If you see a "No such file or directory" message, you need to create one.

    .. code-block:: bash

        ssh-keygen -t ed25519

    When you're prompted to "Enter a file in which to save the key," you can press Enter to accept the default file location. You can optionally enter a passphrase for extra security.

2.  **Add your SSH key to your GitHub account**

    First, you need to copy your public SSH key. You can display it in the terminal with this command:

    .. code-block:: bash

        cat ~/.ssh/id_ed25519.pub

    Copy the entire output, which starts with `ssh-ed25519` and ends with your email address.

    Now, go to your GitHub account settings:

    - Click on your profile picture in the top-right corner and select **Settings**.
    - In the left sidebar, click on **SSH and GPG keys**.
    - Click **New SSH key** or **Add SSH key**.
    - Give your key a title (e.g., "My Laptop") and paste the key into the "Key" field.
    - Click **Add SSH key**.

3.  **Test your SSH connection**

    Follow the `GitHub directions for testing your SSH connection <https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection>`_.

    You should see a message like this:

    .. code-block:: text

        Hi username! You’ve successfully authenticated, but GitHub does not provide shell access.

.. important::

Some networks, such as those on HPC clusters, may block the standard SSH port (22). If you have trouble connecting, you can configure SSH to use the HTTPS port (443) instead.

1.  **Test your connection** by running ``ssh -T -p 443 git@ssh.github.com``. A successful test will show the same authentication message as above.

2.  **Make the change permanent** by adding the following to your ``~/.ssh/config`` file (create the file if it doesn't exist):

    .. code-block:: text

        Host github.com
            Hostname ssh.github.com
            Port 443
            User git

    This ensures all your ``git`` commands for ``github.com`` will automatically use the correct port. For more details, refer to the `official GitHub documentation <https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port>`_.

You're all set! You can now start using Git and GitHub to manage your projects.
