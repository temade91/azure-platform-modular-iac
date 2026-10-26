# Enterprise Azure Infrastructure: Modular AKS, Linux Jumpbox & VNet

A modular, enterprise-ready Infrastructure as Code (IaC) repository provisioning an **Azure Kubernetes Service (AKS)** cluster, an **Ubuntu Linux Jumpbox VM**, and a dedicated **Shared Virtual Network (VNet)** in Azure using HashiCorp Terraform and GitHub Actions.

---

## Architecture Overview

```text
+---------------------------------------------------------------------------------+
|                          Virtual Network (10.0.0.0/16)                          |
|                                                                                 |
|   +----------------------------------+     +----------------------------------+ |
|   |  Subnet: snet-aks                |     |  Subnet: snet-vm                 | |
|   |  CIDR: 10.0.1.0/24               |     |  CIDR: 10.0.2.0/24               | |
|   |                                  |     |                                  | |
|   |  [ AKS Managed Cluster ]         |     |  [ Linux Jumpbox VM ]            | |
|   |  - System Node Pool              |     |  - Ubuntu 22.04 LTS              | |
|   |  - SystemAssigned Managed ID     |     |  - Static Public IP              | |
|   |  - Free SKU Tier                 |     |  - Standard_B1s Burstable Compute| |
|   |  - Subnet Association: snet-aks  |     |  - Subnet Association: snet-vm   | |
|   +----------------------------------+     +----------------------------------+ |
+---------------------------------------------------------------------------------+
```

- **Network Decoupling (`resources_module/vnet`)**: Creates an isolated Virtual Network (`10.0.0.0/16`) carved into two distinct `/24` subnets to segment container infrastructure from administrative virtual machines.
- **AKS Cluster (`resources_module/aks`)**: Deploys an Azure Kubernetes Service cluster configured with Azure AD RBAC, with the system node pool pinned into `snet-aks`.
- **Jumpbox VM (`resources_module/vm`)**: Deploys an administrative Ubuntu 22.04 LTS instance inside `snet-vm` equipped with a dedicated Network Interface (NIC) and static Public IP for bastion access and cluster troubleshooting.
- **Remote State Partitioning**: Uses Azure Blob Storage with dynamic environment isolation keys (`dev/aks.tfstate` and `prod/aks.tfstate`).

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml            # Multi-environment CI/CD deployment pipeline
├── resources_module/
│   ├── vnet/                        # Shared Virtual Network & subnets child module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── aks/                         # Azure Kubernetes Service child module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vm/                          # Linux Jumpbox VM child module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                          # Root orchestrator: instantiates child modules
├── variables.tf                     # Root variable declarations
├── outputs.tf                       # Root outputs (AKS name, VM public IP, etc.)
├── backend.tf                       # Remote backend declaration (partial config)
├── backend-dev.hcl                  # Partial backend config for Dev state
├── backend-prod.hcl                 # Partial backend config for Prod state
├── dev.tfvars.example               # Sanitized input template for Development
├── prod.tfvars.example              # Sanitized input template for Production
├── .gitignore                       # Rules protecting state, secrets, plans, and cache
└── README.md
```

---

## Multi-Environment Strategy

This project leverages partial backend configurations and environment-isolated `.tfvars` to allow seamless multi-environment deployments without code duplication:

| Environment | Backend Config File | State Key in Azure Blob | Variable File | Default Resource Group | Default VM Size |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Dev** | `backend-dev.hcl` | `dev/aks.tfstate` | `dev.tfvars` | `rg-dev` | `Standard_B1s` |
| **Prod** | `backend-prod.hcl` | `prod/aks.tfstate` | `prod.tfvars` | `rg-prod` | `Standard_D2s_v5` |

- **Blast Radius Protection:** State keys are partitioned per environment. Applying changes or destroying development infrastructure cannot corrupt or lock the production state.
- **Dynamic Pipeline Routing:** GitHub Actions maps the selected environment dropdown option to both the target state file and the corresponding variable definitions.

---

## Module Specifications

### `resources_module/vnet`
- **Inputs:** `vnet_name`, `location`, `resource_group_name`, `tags`.
- **Outputs:** `vnet_id`, `aks_subnet_id`, `vm_subnet_id`.

### `resources_module/aks`
- **Inputs:** `cluster_name`, `dns_prefix`, `location`, `resource_group_name`, `node_vm_size`, `vnet_subnet_id`, `tags`.
- **Outputs:** `aks_cluster_name`, `kube_config` (sensitive).

### `resources_module/vm`
- **Inputs:** `vm_name`, `location`, `resource_group_name`, `subnet_id`, `admin_username`, `vm_admin_password` (sensitive), `vm_size`, `tags`.
- **Outputs:** `vm_public_ip`, `vm_private_ip`.

---

## Local Development & Validation

Before committing code or running CI/CD, run local pre-flight checks:

```powershell
# 1. Format code recursively
terraform fmt -recursive

# 2. Re-index module dependencies
terraform get -update

# 3. Initialize backend for Dev
terraform init -backend-config="backend-dev.hcl" -reconfigure

# 4. Validate syntax and argument wiring
terraform validate

# 5. Generate local dry-run execution plan
terraform plan -var-file="dev.tfvars"
```

---

## CI/CD Pipeline Setup (GitHub Actions)

The workflow defined in `.github/workflows/terraform.yml` runs automated linting and validation on Pull Requests, with manual on-demand deployments via `workflow_dispatch`.

### Required GitHub Secrets

Configure the following under **Settings > Secrets and variables > Actions**:

| Secret Name | Description |
| :--- | :--- |
| `AZURE_CLIENT_ID` | Service Principal Application (Client) ID |
| `AZURE_CLIENT_SECRET` | Service Principal Client Secret Key |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription ID |
| `AZURE_TENANT_ID` | Azure Active Directory (Tenant) ID |
| `TF_STATE_RG` | Resource group hosting remote state storage |
| `TF_STATE_STORAGE_ACCOUNT` | Storage account hosting `tfstate` container |
| `VM_ADMIN_PASSWORD` | Administrator password for the Jumpbox VM |

---

## Connecting to Deployed Infrastructure

### SSH into the Jumpbox
```bash
ssh test-admin@<VM_PUBLIC_IP>
```

### Configure kubectl for AKS

Fetch cluster credentials to your local kubeconfig and verify node health:

```bash
az aks get-credentials --resource-group rg-dev --name aks-dev-cluster
kubectl get nodes -o wide
```

---

