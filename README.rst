HKUST HPC Documentation
=======================

Latest doc: `hkust-hpc-docs.readthedocs.io <https://hkust-hpc-docs.readthedocs.io/>`_

**Tutorials, docs and knowledge base** for both AI / HPC users using central HPC resources at the Hong Kong University of Science and Technology (HKUST).

This doc is mainly for the newer generations of HPCs maintained by Information Technology Services Center (ITSC) of HKUST.

- Superpod
- HPC4

However, you may find some useful techniques for the older generations of HPCs or other HPC clusters as well.

Contributor's Guide
-------------------

The doc is written in reStructuredText format and built using Sphinx.

All the doc source files are located in the ``docs/source`` directory.

Getting started
~~~~~~~~~~~~~~~

We use ``pdm`` for managing the dependencies for development and local build. You can install ``pdm`` by running the following commands if you have not.

.. code-block:: bash

    python3 -m ensurepip --user
    pip3 install --user pdm

Standard ``pdm`` workflows can be used.

.. code-block:: bash

    pdm venv create
    pdm install --dev

Editor Recommendations
~~~~~~~~~~~~~~~~~~~~~~

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
  - ``EditorConfig.EditorConfig`` for vscode to use the `.editorconfig` file
