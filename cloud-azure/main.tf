terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2
    }
  }
  required_version = "~>= 1.1.0"

  cloud { 
    organization = "Aurum-Manufacturing-Group"

    workspaces {
      name = "azure-enterprise-infrastruture"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "AMG-Infrastructure"
  location = "westeurope"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-amg-enterprise"
  location            = azure_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azure_subnet" "users" {
  name                 = "subnet-users"
  resource_group_name  = azure_resoruce_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azure_subnet" "admin" {
  name                 = "subnet-admin"
  resource_group_name  = azure_resoruce_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.20.0/24"]
  
}
resource "azure_subnet" "guest" {
  name                 = "subnet-guest"
  resource_group_name  = azure_resoruce_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.50.0/24"]
}

resource "azure_subnet" "dmz" {
  name                 = "subnet-dmz"
  resource_group_name  = azure_resoruce_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.60.0/24"]
}

resource "azure_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azure_resoruce_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.100.0/24"]
}

  
