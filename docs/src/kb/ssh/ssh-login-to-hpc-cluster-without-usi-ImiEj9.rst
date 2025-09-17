Login to HPC Cluster Without Using Password
===========================================

.. meta::
    :description: How to set up and use SSH keys to log in to an HPC cluster, bypassing password and Duo authentication.
    :keywords: ssh, ssh key, login, hpc, duo, authentication
    :author: yhclamab@connect.ust.hk

.. rst-class:: header

    | Last updated: 2025-07-11
    | *Solution under review*

Environment
-----------

    - Windows 10/11, macOS, or Linux
    - SSH client (e.g., PowerShell, MobaXterm, or terminal)

Issue
-----

    - How to log in to an HPC cluster without entering a password and Duo authentication for every connection.
    - How to simplify file transfers (e.g., with ``scp`` or ``rsync``) by avoiding interactive authentication.

Resolution
----------

You can use SSH keys to authenticate to an HPC cluster, which bypasses the need for a password and Duo authentication.
This method is more secure and convenient for both interactive logins and automated file transfers.

The process involves three main steps:

1. **Create an SSH key pair** on your local machine. This consists of a private key (which you must keep secret) and a
   public key (which you can share).
2. **Copy the public key** to the HPC cluster and add it to the ``~/.ssh/authorized_keys`` file.
3. **Configure your SSH client** to use the private key when connecting to your HPC cluster (e.g., ``hpc4.ust.hk``).

For platform-specific instructions, please use the links below:

- `Generating SSH Keys on Windows`_
- `Generating SSH Keys on macOS and Linux`_

Generating SSH Keys on Windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These steps show how to use Windows PowerShell to generate an SSH key pair.

1. Launch **PowerShell** as an **Administrator**.

   - Press **Win + R** to open the Run dialog box.
   - Type ``powershell`` into the Run dialog.
   - Press **Ctrl + Shift + Enter** to run it as an administrator.

2. Ensure the OpenSSH client is installed.

   .. code-block:: shell-session

       Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

3. Set the SSH agent to start automatically and start the service.

   .. code-block:: shell-session

       Set-Service ssh-agent -StartupType Automatic
       Start-Service ssh-agent

4. Generate a new SSH key pair. You can choose between the modern ``ed25519`` algorithm or the widely-used ``rsa``
   algorithm. ``ed25519`` is newer and considered stronger, while ``rsa`` has broader compatibility with older systems.

   **For Ed25519 (recommended):**

   .. code-block:: shell-session

       ssh-keygen -t ed25519

   **For RSA:**

   .. code-block:: shell-session

       ssh-keygen -t rsa -b 4096

   You will be prompted to enter a file in which to save the key. Press Enter to accept the default location. You will
   also be asked to enter a passphrase, which is optional but highly recommended for security.

5. Add your new key to the SSH agent.

   If you generated an **Ed25519** key:

   .. code-block:: shell-session

       ssh-add $HOME\.ssh\id_ed25519

   If you generated an **RSA** key:

   .. code-block:: shell-session

       ssh-add $HOME\.ssh\id_rsa

6. Copy your public key to the HPC cluster. Replace ``<username>`` with your account name and ``<hpc-address>`` with
   your cluster's address (e.g., ``hpc4.ust.hk``).

   If you generated an **Ed25519** key:

   .. code-block:: shell-session

       Get-Content $HOME\.ssh\id_ed25519.pub | ssh <username>@<hpc-address> 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && pubkey=$(cat) && if ! grep -qF -- "$pubkey" ~/.ssh/authorized_keys 2>/dev/null; then echo "$pubkey" >> ~/.ssh/authorized_keys; fi && chmod 600 ~/.ssh/authorized_keys'

   If you generated an **RSA** key:

   .. code-block:: shell-session

       Get-Content $HOME\.ssh\id_rsa.pub | ssh <username>@<hpc-address> 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && pubkey=$(cat) && if ! grep -qF -- "$pubkey" ~/.ssh/authorized_keys 2>/dev/null; then echo "$pubkey" >> ~/.ssh/authorized_keys; fi && chmod 600 ~/.ssh/authorized_keys'

   This command reads your public key, connects to the HPC cluster, creates the ``.ssh`` directory if it doesn't exist,
   sets the correct permissions, and appends your key to the ``authorized_keys`` file.

7. You can now log in to the HPC cluster without a password.

   .. code-block:: shell-session

       ssh <username>@<hpc-address>

Generating SSH Keys on macOS and Linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The process is similar for macOS and Linux.

1. Open a terminal.
2. Start the SSH agent in the background.

   .. code-block:: shell-session

       eval "$(ssh-agent -s)"

3. Generate a new SSH key pair. You can choose between the modern ``ed25519`` algorithm or the widely-used ``rsa``
   algorithm. ``ed25519`` is newer and considered stronger, while ``rsa`` has broader compatibility with older systems.

   **For Ed25519 (recommended):**

   .. code-block:: shell-session

       ssh-keygen -t ed25519

   **For RSA:**

   .. code-block:: shell-session

       ssh-keygen -t rsa -b 4096

   Press Enter to accept the default file location and enter a secure passphrase when prompted.

4. Add your new key to the SSH agent.

   If you generated an **Ed25519** key:

   .. code-block:: shell-session

       ssh-add ~/.ssh/id_ed25519

   If you generated an **RSA** key:

   .. code-block:: shell-session

       ssh-add ~/.ssh/id_rsa

5. Copy the public key to the HPC cluster using the ``ssh-copy-id`` utility. This command automatically handles creating
   the ``.ssh`` directory and setting the correct file permissions on the remote server. To avoid ambiguity, it is best
   to specify which key to copy.

   If you generated an **Ed25519** key:

   .. code-block:: shell-session

       ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<hpc-address>

   If you generated an **RSA** key:

   .. code-block:: shell-session

       ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<hpc-address>

6. You can now log in to the HPC cluster without a password.

   .. code-block:: shell-session

       ssh <username>@<hpc-address>

Using SSH Keys with MobaXterm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you use MobaXterm, you can follow this guide to set up key-based authentication: `Generating SSH keys with MobaXterm
<https://vlaams-supercomputing-centrum-vscdocumentation.readthedocs-hosted.com/en/latest/access/generating_keys_with_mobaxterm.html>`_

Root Cause
----------

Interactive logins to HPC clusters require both a password and Duo two-factor authentication for security. This can be
cumbersome for frequent logins or for use with scripts and file transfer tools. SSH key-based authentication provides a
secure alternative by using a cryptographic key pair to verify your identity, bypassing the interactive password and Duo
prompts.

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://ITSO.ust.hk

    **Article Info**
      | Issued: 2025-07-11
      | Issued by: yhclamab@connect.ust.hk
