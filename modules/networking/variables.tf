# Inputs required by the networking module. Keeping these explicit
# makes the module reusable from different root configurations.
variable "name_prefix" {
  description = "Prefix used to name networking resources."
  type        = string
}

variable "location" {
  description = "Azure region inherited from the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where networking resources are created."
  type        = string
}

variable "address_space" {
  description = "CIDR blocks assigned to the VNet."
  type        = list(string)
}

variable "compute_subnet_prefixes" {
  description = "CIDR blocks assigned to the compute subnet."
  type        = list(string)
}

variable "management_subnet_prefixes" {
  description = "CIDR blocks assigned to the reserved management subnet."
  type        = list(string)
}

variable "allowed_rdp_cidr" {
  description = "Trusted source CIDR permitted to reach TCP/3389."
  type        = string
}

variable "tags" {
  description = "Common Azure tags passed down from the root module."
  type        = map(string)
}
