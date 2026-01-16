===================================================
Getting Started: K8s Deployment from Bare Metal
===================================================

This guide provides comprehensive deployment instructions for establishing a Kubernetes cluster using Rancher RKE2 in HPC environments, covering the complete workflow from bare metal OS installation through deploying your first Argo Workflow.

**Expected duration:** 1-2 days for initial deployment (including familiarization)

**Prerequisites:**

- 3-5 dedicated nodes for K8s cluster
- Linux system administration proficiency
- Familiarity with SSH and command-line tools
- Access to shared storage infrastructure (NFS or equivalent)
- Organizational support for experimental infrastructure

**What this guide covers:**

1. Node preparation
2. RKE2 installation and bootstrap
3. Kubectl configuration
4. Helm basics
5. Persistent storage setup
6. Supporting infrastructure (Git and container registry)
7. Argo Workflows deployment
8. First workflow example

**Out of scope:**

- Networking configuration (assumes functional network infrastructure)
- Storage provisioning (assumes existing shared storage)
- Firewall configuration (environment-specific requirements)
- Production-grade security hardening (optimized for experimental environments)


Architecture Overview
=====================

Before proceeding with installation, understanding the target architecture is essential:

.. code-block:: text

    HPC Environment
    ├── Production Cluster (SLURM nodes)
    │   ├── Uses: Shared storage at /opt/shared, /data
    │   └── Connection: High-speed interconnect
    │
    └── K8s Cluster (Dedicated nodes)
        ├── Master nodes (3): Control plane, etcd
        ├── Worker nodes (optional): Additional compute capacity
        ├── Uses: Same shared storage (read-write for builds)
        ├── Connection: Same high-speed network
        └── Purpose: CI/CD workflows, not production workloads

**Key principles:**

- K8s nodes share storage with production (for artifact delivery)
- K8s nodes on same network (can access production resources)
- K8s lifecycle is independent (not managed via PXE like compute nodes)
- K8s cluster is "disposable" (can rebuild from Git in ~2 hours)


Step 1: Prepare K8s Nodes
==========================

Install Minimal OS
------------------

The deployment begins with a minimal RHEL 9 (or Rocky Linux 9) installation:

**Rationale for manual installation over PXE:**

- K8s nodes maintain persistent state across reboots
- K8s configuration requirements differ from compute nodes
- Independent recovery path simplifies disaster recovery procedures

**Installation steps:**

1. Boot from installation media (USB or virtual media)
2. Choose "Minimal Install" (no GUI needed)
3. Configure network (static IP recommended)
4. Set root password
5. Complete installation and reboot

**Example configuration:** This guide uses 3 nodes configured as K8s masters:

- k8s-master1: 192.168.40.11
- k8s-master2: 192.168.40.12
- k8s-master3: 192.168.40.13

Node Preparation Script
-----------------------

Following OS installation, each node requires preparation for Kubernetes operation. The following script demonstrates the conceptual workflow (adapt to environment-specific requirements):

.. code-block:: bash

    #!/bin/bash
    # prepare-node.sh - Run as root on each K8s node
    # Usage: bash prepare-node.sh <node_name>

    set -euo pipefail

    NODE_NAME="${1:?Node name required}"

    echo "Preparing node: $NODE_NAME"

    # 1. Set hostname
    hostnamectl set-hostname "$NODE_NAME"

    # 2. Disable swap (required for K8s)
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab

    # 3. Disable SELinux (or set to permissive for learning)
    setenforce 0
    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

    # 4. Configure firewall
    # Option A: Disable for simplicity (learning environment)
    systemctl disable --now firewalld
    
    # Option B: Open required ports (production-like)
    # firewall-cmd --permanent --add-port=6443/tcp  # K8s API
    # firewall-cmd --permanent --add-port=2379-2380/tcp  # etcd
    # firewall-cmd --permanent --add-port=10250/tcp  # kubelet
    # ... (see RKE2 documentation for complete list)
    # firewall-cmd --reload

    # 5. Create admin user (not root)
    useradd -m -s /bin/bash sysadmin
    usermod -aG wheel sysadmin  # sudo access

    # 6. Configure sudo (no password for wheel group - optional for convenience)
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

    # 7. Set up SSH keys for passwordless access
    mkdir -p /home/sysadmin/.ssh
    cat >> /home/sysadmin/.ssh/authorized_keys << 'EOF'
    ssh-rsa AAAAB3Nza... your-public-key-here
    EOF
    chmod 700 /home/sysadmin/.ssh
    chmod 600 /home/sysadmin/.ssh/authorized_keys
    chown -R sysadmin:sysadmin /home/sysadmin/.ssh

    # 8. Install Python (for Ansible)
    dnf install -y python3 python3-pip

    # 9. Test SSH access
    echo "Testing SSH..."
    su - sysadmin -c "ssh-keyscan -H $NODE_NAME >> ~/.ssh/known_hosts"

    echo "Node $NODE_NAME prepared successfully"
    echo "Test with: ssh sysadmin@$NODE_NAME"

**Run on each node:**

.. code-block:: bash

    # On k8s-master1
    sudo bash prepare-node.sh k8s-master1

    # On k8s-master2  
    sudo bash prepare-node.sh k8s-master2

    # On k8s-master3
    sudo bash prepare-node.sh k8s-master3

**Verify preparation:**

From your admin workstation:

.. code-block:: bash

    # Should connect without password
    ssh sysadmin@k8s-master1 'hostname'
    ssh sysadmin@k8s-master2 'hostname'
    ssh sysadmin@k8s-master3 'hostname'


Step 2: Deploy RKE2 with Ansible
=================================

Ansible Inventory
-----------------

Create inventory file ``inventory/k8s-cluster.yml``:

.. code-block:: yaml

    all:
      vars:
        ansible_user: sysadmin
        ansible_become: yes
      children:
        k8s_masters:
          hosts:
            k8s-master1:
              ansible_host: 192.168.40.11
              net40_ip: 192.168.40.11
              net44_ip: 192.168.44.11  # Additional network if available
            k8s-master2:
              ansible_host: 192.168.40.12
              net40_ip: 192.168.40.12
              net44_ip: 192.168.44.12
            k8s-master3:
              ansible_host: 192.168.40.13
              net40_ip: 192.168.40.13
              net44_ip: 192.168.44.13

RKE2 Deployment Playbook
-------------------------

Create ``playbooks/deploy-rke2.yml``:

.. code-block:: yaml

    ---
    - name: Configure All Cluster Nodes
      hosts: k8s_masters
      become: true
      gather_facts: true
      roles:
        - baseline  # Basic system configuration
      tasks:
        - name: Display host information
          ansible.builtin.debug:
            msg: "Configured {{ inventory_hostname }} ({{ ansible_host }})"

    - name: Bootstrap RKE2 on First Master
      hosts: k8s-master1
      become: true
      gather_facts: true
      roles:
        - rke2_bootstrap
      tasks:
        - name: Display bootstrap information
          ansible.builtin.debug:
            msg: "Bootstrapped RKE2 on {{ inventory_hostname }} with token: {{ rke2_token }}"

    - name: Join Additional Masters to RKE2 Cluster
      hosts: k8s-master2,k8s-master3
      become: true
      gather_facts: true
      roles:
        - rke2_join
      vars:
        rke2_bootstrap_host: "{{ hostvars['k8s-master1']['net40_ip'] }}"
        rke2_token: "{{ hostvars['k8s-master1']['rke2_token'] }}"
      tasks:
        - name: Display join information
          ansible.builtin.debug:
            msg: "Joined {{ inventory_hostname }} to RKE2 cluster"

RKE2 Configuration Files
-------------------------

**For the first master** (``roles/rke2_bootstrap/templates/config.yaml.j2``):

.. code-block:: yaml

    ---
    # RKE2 Server Configuration for Bootstrap Node
    write-kubeconfig-mode: "0644"

    # Network configuration
    cluster-cidr: "10.140.0.0/16"
    service-cidr: "10.144.0.0/16"

    # TLS SANs for the API server (all IPs that might access API)
    tls-san:
      - "{{ ansible_host }}"
      - "{{ net40_ip }}"
      - "{{ net44_ip }}"
      - "k8s-api.example.com"  # DNS name if you have one

**For additional masters** (``roles/rke2_join/templates/config.yaml.j2``):

.. code-block:: yaml

    ---
    # RKE2 Server Configuration for Additional Nodes
    write-kubeconfig-mode: "0644"

    # Join the existing cluster
    server: https://{{ rke2_bootstrap_host }}:9345
    token: "{{ rke2_token }}"

    # Network configuration (must match bootstrap)
    cluster-cidr: "10.140.0.0/16"
    service-cidr: "10.144.0.0/16"

    # TLS SANs for this node
    tls-san:
      - "{{ ansible_host }}"
      - "{{ net40_ip }}"
      - "{{ net44_ip }}"

Ansible Role: Bootstrap First Master
-------------------------------------

Simplified ``roles/rke2_bootstrap/tasks/main.yml``:

.. code-block:: yaml

    ---
    - name: Install RKE2
      ansible.builtin.shell: |
        curl -sfL https://get.rke2.io | sh -
      args:
        creates: /usr/local/bin/rke2

    - name: Create RKE2 config directory
      ansible.builtin.file:
        path: /etc/rancher/rke2
        state: directory
        mode: '0755'

    - name: Deploy RKE2 config file
      ansible.builtin.template:
        src: config.yaml.j2
        dest: /etc/rancher/rke2/config.yaml
        mode: '0600'

    - name: Enable and start RKE2 service
      ansible.builtin.systemd:
        name: rke2-server
        enabled: yes
        state: started

    - name: Wait for RKE2 to be ready
      ansible.builtin.wait_for:
        path: /etc/rancher/rke2/rke2.yaml
        timeout: 300

    - name: Read RKE2 token
      ansible.builtin.slurp:
        src: /var/lib/rancher/rke2/server/node-token
      register: token_file

    - name: Set RKE2 token fact
      ansible.builtin.set_fact:
        rke2_token: "{{ token_file.content | b64decode | trim }}"

    - name: Display token
      ansible.builtin.debug:
        msg: "RKE2 token: {{ rke2_token }}"

Ansible Role: Join Additional Masters
--------------------------------------

Simplified ``roles/rke2_join/tasks/main.yml``:

.. code-block:: yaml

    ---
    - name: Install RKE2
      ansible.builtin.shell: |
        curl -sfL https://get.rke2.io | sh -
      args:
        creates: /usr/local/bin/rke2

    - name: Create RKE2 config directory
      ansible.builtin.file:
        path: /etc/rancher/rke2
        state: directory
        mode: '0755'

    - name: Deploy RKE2 config file
      ansible.builtin.template:
        src: config.yaml.j2
        dest: /etc/rancher/rke2/config.yaml
        mode: '0600'

    - name: Enable and start RKE2 service
      ansible.builtin.systemd:
        name: rke2-server
        enabled: yes
        state: started

    - name: Wait for node to join cluster
      ansible.builtin.wait_for:
        path: /etc/rancher/rke2/rke2.yaml
        timeout: 300

Run the Deployment
------------------

.. code-block:: bash

    # Execute from your administration workstation
    ansible-playbook -i inventory/k8s-cluster.yml playbooks/deploy-rke2.yml

**Expected deployment sequence:**

- First master initializes RKE2 and generates cluster token
- Additional masters join using distributed token
- All nodes establish control plane membership
- Complete deployment typically requires 10-15 minutes

**Verify deployment:**

Validate cluster status from the first master:

.. code-block:: bash

    ssh sysadmin@k8s-master1
    sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes

    # Expected output:
    # NAME           STATUS   ROLES                       AGE   VERSION
    # k8s-master1    Ready    control-plane,etcd,master   5m    v1.28.x
    # k8s-master2    Ready    control-plane,etcd,master   3m    v1.28.x
    # k8s-master3    Ready    control-plane,etcd,master   2m    v1.28.x


Step 3: Configure Kubectl Access
=================================

Copy Kubeconfig
---------------

Transfer cluster credentials from the first master to your workstation:

.. code-block:: bash

    # Execute on your workstation
    mkdir -p ~/.kube
    scp sysadmin@k8s-master1:/etc/rancher/rke2/rke2.yaml ~/.kube/config

    # Critical: Update the server address
    # Change from: server: https://127.0.0.1:6443
    # Change to: server: https://k8s-master1:6443
    # Or use IP: server: https://192.168.40.11:6443
    sed -i 's/127.0.0.1/k8s-master1/g' ~/.kube/config

    # Validate connectivity
    kubectl get nodes

**Install kubectl** (if not already installed):

.. code-block:: bash

    # Linux
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # macOS
    brew install kubectl

Verify Cluster Access
----------------------

.. code-block:: bash

    kubectl cluster-info
    kubectl get pods -A  # Display all system pods

    # Expected: Active pods in kube-system and rke2-* namespaces


Step 4: Install and Use Helm
=============================

Install Helm
------------

.. code-block:: bash

    # Install Helm 3
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Verify
    helm version

Create Your First Helm Chart
-----------------------------

Example namespace chart implementation:

.. code-block:: bash

    mkdir -p charts/hpc4-namespaces
    cd charts/hpc4-namespaces

**Chart.yaml:**

.. code-block:: yaml

    apiVersion: v2
    name: hpc4-namespaces
    description: Shared dev/prod namespaces for HPC4 projects
    type: application
    version: 0.1.0
    appVersion: "1.0.0"

**values.yaml:**

.. code-block:: yaml

    environment: dev  # dev or prod
    
    namespaces:
      dev: dev-hpc4
      prod: prod-hpc4
    
    commonConfig:
      labels:
        managed-by: helm
      annotations: {}

**templates/namespace.yaml:**

.. code-block:: yaml

    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: {{ index .Values.namespaces .Values.environment }}
      labels:
        environment: {{ .Values.environment }}
        {{- with .Values.commonConfig.labels }}
        {{- toYaml . | nindent 4 }}
        {{- end }}
      {{- with .Values.commonConfig.annotations }}
      annotations:
        {{- toYaml . | nindent 4 }}
      {{- end }}

Install the Chart
-----------------

.. code-block:: bash

    # Install dev namespace
    helm install hpc4-namespaces-dev ./charts/hpc4-namespaces \
      --set environment=dev

    # Verify
    kubectl get namespace dev-hpc4

    # Install prod namespace
    helm install hpc4-namespaces-prod ./charts/hpc4-namespaces \
      --set environment=prod


Step 5: Deploy Persistent Volumes
==================================

Configure Shared Storage Access
--------------------------------

K8s needs to access shared storage for:

- Build artifacts (output)
- Source code (input)
- Software stacks (output)
- Build logs (output)

**Example PersistentVolume** for NFS:

.. code-block:: yaml

    # pv-shared-software.yaml
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-shared-software
    spec:
      capacity:
        storage: 10Ti
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: nfs-server.example.com
        path: /opt/shared/software

**Example PersistentVolumeClaim:**

.. code-block:: yaml

    # pvc-shared-software.yaml
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-shared-software
      namespace: dev-hpc4
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 10Ti
      storageClassName: ""  # Use default
      volumeName: pv-shared-software

**Apply:**

.. code-block:: bash

    kubectl apply -f pv-shared-software.yaml
    kubectl apply -f pvc-shared-software.yaml

    # Verify
    kubectl get pv
    kubectl get pvc -n dev-hpc4


Step 6: Deploy Supporting Infrastructure
=========================================

Workflow deployment requires two essential infrastructure components:

1. **Git repository** - Version control for configurations, build scripts, and workflow definitions
2. **Container registry** - Image storage for workflow execution containers

Both components are fundamental to GitOps practices and reproducible builds.

Git Repository Options
----------------------

The Git repository serves as version control for:

- Workflow definitions (Argo YAML specifications)
- Build scripts and configuration files
- Spack configurations or customized distributions
- OS image construction recipes
- Ansible automation playbooks
- All artifacts entering the build pipeline

**Option A: Existing Git hosting** (Recommended initial approach)

- Platforms: GitHub, GitLab, Bitbucket (cloud or self-hosted)
- Advantages: Immediate availability, established tooling, comprehensive UI
- Considerations: Requires external connectivity

**Option B: Self-hosted on K8s** (For air-gapped or fully autonomous environments)

Deploy Gitea (lightweight Git service) on K8s:

.. code-block:: bash

    # Add Gitea Helm repo
    helm repo add gitea-charts https://dl.gitea.io/charts/
    helm repo update
    
    # Install Gitea
    helm install gitea gitea-charts/gitea \
      --namespace git \
      --create-namespace \
      --set service.http.type=ClusterIP \
      --set persistence.enabled=true \
      --set persistence.size=50Gi

    # Access via port-forward
    kubectl port-forward -n git svc/gitea-http 3000:3000
    # Open http://localhost:3000

**CRITICAL: Source-of-Truth Architecture for Disposable Infrastructure**

.. warning::

   When deploying Git on K8s (Option B), maintain architectural awareness that the K8s cluster is disposable by design:
   
   - Designate a **cloud Git service as the authoritative source** (GitHub, GitLab)
   - Configure K8s-hosted Git as a **local mirror/cache layer**
   - Establish upstream remote: ``git remote add upstream https://github.com/yourorg/hpc-automation.git``
   - Maintain regular synchronization: ``git push upstream main``
   
   **Rationale:** Cluster rebuilds (an expected operational pattern in this experimental approach) should not result in repository history loss. The K8s Git instance can be rapidly reconstructed and synchronized from the authoritative cloud source.
   
   **Architecture pattern:**
   
   .. code-block:: text
   
       Cloud Git (GitHub/GitLab)  ← Authoritative source
            ↓ synchronization
       K8s Git (Gitea)           ← Local cache (performance optimization)
            ↓ consumption
       Argo Workflows            ← Executes from local instance
   
   This architecture ensures cluster disposability without data loss.

**Recommended repository structure:**

Organize the repository following this hierarchy:

.. code-block:: text

    hpc-automation/
    ├── workflows/           # Argo workflow definitions
    ├── ansible/            # Ansible playbooks
    ├── charts/             # Helm charts
    ├── configs/            # Build configurations
    │   ├── os-images/      # PXE image build scripts
    │   └── spack/          # Spack configs or fork
    └── scripts/            # Utility scripts

Container Registry Options
--------------------------

You need a container registry to store:

- Base build images (OS images with compilers)
- Intermediate build containers
- Workflow step containers
- Custom tool containers

**Option A: Existing registry infrastructure** (Simplest approach)

- Platforms: Docker Hub, GitHub Container Registry (ghcr.io), GitLab Container Registry
- Advantages: Zero setup overhead, proven reliability
- Considerations: External dependency, potential rate limiting

**Option B: Minimal self-hosted registry on K8s** (Basic autonomous operation)

Use official Docker registry for basic needs:

.. code-block:: yaml

    # registry-deployment.yaml
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: registry
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: registry-data
      namespace: registry
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: registry
      namespace: registry
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: registry
      template:
        metadata:
          labels:
            app: registry
        spec:
          containers:
          - name: registry
            image: registry:2
            ports:
            - containerPort: 5000
            volumeMounts:
            - name: registry-data
              mountPath: /var/lib/registry
            env:
            - name: REGISTRY_STORAGE_DELETE_ENABLED
              value: "true"
          volumes:
          - name: registry-data
            persistentVolumeClaim:
              claimName: registry-data
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: registry
      namespace: registry
    spec:
      selector:
        app: registry
      ports:
      - port: 5000
        targetPort: 5000
      type: ClusterIP

**Deploy:**

.. code-block:: bash

    kubectl apply -f registry-deployment.yaml
    
    # Access from nodes (for Docker/Podman)
    # Add to /etc/hosts on each K8s node:
    # <node-ip>  registry.local
    
    # Or use port-forward for testing:
    kubectl port-forward -n registry svc/registry 5000:5000
    
    # Test (from node or with port-forward):
    curl http://localhost:5000/v2/_catalog

**Configure nodes for insecure registry access** (development/testing environments without TLS):

On each K8s node, configure containerd:

.. code-block:: bash

    # /etc/rancher/rke2/registries.yaml
    mirrors:
      registry.local:5000:
        endpoint:
          - "http://registry.local:5000"
    
    configs:
      "registry.local:5000":
        tls:
          insecure_skip_verify: true

    # Restart RKE2
    sudo systemctl restart rke2-server

**Option C: Harbor deployment** (Production-grade registry platform)

Harbor provides enterprise features:

- Vulnerability scanning and security analysis
- Image signing and verification
- Cross-registry replication
- Role-Based Access Control (RBAC)
- Comprehensive management interface

.. code-block:: bash

    # Add Harbor Helm repo
    helm repo add harbor https://helm.goharbor.io
    helm repo update
    
    # Install Harbor (requires significant resources)
    helm install harbor harbor/harbor \
      --namespace harbor \
      --create-namespace \
      --set expose.type=clusterIP \
      --set persistence.enabled=true \
      --set externalURL=https://harbor.local

**Recommendation for experimental environments:** Option A (existing infrastructure) or Option B (minimal self-hosted) provide adequate functionality for initial deployment.

Configure Registry Access in Workflows
---------------------------------------

Once you have a registry, configure Argo workflows to use it:

**Pull images from your registry:**

.. code-block:: yaml

    # In workflow templates
    templates:
    - name: build-step
      container:
        image: registry.local:5000/rhel9-buildtools:latest
        # ... rest of config

**Push images to your registry:**

.. code-block:: yaml

    # Build and push workflow example
    templates:
    - name: build-and-push-image
      container:
        image: gcr.io/kaniko-project/executor:latest
        args:
        - "--dockerfile=/workspace/Dockerfile"
        - "--context=/workspace"
        - "--destination=registry.local:5000/my-image:latest"
        volumeMounts:
        - name: workspace
          mountPath: /workspace

**Create registry credentials secret** (if using authenticated registry):

.. code-block:: bash

    kubectl create secret docker-registry regcred \
      --docker-server=registry.local:5000 \
      --docker-username=admin \
      --docker-password=password \
      --namespace=dev-hpc4

    # Use in workflows
    # spec:
    #   imagePullSecrets:
    #   - name: regcred

GitOps Workflow Pattern
-----------------------

Integrated Git and container registry infrastructure enables the following operational pattern:

.. code-block:: text

    Developer/Admin
         ↓
    1. Push code/config to Git
         ↓
    2. Git webhook triggers Argo Workflow
         ↓
    3. Workflow pulls code from Git
         ↓
    4. Workflow builds container/software
         ↓
    5. Workflow pushes image to Registry
         ↓
    6. Workflow runs tests
         ↓
    7. Workflow deploys artifacts to shared storage
         ↓
    8. Production consumes artifacts from shared storage

**Example: Automated PXE image build workflow**

1. Update OS image config in Git: ``configs/os-images/rhel9-hpc.yaml``
2. Push to Git triggers workflow
3. Workflow clones Git repo
4. Workflow builds PXE image
5. Workflow tests image in container
6. Workflow pushes tested image to shared storage
7. Manual step: Deploy to test nodes

Verification
------------

**Verify Git access:**

.. code-block:: bash

    # Clone your repo (test credentials)
    git clone https://github.com/yourorg/hpc-automation.git
    # Or if using Gitea on K8s:
    git clone http://localhost:3000/youruser/hpc-automation.git

**Verify registry access:**

.. code-block:: bash

    # Test pull
    docker pull registry.local:5000/test-image:latest
    
    # Test push
    docker tag alpine:latest registry.local:5000/test-image:latest
    docker push registry.local:5000/test-image:latest
    
    # List images
    curl http://registry.local:5000/v2/_catalog

**Verify from workflow:**

Create a test workflow that accesses both:

.. code-block:: yaml

    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Workflow
    metadata:
      generateName: test-infrastructure-
      namespace: dev-hpc4
    spec:
      entrypoint: main
      templates:
      - name: main
        steps:
        - - name: test-git
            template: clone-repo
          - name: test-registry
            template: pull-image
      
      - name: clone-repo
        container:
          image: alpine/git:latest
          command: [sh, -c]
          args:
          - |
            git clone https://github.com/yourorg/hpc-automation.git /tmp/repo
            ls -la /tmp/repo
      
      - name: pull-image
        container:
          image: registry.local:5000/test-image:latest
          command: [sh, -c]
          args: ["echo 'Registry access working'"]


Step 7: Deploy Argo Workflows
==============================

Argo Workflows Selection Rationale
-----------------------------------

Argo Workflows provides a Kubernetes-native workflow engine with the following capabilities:

- YAML-based workflow definitions
- Dependency management, parallelization, and retry logic
- Integrated monitoring interface
- Well-suited for CI/CD pipeline orchestration

Install Argo Workflows via Helm
--------------------------------

**Create wrapper chart** (``charts/argo-workflows-hpc4/Chart.yaml``):

.. code-block:: yaml

    apiVersion: v2
    name: argo-workflows-hpc4
    description: Argo Workflows wrapper chart with HPC4 configuration
    type: application
    version: 0.1.0
    appVersion: "3.5.0"
    
    dependencies:
      - name: argo-workflows
        version: "0.41.0"
        repository: "https://argoproj.github.io/argo-helm"
        alias: argo

**values.yaml** (customize Argo):

.. code-block:: yaml

    argo:
      # Use server (not controller only)
      server:
        enabled: true
        serviceType: ClusterIP  # Access via kubectl port-forward
      
      # Workflow controller configuration
      controller:
        workflowNamespaces:
          - dev-hpc4
          - prod-hpc4

**Install:**

.. code-block:: bash

    cd charts/argo-workflows-hpc4
    
    # Add Argo Helm repo
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    
    # Install
    helm install argo-workflows . --namespace argo --create-namespace
    
    # Verify
    kubectl get pods -n argo

Access Argo UI
--------------

.. code-block:: bash

    # Establish port forwarding for local access
    kubectl port-forward -n argo svc/argo-workflows-server 2746:2746
    
    # Navigate to: https://localhost:2746

**Note:** Default installation requires authentication tokens. To disable authentication for development environments (unsuitable for production):

.. code-block:: yaml

    # In values.yaml, add:
    argo:
      server:
        extraArgs:
          - --auth-mode=server


Step 8: Your First Workflow
============================

Basic Workflow Implementation
-----------------------------

Initial validation workflow (``workflows/hello-world.yaml``):

.. code-block:: yaml

    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Workflow
    metadata:
      generateName: hello-world-
      namespace: dev-hpc4
    spec:
      entrypoint: main
      templates:
      - name: main
        steps:
        - - name: hello
            template: print-message
            arguments:
              parameters:
              - name: message
                value: "Hello from K8s!"
      
      - name: print-message
        inputs:
          parameters:
          - name: message
        container:
          image: alpine:latest
          command: [sh, -c]
          args: ["echo '{{inputs.parameters.message}}'"]

**Submit workflow:**

.. code-block:: bash

    # Install Argo CLI (optional but helpful)
    curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.5.0/argo-linux-amd64.gz
    gunzip argo-linux-amd64.gz
    chmod +x argo-linux-amd64
    sudo mv argo-linux-amd64 /usr/local/bin/argo

    # Submit workflow
    argo submit -n dev-hpc4 workflows/hello-world.yaml --watch

    # List workflows
    argo list -n dev-hpc4

    # Get logs
    argo logs -n dev-hpc4 @latest

Workflow with Shared Storage
-----------------------------

Example: Write to shared storage:

.. code-block:: yaml

    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Workflow
    metadata:
      generateName: write-to-shared-storage-
      namespace: dev-hpc4
    spec:
      entrypoint: main
      volumeClaimTemplates:
      - metadata:
          name: workdir
        spec:
          accessModes: [ "ReadWriteMany" ]
          storageClassName: ""
          resources:
            requests:
              storage: 1Gi
          volumeName: pv-shared-software
      
      templates:
      - name: main
        steps:
        - - name: write-file
            template: write
        - - name: read-file
            template: read
      
      - name: write
        container:
          image: alpine:latest
          command: [sh, -c]
          args: 
            - |
              echo "Hello from workflow at $(date)" > /work/hello.txt
              ls -la /work/
          volumeMounts:
          - name: workdir
            mountPath: /work
      
      - name: read
        container:
          image: alpine:latest
          command: [sh, -c]
          args:
            - |
              cat /work/hello.txt
          volumeMounts:
          - name: workdir
            mountPath: /work


Next Steps and Learning Resources
==================================

Deployment Summary
------------------

Successful completion establishes:

- ✅ Operational K8s cluster (3-node control plane configuration)
- ✅ Kubectl access from administration workstation
- ✅ Helm package management
- ✅ Shared storage integration for workflow access
- ✅ Git repository for configuration management
- ✅ Container registry for image storage
- ✅ Argo Workflows for pipeline orchestration
- ✅ Complete build system architecture (source → build → artifact)
- ✅ Validated workflow examples

Continuing Education
--------------------

**Kubernetes fundamentals:**

- Core resources: Pods, Deployments, Services
- Configuration management: ConfigMaps and Secrets
- Resource allocation: requests and limits
- Multi-tenancy: Namespaces and RBAC

**Argo Workflows advancement:**

- Workflow templates for reusability
- DAG and steps execution patterns
- Conditional logic and iteration
- Artifact and parameter management
- Retry strategies and error handling

**HPC-specific integration patterns:**

- End-to-end CI/CD pipeline construction (Git → Build → Test → Deploy)
- Container image lifecycle and versioning strategies
- Build artifact caching and optimization
- HPC scheduler integration (SLURM interoperability)
- Long-running build monitoring and logging
- GitOps patterns for infrastructure management

Recommended Documentation:
--------------------------

- RKE2: https://docs.rke2.io/
- Kubernetes: https://kubernetes.io/docs/
- Helm: https://helm.sh/docs/
- Argo Workflows: https://argoproj.github.io/workflows/
- Our case studies: :doc:`case-study-pxe-images` and :doc:`case-study-spack-stack`

Common Troubleshooting Scenarios
---------------------------------

**Pod initialization failures:**

.. code-block:: bash

    kubectl describe pod <pod-name> -n <namespace>
    kubectl logs <pod-name> -n <namespace>

**Workflow execution stalls:**

.. code-block:: bash

    argo get <workflow-name> -n <namespace>
    argo logs <workflow-name> -n <namespace>

**Kubeconfig access issues:**

- Verify file permissions (typically 600)
- Validate server address in kubeconfig file
- Test connectivity: ``kubectl cluster-info``

**Persistent volume connectivity:**

- Verify NFS mounts on nodes: ``mount | grep nfs``
- Check volume status: ``kubectl get pv,pvc``
- Review system events: ``kubectl get events``

Disposable Infrastructure Recovery
----------------------------------

When encountering intractable issues:

1. Document attempted resolution steps
2. Commit functional configurations to Git repository
3. Execute cluster rebuild (approximately 1-2 hours)
4. Analyze and document the learning experience

This experimental environment explicitly supports learning through iteration.


Conclusion
==========

This guide has established a functional Kubernetes environment suitable for CI/CD workflow experimentation in HPC contexts. The resulting infrastructure is:

- **Experimental**: Optimized for learning rather than production-critical services
- **Disposable**: Reconstructible from version control in approximately 2 hours
- **Isolated**: Architecturally separated from production HPC workloads
- **Operational**: Prepared for workflow development and testing

**Next steps:** Examine our detailed case studies demonstrating real-world applications:

- :doc:`case-study-pxe-images` - Automated OS image construction and validation
- :doc:`case-study-spack-stack` - Hierarchical software stack management and deployment
