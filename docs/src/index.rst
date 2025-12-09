HKUST HPC Documentation
=======================

Searchable doc at `readthedocs.io <https://hkust-hpc-docs.readthedocs.io/>`_.

**Tutorials, docs and knowledge base** for AI / HPC users using central HPC resources at the Hong Kong University of
Science and Technology (HKUST).

Despite this doc is tailored for Superpod and HPC4 maintained by Information Technology Services Center (ITSO), you may
find some useful techniques in general and works on other HPC systems as well.

Table of Contents
-----------------

.. toctree::
    :glob:
    :titlesonly:
    :maxdepth: 2

    software/index
    compile-guides/index
    kb/index
    sysadmin/index
    contrib/index

Building the Documentation
--------------------------

To build the documentation locally, first set up the development environment
by following the :doc:`contributor's guide </contrib/index>`.

Once set up, you can build the HTML pages by running:

.. code-block:: bash

    make

The output will be located in the ``build/html`` directory.

Acknowledgement
---------------

Courtesy to `readthedocs.com <https://about.readthedocs.com/>`_ for providing free hosting for open-source
documentations.

Contributors
------------

We very much appreciate contributions to this doc in all forms including but not limited to:

- Reporting issues or suggestions
- Requesting new topics to be discussed
- Submitting corrections or improvements via pull requests
- Sharing your experience or knowledge in articles

To contribute, please refer to the :doc:`contributor's guide </contrib/index>`.

License
-------

This project is licensed under the MIT License.
