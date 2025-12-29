Software Ecosystem
==================

OS Software Management
----------------------

Essential Software
^^^^^^^^^^^^^^^^^^

OS should at least provide essential support for HPC/AI workflows

Apart from items within the base OS previously discussed

- Drivers
- Scheduling System
- Sysadmin Tools
- Monitoring Tools

Software for Developer Experience
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To enhance researcher's Developer Experience, it is best to provide built-in support. The inclusion of these software within the base OS image would significantly reduce the time and effort required for researchers to set up their development environment, allowing them to focus more on their research work.

For example, it is very hard, if not impossible to hackaround missing X11 support without root privilege, even with Spack, due to its deep integration with ``sshd``.

- GUI Support (via X11, port forwarding or other tools)
- GUI Libraries (e.g. Qt, GTK, etc)
- Non-architecture specific Libraries (e.g. zlib, libffi, etc)
- Basic Build Tools (e.g. cmake, gmake, autoconf, etc)
- Modular Package Management (Lmod)
- Backbone for Containerization (Enroot, Apptainer)

.. TODO: Include a non-exhaustive list of these software curated from experience

Spack Software Management for HPC/AI
------------------------------------

Spack is a versatile package manager that provides

- multi-versioned
- multi-compiler/mpi binding
- multi-architecture

software management for HPC/AI environments.

The primary role of Spack is to provide Lmod modules for downstream HPC/AI users and developers to easily load and use the software stack. It is a secondary role to facilitate users to extend the Spack software stack by building additional packages on their own, for the reasons below:

- User often build high-level, propietary, customized HPC/AI software that is tailored to their specific research need, this is outside of Spack's scope;
- It is often simplier to use Lmod instead of Spack for end users;
- User would prefer stick to one or two specific architecture, compiler, MPI combination and focus on their research work

Hierachical Spack / Lmod Setup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See https://hkust-hpc-docs.readthedocs.io/latest/software/index.html for details.

For example, ``aocc/5`` with ``openmpi/5`` specifically for AMD's Zen4 architecture.

.. code-block:: console

    # $ module load aocc/5 openmpi/5
    # $ module avail

    ------------------------------- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/openmpi/5.0.6-7lxgyoz/aocc/5.0.0 -------------------------------
      fftw/3.3.10-ka3at5w         netcdf-c/4.9.2-zen4-su7uzrh          parallel-netcdf/1.14.0-zen4-kwi63ho
      hdf5/1.14.5-zen4-dl3y422    netcdf-fortran/4.6.1-zen4-ayvgcgp    parallelio/2.6.3-zen4-wdeshix

    ------------------------------------------ /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/aocc/5.0.0 ------------------------------------------
      amdblis/5.0-dn6uvvq        amdlibm/5.0-bejgadq             aocl-libmem/5.0-tau3tmx    fftw/3.3.10-3nnsud2 (D)    libxc/7.0.0-trdi2xh
      amdfftw/5.0-qujcnic        aocl-compression/5.0-c6l64pq    boost/1.87.0-djati6y       glib/2.72.4-37b6esr        openmpi/4.1.8-zen4-ipgl3q2
      amdlibflame/5.0-xv7wxm6    aocl-crypto/5.0-a6brcsm         eigen/3.4.0-q3j6krw        gsl/2.8-35kh35v            openmpi/5.0.6-zen4-7lxgyoz (L,D)

    ------------------------------------------------ /opt/shared/.spack-edge/dist/lmod/linux-rocky9-x86_64/Core -------------------------------------------------
      anaconda3/2023.09-0-djormcp            ffmpeg/6.1.1-vju7pzr                                    neovim/0.11.5-qbzcuep
      anaconda3/2024.10-1-qzbchqc            ffmpeg/7.1-r6nw6ht                               (D)    ninja/1.12.1-7kua3c3
      anaconda3/2025.06-1-bwpmoyt   (D)      flex/2.6.3-5lh2bhn                                      node-js/22.14.0-vg4k26t
      ant/1.10.14-2edlxl7                    fpm/0.10.0-qhfqwpr                                      npm/11.2.0-cjx26ky
      aocc/4.2.0-lhjvw3v                     gcc/12.4.0-dqqme7t                                      nvhpc/23.11-odjlr3d
      aocc/5.0.0-bcw5biu            (L,D)    gcc/13.3.0-icpzffn                                      nvhpc/24.11-kkiogbz
      autotools/master-5yg2rql               gcc/14.2.0-6beutk4                               (D)    nvhpc/25.1-roe45to            (D)
      awscli-v2/2.24.24-ciyimz6              gdb/15.2-ssmyaf5                                        ocaml/5.2.1-v554o55
      bash/5.2-7z6hb6s                       git-lfs/3.5.1-agasila                                   octave/9.4.0-yv5f7zm
      bazel/7.0.2-byht6vm                    git/2.48.1-nibpzcv                                      openjdk/1.8.0_265-b01-tkl3lyc
      binutils/2.43.1-dppuct7                gmake/4.4.1-fl3htkp                                     openjdk/11.0.23_9-ho5jmkd
      bison/3.8.2-3cxo27x                    gnuplot/6.0.0-s7asaer                                   openjdk/17.0.11_9-ythui6n     (D)
      cmake/3.31.6-npbmige                   go/1.24.1-pb33xrl                                       parallel/20240822-ygrinr2
      core-packages/master-wn2s3vm           google-cloud-cli/504.0.1-j2g2wko                        perl/5.40.0-j5mftpl
      cuda/11.8.0-gy2eqbu                    googletest/1.15.2-jquhbtz                               python/3.9.21-dcbjhsi
      cuda/12.2.2-2pjj2wa                    gperf/3.1-w25eay7                                       python/3.10.16-dhfnvol
      cuda/12.3.2-x4qiflz                    gradle/8.10.2-ojlfbrv                                   python/3.11.11-rrcr3ae
      cuda/12.4.1-ukp2hyg                    imagemagick/7.1.1-39-tezypzt                            python/3.12.9-3lxwd5b
      cuda/12.5.1-7m5uypi                    intel-oneapi-compilers-classic/2021.10.0-7vq755s        python/3.13.2-sbeg36d         (D)
      cuda/12.6.3-qetd4jn                    intel-oneapi-compilers/2021.4.0-qbuguet                 r/4.4.2-4pchx4a
      cuda/12.8.0-a5bifng           (D)      intel-oneapi-compilers/2022.2.1-utfqjpj                 rstudio/2024.12.1-5hoqdq3
      cudnn/8.9.7.29-11-2darjc5              intel-oneapi-compilers/2023.2.4-raos663                 ruby/3.3.5-3nyrru6
      cudnn/8.9.7.29-12-wtp7bd4              intel-oneapi-compilers/2024.2.1-7ydnbt5                 rust/1.85.0-h5crcnd
      cudnn/9.2.0.82-11-vuiwl4t              intel-oneapi-compilers/2025.0.4-sn26au2          (D)    scons/4.7.0-kv76kva
      cudnn/9.2.0.82-12-ztnynio     (D)      jasper/1.900.31-x6y46r3                                 screen/4.9.1-iyth5bh
      cvs/1.12.13-4umjsdr                    jasper/4.2.8-fsdru5x                             (D)    subversion/1.14.2-6bfibte
      dos2unix/7.4.4-vthdwts                 libpng/1.6.39-sy44qbs                                   swig/4.0.2-fortran-2axjga5
      dotnet-core-sdk/8.0.4-uvuvxno          libtirpc/1.3.3-u5ki22x                                  tcl/8.6.12-lrm4k2h
      doxygen/1.13.2-2zlsbgb                 lua/5.4.6-4jza5qh                                       tcsh/6.24.14-wtzpfp7
      easybuild/4.7.0-gxny6u4                matlab/R2019b-33fin4v                                   texinfo/7.1-d2im5k4
      emacs/30.1-3fnvum7                     matlab/R2022b-sidvmnp                                   vmd/1.9.3-pdbmmmk
      expat/2.7.0-jxuxgae                    matlab/R2023b-7r5y3as                            (D)    yarn/1.22.22-rkfr4zf
      expect/5.45.4-ojqve4w                  maven/3.9.8-swoevk4                                     zsh/5.9-hlaifvi
      ffmpeg/4.4.4-plmxako                   mercurial/6.7.3-hb2tvnq
      ffmpeg/5.1.4-vdbazps                   meson/1.7.0-o3o3drn

while ``intel-oneapi-compilers/2025`` with ``intel-oneapi-mpi/2021`` would have broader architecture support, but similar software stack.

.. code-block:: console

    ---------------------- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/intel-oneapi-mpi/2021.14.2-3hob5dq/oneapi/2025.0.4 ----------------------
      fftw/3.3.10-rfygfzb                      lammps/20250204-pixknz2                 netcdf-fortran/4.6.1-x86_64_v4-u7yhv2n
      hdf5/1.14.5-x86_64_v4-rcob2cy            mpas-model/7.3-frpqueu                  openfoam-org/11-6ifalof
      intel-oneapi-mkl/2023.2.0-omj7iod        mpas-model/8.0.2-prlpnvq                openfoam-org/12-cfqbmfo                  (D)
      intel-oneapi-mkl/2024.2.2-ok3ltvd        mpas-model/8.1.0-6conf6e         (D)    parallel-netcdf/1.14.0-x86_64_v4-snjqiin
      intel-oneapi-mkl/2025.0.1-g746h4u (D)    netcdf-c/4.9.2-x86_64_v4-kvaxzjk        parallelio/2.6.3-x86_64_v4-qhlxuxx

    --------------------------------------- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/oneapi/2025.0.4 ----------------------------------------
      boost/1.87.0-sxg6wzt        glib/2.72.4-7j6fatq                                 libxc/7.0.0-vwglv4q
      eigen/3.4.0-jlemvtf         gsl/2.8-xpj2m2w                                     openmpi/4.1.8-x86_64_v4-zz4jmnw
      fftw/3.3.10-3a4be3v  (D)    intel-oneapi-mpi/2021.14.2-x86_64_v4-3hob5dq (L)    openmpi/5.0.6-x86_64_v4-cnku7u3 (D)

    ------------------------------------------------ /opt/shared/.spack-edge/dist/lmod/linux-rocky9-x86_64/Core -------------------------------------------------
      anaconda3/2023.09-0-djormcp          ffmpeg/6.1.1-vju7pzr                                      neovim/0.11.5-qbzcuep
      anaconda3/2024.10-1-qzbchqc          ffmpeg/7.1-r6nw6ht                               (D)      ninja/1.12.1-7kua3c3
      anaconda3/2025.06-1-bwpmoyt   (D)    flex/2.6.3-5lh2bhn                                        node-js/22.14.0-vg4k26t
      ant/1.10.14-2edlxl7                  fpm/0.10.0-qhfqwpr                                        npm/11.2.0-cjx26ky
      aocc/4.2.0-lhjvw3v                   gcc/12.4.0-dqqme7t                                        nvhpc/23.11-odjlr3d
    # ...

Support Scope (Target)
^^^^^^^^^^^^^^^^^^^^^^

While not a majority of software are available, we are aware of a wide range of HPC/AI applications and libraries, and we prioritize support based on user demand and research trends.

Please check user guide for supported software list: https://hkust-hpc-docs.readthedocs.io/latest/software/index.html


These software are categorized into

- Full high-level applications

  .. TODO: Fill in data

- MPI Libraries

  .. TODO: Fill in data

- Non-mpi Libraries

  .. TODO: Fill in data

- Runtimes

  .. code-block:: console

    app_name,category,installed
    R,runtime,y
    anaconda3,runtime,fix
    gcc,runtime,y
    intel,runtime
    jdk,runtime,y
    julia,runtime,fix
    llvm,runtime,fix
    miniconda3,runtime,n
    miniforge,runtime,n
    octave,runtime,y
    perl,runtime,y
    python,runtime,y
    redis,runtime,n
    ruby,runtime,y
    tcl,runtime,y

- GUI Tools and Visualization

  .. code-block:: console

    app_name,category,installed
    VTK,graphics
    magic,graphics
    openCascade,graphics
    PanoplyJ,graphics
    chimera,graphics
    grads,graphics,y
    ncl,graphics,failed
    visit,graphics,failed
    ImageMagick,graphics,y
    ParaView,graphics,y
    ffmpeg,graphics,y
    ghostscript,graphics,y
    gnuplot,graphics,y
    ncview,graphics,y
    vmd,graphics,y
    atk,gui-libs
    cairo,gui-libs
    fontconfig,gui-libs
    freetype,gui-libs
    harfbuzz,gui-libs
    jasper,gui-libs
    libgd,gui-libs
    libjpeg,gui-libs
    libpng,gui-libs
    libxcb,gui-libs
    libxext,gui-libs
    mesa,gui-libs
    qt,gui-libs
    tk,gui-libs
    xcb,gui-libs

- Build tools

  .. code-block:: console

     app_name,category,installed
     autoconf,build,y
     automake,build,y
     bazel
     binutils,build,y
     bison,build,y
     cmake,build,y
     easybuild
     flex,build,y
     fpm
     gmake
     googletest,build,y
     meson,build,y
     ninja,build,y
     scons
     swig,build,y
     texinfo,build,y

Spack Considerations
^^^^^^^^^^^^^^^^^^^^

Presentation at HPSFcon 2025 - Spack session: **An Opinionated-Default Approach to Enhance Spack Developer Experience**

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/bvQs5R_Ey0g" 
   title="An Opinionated-Default Approach to Enhance Spack Developer Experience" 
   frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
   allowfullscreen></iframe>

`Watch on YouTube <https://www.youtube.com/watch?v=bvQs5R_Ey0g>`_

Start with Rebuilding GCC
"""""""""""""""""""""""""

Rebuilding GCC with Spack is often necessary to ensure compatibility and optimal performance of the software stack. It allows for consistent compiler versions across all packages, reducing potential conflicts and ensuring that all software is built with the same optimizations and features.

It is also a solution to avoid OS build tool bugs, missing features or lack of instruction set.

.. code-block:: yaml

    spack:
    compilers:
      - compiler:
          environment: {}
          extra_rpaths: []
          flags:
            cflags: -std=gnu99
            cxxflags: -std=gnu11
          modules: []
          operating_system: rocky9
          paths:
            cc: /usr/bin/gcc
            cxx: /usr/bin/g++
            f77: /usr/bin/gfortran
            fc: /usr/bin/gfortran
          spec: gcc@=11.4.1.os
          target: x86_64
    concretizer:
      reuse: false
      targets:
        granularity: generic
        host_compatible: true
      unify: false
    packages::
      all:
        permissions:
          read: world
          write: user
        require:
          - "target=x86_64_v4 %gcc@11.4.1.os"
    specs:
      - "gcc@11.5.0 +binutils+bootstrap+graphite+piclibs+profiled languages=c,c++,fortran,lto ^binutils@2.36:"
    view: false

Opinionated Defaults
""""""""""""""""""""""

Default preferences are given to a lot of aspects of the software stack to reduce the complexity of managing too many options, including default enabled features, architecture targets, compiler flags, etc.

.. code-block:: yaml

    packages:
      hdf5:
        prefer:
          - "@1.14:"
          - +cxx
          - +fortran
          - +hl
          - +map
          - +mpi
          - +shared
          - +subfiling
          - +threadsafe
          - +tools
        require:
          - +szip
      netcdf-c:
        prefer:
          - "@4.9:"
          - +blosc
          - +byterange
          - +fsync
          - +logging
          - +mpi
          - +nczarr_zip
          - +optimize
          - +pic
          - +shared
          - +szip
          - +zstd
        require:
          - +parallel-netcdf

"Drop-in" Replacible Software
"""""""""""""""""""""""""""""

We test and support every compiler with complete set of tools and libraries, so users can easily switch between different compilers without worrying about software availability.

.. code-block:: console

    $ module load aocc openmpi
    $ module avail

    ---------------------------------------------- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/openmpi/5.0.6-7lxgyoz/aocc/5.0.0 ----------------------------------------------
      fftw/3.3.10-ka3at5w         netcdf-c/4.9.2-zen4-su7uzrh          parallel-netcdf/1.14.0-zen4-kwi63ho
      hdf5/1.14.5-zen4-dl3y422    netcdf-fortran/4.6.1-zen4-ayvgcgp    parallelio/2.6.3-zen4-wdeshix

    --------------------------------------------------------- /opt/shared/.spack-edge/share/spack/lmod/linux-rocky9-x86_64/aocc/5.0.0 ---------------------------------------------------------
      amdblis/5.0-dn6uvvq        amdlibm/5.0-bejgadq             aocl-libmem/5.0-tau3tmx    fftw/3.3.10-3nnsud2 (D)    libxc/7.0.0-trdi2xh
      amdfftw/5.0-qujcnic        aocl-compression/5.0-c6l64pq    boost/1.87.0-djati6y       glib/2.72.4-37b6esr        openmpi/4.1.8-zen4-ipgl3q2
      amdlibflame/5.0-xv7wxm6    aocl-crypto/5.0-a6brcsm         eigen/3.4.0-q3j6krw        gsl/2.8-35kh35v            openmpi/5.0.6-zen4-7lxgyoz (L,D)
    
    ...

    $ module load hdf5 netcdf-c netcdf-fortran parallel-netcdf parallelio fftw libxc
    $ module load intel-oneapi-compilers intel-oneapi-mpi

    Lmod is automatically replacing "aocc/5.0.0-bcw5biu" with "intel-oneapi-compilers/2025.0.4-sn26au2".


    Lmod is automatically replacing "openmpi/5.0.6-zen4-7lxgyoz" with "intel-oneapi-mpi/2021.14.2-x86_64_v4-3hob5dq".


    The following have been reloaded with a version change:
      1) fftw/3.3.10-3nnsud2 => fftw/3.3.10-3a4be3v                          5) netcdf-fortran/4.6.1-zen4-ayvgcgp => netcdf-fortran/4.6.1-x86_64_v4-u7yhv2n
      2) hdf5/1.14.5-zen4-dl3y422 => hdf5/1.14.5-x86_64_v4-rcob2cy           6) parallel-netcdf/1.14.0-zen4-kwi63ho => parallel-netcdf/1.14.0-x86_64_v4-snjqiin
      3) libxc/7.0.0-trdi2xh => libxc/7.0.0-vwglv4q                          7) parallelio/2.6.3-zen4-wdeshix => parallelio/2.6.3-x86_64_v4-qhlxuxx
      4) netcdf-c/4.9.2-zen4-su7uzrh => netcdf-c/4.9.2-x86_64_v4-kvaxzjk


Composible Environments and Configs
"""""""""""""""""""""""""""""""""""

Using environment enhances reproducibility, the modular environments enables parallel build and composible software stack definition. All these environments would function as a single large Lmod module tree.

.. code-block:: console

    # ls envs/
    0000-spack-gcc        2000-oneapi-impi          3000-netcdf-aocc-openmpi       5000-libs            5001-octave          5003-cloud-cli
    1000-build-tools      2000-oneapi-openmpi       3000-netcdf-oneapi-impi        5000-runtime         5001-perl            5003-ffmpeg
    1000-core-packages    2001-aocc-amdlibs         3000-netcdf-oneapi-openmpi     5000-vcs             5001-python          5003-libs
    1001-cc-aocc          2001-aocc-libs            4001-lammps-oneapi-impi        5000-vcs-tools       5001-r               5003-visualization
    1001-cc-intel-oneapi  2001-oneapi-libs          4001-mpas-model-oneapi-impi    5001-anaconda3       5001-ruby            compiler-find-mpi.build
    1001-cc-nvhpc         3000-fftw-aocc-openmpi    4001-openfoam-org-oneapi-impi  5001-go              5001-runtime         makefile
    1001-cuda             3000-fftw-oneapi-impi     5000-build-tools               5001-graphics-tools  5001-rust
    1002-cc-gcc           3000-fftw-oneapi-openmpi  5000-buildtools                5001-java            5002-dotnet
    1003-runtime          3000-mkl-oneapi-impi      5000-cloud-tools               5001-matlab          5002-texlive
    2000-aocc-openmpi     3000-mkl-oneapi-openmpi   5000-coretools                 5001-nodejs          5002-vistools-basic

A modular configuration allow easier update and version control.

.. code-block:: yaml

    # include.yaml
    include:
    - path: package-policies/externals/os-external.yaml
    - path: package-policies/core.yaml
    - path: package-policies/build.yaml
    - path: package-policies/extra.yaml
    - path: package-policies/compilers/commons.yaml
    - path: package-policies/compilers/aocc.yaml
    - path: package-policies/compilers/gcc.yaml
    - path: package-policies/compilers/nvhpc.yaml
    - path: package-policies/compilers/oneapi.yaml
    - path: package-policies/externals/gui-external.yaml
    - path: package-policies/gui.yaml
    - path: package-policies/externals/mpi-external.yaml
    - path: package-policies/mpi-roce-slurm.yaml
    - path: package-policies/apps/boost.yaml
    - path: package-policies/apps/cuda.yaml
    - path: package-policies/apps/ffmpeg.yaml
    - path: package-policies/apps/hdf5-netcdf.yaml
    - path: package-policies/apps/libxc.yaml
    - path: package-policies/apps/perl.yaml
    - path: package-policies/apps/r.yaml
    - path: package-policies/apps/ruby.yaml
    - path: package-keys/matlab.yaml


.. code-block:: console

    .
    ├── compilers.yaml
    ├── include.yaml
    ├── package-keys
    │   ├── matlab.sample.yaml
    │   └── matlab.yaml
    ├── package-policies
    │   ├── apps
    │   │   ├── boost.yaml
    │   │   ├── cuda.yaml
    │   │   ├── ffmpeg.yaml
    │   │   ├── hdf5-netcdf.yaml
    │   │   ├── libxc.yaml
    │   │   ├── perl.yaml
    │   │   ├── r.yaml
    │   │   └── ruby.yaml
    │   ├── build.yaml
    │   ├── compilers
    │   │   ├── aocc.yaml
    │   │   ├── commons.yaml
    │   │   ├── gcc.yaml
    │   │   ├── nvhpc.yaml
    │   │   └── oneapi.yaml
    │   ├── core.yaml
    │   ├── externals
    │   │   ├── gui-external.sample.yaml
    │   │   ├── gui-external.yaml
    │   │   ├── mpi-external.sample.yaml
    │   │   ├── mpi-external.yaml
    │   │   ├── os-external.sample.yaml
    │   │   └── os-external.yaml
    │   ├── extra.yaml
    │   ├── gui.yaml
    │   ├── mpi-roce-none.yaml
    │   └── mpi-roce-slurm.yaml
    └── packages.yaml

Env & Config as Code
""""""""""""""""""""""

Ensure tracibility and version control of the software stack by managing Spack environments and configuration files as code in a git repository.

Forked Spack: https://github.com/hkust-hpc-team/spack

Env & Config: https://github.com/hkust-hpc-team/spack-community-config

Custom Spack Repos: https://github.com/hkust-hpc-team/spack-meta-pkgs

Usage-driven Maintenance
"""""""""""""""""""""""""

We keep track of module usage statistics to identify popular and less-used packages. This data helps prioritize maintenance efforts, ensuring that the most relevant software remains up-to-date, well-supported and tested, and decisions to deprecate or remove seldom-used packages are made based on actual usage patterns.

Compiling GPU Packages on CPU Nodes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The only prerequisite is to have matching CUDA toolkit and driver installed on the build node, it is not necessary to have a physical GPU present.

Software Testing
----------------

.. TODO: Write up

.. code-block:: markdown

    # HPC4 Test Suite

    This repository contains automated test suites for validating HPC4 cluster environments.

    ## Test Categories

    ### Image Tests (`image-tests/`)
    Tests for validating base container images and system packages:
    - **Commandline utilities** - Common CLI tools availability
    - **Development libraries** - curl-devel, fontconfig-devel, munge-devel, pmix-devel
    - **Compilers** - OS-provided GCC, G++, and GFortran
    - **MPI** - Mellanox OpenMPI installation
    - **Module system** - Lmod functionality
    - **GUI libraries** - Qt5 support
    - **Environment** - System environment variables

    ### Spack Tests (`spack-tests/`)
    Tests for Spack package manager and runtime environments:
    - **Compilers** - Spack-provided C/C++/Fortran compilers
    - **MPI** - Spack MPI implementations
    - **Runtimes** - Go, Java (OpenJDK), MATLAB, Perl, Python, R

    ### Slurm MPI Tests (`slurm-mpi-tests/`)
    Tests for validating Slurm job submission and MPI execution in the cluster environment across various compiler and MPI combinations.

    ## Usage

    ### Image Tests & Spack Tests
    These are container-based unit/integration tests. Use the k8s workflow from:
    **https://github.com/hkust-hpc-team/hpc4-k8s-helm**

    For debugging purposes, individual tests can be executed directly in a bash shell using the same commands as in the workflow.

    ### Slurm MPI Tests
    End-to-end integration tests that validate Spack compilers and MPI implementations through Slurm job submission.

    Each test compiles and runs a simple MPI program with cross-node communication to check **production SLURM scheduled environment** for
    - Compiler / MPI Compiler issues
    - SLURM + MPI integration issues (PMIx failure)
    - MPI initialization issues
    - MPI communication issues etc.

    #### Prerequisites

    - Access to a login node with a valid cluster account
    - Access to at least a CPU queue

    #### Steps to run

    1. Activate your Spack instance:

        ```bash
        . /opt/shared/.spack-edge/dist/bin/setup-env.sh -y
        ```

    2. Create an empty directory and run the submission script

        ```bash
        mkdir -p ~/slurm-mpi-tests && cd ~/slurm-mpi-tests
        /path/to/hpc4-tests/slurm-mpi-tests/submit-mpi-tests.sh
        ```

    3. The script will submit test jobs (various compiler/MPI combinations on 1 and 2 nodes):

        ```shell
        Submitting MPI test jobs to SLURM...
        Temporary directory: /home/user/slurm-mpi-tests/slurm-mpi-tests-tmp
        Log directory: /home/user/slurm-mpi-tests/slurm-mpi-tests-logs

        Submitting job: mpi_intel_oneapi_compilers_2023_intel_oneapi_mpi_2021_n1
          Job ID: 382614, Log: .../mpi_intel_oneapi_compilers_2023_intel_oneapi_mpi_2021_n1.log
        Submitting job: mpi_intel_oneapi_compilers_2023_openmpi_4_n1
          Job ID: 382615, Log: .../mpi_intel_oneapi_compilers_2023_openmpi_4_n1.log
        ...
        ==========================================
        All jobs submitted successfully!
        Total jobs submitted: 24
        ==========================================
        ```

    4. Monitor job progress

        ```bash
        squeue -u $USER
        ```

    1. Check results after completion
      
        ```bash
        # For success cases
        tail --quiet -n 1 slurm-mpi-tests-logs/* | grep "Test Complete"

        # For failed cases
        tail --quiet -n 1 slurm-mpi-tests-logs/* | grep -v "Test Complete"
        ```

    #### Interpreting results

    - **Success:** Last line shows `Test Complete` with timestamp:
      
      ```shell
      === intel-oneapi-compilers/2023 with openmpi/4 (256 tasks) Test Complete on Wed Dec 17 16:10:39 HKT 2025 ===
      ```

    - **Failure:** Last line does NOT contain `Test Complete` - indicates compilation error, MPI initialization failure, or runtime crash. Review the full log file for details.

.. code-block:: console

    $ tree
    .
    ├── image-tests
    │   ├── fixtures
    │   │   ├── hello.c
    │   │   ├── hello.cpp
    │   │   ├── hello.f90
    │   │   ├── mpi_hello.c
    │   │   ├── mpi_hello.cpp
    │   │   ├── mpi_hello.f90
    │   │   ├── test_curl.c
    │   │   ├── test_fontconfig.c
    │   │   ├── test_munge.c
    │   │   └── test_pmix.c
    │   ├── run-test-commandline-utils.sh
    │   ├── run-test-curl-devel.sh
    │   ├── run-test-env.sh
    │   ├── run-test-fontconfig-devel.sh
    │   ├── run-test-lmod.sh
    │   ├── run-test-mlnx-openmpi.sh
    │   ├── run-test-munge-devel.sh
    │   ├── run-test-os-gcc.sh
    │   ├── run-test-os-gfortran.sh
    │   ├── run-test-os-gxx.sh
    │   ├── run-test-pmix-devel.sh
    │   └── run-test-qt5.sh
    ├── README.md
    ├── slurm-mpi-tests
    │   ├── fixtures
    │   │   └── mpi_hello.c
    │   ├── run-test-slurm-mpicc.sh
    │   └── submit-mpi-tests.sh
    └── spack-tests
        ├── fixtures
        │   ├── color_hello.go
        │   ├── hello.c
        │   ├── hello.cpp
        │   ├── hello.f90
        │   ├── hello.go
        │   ├── HelloWorld.java
        │   ├── mpi_hello.c
        │   ├── mpi_hello.cpp
        │   ├── mpi_hello.f90
        │   ├── test_math.m
        │   ├── test_matlab_pkg.m
        │   └── test_parfor.m
        ├── run-test-spack-cc.sh
        ├── run-test-spack-mpicc.sh
        ├── run-test-spack-rt-golang.sh
        ├── run-test-spack-rt-matlab.sh
        ├── run-test-spack-rt-openjdk.sh
        ├── run-test-spack-rt-perl.sh
        ├── run-test-spack-rt-python.sh
        └── run-test-spack-rt-r.sh

Containerization Support
------------------------

Philosophy: Respect "Bare Metal First" experience, the containerization should be customized to mirror the host HPC environment as closely as possible.

General Config
""""""""""""""

.. code-block:: shell

    # Some system comes with very low default value, that would affect container launch
    # /etc/sysctl.d/99-containers.conf
    user.max_user_namespaces=2048920 # reference to RHEL9 default

Enroot / Pyxis
^^^^^^^^^^^^^^

Enable all GPU capabilitys inside container

.. code-block:: shell

    # /etc/enroot/environ.d/19-nvidia-all-caps.env
    NVIDIA_DRIVER_CAPABILITIES=all

    # /etc/enroot/hooks.d/98-nvidia.sh
    # https://github.com/nvidia/nvidia-container-runtime#nvidia_driver_capabilities
    if [ -z "${NVIDIA_DRIVER_CAPABILITIES-}" ]; then
        NVIDIA_DRIVER_CAPABILITIES="utility"
    fi
    for cap in ${NVIDIA_DRIVER_CAPABILITIES//,/ }; do
        case "${cap}" in
        all)
            cli_args+=("--compute" "--compat32" "--display" "--graphics" "--utility" "--video")
            break
            ;;
        compute | compat32 | display | graphics | utility | video)
            cli_args+=("--${cap}")
            ;;
        *)
            common::err "Unknown NVIDIA driver capability: ${cap}"
            ;;
        esac
    done

Automount auxillary host directories into container

.. code-block:: shell

    # /etc/enroot/mounts.d/20-mounts.conf
    /cm/local        /cm/local        none    x-create=dir,rbind,ro,nosuid,noexec,rslave         0   -1
    /cm/shared        /cm/shared        none    x-create=dir,rbind,ro,nosuid,noexec,rslave         0   -1
    # ... other network mounts etc
    # make sure nosuid,noexec are used for security

Apptainer
^^^^^^^^^
