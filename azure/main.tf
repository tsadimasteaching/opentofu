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


# Create Network Security Group and rule
resource "azurerm_network_security_group" "ssh_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ssh_sg_association" {
  network_interface_id      = azurerm_network_interface.devopsrg_Web_NIC.id
  network_security_group_id = azurerm_network_security_group.ssh_nsg.id
}


// Define the Azure Virtual Machine resources for the Web VM.
resource "azurerm_linux_virtual_machine" "devopsrg_Web_VM" {
  name                  = "devopsrg-web-vm"
  location              = azurerm_resource_group.devops_rg.location
  resource_group_name   = azurerm_resource_group.devops_rg.name
  network_interface_ids = [azurerm_network_interface.devopsrg_Web_NIC.id]
  size               = var.vm_size
  admin_username      = "azureuser"


  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    name              = "web-os-disk"
    caching           = "ReadWrite"
    # create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  
  depends_on = [azurerm_public_ip.devopsrg_Web_PIP]
}


resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown" {
  virtual_machine_id = azurerm_linux_virtual_machine.devopsrg_Web_VM.id
  location           = azurerm_resource_group.devops_rg.location

  daily_recurrence_time = "2200" # 10 PM local time (Athens)
  timezone              = "E. Europe Standard Time" # Athens timezone

  enabled = true

  notification_settings {
    enabled         = false  # Set to true if you want email notifications
    email           = var.email
    time_in_minutes = 30     # Notify 30 minutes before shutdown
  }
}