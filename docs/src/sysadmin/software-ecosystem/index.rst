========================================
HPC Software Ecosystem
========================================

This document describes the software provisioning strategy for HPC and AI research environments, focusing on enabling researcher productivity through comprehensive, well-tested software infrastructure.

Effective software ecosystem design impacts researcher productivity. A well-provisioned environment enables researchers to begin computational work immediately, without spending days or weeks resolving dependency issues, compilation errors, or environment configuration problems.

Design Philosophy
=================

Software Provision Layers
--------------------------

Software can be provided at multiple levels, from base OS images to user-space package managers to containerized environments to user's own installation, each with trade-offs in flexibility, maintainability, and usability.

The ecosystem provides software at three tiers, each addressing different requirements:

**Tier 1: Base OS Software Stack**
  System-level software requiring root privileges or deep OS integration:
  
  - **Essential:** SLURM client, baseline GCC toolchain, X11 forwarding, GPU drivers, network fabric drivers
  - **Generic utilities:** GUI libraries (Qt, GTK), system tools (git, vim, atop, tmux, rsync), compression utilities (zip, gzip, xz, zstd)
  - **Developer tools:** Build systems (CMake, Make, Autotools), version control, module system (Lmod)

  These components are impractical to provision through user-space package managers for two reasons: (1) system integration requirements (SSH daemon configuration for X11, graphics stack for GUI libraries, etc.), or (2) operational friction - requiring ``module load rsync`` or ``module load vim`` for basic daily utilities would be unnecessarily cumbersome for researchers.

**Tier 2: Scientific Software Stack (Spack/Lmod)**
  Hierarchical module system addressing toolchain diversity and compatibility:
  
  - Multiple compiler toolchains (GCC, Intel oneAPI, AMD AOCC, NVIDIA HPC SDK)
  - MPI implementations with fabric-specific optimizations
  - Scientific libraries with architecture-specific builds
  - Domain-specific applications
  - Version management through Lmod hierarchy

**Tier 3: Container Support**
  Enable researchers to bring their own complete software environments:
  
  - GPU-accelerated containers (Enroot/Pyxis with SLURM integration)
  - Standard container runtimes (Apptainer/Singularity)
  - Host resource integration (GPUs, network fabric, shared storage)

Rationale: "Software-Libraries-as-a-Service"
---------------------------------------------

**Why centrally manage scientific software when users could install their own?**

This question merits careful consideration. Both approaches - centralized provisioning and user self-service - are viable, with the decision driven primarily by organizational factors: available expertise, support capacity, infrastructure scope, and institutional priorities.

Our experience with centralized software provisioning reveals both advantages and challenges:

**Advantages of shared software infrastructure:**

- **Encoded expertise:** Complex configurations (NUMA-aware MPI across RoCE fabric, compiler optimization flags, GPU-aware libraries) are tested and documented once, benefiting all researchers. Users access performant software without becoming networking specialists or compiler experts.

- **Collective bug resolution:** When issues are discovered and fixed, solutions propagate to all users automatically through module updates. Future users benefit from accumulated fixes without encountering known problems.

- **Reduced friction:** Empirically, many support requests resolve through "migrate to supported module system" or "use containerized environment" guidance. However, quantitative metrics demonstrating overall research productivity impact remain absent.

**Challenges of centralized provisioning:**

- **User collaboration dependency:** Researchers discover edge cases and compatibility issues through their workflows. The service requires ongoing user feedback to identify and address problems.

- **Sustained maintenance commitment:** Users must trust that the infrastructure team will persistently maintain software stacks, respond to issues, and acknowledge gaps in knowledge. This trust develops through demonstrated reliability over time. The service team does not always possess complete knowledge either - learning occurs through user feedback and iterative improvement.

- **Resource investment:** Maintaining diverse compiler/MPI combinations across architectures requires significant testing and maintenance effort. Not all organizations can justify this investment.

We observe that supported module systems and containers address most researcher software requirements in our environment, though we lack quantitative data demonstrating research productivity impact. Some support cases require expanding software coverage. The approach works for our organizational context but is not universally optimal - each site must evaluate based on their specific constraints and priorities.

Why Testing Matters
--------------------

HPC software complexity creates combinatorial configuration space: multiple architectures × multiple compilers × multiple MPI implementations × multiple library versions. Systematic testing identifies incompatibilities, configuration errors, and performance regressions before they impact research workflows.

Testing Strategy
================

Comprehensive testing spans three layers:

**Base OS validation**
  Verify system-level components function correctly: compilers compile, libraries link, MPI executes, GUI applications display, container runtimes launch. These tests run in isolated containers to validate image integrity before deployment.

**Scientific stack validation**
  Test compiler/MPI combinations with representative codes. Ensure library dependencies resolve correctly. Validate optimization flags produce functional binaries. These tests execute in actual cluster environments to detect integration issues.

**Production workflow validation**
  Submit jobs through SLURM with various compiler/MPI combinations on single and multiple nodes. Verify PMIx integration, network fabric utilization, and cross-node communication. These end-to-end tests surface issues that only manifest in production configurations.

The testing framework executes automatically when building new OS images or updating scientific software stacks, providing rapid feedback and preventing deployment of broken configurations.

Subtopics
=========

Detailed documentation for each ecosystem tier:

.. toctree::
   :maxdepth: 2

   os-software-stack
   scientific-software-stack
   container-support

Further References
==================

- :doc:`../k8s-hpc/index` - Automated build and testing infrastructure
- :doc:`../k8s-hpc/case-study-pxe-images` - OS image build automation
- :doc:`../k8s-hpc/case-study-spack-stack` - Scientific software build automation
- User documentation: https://hkust-hpc-docs.readthedocs.io/latest/software/
