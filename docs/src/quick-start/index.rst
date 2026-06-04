Quick Start
===========

.. meta::
    :description: Quick-start onboarding path for new HPC4 users covering access, storage, software setup, and first SLURM jobs.
    :keywords: HPC4, quick start, onboarding, SLURM, software environment, storage

.. rst-class:: header

    | Last updated: 2026-06-04

Use this page as the main onboarding entry for new HPC4 users.
If you received a welcome email with your initial credentials,
keep that email handy as you follow this guide.

.. _understanding-the-cluster:

Understanding the Cluster
--------------------------

What is an HPC cluster?
~~~~~~~~~~~~~~~~~~~~~~~

A cluster is many computers (*nodes*) connected by a high-speed network
and managed as a single shared system.  Hundreds of people use it at the
same time.  HPC4 provides:

- **Login nodes** — where you land when you SSH in.  Shared by everyone.
  Use them only for editing files, light compiling, submitting jobs, and
  transferring data.  **Do not run heavy computations on login nodes** —
  they will be killed by the system administrators.

- **Compute nodes** — the machines that actually run your work.  They
  come in CPU-only and GPU-equipped variants.  You never SSH directly to
  them; instead you submit jobs to the scheduler.

The HPC4 scheduler: Slurm
~~~~~~~~~~~~~~~~~~~~~~~~~

Slurm is the software that manages access to compute nodes.  Think of it as a
restaurant host:

- You tell Slurm what resources you need (CPUs, memory, time, GPUs)
  by writing a *batch script*.
- Slurm puts your job in a queue and starts it when resources are free.
- Requesting **more** resources than you need will make you wait **longer**.
  Start small, measure, then scale up.

Slurm also enforces fair sharing: no single user can monopolise the cluster.

Cluster vs your laptop
~~~~~~~~~~~~~~~~~~~~~~

+----------------------+----------------------+-----------------------------+
|                      | Your laptop          | HPC4 cluster                |
+======================+======================+=============================+
| Who uses it          | You alone            | Shared by hundreds of users |
+----------------------+----------------------+-----------------------------+
| Starting work        | Open a terminal      | Submit a job via ``sbatch`` |
+----------------------+----------------------+-----------------------------+
| Getting results      | Immediately          | After the job runs (queued) |
+----------------------+----------------------+-----------------------------+
| Software             | Install anything     | Load via ``module`` commands|
+----------------------+----------------------+-----------------------------+
| File system          | Local SSD            | Network-mounted (NFS)       |
+----------------------+----------------------+-----------------------------+
| GPUs                 | Usually 0–1          | Many, shared via scheduler  |
+----------------------+----------------------+-----------------------------+

Use the pages below as the main onboarding path.
Each item includes a short description so readers can decide where to start.

.. toctree::
    :hidden:
    :maxdepth: 1
    :titlesonly:

    access-and-authentication
    data-and-storage
    software-environment
    first-job-template
    job-submission

.. grid:: 1 2 2 2
    :gutter: 2

    .. grid-item-card:: Access and Authentication
        :link: access-and-authentication
        :link-type: doc

        Start here if you need the login host, authentication flow, VPN expectations, or a quick check that your account access is ready.

    .. grid-item-card:: Data and Storage
        :link: data-and-storage
        :link-type: doc

        Use this page to understand where to store files on HPC4, what each path is for, and how to move data in and out safely.

    .. grid-item-card:: Software Environment
        :link: software-environment
        :link-type: doc

        Read this when you need Python, compilers, MPI, or module commands, and want a practical starting point for the HPC4 software stack.

    .. grid-item-card:: Submit Your First HPC4 Job
        :link: first-job-template
        :link-type: doc

        Follow this path for the shortest first success: create one small batch script, submit it, and confirm that it runs on a compute node.

    .. grid-item-card:: More Job Submission Patterns
        :link: job-submission
        :link-type: doc

        Continue here after the first batch job works and you need GPU, MPI, interactive ``srun``, or job-control commands such as ``squeue`` and ``scancel``.
