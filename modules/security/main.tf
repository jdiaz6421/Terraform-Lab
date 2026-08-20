# ============================================================
# Security Module
# ============================================================
# Creates an Azure Key Vault configured for Azure RBAC. Access is
# assigned outside this module so callers can decide which workload
# identities should receive which roles.

data "azurerm_client_config" "current" {}

locals {
  # Key Vault names must be globally unique. A short deterministic hash
  # of the subscription ID lowers the chance of a naming collision while
  # keeping repeated deployments in the same subscription predictable.
  vault_suffix = substr(md5(data.azurerm_client_config.current.subscription_id), 0, 6)

  # Keep enough room for the hyphen and six-character suffix while
  # respecting Azure Key Vault's 24-character name limit.
  vault_base = substr(replace("kv-${var.name_prefix}", "_", "-"), 0, 17)
}

resource "azurerm_key_vault" "this" {
  name                = "${local.vault_base}-${local.vault_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # RBAC authorization avoids maintaining legacy Key Vault access
  # policies and lets Azure roles govern data-plane permissions.
  enable_rbac_authorization = true

  # Recovery protections reduce the risk of accidental permanent loss.
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  
  # Public network access enabled for lab deployment.
  public_network_access_enabled = true

  tags = var.tags
}
