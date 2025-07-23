output "vm_public_ip" {
  description = "Dirección IP pública de la VM MySQL"
  value       = azurerm_public_ip.public_ip.ip_address
}
