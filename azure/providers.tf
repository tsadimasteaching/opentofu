terraform {
  required_version = "~> 1.11.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}


// Define the Azure Resource Group that will be used by all resources in our configuration.
provider "azurerm" {
  features {}
  subscription_id = var.sub_id
}