output "public_ip" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.devopsrg_Web_PIP.ip_address
}