
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}