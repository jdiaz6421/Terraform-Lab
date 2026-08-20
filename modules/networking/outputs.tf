# Module outputs let other modules consume networking resources
# without duplicating lookup logic or hardcoding Azure resource IDs.
output "virtual_network_id" {
  description = "Azure resource ID of the VNet."
  value       = azurerm_virtual_network.this.id
}

output "compute_subnet_id" {
  description = "Subnet ID used by the compute module."
  value       = azurerm_subnet.compute.id
}

output "management_subnet_id" {
  description = "Reserved management subnet ID."
  value       = azurerm_subnet.management.id
}

output "compute_nsg_id" {
  description = "NSG protecting the compute subnet."
  value       = azurerm_network_security_group.compute.id
}
