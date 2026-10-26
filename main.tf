resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# 1. Dedicated Shared Virtual Network Module
module "network" {
  source              = "./resources_module/vnet"
  vnet_name           = "vnet-${var.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# 2. AKS Cluster Module
module "aks" {
  source              = "./resources_module/aks"
  cluster_name        = var.cluster_name
  dns_prefix          = "${var.cluster_name}-dns"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  node_vm_size        = var.node_vm_size
  vnet_subnet_id      = module.network.aks_subnet_id
  tags                = var.tags
}

# 3. Virtual Machine Module
module "vm" {
  source              = "./resources_module/vm"
  vm_name             = "vm-${var.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.vm_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.vm_size
  tags                = var.tags
}