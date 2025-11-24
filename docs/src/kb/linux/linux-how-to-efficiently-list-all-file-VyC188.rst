How to efficiently list all files recursively on Linux
======================================================

.. meta::
    :description: A guide to using fd command for fast recursive file listing and searching on Linux HPC clusters
    :keywords: linux, fd, fd-find, file search, recursive listing, find alternative, HPC
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2024-12-20
    | keywords: linux, fd, fd-find, file search, recursive listing, find alternative, HPC
    | *Solution under review*

Environment
-----------

    - Linux HPC Cluster
    - ``fd`` command (available as ``fd-find`` on Ubuntu-based systems)

Issue
-----

    - Need to list all files recursively in large directory structures
    - Traditional ``ls -R`` is slow and produces cluttered output
    - ``find`` command has complex syntax and can be slow on large filesystems
    - Need to quickly search for files by name, extension, or other attributes in HPC environments

Resolution
----------

Basic recursive file listing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``fd`` command provides a fast, user-friendly alternative to ``find`` with simpler syntax and parallel execution.

List all files recursively:

.. code-block:: shell-session

    $ # List all files in current directory and subdirectories
    $ fd
    scripts/process_data.py
    scripts/analyze.R
    data/input.csv
    data/results/output.txt
    logs/job_12345.log
    
    $ # List all files with full paths
    $ fd --absolute-path
    /home/username/project/scripts/process_data.py
    /home/username/project/data/input.csv

.. note::
    By default, ``fd`` automatically excludes hidden files and respects ``.gitignore`` patterns, making output cleaner than ``find``.

Search for files by name
~~~~~~~~~~~~~~~~~~~~~~~~~

Simple pattern matching:

.. code-block:: shell-session

    $ # Find files containing "data" in the name
    $ fd data
    scripts/process_data.py
    data/input.csv
    backup/old_data.tar.gz
    
    $ # Case-insensitive search
    $ fd -i DATA
    scripts/process_data.py
    analysis/DATA_2024.xlsx
    
    $ # Exact filename match
    $ fd --glob "results.txt"
    output/results.txt
    analysis/final/results.txt

Search by file extension:

.. code-block:: shell-session

    $ # Find all Python files
    $ fd -e py
    scripts/process_data.py
    scripts/analyze_results.py
    tools/helper.py
    
    $ # Find all CSV and TSV data files
    $ fd -e csv -e tsv
    data/input.csv
    data/sample.tsv
    results/output.csv
    
    $ # Find all log files
    $ fd -e log
    logs/slurm-12345.log
    logs/application.log

Search only files or only directories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Filter by file type:

.. code-block:: shell-session

    $ # List only regular files
    $ fd -t f
    scripts/process_data.py
    data/input.csv
    
    $ # List only directories
    $ fd -t d
    scripts/
    data/
    results/
    logs/
    
    $ # Find directories named "output"
    $ fd -t d output
    analysis/output/
    results/output/
    backup/2024/output/

Search with depth control
~~~~~~~~~~~~~~~~~~~~~~~~~~

Limit search depth for better performance:

.. code-block:: shell-session

    $ # List files only in current directory (depth 1)
    $ fd -d 1
    README.md
    setup.sh
    
    $ # Search up to 2 levels deep
    $ fd -d 2 -e py
    scripts/main.py
    tools/helper.py
    
    $ # Find all data files within 3 directory levels
    $ fd -d 3 -e csv -e dat
    data/input.csv
    data/2024/sample.csv
    analysis/raw/measurements.dat

Include hidden files and ignore patterns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Control what files to include:

.. code-block:: shell-session

    $ # Include hidden files (starting with .)
    $ fd -H config
    .config/settings.ini
    scripts/.config.json
    
    $ # Show all files including ignored ones
    $ fd -I -e tmp
    cache/temp.tmp
    build/output.tmp
    
    $ # Exclude specific directories
    $ fd -E node_modules -E __pycache__ -e py
    scripts/main.py
    analysis/process.py

Finding files by modification time
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Search based on when files were modified:

.. code-block:: shell-session

    $ # Files changed in the last 24 hours
    $ fd --changed-within 24h
    results/latest_output.txt
    logs/job_today.log
    
    $ # Files changed in the last week
    $ fd --changed-within 7d -e py
    scripts/new_analysis.py
    
    $ # Files older than 30 days
    $ fd --changed-before 30d -e log
    logs/old_job.log
    archive/2024-11/results.log

.. note::
    Time units: ``s`` (seconds), ``m`` (minutes), ``h`` (hours), ``d`` (days), ``w`` (weeks)

Executing commands on found files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Perform operations on search results:

.. code-block:: shell-session

    $ # Count lines in all Python files
    $ fd -e py -x wc -l
    234 scripts/process_data.py
    156 scripts/analyze.py
    89 tools/helper.py
    
    $ # Copy all CSV files to backup directory
    $ fd -e csv -x cp {} backup/
    
    $ # Compress all log files older than 7 days
    $ fd -e log --changed-before 7d -x gzip {}
    
    $ # Show detailed info for recently modified files
    $ fd --changed-within 1d -x ls -lh
    -rw-r--r-- 1 username users 2.3M Dec 20 14:30 results/output.csv
    -rw-r--r-- 1 username users  156K Dec 20 15:45 logs/job.log

Practical HPC examples
~~~~~~~~~~~~~~~~~~~~~~

Common use cases on HPC clusters:

.. code-block:: shell-session

    $ # Find all SLURM output files
    $ fd 'slurm-*.out'
    jobs/slurm-12345.out
    jobs/slurm-12346.out
    
    $ # Find all checkpoint files
    $ fd -e ckpt -e chk
    checkpoints/model_epoch10.ckpt
    results/simulation.chk
    
    $ # Find large output files (>100MB) modified this week
    $ fd --changed-within 7d --size +100m
    results/simulation_output.dat
    data/processed/large_dataset.hdf5
    
    $ # List all job scripts in home directory
    $ fd -e sh -e pbs -e slurm ~
    /home/username/jobs/run_analysis.sh
    /home/username/scripts/submit.slurm
    
    $ # Find all files owned by you in scratch directory
    $ fd . /scratch/username -t f
    
    $ # Clean up temporary files older than 30 days
    $ fd -e tmp -e temp --changed-before 30d -x rm {}

Performance comparison
~~~~~~~~~~~~~~~~~~~~~~

Compare ``fd`` with traditional commands:

.. code-block:: shell-session

    $ # Traditional approach (slower)
    $ time find . -name "*.py"
    real    0m2.450s
    
    $ # Using fd (faster with parallel execution)
    $ time fd -e py
    real    0m0.124s

.. note::
    ``fd`` is significantly faster than ``find`` on large directory trees due to parallel traversal and optimized algorithms. This is especially noticeable on HPC filesystems with millions of files.

Root Cause
----------

Traditional file listing commands have limitations:

- ``ls -R`` produces verbose output and is slow on large directories
- ``find`` has complex syntax that is hard to remember (e.g., ``-name``, ``-type``, ``-mtime``)
- ``find`` performs sequential directory traversal, which is slow on large filesystems
- No built-in filtering for version control files or common ignore patterns

The ``fd`` command addresses these issues by:

- Using simpler, more intuitive syntax with sensible defaults
- Executing parallel directory traversal for better performance
- Automatically respecting ``.gitignore`` patterns
- Providing colored output for better readability
- Supporting human-readable time specifications
- Offering regex support by default (no need for complex glob patterns)

References
----------

- ``fd`` official repository: https://github.com/sharkdp/fd
- ``fd`` user guide: https://github.com/sharkdp/fd#tutorial
- Command help: ``fd --help`` or ``man fd``

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2024-12-20
      | Issued by: kftse@ust.hk
