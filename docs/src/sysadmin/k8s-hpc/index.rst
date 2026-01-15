===============================
Kubernetes in HPC Environments
===============================

Introduction
============

This guide describes a pragmatic, experimental approach to integrating Kubernetes (K8s) into existing HPC and AI computing environments. Unlike approaches that attempt to replace or deeply integrate with traditional HPC workload managers like SLURM, this method focuses on using K8s as a complementary DevOps automation platform that runs alongside your existing infrastructure.

**This is fundamentally a learning project** - an experiment in bringing modern DevOps practices (CI/CD, GitOps, Infrastructure as Code) to traditional HPC environments while minimizing risk to production operations.

The Problem: Managing HPC Software Lifecycle
---------------------------------------------

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A key aspect of our approach is treating the K8s cluster as **disposable infrastructure**:

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

This learning project has taught us several valuable lessons about bringing modern DevOps practices to HPC environments.

Learning GitOps and CI/CD in HPC Context
-----------------------------------------

**Infrastructure as Code works for HPC**
  Storing all K8s configs, workflows, and build scripts in Git provides a single source of truth. When something breaks, we can see what changed.

**CI/CD concepts translate to HPC tasks**
  The idea of "commit triggers build → run tests → deploy artifact" applies to OS images and software stacks, not just web applications.

**Declarative configuration reduces tribal knowledge**
  Instead of "SSH to the build node and run these commands," workflows document the entire process. New team members can understand what happens without asking.

**GitOps for reproducibility**
  Rebuilding from Git is easier than remembering what commands we ran six months ago.

**Key insight:** You don't need to fully embrace "cloud-native" culture to benefit from these practices. We're applying CI/CD concepts selectively to HPC admin tasks, not rewriting everything.

Learning to Operate K8s (Low-Stakes Edition)
---------------------------------------------

**K8s concepts through practice**
  Reading K8s docs is overwhelming. Building actual workflows (even simple ones) makes concepts like pods, services, persistent volumes, and namespaces concrete.

**Troubleshooting skills develop gradually**
  Early on, every error was mysterious. Over time, we learned to read logs, understand pod lifecycle issues, and diagnose common problems.

**Mistakes are learning opportunities**
  When we misconfigure something, production isn't affected. We can take time to understand what went wrong, experiment with fixes, and document solutions.

**"Throw it away and rebuild" is valid**
  Several times we couldn't figure out a K8s problem. Rebuilding from scratch (1-2 hours) taught us more than hours of troubleshooting. This only works because K8s isn't mission-critical.

**Unexpected benefit:** Team members who were K8s-hesitant became more comfortable through low-pressure exposure. "It's just for builds, not critical" reduced anxiety about making changes.

Learning What Goes Wrong and How to Avoid It
---------------------------------------------

**Testing catches stupid mistakes**
  Forgetting to install a package, breaking a symlink, or misconfiguring a path - automated tests catch these immediately. We learned that even basic tests have value.

**Failures teach you your system**
  When a build workflow fails, we learned about dependencies we didn't know existed, OS behaviors we hadn't considered, or environmental assumptions we made.

**Documentation emerges from troubleshooting**
  Each failure that we solved became documentation. The test suite became a knowledge base of "things that broke and how we detected them."

**Systematic prevention**
  Instead of "remember to check X," we write a test for X. Instead of "don't forget to configure Y," we add Y to the automated setup. Manual checklists become automated checks.

Incidental Benefits We Noticed
-------------------------------

While learning, we also noticed some operational improvements:

**More frequent updates**
  Because automated testing reduces uncertainty, we're more willing to update software regularly rather than delaying updates out of caution.

**Parallel builds help**
  For repetitive tasks (building software with multiple compilers), parallelization across K8s nodes does save time, though setup overhead is significant.

**Test-driven development for infrastructure**
  Writing tests for infrastructure (can this image boot? do compilers work?) feels similar to unit testing code. It's a mindset shift for HPC admins used to manual validation.

**Shared build logs**
  Automatically capturing and organizing build logs in one place (rather than scattered terminal sessions) helps when debugging or reviewing what happened.

**Reality check:** These aren't dramatic transformations. They're incremental improvements that accumulate over time. The real value is in building operational muscle memory and institutional knowledge.


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

**Bottom line:** If you're interested in learning modern DevOps practices, can tolerate some experimentation, and can spare a few nodes, this approach provides a low-risk way to gain valuable experience. If you need immediate productivity gains or have no tolerance for learning curves, this may not be the right time.


Real-World Applications
=======================

To see this approach in action, we've documented two detailed case studies:

.. toctree::
   :maxdepth: 1

   case-study-pxe-images
   case-study-spack-stack

These case studies show the messy reality of implementing automation - what works, what's challenging, and what we learned along the way.


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
