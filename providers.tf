# ============================================================
# Terraform and Provider Requirements
# ============================================================
# Pin provider versions for consistent deployments.

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

# AzureRM authenticates using the developer/CI identity available in
# the environment. The subscription is supplied as an input variable.
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}
