# modules/vm/outputs.tf

output "vm_public_ip" {
  description = "The public IP address of the Linux VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "vm_private_ip" {
  description = "The private IP address of the Linux VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "vm_id" {
  description = "The resource ID of the Linux VM"
  value       = azurerm_linux_virtual_machine.vm.id
}