K8s in HPC/AI
=============

HPC communities are increasingly adopting containerization and microservices architectures to enhance application deployment, scalability, and management.

There are approaches that fully integrate K8s with HPC workload managers, but they often add complexity and overhead.

Our approach is less aggressive, focusing on leveraging K8s for DevOps automation without interfering with existing HPC/AI workloads. Even with traditional HPC/AI workload managers like SLURM, having K8s alongside can provide substantial benefits.

K8s as Admin DevOps Tool
------------------------

Low risk approach to introduce K8s into existing HPC/AI clusters while extracting benefits.

- Exploit K8s strength in DevOps automation

  - CI/CD pipelines
  - Containerized build/test environments
  - Self-contained auxiliary services (e.g. container registry)

- "Do no harm" to existing HPC/AI workloads

  - By designed only coupled via shared storage and network

- Adopt K8s only for non-urgent DevOps tasks

  - OS Image Build / Testing
  - Software Build / Testing

- Not to worry disaster recovery

  - No user data / workload
  - No critical services
  - 4-stage stateless, scripted recovery within hours

    - Reinstall Minimal OS
    - OS preparation script
    - Ansible-playbook bootstrap RKE2
    - Helm charts deploy all services

Actual Benefits
^^^^^^^^^^^^^^^

- Confidence in deployment

  - Building / unit testing software for next-iteration of OS image / software modules without touching production environment.
  - Containerized build / test environments ensure reproducible results
  - Much more unit tests can be performed automatically than manual approach

- Saving Man-hours

  - Compile and installs are slow
  - K8s workflow automatically run compile/test automatically in the background, and record all build logs
  - Define once, run many times

- Improved workflow

  - Allows GPU software compile on non-GPU K8s nodes, as long as an image with GPU driver is available.

Who should NOT use K8s
^^^^^^^^^^^^^^^^^^^^^^

- Cannot spare any nodes for K8s
- Running handful of HPC applications only (e.g. Specialized CFD/Weather cluster)
- No DevOps automation needs
- Automation does not justify the added complexity
- Does not have the technical expertise to minimally operate K8s

Our K8s Deployment
------------------

K8s are deployed on dedicated nodes within the existing cluster sharing the same high-speed interconnect and storage systems, defining read-only/read-writable persistent volumes to shared software storage volume.

The integration allows K8s to directly access the same software ecosystem, storage, and networking infrastructure as the SLURM-managed workloads, ensuring consistency and performance.

The lifecycle of K8s is managed independently, not from PXE, as these nodes are generally stateful, and requires different configurations.

The following example make heavy use of ansible for automation, but the concepts can be applied using other tools.

Prepare K8s Nodes
^^^^^^^^^^^^^^^^^

We start with minimal standard RHEL 9.4 installation from virtual media to avoid any dependencies on PXE, at least for K8s master nodes.

.. code-block:: bash

    #!/bin/bash
    # prepare-node.sh - Run as root
    # Usage: bash prepare-node.sh <node_name> [ssh_keys_source_path]

    set -euo pipefail
    # ... Implementation please refer to source file ...

    # Main execution
    rootprep::main() {
        # Parse arguments
        local input_node_name="${1:-}"
        SYSADMIN_SSH_KEY_PATH="${2:-$DEFAULT_SYSADMIN_SSH_KEY_PATH}"
        
        # Pre-flight checks
        rootprep::prereq::check_root
        rootprep::prereq::check_run_once
        
        # Validate input
        if [ -z "$input_node_name" ]; then
            rootprep::utils::usage
        fi
        
        # Validate and calculate
        rootprep::utils::validate "$input_node_name"
        
        # Check network configuration
        rootprep::prereq::check_network_interface
        
        # Confirm with user
        rootprep::utils::confirm
        
        # Execute preparation steps (continue even if some fail)
        set -x
        rootprep::check_disk_partitions || true
        rootprep::check_disable_swap || true
        rootprep::disable_selinux || true
        rootprep::set_hostname || true
        rootprep::setup_user || true
        rootprep::setup_sudo || true
        rootprep::setup_ssh_keys || true
        rootprep::check_python || true
        rootprep::test_ssh || true
        rootprep::test_sudo || true
        set +x
        rootprep::summary 
    }

    # Run main function
    rootprep::main "$@"

Deploy Rancher RKE2
^^^^^^^^^^^^^^^^^^^

Here is an example ansible playbook to deploy RKE2 cluster with 3 master nodes.

You may disable firewalld or whitelist all required ports for RKE2 operation.

.. code-block:: yaml

    - become: true
      gather_facts: true
      hosts: all
      name: Configure All Cluster Nodes
      roles:
        - baseline
      tasks:
        - ansible.builtin.debug:
            msg: "Configured {{ inventory_hostname }} ({{ ansible_host }})"
          name: Display host information
    - become: true
      gather_facts: true
      hosts: k8s-master1
      name: Bootstrap RKE2 on First Master
      roles:
        - rke2_bootstrap
      tasks:
        - ansible.builtin.debug:
            msg: "Bootstrapped RKE2 on {{ inventory_hostname }} with token: {{ rke2_token }}"
          name: Display bootstrap information
    - become: true
      gather_facts: true
      hosts: k8s-master2,k8s-master3
      name: Join Additional Masters to RKE2 Cluster
      roles:
        - rke2_join
      tasks:
        - ansible.builtin.debug:
            msg: "Joined {{ inventory_hostname }} to RKE2 cluster"
          name: Display join information
      vars:
        rke2_bootstrap_host: "{{ hostvars['k8s-master1']['net40_ip'] }}"
        rke2_token: "{{ hostvars['k8s-master1']['rke2_token'] }}"

RKE Config for First Master
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml
    
    ---
    # RKE2 Server Configuration for Bootstrap Node
    write-kubeconfig-mode: "0644"

    # Network configuration
    cluster-cidr: "{{ cluster_cidr | default('10.140.0.0/16') }}"
    service-cidr: "{{ service_cidr | default('10.144.0.0/16') }}"

    # TLS SANs for the API server
    tls-san:
      - "{{ ansible_host }}"
      - "{{ net40_ip }}"
      - "{{ net44_ip }}"
    {% if additional_tls_san is defined %}
    {% for san in additional_tls_san %}
      - "{{ san }}"
    {% endfor %}
    {% endif %}

RKE2 Config for Additional Masters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

    ---
    # RKE2 Server Configuration for Additional Nodes
    write-kubeconfig-mode: "0644"

    # Join the existing cluster
    server: https://{{ rke2_bootstrap_host }}:9345
    token: "{{ rke2_token }}"

    # Network configuration
    cluster-cidr: "{{ cluster_cidr | default('10.140.0.0/16') }}"
    service-cidr: "{{ service_cidr | default('10.144.0.0/16') }}"

    # TLS SANs for the API server
    tls-san:
      - "{{ ansible_host }}"
      - "{{ net40_ip }}"
      - "{{ net44_ip }}"
    {% if additional_tls_san is defined %}
    {% for san in additional_tls_san %}
      - "{{ san }}"
    {% endfor %}
    {% endif %}

Config Kubectl Access
"""""""""""""""""""""

After RKE2 installation, copy kubeconfig from master node to sysadmin user ``~/.kube/config`` for kubectl access.

Note you may need to change the server address in kubeconfig to the API server's reachable IP or DNS name.

Using Helm
^^^^^^^^^^

Here is a simple namespace creation and helm chart.

.. code-block:: yaml

    # charts/hpc4-ust-hk-ns/Chart.yaml 
    apiVersion: v2
    appVersion: "1.0.0"
    description: Shared dev/prod namespaces for HPC4 UST HK projects
    name: hpc4-ust-hk-ns
    type: application
    version: 0.1.0

.. code-block:: yaml

    # cat charts/hpc4-ust-hk-ns/values.yaml 
    commonConfig:
      annotations: {}
      labels:
        managed-by: helm
    environment: dev
    namespaces:
      dev: dev-hpc4-ust-hk
      prod: prod-hpc4-ust-hk
    
.. code-block:: yaml

    # charts/hpc4-ust-hk-ns/templates/namespace.yaml 
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: {{ include "hpc4-ust-hk-ns.targetNamespace" . }}
      labels:
        {{- include "hpc4-ust-hk-ns.labels" . | nindent 4 }}
        environment: {{ .Values.environment }}
        {{- with .Values.commonConfig.labels }}
        {{- toYaml . | nindent 4 }}
        {{- end }}
      {{- with .Values.commonConfig.annotations }}
      annotations:
        {{- toYaml . | nindent 4 }}
      {{- end }}

and one-line installation / upgrade of the chart

.. code-block:: bash

    helm upgrade --install $(RELEASE_NAME) \
      "$(CHARTS_DIR)/$(CHART_NAME)" \
      --set environment="$(ENVIRONMENT)" \
      --namespace "$(TARGET_NAMESPACE)" \
      --wait

Deploy Container Registry
^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to implementation

Deploy Argo Workflow
^^^^^^^^^^^^^^^^^^^^

We simply can create a helm chart to depend on argo/argo-workflows chart, only providing values overrides as needed.

.. code-block:: yaml

    # charts/argo-workflows/Chart.yaml
    apiVersion: v2
    appVersion: "3.7.3"
    dependencies:
      - name: hpc4-ust-hk-ns
        repository: "file://../hpc4-ust-hk-ns"
        version: "^0.1.0"
        condition: deps.namespace.install
      - name: argo-workflows
        version: "0.45.27"
        repository: "https://argoproj.github.io/argo-helm"
        alias: argo
    description: Argo Workflows wrapper chart with HPC4 configuration
    name: argo-workflows-hpc4
    type: application
    version: 0.1.0

Deploy Dev Namespace and PV/PVC
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Refer to implementation and K8s doc on concept of Persistent Volume and Persistent Volume Claim.

Get Started with Workflows
^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploy your first workflow following the Argo Workflows documentation. A workflow template looks like this

.. code-block:: yaml

    # charts/workflow-spack-tests/templates/workflow-spack-tests-main.yaml  
    ---
    apiVersion: argoproj.io/v1alpha1
    kind: WorkflowTemplate
    metadata:
      name: {{ include "workflow-spack-tests.fullname" . }}-{{ .Values.workflowConfig.name }}
      namespace: {{ include "workflow-spack-tests.targetNamespace" . }}
      labels:
        {{- include "workflow-spack-tests.labels" . | nindent 4 }}
    spec:
      entrypoint: {{ .Values.workflowConfig.name }}
      serviceAccountName: {{ .Values.workflowConfig.serviceAccountName }}
      
      templates:
      # Main entry point for all spack tests
      - name: {{ .Values.workflowConfig.name }}
        inputs:
          parameters:
          - name: image-tag
            default: "latest"
        steps:
        - - name: compiler-tests
            template: {{ .Values.test.spackCompilerTests.name }}
            arguments:
              parameters:
              - name: image-tag
                value: "{{`{{inputs.parameters.image-tag}}`}}"
          - name: mpi-compiler-tests
            template: {{ .Values.test.spackMpiCompilerTests.name }}
            arguments:
              parameters:
              - name: image-tag
                value: "{{`{{inputs.parameters.image-tag}}`}}"
          - name: runtime-tests
            template: {{ .Values.test.spackRuntimeTests.name }}
            arguments:
              parameters:
              - name: image-tag
                value: "{{`{{inputs.parameters.image-tag}}`}}"
      # ...

``kubectl forward -n <namespace> svc/argo-server 2746:2746`` to access the web UI.
