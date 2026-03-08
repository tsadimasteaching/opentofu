output "public_ip" {
  description = "The public IP address of the VM (empty when deploy_vm = false)"
  value       = var.deploy_vm ? azurerm_public_ip.devopsrg_Web_PIP.ip_address : null
}

output "webapp_url" {
  description = "The default HTTPS URL of the Spring Boot Web App (empty when deploy_webapp = false)"
  value       = var.deploy_webapp ? "https://${azurerm_linux_web_app.webapp.default_hostname}" : null
}

output "postgres_fqdn" {
  description = "The FQDN of the PostgreSQL server (empty when deploy_webapp = false)"
  value       = var.deploy_webapp ? azurerm_postgresql_flexible_server.postgres.fqdn : null
}

output "postgres_connection_string" {
  description = "JDBC connection string for the application database (empty when deploy_webapp = false)"
  value       = var.deploy_webapp ? "jdbc:postgresql://${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${var.postgres_db_name}?sslmode=require" : null
}