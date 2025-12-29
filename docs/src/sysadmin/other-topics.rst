Other Administration Topics
===========================

NUMA Topology
-------------

- Machine should have balanced NUMA architecture, e.g. equal number of CPUs, memory, and GPUs per NUMA node. This can be verified with ``lstopo`` from the ``hwloc`` package.

- ``numactl -i all ./a.out`` should be used to launch memory-intensive applications to ensure memory is allocated from all NUMA nodes.

- In RoCEv2, the last-mile buffer transfer problem is solved by the kernel, unlike InfiniteBand that directly deliver to userspace buffer.
  Majority of MPI application benefit from leaving some cores onthe NIC's NUMA node idle, e.g. running only 248 out of 256 CPU with specific bindings.

  .. code-block:: bash

      function set_binding() {
        local ntasks_per_node=$(($SLURM_NTASKS_PER_NODE - $AMD_CCD))
        local ntasks=$(($SLURM_NNODES * $ntasks_per_node))
        local roce_core_start=0
        local roce_core_end=0

        # Reserve core for IB communication
        if [[ "$(hostname)" == *"himem"* ]]; then
          #! himem do not use core 64-71
          roce_core_start=64
          roce_core_end=71
        else
          #! amd do not use core 192-199
          roce_core_start=192
          roce_core_end=199
        fi
        if [[ $ntasks_per_node -lt $SLURM_NTASKS_PER_NODE ]]; then
          local cpu_bind="verbose,map_cpu:$(seq --sep=, 0 $(($roce_core_start - 1))),$(seq --sep=, $(($roce_core_end + 1)) 255)"
        else
          local cpu_bind="verbose,core"
        fi
        local mem_bind="verbose,local"
        export SRUN_NTASKS=$ntasks
        export SRUN_TASK_ARGS="--ntasks=$ntasks --ntasks-per-node=$ntasks_per_node --cpu-bind=$cpu_bind --mem-bind=$mem_bind"
        echo "SRUN_NTASKS: $SRUN_NTASKS"
        echo "SRUN_TASK_ARGS: $SRUN_TASK_ARGS"
      }


GPU-aware NUMA
^^^^^^^^^^^^^^

- SLURM should be tested to assign NUMA-aware CPU+GPU combinations to jobs.

Hardware Troubleshooting and Maintenance
-----------------------------------------

.. Lustre (DDN), internal NDA docs only

.. NVIDIA H800 GPUs, internal NDA docs only

RoCEv2 Networking
^^^^^^^^^^^^^^^^^^

Infiniband Networking
^^^^^^^^^^^^^^^^^^^^^^

.. todo: cable checking procedures

.. todo: ibdiagnet

Known Issues
-------------

RHEL 9: Binutils not compatible with Zen4 or newer
"""""""""""""""""""""""""""""""""""""""""""""""""""

- No workaround
- Rebuild GCC and binutils

RHEL 9: DMA Driver not available for Zen4 or newer
"""""""""""""""""""""""""""""""""""""""""""""""""""

- Fixed in RHEL 9.7

AOCC 5.0 Fortran Compiler does not read ``flang.cfg``
""""""""""""""""""""""""""""""""""""""""""""""""""""""

- Regression from AOCC 4.2
- No Workaround
- Ensure the detected GCC is fully functional (it may end up a partially installed, non-functional GCC in e.g. RHEL's ``gcc-toolset-12``).
