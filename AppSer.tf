#terraform {
 # required_version = "> 0.12.0"
  
#provider "azurerm" {
#  version = ">=2.0.79"
#  features {}
#}
terraform {
  required_providers {
    azurerm = {
     source  = "hashicorp/azurerm"
    version = ">=2.0.79"
    }
   }
  }

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

 subscription_id = "16acbe7c-85aa-4236-af7b-3583b1869ee7"
  client_id       = "6e4b4e8e-c7dc-40ab-a7c0-0e823507f5cd"
  client_secret   = "VITN4WwZMLOwBWjaJ-kRaJNrupWEDXC3BZ"
  tenant_id       = "b41b72d0-4e9f-4c26-8a69-f949f367c91d"
}


resource "azurerm_resource_group" "prodenv" {
  name     = "prod"
  location = "West Europe"
}

resource "azurerm_virtual_network" "prodenv" {
  name                = "prod-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.prodenv.location
  resource_group_name = azurerm_resource_group.prodenv.name
}

resource "azurerm_subnet" "prodenv" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.prodenv.name
  virtual_network_name = azurerm_virtual_network.prodenv.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "prodenv" {
  name                = "prod-nic"
  location            = azurerm_resource_group.prodenv.location
  resource_group_name = azurerm_resource_group.prodenv.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prodenv.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "prodenv" {
  name                = "prod-machine"
  resource_group_name = azurerm_resource_group.prodenv.name
  location            = azurerm_resource_group.prodenv.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.prodenv.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


