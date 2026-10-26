resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet for AKS Cluster Nodes & Pods
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_prefix
}

# Subnet for the VM
resource "azurerm_subnet" "vm_subnet" {
  name                 = "snet-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vm_subnet_prefix
}