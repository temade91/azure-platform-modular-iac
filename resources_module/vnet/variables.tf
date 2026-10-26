variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vm_subnet_prefix" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "tags" {
  type        = map(string)
  default     = {}
}