===============================
Kubernetes in HPC Environments
===============================

This guide describes a pragmatic approach to integrating Kubernetes (K8s) into existing HPC and AI computing environments. Unlike approaches that attempt to replace or deeply integrate with traditional HPC workload managers like SLURM, this method focuses on using K8s as a complementary DevOps automation platform that runs alongside your existing infrastructure.

**This represents an experimental initiative** - an exploration of how modern DevOps practices (CI/CD, GitOps, Infrastructure as Code) can be adapted to traditional HPC environments while minimizing risk to production operations.

The Problem: Managing HPC Software Lifecycle
=============================================

HPC system administrators face several recurring challenges:

**Time-Consuming Manual Processes**
  Building and testing new software stacks, compiling applications with different toolchains, and validating OS images often require hours of manual work on production or dedicated test systems.

**Risk of Production Disruption**
  Testing new software configurations or OS images on production systems risks breaking working environments. Creating isolated test environments manually is time-consuming and difficult to maintain.

**Limited Testing Coverage**
  Manual testing processes limit how thoroughly you can validate software before deploying to production. Many edge cases go untested due to time constraints.

**Poor Reproducibility**
  Manual build processes are hard to reproduce exactly. "It worked on my test node" scenarios are common when the same process fails differently on production systems.

**Lack of Modern DevOps Practices**
  Traditional HPC centers often lack CI/CD pipelines and GitOps practices. Most software builds are manual, configurations live in scattered scripts or admin knowledge, and "version control" means dated directory names.


Our Approach: K8s as a Low-Risk Learning Platform
==================================================

Our approach addresses these challenges by introducing GitOps and CI/CD practices to HPC systems in a measured, incremental way. 

Philosophy: "Do No Harm"
------------------------

Rather than replacing or tightly coupling with SLURM and other HPC workload managers, we deploy Kubernetes on dedicated nodes within the existing cluster to handle DevOps automation tasks. This approach:

- **Preserves existing HPC workflows** - SLURM jobs continue running exactly as before
- **Shares infrastructure** - K8s nodes use the same high-speed network and storage systems
- **Adds new capabilities** - Automated build/test pipelines without affecting production workloads
- **Minimizes risk** - K8s handles non-critical DevOps tasks only; if it fails, user workloads are unaffected
- **Enables learning** - Low-stakes environment to learn K8s and modern DevOps practices

What K8s Does in This Architecture
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Kubernetes excels at:

1. **Automated CI/CD Pipelines**
   
   - Automatically build software when source code changes
   - Run comprehensive test suites without manual intervention
   - Generate build reports and logs automatically

2. **Reproducible Build Environments**
   
   - Containerized builds ensure identical environments every time
   - No "works on my machine" problems
   - Easy to version and roll back build configurations

3. **Self-Service Infrastructure**
   
   - Developers can trigger builds without admin intervention
   - Container registry for sharing built images
   - Workflow engines (like Argo) for complex multi-step processes

4. **Resource Management**
   
   - Efficiently share build nodes among multiple projects
   - Automatic scheduling of build jobs
   - Handle long-running tasks in the background

The Architecture Boundary: K8s vs. Production
----------------------------------------------

Understanding the separation between K8s and production is critical to this approach's low-risk nature.

**K8s Side: The Build Factory**

- Runs CI/CD pipelines and automated builds
- Generates artifacts: compiled software, container images, OS images, test reports
- Delivers these artifacts to shared storage accessible by production nodes
- Think of it as your "software factory" or "build kitchen"

**Production Side: The Service Infrastructure**

- Runs SLURM and actual user workloads
- Hosts application binaries, containers, user data, and databases
- Consumes artifacts produced by K8s (reads from shared storage)
- This is where all critical work happens

**Critical Point: Zero Production Dependency on K8s**

The production cluster has **no runtime dependency** on K8s for day-to-day operations:

- If K8s cluster goes down, production continues running normally
- Users can still submit jobs, applications keep working, data remains accessible
- The only impact: new software builds/updates are delayed until K8s recovers
- Production never calls K8s APIs or depends on K8s services

This is fundamentally different from architectures where K8s manages the production workloads directly. Here, K8s is purely a build-time tool, not a runtime dependency.

The "Disposable K8s" Philosophy
---------------------------------

A key aspect of this approach is treating the K8s cluster as **disposable infrastructure**:

**What this means:**

- If something breaks badly and we can't figure it out → rebuild from scratch
- All K8s configuration lives in Git (Infrastructure as Code)
- Rebuilding takes 1-2 hours, not days
- No critical user data or production workloads live on K8s nodes
- Learning by rebuilding is a valid strategy

**Why this works:**

- Removes pressure to maintain "perfect" K8s operations
- Enables experimentation without fear
- Forces good practices (everything in Git, documented procedures)
- Makes disaster recovery straightforward

**Rebuilding K8s (when needed):**

1. Reinstall minimal OS on K8s nodes (30 min)
2. Run node preparation script (15 min)
3. Apply Ansible playbook to bootstrap RKE2 (30 min)
4. Deploy Helm charts to restore all services (30 min)

Total: ~2 hours to full recovery, and production was never affected.


What We Learned: Key Insights
==============================

This experimental initiative has yielded several valuable insights about adapting modern DevOps practices to HPC environments.

Streamlining Operations
------------------------

**Deterministic and reproducible builds**
  Traditional HPC builds face several challenges: full compute nodes (256 cores) allocated for builds that use only 16 cores; software builds on compute nodes risk "pollution" from previous runs or ad-hoc installations; GPU-dependent builds require physical GPU nodes, limiting flexibility; parallel builds across nodes require ad-hoc file locking mechanisms prone to race conditions. Kubernetes workflows address these through containerized builds where each step runs from a specified container image, ensuring deterministic starting state. This eliminates "works on my machine" problems and enables cross-compilation capabilities (e.g., CUDA builds without requiring GPU hardware).

**Isolation with right-sized resource allocation**
  Kubernetes enables precise resource allocation (e.g., 16 cores per build instance) rather than over-provisioning full compute nodes. Isolated storage via Persistent Volume Claims prevents build interference between concurrent workflows. Native parallelization through independent workflow steps (pods) eliminates custom locking mechanisms. Together, deterministic builds and efficient parallelization enable more frequent software updates - not because individual builds are faster, but because validation becomes reliable and debugging time decreases significantly.

Introducing GitOps and CI/CD to HPC Operations
-----------------------------------------------

**Infrastructure as Code and CI/CD patterns**
  Maintaining K8s configurations, workflows, and build scripts in version control provides a single source of truth. Configuration changes become traceable through Git history, improving accountability and debugging capabilities. The fundamental CI/CD pattern of "commit triggers build → run tests → deploy artifact" applies equally well to OS images and software stacks as it does to web applications. Declarative workflows encode procedural knowledge that traditionally existed as informal instructions, improving knowledge transfer and onboarding.

**Knowledge captured in code and test cases**
  Automated tests catch common configuration errors (missing package dependencies, broken symbolic links, path misconfigurations) immediately. Resolved failures become codified as test cases - over time, the test suite evolves into institutional knowledge, a catalog of failure modes and their detection mechanisms. Procedural knowledge traditionally maintained as checklists ("remember to check X", "don't forget to configure Y") transforms into automated validation steps, reducing cognitive load and ensuring consistent execution.

**Key insight:** Selective adoption of DevOps practices is viable. Organizations can apply CI/CD concepts to specific HPC administrative tasks without comprehensive infrastructure redesign or cultural transformation.

Developing K8s Operational Expertise
-------------------------------------

**Low-risk experimentation environment**
  Kubernetes documentation can be overwhelming for newcomers. Building actual workflows, even simple ones, provides concrete understanding of core concepts like pods, services, persistent volumes, and namespaces. Configuration errors in this architecture don't impact production workloads, enabling methodical investigation of problems, experimental fixes, and thorough documentation without pressure. The low-stakes nature of this implementation pattern facilitated broader team adoption - staff members initially hesitant about Kubernetes became more comfortable through exposure to a system explicitly positioned as non-critical infrastructure.

**Rapid iteration through disposability**
  When troubleshooting becomes protracted, rebuilding the K8s cluster from scratch (1-2 hours via Infrastructure as Code) often proves more educational than extended debugging sessions. This approach is viable specifically because K8s manages non-critical build infrastructure. All configuration lives in Git, making rebuilding mechanical rather than requiring creative problem-solving. This "disposable infrastructure" philosophy removes pressure to maintain "perfect" operations and enables fearless experimentation.


Is This Approach Right for You?
================================

This approach is well-suited for:
----------------------------------

✅ **Medium to large HPC centers** with diverse software stacks requiring regular updates

✅ **Sites building custom software** or maintaining multiple application versions

✅ **Teams interested in learning modern DevOps practices** in a low-risk environment

✅ **Centers with spare compute capacity** to dedicate 3-5 nodes to K8s infrastructure

✅ **Teams willing to invest time in learning** - initial setup and learning curve is significant

✅ **Organizations comfortable with experimental approaches** that evolve over time

This approach may NOT be suitable if:
-------------------------------------

❌ **Very limited node count** - Cannot spare even 3 nodes for K8s cluster

❌ **Single-purpose clusters** - Running only 2-3 specific applications that rarely change

❌ **No automation needs** - Manual processes work fine for your workload

❌ **Resource constraints** - Every node must run user jobs; no capacity for infrastructure

❌ **Need production-ready solution immediately** - This is a learning project, not turnkey

❌ **Risk-averse culture** - Not comfortable with experimental approaches

**Assessment framework:** This approach suits organizations seeking to explore modern DevOps practices with manageable risk, available infrastructure capacity (3-5 nodes), and tolerance for experimentation. Organizations requiring immediate operational improvements or lacking capacity for learning investment should consider alternative solutions or defer adoption until circumstances align better.


Real-World Applications
=======================

Two detailed case studies demonstrate this approach in production environments:

.. toctree::
   :maxdepth: 1

   case-study-pxe-images
   case-study-spack-stack

These case studies present realistic implementation experiences - successful patterns, ongoing challenges, and practical lessons learned.


Getting Started
===============

Ready to experiment with this approach? See our getting started guide:

.. toctree::
   :maxdepth: 1

   getting-started

This guide covers the practical steps from bare metal OS installation through deploying your first Argo workflow.


Further Reading
===============

- :doc:`../software-ecosystem` - Understanding hierarchical module systems with Spack
- Rancher RKE2 documentation: https://docs.rke2.io/
- Argo Workflows documentation: https://argoproj.github.io/workflows/
- GitOps principles: https://opengitops.dev/
