variable "location" {
  description = "Azure region for the resource group and AKS cluster."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group that will contain the AKS cluster."
  type        = string
  default     = "rg-aks-demo"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-demo"
}

variable "node_vm_size" {
  description = "Azure VM size for the default AKS node pool."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster."
  type        = string
  default     = "aks-demo-dns"
}

variable "node_count" {
  description = "Number of worker nodes in the default node pool."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to the AKS cluster."
  type        = map(string)
  default     = {}
}

variable "vnet_subnet_id" {
  type        = string
  description = "The ID of the Subnet where the AKS default node pool should run"
  default     = null
}

