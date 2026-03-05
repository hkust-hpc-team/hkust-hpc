Contributor's Guide
===================

This documentation is written in reStructuredText (RST) and built with Sphinx.
All source files live under ``docs/src/``.

Getting Started
---------------

**Prerequisites**

- Python >= 3.11
- `uv <https://docs.astral.sh/uv/>`_ (Python package manager)

Install ``uv`` if you don't have it:

.. code-block:: bash

   curl -LsSf https://astral.sh/uv/install.sh | sh

Then set up the local development environment:

.. code-block:: bash

   git clone https://github.com/hkust-hpc-team/hkust-hpc.git
   cd hkust-hpc
   make install    # creates .venv, installs deps + pre-commit hooks

Building the Documentation
--------------------------

.. code-block:: bash

   make build      # builds HTML to build/html/

Open ``build/html/index.html`` in a browser to preview.

Contribution Workflow
---------------------

1. **Fork** the repository on GitHub.
2. **Create a branch** from ``main``:

   .. code-block:: bash

      git checkout -b docs/my-topic

3. **Edit** RST files under ``docs/src/``.
4. **Build locally** with ``make build`` and verify the output.
5. **Commit** your changes -- pre-commit hooks will run automatically.
6. **Push** your branch and open a **Pull Request** against ``main``.

Pre-commit hooks check RST style (``doc8``), RST syntax (``rstcheck``),
Python style (``ruff``), and file hygiene (trailing whitespace, etc.).
To run all hooks manually:

.. code-block:: bash

   uv run pre-commit run --all-files

Tool Versions
-------------

All linter and formatter versions are managed through ``pyproject.toml`` and
locked in ``uv.lock``. Pre-commit hooks use ``language: system`` with
``uv run``, ensuring local development, CI, and ReadTheDocs all use
identical tool versions.

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Tool
     - Purpose
   * - ``doc8``
     - RST style (blank lines, indentation; line-length check disabled — see below)
   * - ``rstcheck``
     - RST syntax validation
   * - ``ruff``
     - Python linting and formatting (``conf.py``)
   * - ``prettier``
     - YAML and Markdown formatting
   * - ``sphinx-build -W``
     - Full documentation build with warnings-as-errors

RST Writing Tips
----------------

- **Line length**: No hard limit enforced. RST has no auto-formatter, so ``doc8``'s
  line-length check (D001) is disabled to avoid false positives on pre-existing content.
  Aim for ~120 characters as a guideline, but this is not a blocking check.
- **Indentation**: 3 spaces for directive content.
- **Cross-references**: Use ``:doc:`/path/to/page``` for other pages,
  ``:ref:`label-name``` for labeled sections.
- **Code blocks**: Always specify the language:

  .. code-block:: rst

     .. code-block:: bash

        srun --gres=gpu:1 --pty bash

- **Admonitions**: Use ``.. note::``, ``.. warning::``, ``.. tip::`` for callouts.

Project Structure
-----------------

::

   hkust-hpc/
   ├── docs/src/              # RST source files
   │   ├── index.rst          # Root toctree
   │   ├── kb/                # Knowledge base articles
   │   ├── compile-guides/    # Software compilation guides
   │   ├── sysadmin/          # System administration
   │   └── contrib/           # This guide
   ├── examples/              # Code examples with README
   ├── workshops/             # Workshop materials
   ├── pyproject.toml         # Dependency and tool configuration
   ├── .pre-commit-config.yaml
   ├── .readthedocs.yaml
   └── Makefile               # Build automation

Editor Setup
------------

We recommend VS Code. The repository ships ``.vscode/extensions.json``
(recommended extensions) and ``.vscode/settings.json`` (tool paths pointing
to ``.venv``). Open the project in VS Code and accept the extension
recommendations when prompted.

Key extensions:

- ``swyddfa.esbonio`` -- Sphinx language server with live diagnostics
- ``lextudio.restructuredtext`` -- RST syntax highlighting and linting
- ``charliermarsh.ruff`` -- Python linter/formatter
- ``esbenp.prettier-vscode`` -- YAML/Markdown formatting
