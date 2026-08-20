# ============================================================
# Root Outputs
# ============================================================
# Outputs expose useful deployment results without requiring a user
# to inspect the Terraform state file directly.

output "resource_group_name" {
  description = "Resource group created by the lab."
  value       = azurerm_resource_group.this.name
}

output "virtual_network_id" {
  description = "ID of the lab virtual network."
  value       = module.networking.virtual_network_id
}

output "compute_subnet_id" {
  description = "ID of the compute subnet containing the VM NIC."
  value       = module.networking.compute_subnet_id
}

output "virtual_machine_id" {
  description = "Azure resource ID of the Windows lab VM."
  value       = module.compute.virtual_machine_id
}

output "virtual_machine_private_ip" {
  description = "Private IPv4 address assigned to the Windows VM."
  value       = module.compute.private_ip_address
}

output "key_vault_name" {
  description = "Name of the RBAC-enabled Key Vault."
  value       = module.security.key_vault_name
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace receiving VM telemetry."
  value       = module.monitoring.log_analytics_workspace_name
}

output "data_collection_rule_id" {
  description = "ID of the Azure Monitor Data Collection Rule associated with the VM."
  value       = module.monitoring.data_collection_rule_id
}
