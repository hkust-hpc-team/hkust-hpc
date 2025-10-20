# Workshops

Here are slides to workshops conducted by the HKUST HPC Team.

## Beginner to Intermediate Level

### **Unleashing AI and HPC: Exploring SuperPod, HPC4, and Scalable Systems** (Oct 2, 2025)

**Keywords**: SLURM, HPC Architecture, AI Infrastructure, SuperPod, Git, SSH, IDE, LLM, Fat Tree Network, RDMA, InfiniBand, NUMA, Parallel File System, Lustre, Containers, Docker, Apptainer, Enroot, Monitoring, Debugging, `nvidia-smi`, GDB, NCCL

**Slides**: https://github.com/hkust-hpc-team/hkust-hpc/blob/main/workshops/20251002-ai-hpc-systems/ai-hpc-systems.pdf

**Contents**

- **AI/HPC Survival Kit: 4 Steps for Researchers**
  - **[Paid]** Using an Intelligent IDE with LLM Integration (e.g., VS Code + Copilot, Cursor).
  - **[Free]** Setting up password-less SSH key authentication to save time.
  - **[Free]** Getting familiar with Git for version control and development.
  - **[Free]** Using SLURM "The Modern Way" by specifying resources explicitly (e.g., `--gpus-per-node`, `--cpus-per-task`) to avoid ambiguity and ensure performance.
- **Introduction to AI/HPC System Architectures**
  - **Fat Tree Network & RDMA**: Understanding the 1:1 non-blocking network topology and the role of RDMA (InfiniBand, RoCEv2). Best practice is to use established async libraries like `torch.distributed`, MPI, and NCCL.
  - **NUMA Domains & Hardware Locality**: How intra-node components (CPU, GPU, NICs) are connected and why keeping work within a local NUMA domain is critical for performance.
  - **GPU Computing**: The core principle of "thinking in parallel" by programming with matrix operations rather than imperative loops.
  - **Parallel File Systems**: Contrasting local filesystems with parallel ones (Lustre, Ceph) and the importance of aggregating small files into large data blocks (e.g., JSONL, WebDataset, HDF5, npz) to maximize I/O performance.
- **Containerization for AI/HPC Workloads**
  - **Docker Inner Workings**: A brief on how Docker uses OverlayFS and a root-privileged daemon.
  - **Why Docker is Not Ideal for HPC**: Discussing the incompatibility with schedulers, poor performance with many small files, and security issues related to root access.
  - **HPC Container Alternatives**: How HPC containers (e.g., Apptainer, Enroot) work by squashing images (SquashFS/SIF), running in user-space (rootless), and integrating with schedulers and high-performance hardware.
- **Monitoring and Debugging AI/HPC Workloads**
  - **Scaling Job Monitoring**: Using `nvidia-smi dmon` to monitor the three main indicators of GPU health: Utilization (sm%), Power Consumption (pwr), and PCI-e Throughput (rxpci/txpci).
  - **Correlating Distributed Logging**: The importance of including timestamps and hostnames in logs to make sense of output from multi-node jobs.
  - **Built-in Tracing in Frameworks**: Using environment variables like `NCCL_DEBUG` and `UCX_LOG_LEVEL` to diagnose framework-level issues, especially during initialization.
  - **Debugging with GDB**: A workflow for analyzing "Segmentation Fault" errors by compiling with debug flags (`-g`), enabling coredumps, and using GDB to inspect the program state at the time of the crash.

### **Scaling Deep Learning Pipelines on H800 GPU Clusters** (Nov 19, 2024)  

**Keywords**: Deep Learning, MLOps, Data Pipeline, H800, Data Acquisition, HuggingFace, Git LFS, Data Transfer, Data Preprocessing, Python, `multiprocessing`, Data Loading, Scale-out Training, Monitoring, `nvidia-smi`, Checkpointing, SLURM

**Slides**: https://github.com/hkust-hpc-team/hkust-hpc/blob/main/workshops/20241119-scaling-dl-pipeline/scaling-dl-on-h800.pdf

**Contents**

- **Data Acquisition**
  - Pitfalls and advice for downloading large datasets (e.g., from HuggingFace, Git LFS, URL lists).
  - Best practices for resuming downloads, checksum verification, and being a considerate user of shared network resources.
  - Recipes for downloading from HuggingFace, Git LFS, and parallel downloads from a list of URLs using `xargs`.
- **Data Transfer**
  - Standard workflows for data ingress/egress, comparing on-campus network transfers vs. on-site disk transfers.
  - A decision flowchart and bandwidth conversion table to help choose the best transfer method.
  - Recipes for high-performance parallel file operations to replace standard commands like `ls`, `cp`, and `rm`.
- **Data Preprocessing**
  - Common pitfalls and suggestions for large-scale batch preprocessing, including handling broken data and estimating completion time.
  - A sample Python workflow demonstrating how to parallelize a preprocessing task using the `multiprocessing` library.
- **Data Loading**
  - How to perform a smoke test to identify data loading bottlenecks.
  - Best practices for proper data sizing to maintain sustainable IO bandwidth from storage to the training nodes.
- **Monitoring and Debugging Scale-out Training**
  - Key indicators for effective GPU utilization: utilization percentage, power consumption, and PCI-e bandwidth.
  - A simple recipe to monitor GPU stats (`nvidia-smi dmon`) during a SLURM job and interpret the output.
  - Debugging techniques for multi-node training issues, including using environment variables like `NCCL_DEBUG`.
- **Checkpointing Techniques**
  - A flowchart for determining a checkpointing strategy based on model size, frequency, and storage tiers (T1 vs. T2).
  - How to estimate checkpoint size and time, and optimization strategies like sharded checkpointing.
  - A Python code snippet for handling SLURM job timeouts gracefully to save a final checkpoint.
