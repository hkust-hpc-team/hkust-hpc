Testing and Tracing
===================

Hardware Validation
-------------------

/proc/cpuinfo
/proc/meminfo
lspci -vvvt
lstopo
nvidia-smi topo -m
ibnetdiscover

Fault Tolerance / HA Testing
----------------------------

Most worker nodes are not designed to be HA/FT, still there would be several stateful HA/FT-ed components such as management node, storage appliances and IB subnet manager.

Example Test Plan
^^^^^^^^^^^^^^^^^

.. TODO: Get DDN Test Plan

Performance Testing
-------------------

These serves several purposes
- assert end-to-end integration of user environment
- validate end-to-end performance with provisioned software stacks and libraries
- provide performance reference for later regression testing

Bottom line: Always use real environment, do NOT go via any power-user features; If there is SLURM, use SLURM scheduler to run the workload; If there is container, use the container system

SPEC CPU 2017
^^^^^^^^^^^^^

CPU application benchmarks

STREAM
^^^^^^

Test for memory bandwidth

NCCL
^^^^

All-reduce, All-to-all

IMB-MPI1
^^^^^^^^

Test all communication patterns, e.g. Exchange, All-reduce, All-to-all, Bcast, Barrier
Look for anomaly like jumpy / inconsistent results

MPI-IO
^^^^^^

Test for Parallel File System IO

HPL/HPL-AI / HPCG
^^^^^^^^^^^^^^^^^

Generic raw performance test

MLPerf
^^^^^^

AI/ML workload oriented testing covering mostly LLM

SPEChpc-2021
^^^^^^^^^^^^

HPC workload oriented testing covering technologies such as MPI, OMP, OpenACC, OpenMP-offload

.. TODO: Show our CPU/GPU results

Regression Testing
------------------

Feature regression vs performance regression

Image Testing
^^^^^^^^^^^^^

- Have a test when adding features
- Learn from mistake: Convert known regression into tests

Performance Check
^^^^^^^^^^^^^^^^^

Carry out some of previous tests and compare to known figures after major subsystem changes / maintenance, driver update etc, figures are usually obviously wrong if there is a regression.

Diagnostic Testing
------------------

DCGMI
^^^^^

Nvidia Datacenter GPU specific diagnostics

NVSM Stress
^^^^^^^^^^^

CPU, Memory, GPU stress test for Nvidia DGX systems

FIO
^^^

Simple tests for local/network file system

Stress-NG
^^^^^^^^^

Local subsystem stress test

RDMA-RW
^^^^^^^

For RDMA network traffic

iperf
^^^^^

For TCP traffic

Monitoring
----------

Prometheus Exporters
^^^^^^^^^^^^^^^^^^^^

Logging
-------

Logging is not monitoring, diagnostic / debug tool vs overview tool.

Config persistent logging
^^^^^^^^^^^^^^^^^^^^^^^^^

Useful logs are those which survive a crash.

Atop Service
^^^^^^^^^^^^

Offers system overview backtracking at 10-min intervals, providing useful investigative directions. Use case scenario: Before the crash
- What likely happened?
- What are the loads of NFS, Network, CPU, Local Disk, Memory Usage?
- Is there any program potentially causing a crash?

Kernel lockup traces
^^^^^^^^^^^^^^^^^^^^

Useful when debugging system issues


Userspace Tracing
-----------------

Researchers need tools to understand why their program doesn't work.

CPU Hardware Profilier
^^^^^^^^^^^^^^^^^^^^^^

System: sysctl kernel.perf_event_paranoid

perf + flamegraph.pl

User coredump
^^^^^^^^^^^^^^

System: set a non-zero coredump size

User can retrieve stack trace when program faulted, and analyse the line of fault.

Nvidia Nsight
^^^^^^^^^^^^^

System: nvreg thing

Use nsys

MPI stack trace
^^^^^^^^^^^^^^^

Some MPI offers lockup stacktrace, e.g. if a call locked up for 30s, cause all ranks to traceback.

.. TODO: OpenMPI example

LLM as trace analysis tool
--------------------------

The stack is complicated, commercial LLMs were likely fed with vast amount of low level library source code, it is surprisingly accurate at providing solution / workaround if an appropriate stack trace is given.
