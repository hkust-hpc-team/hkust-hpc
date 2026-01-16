================================
Container Support
================================

Container technologies enable portable, reproducible computational workflows while integrating seamlessly with HPC cluster infrastructure. The container strategy respects "bare metal first" philosophy - containers mirror host environments rather than replacing them.

Host Environment Parity
========================

Containers in HPC contexts serve different purposes than in cloud-native environments:

**Host-integrated design**
  Containers access host-provided software stacks (Spack modules), GPUs, high-speed interconnects, and shared storage. They augment rather than isolate from cluster capabilities.

**Bare metal first principle**
  Most workloads execute directly on nodes using Lmod modules. Containers address specific use cases: software portability, dependency isolation, workflow reproducibility, and complex application packaging.

**Environmental transparency**
  Container configuration mirrors host environment conventions. Module systems, network mounts, and GPU access function identically inside and outside containers.

  **Note:** Environmental transparency requires deliberate configuration—it doesn't come automatically with container runtime installation. Achieving seamless integration demands careful setup of mount points, device passthrough, UID/GID mapping, and consideration of base image compatibility (glibc versions, kernel requirements). Simply installing Apptainer doesn't guarantee that arbitrary containers (e.g., CentOS 5 images on Ubuntu 24.04 hosts) will function correctly without additional configuration work.

Container Technologies
======================

Enroot and Pyxis
----------------

NVIDIA Enroot provides unprivileged container execution with GPU awareness, integrated with SLURM via Pyxis.

**Key capabilities:**
  - Unprivileged operation (no root daemon)
  - Native GPU access (full CUDA capabilities)
  - SLURM integration via Pyxis plugin
  - OCI image compatibility
  - Minimal overhead

**Use cases:**
  - GPU-accelerated workloads requiring specific CUDA versions
  - Deep learning frameworks with complex dependencies
  - Multi-node parallel applications in containers
  - Reproducible computational environments

Apptainer (formerly Singularity)
---------------------------------

Apptainer provides OCI-compatible container runtime emphasizing HPC integration:

**Key capabilities:**
  - Unprivileged execution (no setuid required in recent versions)
  - MPI integration (host MPI can interact with container MPI)
  - GPU support (via ``--nv`` flag)
  - Bind mount flexibility
  - HPC-specific design

**Use cases:**
  - Legacy Singularity workflows
  - MPI applications requiring host fabric integration
  - Software distribution and archiving
  - Multi-tenant environments requiring isolation

Container Configuration
========================

System-Level Settings
---------------------

**User namespace limits:**

Increase default limits to support concurrent container launches:

.. code-block:: shell

   # /etc/sysctl.d/99-containers.conf
   user.max_user_namespaces=2048920  # RHEL9 default, adjust as needed

This prevents "no space left on device" errors when many users launch containers simultaneously.

Enroot Configuration
--------------------

**Enable full GPU capabilities:**

.. code-block:: shell

   # /etc/enroot/environ.d/19-nvidia-all-caps.env
   NVIDIA_DRIVER_CAPABILITIES=all

This environment variable ensures containers access all NVIDIA driver capabilities (compute, graphics, video, utility).

**GPU capability enforcement hook:**

.. code-block:: shell

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

This hook translates ``NVIDIA_DRIVER_CAPABILITIES`` into enroot's internal flags, ensuring requested GPU features are available.

**Auto-mount host directories:**

.. code-block:: shell

   # /etc/enroot/mounts.d/20-mounts.conf
   /cm/local        /cm/local        none  x-create=dir,rbind,ro,nosuid,noexec,rslave  0  -1
   /cm/shared       /cm/shared       none  x-create=dir,rbind,ro,nosuid,noexec,rslave  0  -1
   /opt/shared      /opt/shared      none  x-create=dir,rbind,ro,nosuid,noexec,rslave  0  -1
   /data            /data            none  x-create=dir,rbind,rw,nosuid,noexec,rslave  0  -1
   
   # Security: nosuid prevents setuid execution, noexec blocks direct execution
   # rslave ensures mount propagation works correctly

**Rationale:**
  - Researchers access Spack modules from ``/opt/shared`` inside containers
  - Shared data directories (``/data``, ``/scratch``) remain accessible
  - ``nosuid,noexec`` prevent security issues with mounted filesystems
  - Read-only mounts for system directories prevent accidental modification

Apptainer Configuration
-----------------------

**Bind mount configuration:**

.. code-block:: shell

   # /etc/apptainer/apptainer.conf
   bind path = /cm/local
   bind path = /cm/shared
   bind path = /opt/shared
   bind path = /data
   bind path = /scratch

**User namespace settings:**

.. code-block:: shell

   # Enable unprivileged user namespaces
   allow setuid = no        # Modern Apptainer doesn't require setuid
   max loop devices = 256   # Support multiple simultaneous containers

Pyxis Integration with SLURM
==============================

Pyxis enables native container execution through SLURM job scripts.

Configuration
-------------

**SLURM integration:**

.. code-block:: shell

   # /etc/slurm/plugstack.conf
   required /usr/local/lib/slurm/spank_pyxis.so

**Pyxis settings:**

.. code-block:: text

   # /etc/pyxis/pyxis.conf
   {
       "runtime": "enroot",
       "cache_dir": "/tmp/enroot_cache",
       "enroot_path": "/usr/bin/enroot"
   }

Conclusion
==========

Container support extends HPC capabilities while maintaining host environment integration. Enroot/Pyxis and Apptainer provide complementary technologies serving different use cases. Configuration emphasizing host parity ensures containers augment rather than complicate researcher workflows. Proper implementation balances portability, reproducibility, performance, and security.

Related Documentation
=====================

- :doc:`os-software-stack` - Base system software foundation
- :doc:`scientific-software-stack` - Spack/Lmod module system
- :doc:`../k8s-hpc/index` - Automated build and testing infrastructure
