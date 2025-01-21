Contributor's Guide
===================

The doc is written in reStructuredText format and built using Sphinx.

All the doc source files are located in the ``docs`` directory.

Getting started
---------------

We use ``pdm`` as the package manager for this project.

**Prerequisites**

- ``python >= 3.10,< 3.13``
- ``pip``
- ``pdm``

You can install ``pdm`` by running the following commands if you have not.

.. code-block:: bash

    python3 -m ensurepip --user
    pip3 install --user pdm

All dependencies in this project can then be installed by

.. code-block:: bash

    # at project root
    make install

A Python virtual env will be created at ``${projectRoot}/.venv.``

Editor Recommendations
----------------------

We recommend using vscode for editing the doc.

The following extensions are recommended:

- python

  - ``ms-python.vscode-pylance``
  - ``ms-python.black-formatter``
  - ``ms-python.isort``

- reStructuredText

  - ``lextudio.restructuredtext`` for syntax highlighting
  - ``swyddfa.esbonio`` for reStructuredText preview

- misc

  - ``aaron-bond.better-comments`` for comments
  - ``eamodio.gitlens`` better version control
  - ``EditorConfig.EditorConfig`` for vscode to use the ``.editorconfig`` file
