Python Ecosystems
=================

Python is available through the Spack package manager with support for 
multiple versions, package managers, and development tools.

We provide two main Python options:

**Native Python Module**

- Direct Python installations (3.9, 3.10, 3.11, 3.12, 3.13)
- Lightweight and fast
- Supports modern package managers (pip, uv, pdm, poetry)
- Ideal for custom environments and production workflows

**Anaconda3 Distribution**

- Comprehensive Python distribution with conda
- Pre-installed scientific libraries
- Built-in environment management
- Ideal for data science and scientific computing

.. toctree::
   :maxdepth: 1
   :caption: Documentation

   python
   anaconda3

Package Manager & Tool
----------------------

All native Python installations (3.9-3.13) include: ``pip``, ``wheel``, ``setuptools``, ``uv``, ``pdm``, ``poetry``, and ``Cython`` pre-installed.

Here is a quick comparison of their advantages and features:


.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Feature
     - Native Python
     - Anaconda3
   * - **Package Manager**
     - pip, uv, pdm, poetry
     - conda, pip
   * - **Environment Tool**
     - venv, uv, pdm, poetry
     - conda
   * - **Installation Speed**
     - Fast (especially with uv)
     - Moderate
   * - **Pre-installed Packages**
     - Minimal
     - Extensive (scientific stack)
   * - **Disk Space**
     - Minimal
     - Large
   * - **Best For**
     - Custom setups, production
     - Data science, quick start

Which Should I Use?
-------------------

**Choose Native Python if:**

- You prefer modern tools like uv, poetry or pdm
- You want minimal disk usage
- You are building production python applications
- You need fine-grained control over dependencies

**Choose Anaconda3 if:**

- You are familiar with the conda ecosystem
- You are doing data science or scientific computing
- You want to import conda environments from other systems
- You would use non-python packages available in conda
