How to Make a Pull Request (PR)
===============================

.. meta::
   :description: Creating and submitting pull requests on GitHub for HKUST HPC documentation
   :keywords: GitHub, pull request, PR, git, collaboration, code review, version control
   :author: HKUST HPC Team <hpc@ust.hk>

.. container::
   :name: header

   | Last updated: 2026-10-27
   | *Solution verified: 2026-10-27*

Overview
--------

A pull request (PR) proposes changes to a repository for review before merging into ``main``.

For local setup, building the docs, and the basic fork/branch/PR sequence, see the :doc:`Contributor's Guide </contrib/index>`. This page covers branch naming, commit messages, opening a PR on GitHub, and handling review.

Branch Naming
-------------

Never commit directly to ``main``. Always work on a dedicated branch.

Use a prefix that matches the change type:

- ``docs/<topic>`` for documentation updates (for example, ``docs/slurm-gpu-guide``)
- ``feat/<name>`` or ``feature/<name>`` for new features
- ``fix/<issue>`` for bug fixes

Create and switch to a branch from an up-to-date ``main``:

.. code-block:: bash

   git switch -c docs/my-topic

If you have push access to the repository, push your branch to ``origin``. External contributors should fork the repository first, push to their fork, and keep ``upstream`` pointed at the main repository:

.. code-block:: bash

   git remote add upstream https://github.com/hkust-hpc-team/hkust-hpc.git

Commit Messages
---------------

Make small, focused commits. Follow the `Conventional Commits <https://www.conventionalcommits.org/>`_ format:

.. code-block:: text

   type(scope): short description

   [optional body]

Common types:

- ``docs``: Documentation changes
- ``feat``: New feature
- ``fix``: Bug fix
- ``refactor``: Code restructuring without behavior change
- ``style``: Formatting or lint fixes
- ``test``: Adding or updating tests
- ``chore``: Build or maintenance tasks

Examples:

.. code-block:: bash

   git commit -m "docs(slurm): add interactive GPU session example"
   git commit -m "fix(compile-guides): correct OpenMPI configure flags"

To credit a co-author, add a trailer at the end of the commit message body:

.. code-block:: text

   Co-authored-by: Name <email@example.com>

Opening the Pull Request on GitHub
----------------------------------

1. Push your branch to GitHub:

   .. code-block:: bash

      git push -u origin docs/my-topic

2. Open the repository on GitHub and click **Compare & pull request** (or run ``gh pr create`` with the `GitHub CLI <https://cli.github.com/>`_).
3. Check that the base branch is ``main`` and the compare branch is your feature branch.
4. Write a clear title and description:

   - **Title**: State what changed in plain language (for example, ``Add Slurm array job examples``, not ``Updates``).
   - **Description**: Summarize what changed and why. Note how you verified the change (such as ``make build``).
   - **Linked issues**: Reference related issues with ``Fixes #123`` or ``Closes #456`` so GitHub links and closes them on merge.

5. Review the **Files changed** tab yourself to catch unintended edits or leftover debug lines.
6. If the work is not ready for merge yet, open it as a **Draft PR** and mark it ready when finished.

Responding to Review
--------------------

After you open a PR:

1. **Automated checks**: CI runs ``pre-commit`` and ``sphinx-build -W`` automatically. If a check fails, inspect the log, fix the issue locally (see :doc:`/contrib/index` for running checks locally), and push a new commit.
2. **Reviewer feedback**: Push new commits to the same branch to address comments. The PR updates automatically:

   .. code-block:: bash

      git add <files>
      git commit -m "docs(slurm): clarify partition walltime limits"
      git push origin docs/my-topic

   For HKUST HPC documentation changes, at least one team member must review and approve the PR before merging.

Updating an Outdated Branch or Resolving Conflicts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If ``main`` has moved ahead or your PR shows merge conflicts, rebase your branch onto the latest ``main``:

.. code-block:: bash

   # Fetch latest main (use 'upstream' instead of 'origin' if working from a fork)
   git fetch origin main
   git rebase origin/main

   # If conflicts occur, edit the conflicted files, then continue:
   git add <resolved-files>
   git rebase --continue

   # Update your remote branch after rebasing
   git push --force-with-lease origin docs/my-topic

Squashing Commits
~~~~~~~~~~~~~~~~~

If a reviewer asks you to clean up your commit history before merging, use an interactive rebase:

.. code-block:: bash

   git rebase -i HEAD~n   # n = number of commits to combine
   git push --force-with-lease origin docs/my-topic

Fixing Common Mistakes
----------------------

Committed to ``main`` by mistake (not pushed yet):

.. code-block:: bash

   git switch -c docs/my-topic
   git switch main
   git reset --hard origin/main
   git switch docs/my-topic

Edited files on ``main`` before creating a branch:

.. code-block:: bash

   git switch -c docs/my-topic
