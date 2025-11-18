"setenv: command not found" when running shell scripts in Bash
==============================================================

.. meta::
    :description: Explains why the "setenv: command not found" error occurs when executing a shell script with `bash` and provides the correct method of execution using the shebang.
    :keywords: setenv, bash, csh, tcsh, shebang, chmod, command not found, shell script
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-11-18
    | *Solution under review*

Environment
-----------

    - **Operating System**: Linux, macOS, or other Unix-like systems
    - **Shells**: Bash (`bash`), C-shell (`csh`), TC-shell (`tcsh`)

Issue
-----

    - When executing a shell script using `bash ./script.sh`, the following error is displayed:

      .. code-block:: shell-session

          $ bash ./script.sh
          ./script.sh: line 3: setenv: command not found

      The script is intended to set environment variables but fails with a "command not found" error, even though the script appears correct.

Resolution
----------

Instead of forcing the script to run with `bash`, make it executable and allow the system to use the correct interpreter specified in the script's shebang line.

1.  **Make the script executable** using the `chmod +x` command. This grants the file permission to be executed.

    .. code-block:: shell-session

        $ chmod +x ./script.sh

2.  **Run the script directly**. The operating system will automatically use the interpreter specified in the shebang line (e.g., `#!/bin/csh`).

    .. code-block:: shell-session

        $ ./script.sh

    .. note::
        If the script is not in your PATH, you must use a relative path (`./script.sh`) or an absolute path (`/path/to/your/script.sh`) to run it.

Root Cause
----------

The error occurs because the script is being executed with the wrong shell interpreter.

- The command `setenv` is used by the C-shell (`csh`) and TC-shell (`tcsh`) to define environment variables.
- The command `bash ./script.sh` explicitly tells the system to use `bash` as the interpreter, ignoring the shebang line (the first line of the script, e.g., `#!/bin/csh`).
- `bash` does not have a built-in `setenv` command. The `bash` equivalent is `export`.

For example, a script written for `csh` might look like this:

.. code-block:: csh

    #!/bin/csh
    # This is a csh script
    setenv MY_VARIABLE "hello"
    echo "My variable is $MY_VARIABLE"

When you run `bash ./script.sh`, `bash` tries to interpret `setenv MY_VARIABLE "hello"`, which is invalid syntax in `bash`, leading to the "command not found" error. By making the script executable and running it with `./script.sh`, you allow the system to read the `#!/bin/csh` shebang and use the correct `csh` interpreter.

Diagnosis
---------

You can check the first line of the script (the shebang) to identify which interpreter it is designed for.

- Use the `head` command to view the first line of your script:

  .. code-block:: shell-session

      $ head -n 1 ./script.sh
      #!/bin/csh

- If the line starts with `#!/bin/csh` or `#!/bin/tcsh`, the script is intended for the C-shell or TC-shell, and the resolution above applies.
- If it starts with `#!/bin/bash`, the script is a `bash` script, and the use of `setenv` is an error in the script itself. In this case, it should be replaced with `export`.

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-11-18
      | Issued by: kftse@ust.hk
