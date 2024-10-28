.. _command-reference:

Command Reference
===============

Essential Commands
----------------
* :command:`srun` - Run interactive job
* :command:`sbatch` - Submit batch job
* :command:`squeue` - View job queue
* :command:`scancel` - Cancel job

Common Parameters
---------------
.. option:: --partition=<partition>
   Specify job partition

.. option:: --time=<time>
   Set time limit

.. option:: --nodes=<count>
   Request node count

Environment Variables
-------------------
.. envvar:: SLURM_JOBID
   Current job ID

.. envvar:: SLURM_SUBMIT_DIR
   Job submission directory