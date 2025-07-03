Cloning GitHub with VS Code
===============================

Prerequisites
-------------

- Git installed on your system.
- A GitHub account.
- Visual Studio Code installed.
- The `GitHub Pull Requests and Issues` extension for VS Code (`GitHub.vscode-pull-request-github`).

Cloning this Repository
--------------------

1.  **Open the Terminal**: Press ``Ctrl+J`` (or ``Cmd+J`` on macOS) to open the integrated terminal in VS Code.
2.  **Choose where to put the project**: Navigate to the parent directory where you want to create your new project folder. For example, to go to your Desktop, you would type:
    .. code-block:: bash

        cd ~/Desktop

    If you want to create a new parent folder (e.g., a folder called `projects`), you can create it and navigate into it with these commands:
    .. code-block:: bash

        mkdir folder_name
        cd folder_name

3.  **Run the clone command**: Type `git clone` followed by the repository URL. This will create a new folder named `hkust-hpc` inside your current directory.

    .. code-block:: bash

        git clone https://github.com/hkust-hpc-team/hkust-hpc.git

    You can find this URL on the repository's main page on GitHub by clicking the green "Code" button.

VS Code will clone the repository. You can then open the `hkust-hpc` folder to start working :).

