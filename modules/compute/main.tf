# ============================================================
# Compute Module
# ============================================================
# Deploys a Windows Server VM using a private NIC and a system-assigned
# managed identity. No public IP resource is created by this module.

# Private network interface attached to the compute subnet.
resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name_prefix}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows Server 2022 Azure Edition VM with modern security controls.
resource "azurerm_windows_virtual_machine" "this" {
  name                = "vm-${var.name_prefix}-01"
  computer_name       = "TFWIN01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  # Guest agent enables Azure VM extensions such as Azure Monitor Agent.
  provision_vm_agent = true

  # Let Windows manage OS updates for this lab VM.
  enable_automatic_updates = true
  patch_mode               = "AutomaticByOS"

  # Trusted Launch controls improve protection against boot-level attacks.
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Encrypt temporary/cache data at the host layer when supported.
  encryption_at_host_enabled = true

  os_disk {
    name                 = "osdisk-${var.name_prefix}-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Managed boot diagnostics avoids creating a separate storage account.
  boot_diagnostics {}

  # The system-assigned identity is later granted Key Vault access with
  # Azure RBAC from the root module.
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
