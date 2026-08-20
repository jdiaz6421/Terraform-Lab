# Inputs required by the security module.
variable "name_prefix" {
  description = "Prefix used to derive the Key Vault name."
  type        = string
}

variable "location" {
  description = "Azure region inherited from the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Key Vault is created."
  type        = string
}

variable "tags" {
  description = "Common Azure tags passed down from the root module."
  type        = map(string)
}
