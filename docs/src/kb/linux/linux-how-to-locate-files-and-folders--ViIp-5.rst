How to locate files and folders on Linux systems
================================================

.. meta::
    :description: A guide to using find command to locate files and folders by name or modification time
    :keywords: linux, find, file search, find files, locate, modified time
    :author: kftse <kftse@ust.hk>

.. rst-class:: header

    | Last updated: 2025-10-20
    | keywords: linux, find, file search, find files, locate, modified time
    | *Solution under review*

Environment
-----------

    - Linux systems (Ubuntu, Rocky Linux, etc.)

Issue
-----

    - Missing files or folders on Linux systems
    - Find accidentally moved files or directories
    - Need to find recently modified files (e.g., files modified today or yesterday)

Resolution
----------

Basic file and directory search
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``find`` command is available on all Linux systems without additional installation. Basic syntax is: ``find [path] [options]``

Search for files or directories by name:

.. code-block:: shell-session

    $ # Search for files/directories named "report.txt" starting from current directory
    $ find . -name "report.txt"
    ./project/report.txt
    ./backup/report.txt
    
    $ # Search with wildcards (use quotes)
    $ find . -name "*report*"
    ./documents/annual_report.pdf
    ./reports/monthly_report_2024.xlsx
    ./backup/old_reports/
    
    $ # Case-insensitive search
    $ find . -iname "*report*"
    ./documents/annual_report.pdf
    ./reports/Monthly_Report_2024.xlsx
    ./files/REPORT.txt

.. note::
    The dot ``.`` means current directory. Use ``~`` to search from home directory, or ``/`` to search entire system (requires more time).

Search only files or only directories:

.. code-block:: shell-session

    $ # Search only files
    $ find . -type f -name "*report*"
    ./documents/annual_report.pdf
    ./reports/monthly_report_2024.xlsx
    
    $ # Search only directories
    $ find . -type d -name "*backup*"
    ./backup/old_reports/
    ./data/backup/
    
    $ # Search for a directory named "data"
    $ find . -type d -name "data"
    ./projects/data
    ./analysis/data
    ./archive/old_project/data

Search with file extensions:

.. code-block:: shell-session

    $ # Find all Python files
    $ find . -type f -name "*.py"
    ./scripts/process_data.py
    ./tools/helper.py
    
    $ # Find all PDF files
    $ find . -type f -name "*.pdf"
    ./documents/manual.pdf
    ./reports/summary.pdf

Finding recently modified files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Find files modified within a specific time period:

.. code-block:: shell-session

    $ # Files modified in the last 24 hours (today)
    $ find . -type f -mtime -1
    ./data/output.csv
    ./logs/application.log
    ./workspace/notes.txt
    
    $ # Files modified in the last 7 days
    $ find . -type f -mtime -7
    ./reports/weekly_summary.xlsx
    ./data/recent_analysis.csv
    
    $ # Files modified more than 30 days ago
    $ find . -type f -mtime +30
    ./archive/old_data.csv
    ./backup/legacy_files/document.txt

.. note::
    - ``-mtime -1`` means modified less than 1 day ago (within last 24 hours)
    - ``-mtime +30`` means modified more than 30 days ago
    - ``-mtime 7`` means modified exactly 7 days ago

For more precise time control (minutes):

.. code-block:: shell-session

    $ # Files modified in the last 60 minutes (1 hour)
    $ find . -type f -mmin -60
    ./logs/application.log
    
    $ # Files modified in the last 10 minutes
    $ find . -type f -mmin -10
    ./workspace/current_work.txt

Combining search criteria
~~~~~~~~~~~~~~~~~~~~~~~~~~

Combine name patterns with time filters:

.. code-block:: shell-session

    $ # Find PDF files modified in the last day
    $ find . -type f -name "*.pdf" -mtime -1
    ./reports/daily_report_2024-12-20.pdf
    
    $ # Find Python files in scripts directory modified in last week
    $ find ./scripts -type f -name "*.py" -mtime -7
    ./scripts/new_feature.py
    ./scripts/bugfix.py
    
    $ # Find log files older than 7 days
    $ find . -type f -name "*.log" -mtime +7
    ./logs/application.log.2024-12-01
    ./logs/access.log.old

Limit search depth:

.. code-block:: shell-session

    $ # Search only in current directory (not subdirectories)
    $ find . -maxdepth 1 -name "*report*"
    ./report.txt
    
    $ # Search only 2 levels deep
    $ find . -maxdepth 2 -type f -name "*.txt"
    ./notes.txt
    ./documents/readme.txt

Exclude specific directories:

.. code-block:: shell-session

    $ # Exclude .git and node_modules directories
    $ find . -type f -name "*report*" -not -path "*/node_modules/*" -not -path "*/.git/*"
    ./src/report_generator.py
    ./docs/report_template.md

Practical examples for finding missing files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Common scenarios for locating files:

.. code-block:: shell-session

    $ # Find all files modified today in home directory
    $ find ~ -type f -mtime -1
    
    $ # Find a file you worked on yesterday
    $ find ~ -type f -mtime -2 -name "*presentation*"
    
    $ # Find all Excel files in home directory
    $ find ~ -type f -name "*.xlsx" -o -name "*.xls"
    
    $ # Find large files (bigger than 100MB) modified this week
    $ find . -type f -size +100M -mtime -7
    
    $ # Find files owned by specific user
    $ find . -type f -user username

Root Cause
----------

Files may appear missing on Linux systems due to:

- Accidentally moved to different directory
- Saved with slightly different name than expected
- Located in unexpected subdirectory
- Hidden files (starting with dot ``.``)

The ``find`` command is a standard Unix tool that:

- Comes pre-installed on all Linux systems
- Recursively searches directory trees
- Supports complex search criteria
- Can perform actions on found files

While the syntax may seem complex initially, ``find`` is powerful and universally available, making it the most reliable tool for file search on Linux systems.

References
----------

- ``find`` manual: Use ``man find`` for complete documentation
- Common ``find`` examples: ``find --help``

.. rst-class:: footer

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: 2025-10-20
      | Issued by: kftse@ust.hk
