#terraform {
 # required_version = "> 0.12.0"
  
provider "azurerm" {
  version = ">=2.0.79"
  features {}
}

variable "app_service_name_prefix" {
  default = "my-prod-env"
  description = "The beginning part of your App Service host name"
}

resource "random_integer" "app_service_name_suffix" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "example" {
  name     = "prod"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "example" {
  name                = "prod-appserviceplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Basic"
    size = "B1"
 }
}

resource "azurerm_app_service" "prod" {
  name                = "${var.app_service_name_prefix}-dev-${random_integer.app_service_name_suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

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
