resource "azurerm_resource_group" "devops_rg" {
  name     = var.resource_group_name
  location = var.location
}

// Define the Azure Virtual Network that will be used by the Web VM and App VM.
resource "azurerm_virtual_network" "devopsrg_vnet" {
  name                = "devopsrg-vnet"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  address_space       = ["10.0.0.0/16"]
}

// Define the Azure Subnet for the VM.
resource "azurerm_subnet" "devopsrg_subnet" {
  name                 = "devopsrg-subnet"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devopsrg_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "devopsrg_Web_PIP" {
  name                = "devopsrg-web-pip"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "devopsrg_Web_NIC" {
  name                = "devopsrg-web-nic"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devopsrg_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devopsrg_Web_PIP.id
  }
}

// Define the Azure Virtual Machine resources for the Web VM.
resource "azurerm_virtual_machine" "devopsrg_Web_VM" {
  name                  = "devopsrg-web-vm"
  location              = azurerm_resource_group.devops_rg.location
  resource_group_name   = azurerm_resource_group.devops_rg.name
  network_interface_ids = [azurerm_network_interface.devopsrg_Web_NIC.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "web-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  delete_os_disk_on_termination = true  # Ensure OS disk is deleted when the VM is destroyed
  os_profile {
    computer_name  = "devopsrg-web-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on = [azurerm_public_ip.devopsrg_Web_PIP]
}


