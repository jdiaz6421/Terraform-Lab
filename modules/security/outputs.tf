# Export the vault identifiers so the root module can create RBAC
# assignments without coupling this module to a specific workload.
output "key_vault_id" {
  description = "Azure resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Globally unique Key Vault name."
  value       = azurerm_key_vault.this.name
}
