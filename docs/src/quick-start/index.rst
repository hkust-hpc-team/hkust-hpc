Quick Start
===========

Use this page as the main onboarding entry for new HPC4 users.

Background
----------

HPC4 is designed for CPU-intensive computational jobs and jobs requiring GPU coprocessor support.
It is open to all approved university researchers, while School of Science and Engineering users have higher access priority.

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
