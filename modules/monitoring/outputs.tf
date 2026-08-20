# Outputs expose important monitoring resources for troubleshooting,
# future modules, and root-level deployment information.
output "log_analytics_workspace_id" {
  description = "Azure resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "data_collection_rule_id" {
  description = "Azure resource ID of the Windows telemetry DCR."
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "action_group_id" {
  description = "Azure resource ID of the alert Action Group."
  value       = azurerm_monitor_action_group.this.id
}
