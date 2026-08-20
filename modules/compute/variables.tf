# Inputs required by the compute module.
variable "name_prefix" {
  description = "Prefix used to name compute resources."
  type        = string
}

variable "location" {
  description = "Azure region inherited from the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where compute resources are created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the VM NIC will be attached."
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU."
  type        = string
}

variable "admin_username" {
  description = "Local administrator username."
  type        = string
}

variable "admin_password" {
  description = "Sensitive local administrator password passed from the root module."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common Azure tags passed down from the root module."
  type        = map(string)
}
