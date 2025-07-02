How to Make a Pull Request (PR)
===============================

.. meta::
    :description: A comprehensive guide to creating and submitting pull requests on GitHub
    :keywords: GitHub, pull request, PR, git, collaboration, code review, version control
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-07-02
    | *Solution verified: 2025-07-02*

Overview
--------

A Pull Request (PR) is a method of submitting contributions to a project. It allows you to propose changes to a repository and request that the maintainers review and merge your changes into the main codebase.

Prerequisites
-------------

Before creating a pull request, ensure you have:

1. **GitHub Account**
   
   - Active GitHub account with proper access to the repository
   - Two-factor authentication enabled (recommended)

2. **Git Setup**
   
   - Git installed on your local machine
   - Git configured with your name and email:
   
   .. code-block:: bash
   
       git config --global user.name "Your Name"
       git config --global user.email "your.email@example.com"

3. **Repository Access**
   
   - Fork access to the target repository (for external contributions)
   - Direct push access (for internal team members)

Step-by-Step Guide
------------------

Method 1: Fork and Pull Request (External Contributors)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Fork the Repository**
   
   - Navigate to the target repository on GitHub
   - Click the "Fork" button in the top-right corner
   - Select your account to create a fork

2. **Clone Your Fork**
   
   .. code-block:: bash
   
       # Clone your forked repository
       git clone https://github.com/YOUR_USERNAME/REPOSITORY_NAME.git
       cd REPOSITORY_NAME
       
       # Add the original repository as upstream
       git remote add upstream https://github.com/ORIGINAL_OWNER/REPOSITORY_NAME.git

3. **Create a Feature Branch**
   
   .. code-block:: bash
   
       # Using modern git switch command (Git 2.23+)
       git switch -c feature/your-feature-name
       
       # Or traditional checkout method
       git checkout -b feature/your-feature-name
       
       # For bug fixes
       git switch -c fix/issue-description

4. **Make Your Changes**
   
   - Edit files using your preferred editor
   - Follow the project's coding standards and conventions
   - Make logical, atomic commits

5. **Commit Your Changes**
   
   .. code-block:: bash
   
       # Stage your changes
       git add .
       
       # Or add specific files
       git add path/to/file.py
       
       # Commit with a descriptive message
       git commit -m "Add feature: descriptive commit message"

6. **Push to Your Fork**
   
   .. code-block:: bash
   
       # Push your branch to your fork
       git push origin feature/your-feature-name

7. **Create the Pull Request**
   
   - Navigate to your fork on GitHub
   - Click "Compare & pull request" button
   - Fill out the PR template (see below)
   - Click "Create pull request"

Method 2: Direct Branch (Internal Contributors)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Clone the Repository**
   
   .. code-block:: bash
   
       git clone https://github.com/ORGANIZATION/REPOSITORY_NAME.git
       cd REPOSITORY_NAME

2. **Update Main Branch**
   
   .. code-block:: bash
   
       git checkout main
       git pull origin main

3. **Create Feature Branch**
   
   .. code-block:: bash
   
       git checkout -b feature/your-feature-name

4. **Make Changes and Commit**
   
   .. code-block:: bash
   
       # Make your changes
       git add .
       git commit -m "Add feature: descriptive message"

5. **Push Branch**
   
   .. code-block:: bash
   
       git push origin feature/your-feature-name

6. **Create Pull Request**
   
   - Navigate to the repository on GitHub
   - Click "Compare & pull request"
   - Complete the PR details

Pull Request Best Practices
---------------------------

Writing Good PR Titles
~~~~~~~~~~~~~~~~~~~~~~

**Good Examples:**

- ``Add user authentication system``
- ``Fix memory leak in data processing module``
- ``Update documentation for API endpoints``
- ``Refactor database connection handling``

**Poor Examples:**

- ``Fix stuff``
- ``Updates``
- ``Changes``

Writing Effective PR Descriptions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Include the following sections in your PR description:

.. code-block:: markdown

    ## Summary
    Brief description of what this PR does.
    
    ## Changes Made
    - List of specific changes
    - Another change
    - Third change
    
    ## Testing
    - How you tested these changes
    - Test cases covered
    - Manual testing performed
    
    ## Related Issues
    Fixes #123
    Related to #456
    
    ## Screenshots (if applicable)
    Include before/after screenshots for UI changes
    
    ## Checklist
    - [ ] Code follows project style guidelines
    - [ ] Self-review completed
    - [ ] Tests added/updated
    - [ ] Documentation updated

Commit Message Guidelines
~~~~~~~~~~~~~~~~~~~~~~~~~

Follow conventional commit format:

.. code-block:: text

    type(scope): description
    
    [optional body]
    
    [optional footer]

**Types:**
- ``feat``: New feature
- ``fix``: Bug fix
- ``docs``: Documentation changes
- ``style``: Code style changes
- ``refactor``: Code refactoring
- ``test``: Test additions/modifications
- ``chore``: Maintenance tasks

**Examples:**

.. code-block:: bash

    git commit -m "feat(auth): add OAuth2 authentication"
    git commit -m "fix(api): resolve null pointer exception in user service"
    git commit -m "docs(readme): update installation instructions"

Code Review Process
-------------------

After Creating Your PR
~~~~~~~~~~~~~~~~~~~~~~

1. **Automated Checks**
   
   - CI/CD pipelines will run automatically
   - Address any failing tests or linting issues
   - Green checkmarks indicate passing checks

2. **Request Reviewers**
   
   - Assign relevant team members as reviewers
   - Use GitHub's reviewer suggestion feature
   - Tag specific people with ``@username`` if needed

3. **Respond to Feedback**
   
   - Address reviewer comments promptly
   - Make requested changes in new commits
   - Use ``git commit --fixup`` for small fixes
   - Respond to comments with explanations when needed

4. **Keep Your Branch Updated**
   
   .. code-block:: bash
   
       # Fetch latest changes from main
       git fetch upstream main  # For forks
       git fetch origin main    # For direct access
       
       # Rebase your branch (preferred)
       git rebase main
       
       # Or merge (if rebasing isn't suitable)
       git merge main

Common PR Commands
------------------

Updating Your PR
~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Make additional changes
    git add .
    git commit -m "Address review comments"
    
    # Push updates
    git push origin feature/your-feature-name

Squashing Commits (if requested)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # Interactive rebase to squash commits
    git rebase -i HEAD~n  # n = number of commits to squash
    
    # Force push after squashing (safer than --force)
    git push --force-with-lease origin feature/your-feature-name

.. note::
   
   ``--force-with-lease`` is safer than ``--force`` as it checks that no one else
   has pushed to the branch since your last fetch, preventing accidental overwrites.

Syncing with Upstream
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    # For forked repositories
    git fetch upstream
    git checkout main
    git merge upstream/main
    git push origin main

Troubleshooting
---------------

Common Issues and Solutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Issue: Merge conflicts**

.. code-block:: bash

    # Update your branch with latest main
    git fetch origin main
    git rebase main
    
    # Resolve conflicts in your editor
    # After resolving conflicts:
    git add .
    git rebase --continue

**Issue: Failed CI checks**

1. Check the CI logs for specific errors
2. Fix the issues locally
3. Commit and push the fixes
4. CI will re-run automatically

**Issue: Large PR with many changes**

1. Consider splitting into smaller, focused PRs (recommended: <400 lines of changes)
2. Use draft PRs for work-in-progress
3. Communicate with maintainers about the scope
4. Break complex features into logical, reviewable chunks

**Issue: Sensitive data in commits**

.. code-block:: bash

    # If you accidentally committed sensitive data
    # Remove the file and commit the removal
    git rm sensitive-file.txt
    git commit -m "Remove sensitive data"
    
    # For data in previous commits, use git filter-branch or BFG
    # Contact repository administrators for help with history rewriting

PR Templates and Automation
---------------------------

Creating PR Templates
~~~~~~~~~~~~~~~~~~~~~

Create ``.github/pull_request_template.md`` in your repository:

.. code-block:: markdown

    ## Description
    Brief description of changes
    
    ## Type of Change
    - [ ] Bug fix
    - [ ] New feature
    - [ ] Documentation update
    - [ ] Performance improvement
    - [ ] Code refactoring
    
    ## Testing
    - [ ] Unit tests pass
    - [ ] Integration tests pass
    - [ ] Manual testing completed
    
    ## Checklist
    - [ ] Code follows style guidelines
    - [ ] Self-review completed
    - [ ] Documentation updated
    - [ ] No new warnings introduced

Automated Workflows
~~~~~~~~~~~~~~~~~~~

Example GitHub Actions workflow for PR validation:

.. code-block:: yaml

    name: PR Validation
    on:
      pull_request:
        branches: [ main, develop ]
    
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Run tests
            run: |
              npm install
              npm test
          - name: Check formatting
            run: npm run format:check

Advanced Tips
-------------

1. **Use Draft PRs**
   
   - Mark PR as draft for work-in-progress
   - Convert to ready when complete
   - Allows early feedback without formal review

2. **Link Issues**
   
   - Use keywords: ``Fixes #123``, ``Closes #456``
   - GitHub automatically links and closes issues

3. **Use Co-authors**
   
   .. code-block:: bash
   
       git commit -m "Feature: add new component
       
       Co-authored-by: Name <email@example.com>"

4. **Review Your Own PR**
   
   - Check the "Files changed" tab before requesting review
   - Look for typos, debugging code, or unintended changes

5. **Use GitHub CLI**
   
   .. code-block:: bash
   
       # Install GitHub CLI
       gh pr create --title "Feature: add new component" --body "Description"
       
       # Check PR status
       gh pr status
       
       # View PR in browser
       gh pr view --web

6. **Use GitHub Web Editor**
   
   - For small changes, use GitHub's web interface
   - Click the pencil icon on any file to edit directly
   - Useful for quick documentation fixes or typos

7. **Consider Signed Commits**
   
   .. code-block:: bash
   
       # Configure GPG signing (one-time setup)
       git config --global user.signingkey YOUR_GPG_KEY_ID
       git config --global commit.gpgsign true
       
       # Sign individual commits
       git commit -S -m "Add signed commit"

Additional Resources
--------------------

- `GitHub Pull Request Documentation <https://docs.github.com/en/pull-requests>`_
- `Git Documentation <https://git-scm.com/doc>`_
- `Conventional Commits <https://www.conventionalcommits.org/>`_
- `GitHub CLI <https://cli.github.com/>`_

.. note::
   
   Different projects may have specific contribution guidelines. Always check the repository's
   ``CONTRIBUTING.md`` file for project-specific requirements and workflows.

.. tip::
   
   For HKUST HPC team members: Follow our internal code review checklist and ensure all
   documentation changes are reviewed by at least one team member before merging.
