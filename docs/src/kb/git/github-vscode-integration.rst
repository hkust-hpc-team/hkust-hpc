Cloning GitHub with VS Code
===============================

.. meta::
    :description: A comprehensive guide to cloning GitHub repositories with Visual Studio Code for an efficient development workflow.
    :keywords: VS Code, Git, GitHub, clone, version control, source control
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-07-03
    | *Guide verified: 2025-07-03*


Environment
~~~~~~~~~~~~~~~~~~~

.. tip::
   For working on remote HPC systems, it is recommended to first connect to the remote server using the **Remote - SSH** extension. 
   You can connect to ``<username>@hpc4.ust.hk`` and then perform the clone operation. This will clone the repository directly onto the HPC system.

Before you begin, please ensure you have the following setup:

1.  **Git Installed**
    
    - Git must be installed on your local system.
    - Configure your Git username and email:
    
    .. code-block:: bash
    
        git config --global user.name "Your Name"
        git config --global user.email "your.email@example.com"

2.  **GitHub Account**
    
    - A GitHub account.
    - You should be logged into your account.

3.  **Visual Studio Code**
    
    - VS Code installed.
    - The built-in Git extension is enabled by default.

Cloning a Repository
----------------------------

Cloning creates a local copy of a remote repository on your machine.

Step-by-Step Guide to Cloning
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Method 1: Using the VS Code Terminal**

This is the traditional command-line approach, which works in any terminal.

1.  **Open the Terminal**: In VS Code, open the integrated terminal with ``Ctrl+J`` (or ``Cmd+J`` on macOS).
2.  **Navigate to Your Projects Directory**: Go to the folder where you want to store the project.
    
    .. code-block:: bash
    
        # Example: navigate to your home directory's 'name' folder
        cd ~/<folder-name>
    
    .. tip::
        If the directory doesn't exist, you can create it with `mkdir ~/projects`.

3.  **Run the `git clone` Command**: Use the `git clone` command followed by the repository URL.
    
    .. code-block:: console
    
        $ git clone https://github.com/hkust-hpc-team/hkust-hpc.git
    
    You can get the URL from the repository's page on GitHub by clicking the green "Code" button.

4.  **Open the Repository in VS Code**:
    
    .. code-block:: bash
    
        code hkust-hpc

**Method 2: Using the Command Palette**

This method uses VS Code's interface to guide you.

1.  **Open the Command Palette**: Press ``Ctrl+Shift+P`` (or ``Cmd+Shift+P`` on macOS).
2.  **Run the Git Clone Command**: Type `Git: Clone` and press Enter.
3.  **Provide Repository URL**: Paste the repository URL into the prompt.
4.  **Select Local Directory**: VS Code will then ask you where you want to save the cloned project. Choose a directory on your local machine.
5.  **Open the Repository**: Once cloned, VS Code will ask if you want to open the repository. Click "Open".


Troubleshooting Common Issues
-----------------------------

**Issue: "fatal: repository not found" when cloning.**
- **Solution**: Double-check that the repository URL is correct and that you have permission to access it. If it's a private repository, ensure you are properly authenticated to GitHub.

**Issue: "Permission denied (publickey)" when cloning with SSH.**
- **Solution**: This error indicates your SSH key is not set up correctly with GitHub.
  Ensure you have added your SSH key to your GitHub account by following the instructions in the `GitHub documentation <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>`.

**Issue: "fatal: destination path 'repository-name' already exists and is not an empty directory."**
- **Solution**: This means that a folder with the same name already exists in the current directory. You can either delete that folder or choose a different name for the cloned repository.

**Issue: "fatal: unable to access '<repository-url>': <error-details>"**
- **Solution**: This error can be caused by a network issue or an incorrect URL.
  Check your internet connection and the URL. If you are behind a proxy, you may need to configure Git's proxy settings.

Recommended Extensions for Git
------------------------------

1.  **GitLens**: Supercharges the Git capabilities built into VS Code. It helps you visualize code authorship with Git blame annotations, navigate and explore Git repositories, and much more.
    - `Extension ID: eamodio.gitlens`
2.  **Git Graph**: View a Git Graph of your repository, and easily perform Git actions from the graph.
    - `Extension ID: mhutchie.git-graph`

Additional Resources
--------------------

- `VS Code Version Control Documentation <https://code.visualstudio.com/docs/editor/versioncontrol>`_
- `Git Official Documentation <https://git-scm.com/doc>`_
- `GitHub Docs <https://docs.github.com/en>`_

----

.. container::
    :name: footer

    **HPC Support Team**
      | ITSC, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itsc.ust.hk

    **Article Info**
      | Issued: 2025-07-03
      | Issued by: HKUST HPC Team

