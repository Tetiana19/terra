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
  name     = "Intermine_Project_Prod"
  location = "West Europe"
}

resource "azurerm_virtual_network" "prodenv" {
  name                = "prod-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name
}

resource "azurerm_subnet" "prodenv" {
  name                 = "pinternal"
  resource_group_name  = azurerm_resource_group.proj.name
  virtual_network_name = azurerm_virtual_network.prodenv.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "prodenv" {
  name                = "prodpubip"
  resource_group_name = azurerm_resource_group.proj.name
  location            = azurerm_resource_group.proj.location
  allocation_method   = "Static"
 
 tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "prodSG"
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name

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

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "prodenv" {
  name                = "prod-inter"
  location            = azurerm_resource_group.proj.location
  resource_group_name = azurerm_resource_group.proj.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.prodenv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prodenv.id
  }

  tags = {
    environment = "Production"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.prodenv.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.proj.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "proden" {
  name                     = "prod${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.proj.name
  location                 = azurerm_resource_group.proj.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Production"
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
resource "azurerm_resource_group" "proj1" {
  name     = "Intermine_Project_Dev"
  location = "West Europe"
}

resource "azurerm_virtual_network" "devenv" {
  name                = "dev-network"
  address_space       = ["11.0.0.0/16"]
  location            = azurerm_resource_group.proj1.location
  resource_group_name = azurerm_resource_group.proj1.name
}

resource "azurerm_subnet" "devenv" {
  name                 = "dinternal"
  resource_group_name  = azurerm_resource_group.proj1.name
  virtual_network_name = azurerm_virtual_network.devenv.name
  address_prefixes     = ["11.0.4.0/24"]
}

 
 resource "azurerm_public_ip" "devenv" {
  name                = "devpubip"
  resource_group_name = azurerm_resource_group.proj1.name
  location            = azurerm_resource_group.proj1.location
  allocation_method   = "Static"
  
  tags = {
    environment = "Development"
  }
 }

resource "azurerm_network_security_group" "devenv" {
  name                = "devSG"
  location            = azurerm_resource_group.proj1.location
  resource_group_name = azurerm_resource_group.proj1.name

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

  tags = {
    environment = "Development"
  }
}

resource "azurerm_network_interface" "dev" {
  name                = "dev-inter"
  location            = azurerm_resource_group.proj1.location
  resource_group_name = azurerm_resource_group.proj1.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.devenv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devenv.id
  }

  tags = {
    environment = "Development"
  }
}

resource "azurerm_network_interface_security_group_association" "devenv" {
  network_interface_id      = azurerm_network_interface.dev.id
  network_security_group_id = azurerm_network_security_group.devenv.id
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "devenv" {
  name                     = "dev${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.proj1.name
  location                 = azurerm_resource_group.proj1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Development"
  }
}

resource "tls_private_key" "devenv" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "devenv" {
  name                = "dev-machine"
  resource_group_name = azurerm_resource_group.proj1.name
  location            = azurerm_resource_group.proj1.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.dev.id,
  ]

   admin_ssh_key {
        username = "azureuser"
        public_key = tls_private_key.devenv.public_key_openssh 
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





