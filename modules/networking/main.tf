# ============================================================
# Networking Module
# ============================================================
# Builds the network boundary used by the lab. The module separates
# compute and management traffic and applies NSGs at the subnet level.

# Main virtual network for the deployment.
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet used by workload VMs.
resource "azurerm_subnet" "compute" {
  name                 = "snet-compute"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.compute_subnet_prefixes
}

# Reserved management subnet. A future branch can place Bastion or
# other management tooling here without mixing it with workloads.
resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.management_subnet_prefixes
}

# Compute NSG permits RDP only from an explicitly trusted CIDR.
resource "azurerm_network_security_group" "compute" {
  name                = "nsg-${var.name_prefix}-compute"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "Allow-RDP-From-Trusted-CIDR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_rdp_cidr
    destination_address_prefix = "*"
  }

  # Explicitly deny unsolicited Internet-originated inbound traffic.
  # Azure NSGs are stateful, so response traffic to permitted outbound
  # connections is still handled automatically.
  security_rule {
    name                       = "Deny-Internet-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Management subnet has its own NSG so controls can evolve separately
# from the workload subnet as management services are added.
resource "azurerm_network_security_group" "management" {
  name                = "nsg-${var.name_prefix}-management"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Associate each NSG with its corresponding subnet.
resource "azurerm_subnet_network_security_group_association" "compute" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.compute.id
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}
