# Configure the Azure provider
provider "azurerm" {
    features {}
  }

# Define a resource group
resource "azurerm_resource_group" "my_resource_group" {
  name     = "Jayendra-CICD-RG"
  location = "East Asia"
}

# Define a virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "application-VNet"
  address_space       = ["172.17.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define a subnet
resource "azurerm_subnet" "my_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["172.17.1.0/24"]
}

# Define a public IP address
resource "azurerm_public_ip" "my_public_ip" {
  name                = "myPublicIP02"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  allocation_method   = "Dynamic"
}

# Define a network security group (optional)
resource "azurerm_network_security_group" "my_nsg" {
  name                = "myNSG01"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define a network interface
resource "azurerm_network_interface" "my_nic" {
  name                = "myNIC01"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "myNICConfig01"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip.id
  }
}

# Define a virtual machine
resource "azurerm_virtual_machine" "my_vm" {
  name                  = "Server-01"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.my_nic.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "Server-01"
    admin_username = "Jayendra"
    admin_password = "Yatindra@123" # Replace with your desired password
    
  }

  os_profile_windows_config {
    enable_automatic_upgrades   = true
    provision_vm_agent          = true
    

  }
}

# Define a virtual machine extension for Windows VM
resource "azurerm_virtual_machine_extension" "winrm" {
  name                 = "winrm_conn"
  virtual_machine_id   = azurerm_virtual_machine.my_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": ["https://poswerhsellscript.blob.core.windows.net/poswerhsellscript/psremoting.ps1"]
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -File psremoting.ps1 -EnableCredSSP",
      "storageAccountName": "poswerhsellscript",
      "storageAccountKey": "ZX2SZs4U3wg77DJF2OuhqFYh7plD7JeTYdXKcvE/L2KV67ChyLlx4fLIqCXXmSmkcCff2P9J62uS+AStAKU/rw=="
    }
  PROTECTED_SETTINGS
}

