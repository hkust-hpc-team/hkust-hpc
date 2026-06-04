Access and Authentication
=========================

Environment
-----------

    - Users who need to access the HPC service for the first time
    - Windows 10/11, macOS, or Linux
    - SSH client or other approved remote access tools

Account Application
~~~~~~~~~~~~~~~~~~~

- Available to HKUST researchers.
- Account applications are available to HKUST faculty members acting as principal investigators (PIs) for their research projects.
- Users must apply for an account before accessing the HPC4 cluster.
- All applications must be sponsored by a principal investigator (PI), who must be a faculty member of the university.
- A PI must also apply for an account if they need direct access to the cluster.
- The HPC4 account name is the same as the user's HKUST account name.
- The HPC4 account password is the same as the user's HKUST account password.

Login Methods
~~~~~~~~~~~~~

- HPC4 SSH login supports both password authentication and public-key authentication.
- For password authentication, Duo MFA is required as a second factor.
- Users should enroll in Duo MFA before attempting password-based SSH login.
- For login, enter your username only, without the ``@ust.hk`` or ``@connect.ust.hk`` domain name.

SSH with password and Duo authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use any SSH client to log in to ``hpc4.ust.hk``.

When logging in from a terminal:

- Enter your HKUST username only.
- Do not include ``@ust.hk`` or ``@connect.ust.hk`` in the username.

.. code-block:: shell-session

    $ ssh <username>@hpc4.ust.hk
    <username>@hpc4.ust.hk's password:
    Duo two-factor login for <username>
    Enter a passcode or select one of your enrolled Duo authentication methods.

After entering your password, complete the Duo authentication step using one of your enrolled Duo methods.

VPN Requirements
~~~~~~~~~~~~~~~~

- Before using HPC4, connect to the campus network using either a wired campus connection or the ``eduroam`` Wi-Fi service.
- If you are off campus, use Secure Remote Access (VPN) before connecting to HPC4.
- Off-campus users should not assume direct access to ``hpc4.ust.hk`` without VPN.

References
----------

- Official VPN setup page: https://itso.hkust.edu.hk/services/cyber-security/vpn
- Official login guide: https://itso.hkust.edu.hk/services/academic-teaching-support/high-performance-computing/hpc4/login
- Official Duo MFA page: https://itso.hkust.edu.hk/services/cyber-security/duo
