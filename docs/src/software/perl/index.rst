Perl Support
=============

Perl is available through the Spack package manager with support for 
scripting, CPAN package management, and comprehensive standard library.

.. contents:: Table of Contents
   :local:
   :depth: 2

Quick Start
-----------

.. code-block:: bash

   # Activate Spack environment
   source /opt/shared/.spack-edge/dist/bin/setup-envs.sh -y
   
   # Check available Perl versions
   module avail perl
   
   # Load Perl
   module load perl/5.40
   
   # Verify installation
   perl --version
   
   # Run Perl code
   perl -e 'print "Hello, World!\n"'
   
   # Run a script
   perl my_script.pl

.. note::
   Module names may include a 7-digit hash suffix (e.g., ``perl/5.40.0-abc123d``).
   You do **NOT** need to include this hash when loading - the version alone 
   (e.g., ``5.40``) is sufficient.

Tutorials
---------

.. toctree::
   :maxdepth: 1
   :titlesonly:

Features Availability
---------------------

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Feature / Version
     - Perl 5.40
     - Others :sup:`[1]`
   * - **Installed**
     - ✓ (Default)
     - ✗ :sup:`[1]`
   * - **Perl Interpreter**
     - ✓
     - ✓
   * - **CPAN Package Manager**
     - ✓
     - ✓
   * - **cpanm (App::cpanminus)**
     - ✓
     - Available via CPAN
   * - **SLURM Compatibility**
     - ✓
     - ✓

**Notes:**

:sup:`[1]` **Others (Perl 5.x versions):** Can be installed on your own via Spack (not pre-installed as module). Self-installed versions have not been tested by HPC team.

Environment Variables
---------------------

When loading the Perl module, the following environment variables are set automatically.

PERL5LIB
^^^^^^^^
Specifies the directories to search for Perl library files and modules.

**Default:** ``$HOME/.perl5/lib/perl5``

PERL_LOCAL_LIB_ROOT
^^^^^^^^^^^^^^^^^^^
Points to the root directory of the local Perl library installation.

**Default:** ``$HOME/.perl5``

PERL_MB_OPT
^^^^^^^^^^^
Options passed to Module::Build for building and installing Perl modules.

**Default:** ``--install_base "$HOME/.perl5"``

PERL_MM_OPT
^^^^^^^^^^^
Options passed to ExtUtils::MakeMaker for building and installing Perl modules.

**Default:** ``INSTALL_BASE=$HOME/.perl5``

PERL_CPAN_MIRROR
^^^^^^^^^^^^^^^^
Specifies the CPAN mirror URL for downloading Perl modules.

**Default:** ``https://www.cpan.org/``

.. note::
   These environment variables are automatically configured when you load the Perl module. 
   They enable local installation of CPAN modules in your home directory without requiring 
   root privileges. You typically don't need to modify them manually.

Support and Resources
---------------------

**Perl Documentation**

- `Perl Documentation <https://perldoc.perl.org/>`_
- `CPAN (Comprehensive Perl Archive Network) <https://www.cpan.org/>`_
- `MetaCPAN <https://metacpan.org/>`_
- `App::cpanminus Documentation <https://metacpan.org/pod/App::cpanminus>`_
- `local::lib Documentation <https://metacpan.org/pod/local::lib>`_

**Learning Resources**

- `Learn Perl <https://learn.perl.org/>`_
- `Perl Tutorial <https://perldoc.perl.org/perlintro>`_
- `Modern Perl Book <http://modernperlbooks.com/books/modern_perl_2016/>`_
