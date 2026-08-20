# These outputs allow the root and monitoring modules to reference the
# VM without performing separate Azure data-source lookups.
output "virtual_machine_id" {
  description = "Azure resource ID of the Windows VM."
  value       = azurerm_windows_virtual_machine.this.id
}

output "virtual_machine_name" {
  description = "Azure name of the Windows VM."
  value       = azurerm_windows_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP assigned to the VM NIC."
  value       = azurerm_network_interface.this.private_ip_address
}

output "principal_id" {
  description = "Object ID of the VM system-assigned managed identity."
  value       = azurerm_windows_virtual_machine.this.identity[0].principal_id
}
