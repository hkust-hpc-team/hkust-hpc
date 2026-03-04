Contributor's Guide
===================

The documentation is written in `reStructuredText
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html>`_
format and built using `Sphinx <https://www.sphinx-doc.org/>`_.
All doc source files are located in the ``docs/src/`` directory.

Getting Started
---------------

This project uses `uv <https://docs.astral.sh/uv/>`_ for Python package
management.

**Prerequisites**

- Python >= 3.11
- ``uv``

First, install ``uv`` if you don't have it:

.. code-block:: bash

    wget -qO- https://astral.sh/uv/install.sh | sh

Then, set up the local development environment by running ``make install``
from the project root. This will create a virtual environment in ``.venv/``
and install all required dependencies (including pre-commit hooks).

.. code-block:: bash

    make install

Building the Documentation
--------------------------

To build the HTML content, run:

.. code-block:: bash

    make

The output will be generated in the ``build/html`` directory. Open
``build/html/index.html`` in your browser to preview the site locally.

How to Contribute
-----------------

We welcome contributions in various forms, such as reporting issues,
suggesting new topics, or submitting pull requests for corrections and
improvements.

All development happens on our GitHub repository:
`hkust-hpc-team/hkust-hpc <https://github.com/hkust-hpc-team/hkust-hpc>`_

Contribution Workflow
^^^^^^^^^^^^^^^^^^^^^

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally and set up the dev environment
   (see `Getting Started`_ above).
3. **Create a branch** for your changes:

   .. code-block:: bash

       git checkout -b my-improvement

4. **Make your changes** in ``docs/src/``.
5. **Build locally** to verify your changes render correctly:

   .. code-block:: bash

       make build

6. **Commit** your changes:

   .. code-block:: bash

       git commit -m "Describe the change"

7. **Push** to your fork and **open a Pull Request** on GitHub.

Pre-commit hooks will run automatically on your commits to check for common
issues (trailing whitespace, RST syntax, code formatting). They will also
run on your PR via `pre-commit.ci <https://pre-commit.ci/>`_.

Writing RST Content
^^^^^^^^^^^^^^^^^^^

A few tips for writing reStructuredText:

- Use 4 spaces for indentation (no tabs).
- Keep lines under 120 characters where practical.
- Use ``.. code-block:: <language>`` for code examples.
- Use ``:doc:`` and ``:ref:`` roles for cross-references within the docs.
- Preview your changes locally before submitting a PR.

For RST syntax reference, see the
`Sphinx reStructuredText Primer
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html>`_.

Editor Recommendations
----------------------

We recommend using VS Code for editing the documentation. The repository
includes a recommended workspace configuration.

The following extensions are recommended and align with our pre-commit hooks:

- **Python**

  - ``ms-python.python``: Core Python support.
  - ``ms-python.vscode-pylance``: Powerful language server for Python.
  - ``charliermarsh.ruff``: Integrates the Ruff linter and formatter.

- **reStructuredText**

  - ``lextudio.restructuredtext``: Syntax highlighting and snippets.
  - ``swyddfa.esbonio``: Live preview and language server for Sphinx projects.

- **Other Languages**

  - ``esbenp.prettier-vscode``: For formatting YAML and Markdown files.
  - ``redhat.vscode-yaml``: Comprehensive YAML language support.
  - ``tamasfe.even-better-toml``: Enhanced TOML file support.

- **General Development**

  - ``aaron-bond.better-comments``: Improve comments readability.
  - ``EditorConfig.EditorConfig``: Enforces consistent coding styles.
  - ``eamodio.gitlens``: Supercharges Git capabilities within VS Code.
