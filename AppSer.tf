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

variable "app_service_name_prefix1" {
  default = "my-prod-env"
  description = "The beginning part of your App Service host name"
}

variable "app_service_name_prefix2" {
  default = "my-dev-env"
  description = "The beginning part of your App Service host name"
}

resource "random_integer" "app_service_name_suffix" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "prodenv" {
  name     = "prod"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "prodenv" {
  name                = "prod-appserviceplan"
  location            = azurerm_resource_group.prodenv.location
  resource_group_name = azurerm_resource_group.prodenv.name
  os_type             = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
 }
}

resource "azurerm_app_service" "prod" {
  name                = "${var.app_service_name_prefix1}-prod-${random_integer.app_service_name_suffix.result}"
  location            = azurerm_resource_group.prodenv.location
  resource_group_name = azurerm_resource_group.prodenv.name
  app_service_plan_id = azurerm_app_service_plan.prodenv.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}




resource "azurerm_resource_group" "devenv" {
  name     = "dev"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "devenv" {
  name                = "dev-appserviceplan"
  location            = azurerm_resource_group.devenv.location
  resource_group_name = azurerm_resource_group.devenv.name
  os_type             = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
 }
}

resource "azurerm_app_service" "dev" {
  name                = "${var.app_service_name_prefix2}-dev-${random_integer.app_service_name_suffix.result}"
  location            = azurerm_resource_group.devenv.location
  resource_group_name = azurerm_resource_group.devenv.name
  app_service_plan_id = azurerm_app_service_plan.devenv.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
