terraform {
  required_version = ">= 1.5.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}