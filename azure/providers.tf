terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}


// Define the Azure Resource Group that will be used by all resources in our configuration.
provider "azurerm" {
  features {}
  subscription_id = "954b35e0-374a-4ad9-9b6a-c56889734a6a"
}