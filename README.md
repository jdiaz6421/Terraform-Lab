# Azure Terraform Lab

Terraform project for deploying a small Windows-based Azure environment using reusable modules.

The environment includes segmented networking, a Windows Server VM, Azure Key Vault, managed identity, Log Analytics, Azure Monitor, and GitHub Actions validation.

## Architecture

```text
Azure Subscription
└── Resource Group
    ├── Virtual Network
    │   ├── Compute Subnet + NSG
    │   │   └── Windows Server 2022 VM
    │   │       ├── Private NIC / Private IP
    │   │       ├── System-assigned Managed Identity
    │   │       ├── Secure Boot + vTPM
    │   │       └── Azure Monitor Agent
    │   └── Management Subnet + NSG
    │       └── Reserved for management services
    ├── Azure Key Vault
    │   └── VM identity -> Key Vault Secrets User
    └── Monitoring
        ├── Log Analytics Workspace
        ├── Data Collection Rule
        ├── DCR Association
        ├── Action Group
        └── High CPU Metric Alert
```

## Repository Layout

```text
azure-terraform-lab/
├── README.md
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── security/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/
    └── workflows/
        └── terraform.yml
```

## Prerequisites

- Terraform 1.8 or newer
- Azure CLI
- Azure subscription
- Permissions to create Azure resources and RBAC assignments

Authenticate before deployment:

```bash
az login
az account set --subscription "<subscription-id>"
```

## Configuration

Copy the variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the subscription ID, location, network ranges, and other values as needed.

Do not store the VM administrator password in source control. Set it with an environment variable instead.

PowerShell:

```powershell
$env:TF_VAR_admin_password = "Use-A-Strong-Unique-Password!"
```

Bash:

```bash
export TF_VAR_admin_password='Use-A-Strong-Unique-Password!'
```

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Review the plan before applying changes.

## Destroy

Remove the environment when it is no longer needed:

```bash
terraform destroy
```

Key Vault purge protection is enabled, so Azure may retain the deleted vault according to its configured retention period.

## Networking

The networking module creates separate compute and management subnets.

The Windows VM is deployed without a public IP address. RDP access requires a private route such as VPN, VNet peering, a jump host, or Azure Bastion.

The compute subnet NSG restricts TCP/3389 to the configured trusted CIDR.

## Compute

The compute module deploys a Windows Server 2022 Azure VM with:

- Private NIC
- Standard SSD OS disk
- System-assigned managed identity
- Secure Boot
- vTPM
- Host encryption
- Automatic Windows updates
- Boot diagnostics

## Key Vault

The security module creates an Azure Key Vault using Azure RBAC.

The VM managed identity is assigned the `Key Vault Secrets User` role at the Key Vault scope.

No Azure service principal credentials are stored on the VM.

## Monitoring

The monitoring module creates:

- Log Analytics Workspace
- Azure Monitor Agent
- Data Collection Rule
- DCR association
- Azure Monitor Action Group
- High CPU metric alert

The Data Collection Rule sends selected Windows event logs and guest performance counters to Log Analytics.

```text
Windows VM
   ↓
Azure Monitor Agent
   ↓
Data Collection Rule
   ↓
Log Analytics Workspace
```

The CPU alert uses the Azure VM platform metric and triggers when average CPU exceeds the configured threshold.

## Terraform State

Local state is used by default.

Terraform state files and local variable files are excluded from Git through `.gitignore`.

For shared or automated deployments, a remote Azure Storage backend can be configured separately.

Example:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "<storage-account-name>"
    container_name       = "tfstate"
    key                  = "azure-terraform-lab.tfstate"
  }
}
```

## GitHub Actions

The workflow in `.github/workflows/terraform.yml` runs Terraform checks on pushes and pull requests to `main`.

It runs:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The workflow does not run `terraform apply` or authenticate to Azure.

## Notes

- The management subnet is reserved for future management services such as Azure Bastion.
- Key Vault public network access is enabled for this lab.
- The VM does not have a public IP.
- `terraform.tfvars` and Terraform state files should not be committed.
- Azure resources created by this project may generate charges.
