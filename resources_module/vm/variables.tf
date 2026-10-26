variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the jumpbox VM"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID where the VM NIC will attach"
}

variable "tags" {
  type        = map(string)
  default     = {}
}