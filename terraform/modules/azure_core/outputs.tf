output "vm_public_ip" {
  description = "MySQL VM public IP address"
  value       = azurerm_public_ip.public_ip.ip_address
}
