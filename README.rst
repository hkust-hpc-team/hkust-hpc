HKUST HPC Documentation
========================

This is a collection of documentations for AI / HPC users using central HPC resources at the Hong Kong University of Science and Technology (HKUST).

The documentation is available at https://hkust-hpc-docs.readthedocs.io/

Main HPC facilities currently maintained by the HKUST Information Technology Services (ITSC)
- Superpod
- HPC3
- HPC4

Contributor's Guide
--------------------

The documentation is written in reStructuredText format and built using Sphinx.

All the documentation source files are located in the ``docs/source`` directory.

Getting started
~~~~~~~~~~~~~~~~

We use ``pdm`` for managing the dependencies for development and local build.
You can install ``pdm`` by running the following commands if you have not.

.. code-block:: bash

    python3 -m ensurepip --user
    pip3 install --user pdm

Standard ``pdm`` workflows can be used.

.. code-block:: bash

    pdm venv create
    pdm install --dev

Editor Recommendations
~~~~~~~~~~~~~~~~~~~~~~~

We recommend using vscode for editing the documentation.

The following extensions are recommended:

- Python
  - ms-python.vscode-pylance
  - ms-python.black-formatter
  - ms-python.isort
- reStructuredText
  - `lextudio.restructuredtext` for syntax highlighting
  - `swyddfa.esbonio` for reStructuredText preview
- Misc
  - `aaron-bond.better-comments` for comments
  - `eamodio.gitlens` better version control
  - `EditorConfig.EditorConfig` for vscode to use the `.editorconfig` file
