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


resource "azurerm_resource_group" "proj" {
  name     = "Intermine_Project"
  location = "West Europe"
}

resource "azurerm_virtual_network" "prodenv" {
  name                = "prod-network"
  address_space       = ["10.0.1.0/16"]
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name
}

resource "azurerm_subnet" "prodenv" {
  name                 = "pinternal"
  resource_group_name  = azurerm_resource_group.proj.name
  virtual_network_name = azurerm_virtual_network.prodenv.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "prodenv" {
  name                = "prod-nic"
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name

  ip_configuration {
    name                          = "pinternal"
    subnet_id                     = azurerm_subnet.prodenv.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "prodenv" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "prodenv" {
  name                = "prod-machine"
  resource_group_name = azurerm_resource_group.proj.name
  location            = azurerm_resource_group.proj.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.prodenv.id,
  ]

   admin_ssh_key {
        username = "azureuser"
        public_key = tls_private_key.prodenv.public_key_openssh 
    }

    tags = {
        environment = "Production"
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


#Dev env
resource "azurerm_virtual_network" "devenv" {
  name                = "prod-network"
  address_space       = ["10.0.3.0/16"]
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name
}

resource "azurerm_subnet" "devenv" {
  name                 = "dinternal"
  resource_group_name  = azurerm_resource_group.proj.name
  virtual_network_name = azurerm_virtual_network.devenv.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_network_interface" "devenv" {
  name                = "dev-nic"
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name

  ip_configuration {
    name                          = "dinternal"
    subnet_id                     = azurerm_subnet.devenv.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "devenv" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "dev" {
  name                = "devd-machine"
  resource_group_name = azurerm_resource_group.proj.name
  location            = azurerm_resource_group.proj.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.devenv.id,
  ]

   admin_ssh_key {
        username = "azureuser"
        public_key = tls_private_key.devenv.public_key_openssh #The magic here
    }

    tags = {
        environment = "Development"
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




