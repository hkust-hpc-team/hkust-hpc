Access and Authentication
=========================

.. meta::
    :description: Access requirements and SSH login workflow for new HPC4 and SuperPOD users.
    :keywords: HPC4, SuperPOD, access, authentication, SSH, Duo MFA, VPN, account application

.. rst-class:: header

    | Last updated: 2026-06-04

.. tip::

   If you are new to HPC clusters, read the :ref:`Understanding the Cluster
   <understanding-the-cluster>` section first.

Environment
-----------

    - Users who need to access HPC4 or SuperPOD for the first time
    - Windows 10/11, macOS, or Linux
    - SSH client or other approved remote access tools

Account Application
~~~~~~~~~~~~~~~~~~~

Both HPC4 and SuperPOD accounts are available to HKUST researchers.
Applications must be sponsored by a principal investigator (PI), who must
be a HKUST faculty member.  Account names and passwords are the same as
your HKUST credentials.

- **HPC4**: `Account Application Form <https://hkust.service-now.com/itsc?id=sc_cat_item&sys_id=ae106bca47901a50a0c3db74116d4358>`__
- **SuperPOD**: `Account Application Form <https://hkust.service-now.com/itsc?id=sc_cat_item&sys_id=828f67fc4704d610b0c2b9ca216d433e>`__

Students should ask their supervisor (PI) to submit the application on
their behalf.  A PI must also apply for an account if they need direct
access.

.. note::

   **For teaching / courses**: if you need HPC resources for an
   instructor-led course, contact ``cchelp@ust.hk`` and specify your
   course code and computing resource requirements.

Login Methods
~~~~~~~~~~~~~

Both clusters support password and public-key SSH authentication.
Password authentication requires Duo MFA as a second factor —
enroll in Duo MFA beforehand.

When logging in, enter your **username only** — do not include
``@ust.hk`` or ``@connect.ust.hk``.

.. list-table::
   :header-rows: 1
   :widths: 25 37 38

   * -
     - HPC4
     - SuperPOD
   * - Hostname
     - ``hpc4.ust.hk``
     - ``superpod.ust.hk``
   * - SSH port
     - 22 (default)
     - 22 (default)
   * - Authentication
     - Password + Duo MFA, or public key
     - Password + Duo MFA, or public key
   * - Account credentials
     - Your HKUST ITSC account
     - Your HKUST ITSC account
   * - Example SSH command
     - ``ssh alice@hpc4.ust.hk``
     - ``ssh alice@superpod.ust.hk``

SSH with password and Duo authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: shell-session

    $ ssh <username>@hpc4.ust.hk
    <username>@hpc4.ust.hk's password:
    Duo two-factor login for <username>
    Enter a passcode or select one of your enrolled Duo authentication methods.

After entering your password, complete the Duo authentication step.

SSH with public key (recommended for daily use)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An SSH key pair eliminates the password + Duo MFA prompt on every login.
Use this if you log in frequently.

.. dropdown:: Linux / macOS
   :class-title: sd-fs-5
   :animate: fade-in

   **Step 1 — Generate a key pair (on your local machine):**

   .. code-block:: bash

       ssh-keygen -t ed25519 -C "your_username@hkust"

   Accept the defaults (file ``~/.ssh/id_ed25519``, no passphrase is ok for
   personal workstations; use a passphrase if shared or public machine).

   **Step 2 — Copy the public key to the cluster:**

   .. code-block:: bash

       ssh-copy-id <username>@hpc4.ust.hk

   Enter your password once.  This installs ``~/.ssh/id_ed25519.pub`` into
   ``~/.ssh/authorized_keys`` on the cluster.

   **Step 3 — Test:**

   .. code-block:: bash

       ssh <username>@hpc4.ust.hk

   You should log in without a password prompt.

   **Repeat for SuperPOD** — the same key works for both clusters:

   .. code-block:: bash

       ssh-copy-id <username>@superpod.ust.hk

.. dropdown:: Windows (PowerShell)
   :class-title: sd-fs-5
   :animate: fade-in

   Windows 10/11 ships with OpenSSH.  Open **PowerShell** (not CMD) and
   run the same commands as Linux:

   **Step 1 — Generate a key pair:**

   .. code-block:: powershell

       ssh-keygen -t ed25519 -C "your_username@hkust"

   **Step 2 — Copy the public key to the cluster:**

   ``ssh-copy-id`` is not available on Windows.  Use this one-liner instead:

   .. code-block:: powershell

       Get-Content ~\.ssh\id_ed25519.pub | ssh <username>@hpc4.ust.hk "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

   **Step 3 — Test:**

   .. code-block:: powershell

       ssh <username>@hpc4.ust.hk

   **Repeat for SuperPOD**:

   .. code-block:: powershell

       Get-Content ~\.ssh\id_ed25519.pub | ssh <username>@superpod.ust.hk "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

When to use which
~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 30 30 40

   * -
     - Password + Duo MFA
     - SSH public key
   * - Security
     - Good — MFA adds second factor
     - Good — passphrase on key adds second factor
   * - Convenience
     - Must enter password + Duo every time
     - No prompt after initial setup
   * - Best for
     - First-time login, infrequent access
     - Daily work, automation, rsync

VPN Requirements
~~~~~~~~~~~~~~~~

- Connect to the campus network via wired connection or ``eduroam`` Wi-Fi.
- If you are off campus, use `Secure Remote Access VPN
  <https://itso.hkust.edu.hk/services/cyber-security/vpn>`__ before
  connecting.

References
----------

- `HPC4 login guide <https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/login>`__
- `SuperPOD login guide <https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/superpod/usage-tips/login>`__
- `VPN setup <https://itso.hkust.edu.hk/services/cyber-security/vpn>`__
- `Duo MFA <https://itso.hkust.edu.hk/services/cyber-security/duo>`__
