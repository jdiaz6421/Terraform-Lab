# Inputs required by the monitoring module.
variable "name_prefix" {
  description = "Prefix used to name monitoring resources."
  type        = string
}

variable "location" {
  description = "Azure region inherited from the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where monitoring resources are created."
  type        = string
}

variable "virtual_machine_id" {
  description = "Azure resource ID of the VM being monitored."
  type        = string
}

variable "tags" {
  description = "Common Azure tags passed down from the root module."
  type        = map(string)
}
