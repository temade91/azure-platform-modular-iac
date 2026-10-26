variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "cluster_name" {
  type        = string
  description = "The name of the AKS cluster"
}

variable "node_vm_size" {
  type        = string
  description = "The VM size for the worker nodes"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the jumpbox VM"
}
variable "admin_username" {
  type        = string
  default     = "azureuser"
}
variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
}

