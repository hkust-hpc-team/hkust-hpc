Contributor's Guide
===================

The doc is written in reStructuredText format and built using Sphinx.
All the doc source files are located in the ``docs/src/`` directory.

Getting started
---------------

This project uses ``uv`` for Python package management.

**Prerequisites**

- Python >= 3.11
- ``uv``

First, install ``uv`` if you don't have it:

.. code-block:: bash

    wget -qO- https://astral.sh/uv/install.sh | sh

Then, set up the local development environment by running ``make install``
from the project root. This will create a virtual environment in ``.venv/``
and install all required dependencies.

.. code-block:: bash

    make install

Building the Documentation
--------------------------

To build the HTML content, simply run ``make``:

.. code-block:: bash

    make

The output will be generated in the ``build/html`` directory.

How to Contribute
-----------------

We welcome contributions in various forms, such as reporting issues,
suggesting new topics, or submitting pull requests for corrections and improvements.

All development happens on our GitHub repository: `hkust-hpc-team/hkust-hpc <https://github.com/hkust-hpc-team/hkust-hpc>`_

Please feel free to open an issue or a pull request.

Editor Recommendations
----------------------

We recommend using VS Code for editing the documentation. The repository includes a recommended workspace configuration.

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
