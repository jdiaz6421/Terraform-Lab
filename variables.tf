# ============================================================
# Root Input Variables
# ============================================================

variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Short project name used in Azure resource names."
  type        = string
  default     = "tf-lab"

  # Restrict the value so Azure resource names stay simple.
  validation {
    condition     = can(regex("^[a-z0-9-]{2,18}$", var.project_name))
    error_message = "project_name must be 2-18 characters using lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
  default     = "dev"

  # A controlled environment list prevents inconsistent naming such
  # as dev/development/nonprod across deployments.
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for the lab."
  type        = string
  default     = "eastus"
}

variable "address_space" {
  description = "CIDR range for the virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "compute_subnet_prefixes" {
  description = "CIDR range for the compute subnet."
  type        = list(string)
  default     = ["10.20.10.0/24"]
}

variable "management_subnet_prefixes" {
  description = "CIDR range reserved for management services such as a future Azure Bastion deployment."
  type        = list(string)
  default     = ["10.20.20.0/24"]
}

variable "allowed_rdp_cidr" {
  description = "Source CIDR allowed to reach TCP/3389. Use a trusted private range or tightly scoped source."
  type        = string
  default     = "10.0.0.0/8"
}

variable "vm_size" {
  description = "Azure VM size. B-series keeps the lab relatively inexpensive."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Local administrator username for the Windows lab VM."
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Local administrator password. Supply via TF_VAR_admin_password; never commit it."
  type        = string
  sensitive   = true

  # organizational password policy and avoid long-lived local secrets.
  validation {
    condition     = length(var.admin_password) >= 14
    error_message = "admin_password must be at least 14 characters."
  }
}

variable "tags" {
  description = "Additional tags applied to supported Azure resources."
  type        = map(string)

  default = {
    owner   = "lab"
    purpose = "terraform-lab"
  }
}
