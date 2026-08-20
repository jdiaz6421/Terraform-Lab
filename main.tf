# ============================================================
# Root Module
# ============================================================
# This file acts as the orchestration layer for the project.
# It creates the shared resource group and connects the reusable
# networking, security, compute, and monitoring modules together.

locals {
  # Consistent naming keeps related Azure resources easy to identify.
  name_prefix = "${var.project_name}-${var.environment}"

  # Merge caller-supplied tags with tags that should exist on every
  # supported resource. Values here override duplicate keys in var.tags.
  common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed_by  = "Terraform"
  })
}

# Shared resource group for all resources in this lab deployment.
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# ------------------------------------------------------------
# Networking
# ------------------------------------------------------------
# Creates the VNet, compute/management subnets, and NSGs.
# The compute subnet ID is passed directly into the compute module,
# creating an implicit Terraform dependency between the modules.
module "networking" {
  source = "./modules/networking"

  name_prefix                = local.name_prefix
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  address_space              = var.address_space
  compute_subnet_prefixes    = var.compute_subnet_prefixes
  management_subnet_prefixes = var.management_subnet_prefixes
  allowed_rdp_cidr           = var.allowed_rdp_cidr
  tags                       = local.common_tags
}

# ------------------------------------------------------------
# Security
# ------------------------------------------------------------
# Creates an RBAC-enabled Azure Key Vault. The VM is granted access
# later through its system-assigned managed identity; no service
# principal secret needs to be stored on the VM.
module "security" {
  source = "./modules/security"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

# ------------------------------------------------------------
# Compute
# ------------------------------------------------------------
# Creates a private Windows Server VM and NIC. No public IP is
# provisioned by design. Administrative access should come from a
# trusted private path such as VPN, peering, or a future Bastion host.
module "compute" {
  source = "./modules/compute"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.networking.compute_subnet_id
  vm_size             = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  tags                 = local.common_tags
}

# ------------------------------------------------------------
# Key Vault RBAC
# ------------------------------------------------------------
# Connects the VM's managed identity to Key Vault using Azure RBAC.
# "Key Vault Secrets User" allows the workload to read secret values
# without embedding Azure credentials in scripts or configuration.
resource "azurerm_role_assignment" "vm_key_vault_secrets_user" {
  scope                = module.security.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.compute.principal_id
}

# ------------------------------------------------------------
# Monitoring
# ------------------------------------------------------------
# Creates Log Analytics, Azure Monitor alerting, Azure Monitor Agent,
# and a Data Collection Rule association for the Windows VM.
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  virtual_machine_id  = module.compute.virtual_machine_id
  tags                = local.common_tags
}
