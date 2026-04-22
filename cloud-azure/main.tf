terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"

  cloud {
    organization = "Aurum-Manufacturing-Group"

    workspaces {
      name = "azure-enterprise-infrastructure"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "AMG-Infrastructure"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-amg-enterprise"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "users" {
  name                 = "subnet-users"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "admin" {
  name                 = "subnet-admin"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "guest" {
  name                 = "subnet-guest"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.50.0/24"]
}

resource "azurerm_subnet" "dmz" {
  name                 = "subnet-dmz"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.60.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.100.0/24"]
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "fw-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                  = "azure-firewall"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  ip_configuration {
    name                    = "fw-config"
    subnet_id               = azurerm_subnet.firewall.id
    public_ip_address_id    = azurerm_public_ip.fw_pip.id
  } 
}

resource "azurerm_route_table" "rt" {
  name                  = "rt-internal"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_route" "default-route" {
  name                    = "route-to-firewall"
  resource_group_name     = azurerm_resource_group.rg.name
  route_table_name        = azurerm_route_table.rt.name
  address_prefix          = "0.0.0.0/0"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "users_assoc" {
  subnet_id                  = azurerm_subnet.users.id
  route_table_id             = azurerm_route_table.rt.id
}

resource "azurerm_subnet_route_table_association" "admin_assoc" {
  subnet_id                  = azurerm_subnet.admin.id
  route_table_id             = azurerm_route_table.rt.id
}

resource "azurerm_subnet_route_table_association" "guest_assoc" {
  subnet_id                  = azurerm_subnet.guest.id
  route_table_id             = azurerm_route_table.rt.id
}

resource "azurerm_subnet_route_table_association" "dmz_assoc" {
  subnet_id                  = azurerm_subnet.dmz.id
  route_table_id             = azurerm_route_table.rt.id
}

resource "azurerm_firewall_network_rule_collection" "allow_internet" {
  name = "allow-internet"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority = 100
  action = "Allow"

  rule{
    name = "allow-all-outbound"
    source_addresses = ["10.0.0.0/16"]

    destination_addresses = ["*"]
    destination_ports = ["80", "443"]
    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "deny_guest_to_internal" {
  name                      = "deny-guest-to-internal"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority = 110
  action = "Deny"

  rule {
    name = "deny-guest-to-vnet"

    source_addresses = ["10.0.50.0/24"]

    destination_addresses = ["10.0.0.0/16"]
    destination_ports = ["*"]
    protocols = ["Any"]
  }
}

resource "azurerm_network_interface" "dmz_nic" {
  name = "dmz-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.dmz.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "guest_nic_win" {
  name = "guest-win-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.guest.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "dc_nic" {
  name = "dc-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.admin.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "dc" {
  name = "amg-dc01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2als_v6"
  admin_username = "azureadadmin"
  admin_password = "Input-password..."

  network_interface_ids = [
    azurerm_network_interface.dc_nic.id
  ]
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter-gensecond"
    version = "latest"
  }
}


resource "azurerm_windows_virtual_machine" "guest" {
  name = "guest-win-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2als_v6"

  admin_username = "windowsguest"
  admin_password = "Input-password..."

  network_interface_ids = [
    azurerm_network_interface.guest_nic_win.id
  
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-datacenter-azure-edition"
    version = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "dmz_vm" {
  name = "dmz-web-server"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2_v3"
  admin_username = "azureadmin"

  network_interface_ids = [
    azurerm_network_interface.dmz_nic.id
  ]
  
  admin_password = "Input-password..."

  disable_password_authentication = false

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
}

resource "azurerm_subnet" "bastion" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.200.0/24"]
}

resource "azurerm_public_ip" "bastion_pip" {
  name = "bastion-pip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = "bastion-host"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "bastion-config"
    subnet_id = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_public_ip" "web_pip" {
  name = "web-public-ip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_firewall_nat_rule_collection" "dmz_nat" {
  name = "dmz-nat"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority = 100
  action = "Dnat"

  rule {
    name  = "web-dnat"

    source_addresses = ["*"]

    destination_addresses = [azurerm_public_ip.fw_pip.ip_address]
    destination_ports = ["80"]

    translated_address = azurerm_network_interface.dmz_nic.private_ip_address
    translated_port = "80"

    protocols = ["TCP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "allow_dmz_http" {
  name = "allow-dmz-http"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority = 120
  action = "Allow"

  rule {
    name = "allow-http"

    source_addresses = ["*"]

    destination_addresses = [
      azurerm_network_interface.dmz_nic.private_ip_address
    ]

    destination_ports = ["80"]
    protocols = ["TCP"]
  }
}

resource "azurerm_log_analytics_workspace" "law" {
  name = "law-amg-enterprise-network"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_diagnostic_setting" "fw_logs" {
  name = "fw-logs"
  target_resource_id = azurerm_firewall.fw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "AzureFirewallNetworkRule"
    enabled = true
  }
  
  log {
    category = "AzureFirewallApplicationRule"
    enabled = true
  }

  log {
    category = "AzureFirewallDnsProxy"
    enabled = true
  }
}


