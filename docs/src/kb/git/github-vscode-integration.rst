Integrating GitHub with VS Code
===============================

Prerequisites
-------------

- Git installed on your system.
- A GitHub account.
- Visual Studio Code installed.
- The `GitHub Pull Requests and Issues` extension for VS Code (`GitHub.vscode-pull-request-github`).

Cloning a Repository
--------------------

1.  **Open the Terminal**: Press ``Ctrl+J`` (or ``Cmd+J`` on macOS) to open the integrated terminal in VS Code.
2.  **Navigate to your project folder**: Use the `cd` command to navigate to the directory where you want to store the project.
3.  **Run the clone command**: Type `git clone` followed by the URL of the repository you want to clone. For example:

    .. code-block:: bash

        git clone https://github.com/owner/repository.git

    You can find this URL on the repository's main page on GitHub by clicking the green "Code" button.

VS Code will clone the repository into a new folder in your current directory. You can then open this folder to start working.

Authenticating with GitHub
--------------------------

The first time you try to push to a repository or perform other actions that require authentication, VS Code will prompt you to sign in to GitHub. Follow the prompts to authorize VS Code with your GitHub account. This usually involves opening a browser window and logging in to GitHub.

Making Changes and Committing
-----------------------------

1.  **View Changes**: Open the Source Control view by clicking on the corresponding icon in the Activity Bar on the side of VS Code. You will see a list of modified files.
2.  **Stage Changes**: Click the `+` icon next to a file to stage it, or use the `+` icon at the top of the Changes section to stage all files.
3.  **Commit**: Enter a commit message in the text box at the top of the Source Control view and press ``Ctrl+Enter`` (or ``Cmd+Enter`` on macOS) to commit the staged changes.

Pushing to GitHub
-----------------

After committing your changes, you can push them to your remote repository on GitHub.

- Click the Synchronize Changes button in the status bar at the bottom of the window. This will pull any remote changes and push your local commits.
- Alternatively, you can open the Command Palette (``Ctrl+Shift+P`` or ``Cmd+Shift+P``) and use the `Git: Push` command.

Working with Pull Requests
--------------------------

With the `GitHub Pull Requests and Issues` extension, you can manage pull requests directly in VS Code.

1.  **View Pull Requests**: Open the GitHub view from the Activity Bar. Here you can see open pull requests.
2.  **Create a Pull Request**: After pushing a new branch, you can create a pull request from the GitHub view or by following the prompt that appears in VS Code.
3.  **Review Pull Requests**: You can check out pull request branches, view diffs, and add comments all within the editor.

Useful Extensions
-----------------

- **GitHub Pull Requests and Issues** (`GitHub.vscode-pull-request-github`): Essential for working with pull requests and issues.
- **GitLens** (`eamodio.gitlens`): Supercharges the Git capabilities built into VS Code. It helps you to visualize code authorship at a glance via Git blame annotations and code lens, seamlessly navigate and explore Git repositories, gain valuable insights via powerful comparison commands, and so much more.
