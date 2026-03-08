// Spring Boot CaaS + Managed PostgreSQL
// Deploys a Spring Boot image from GHCR (public) as an Azure Linux Web App,
// backed by an Azure Database for PostgreSQL Flexible Server.
//
// Namespaces required:
//   Microsoft.Web              – App Service Plan + Web App
//   Microsoft.DBforPostgreSQL  – PostgreSQL Flexible Server
//
// NOTE: Microsoft.DBforPostgreSQL is NOT available on Azure for Students
// subscriptions. Use a Pay-As-You-Go or MSDN subscription for this scenario.

// ── App Service Plan ─────────────────────────────────────────────────────────

resource "azurerm_service_plan" "webapp_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
  lifecycle { enabled = var.deploy_webapp }
}

// ── PostgreSQL Flexible Server ───────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.postgres_server_name
  location               = azurerm_resource_group.devops_rg.location
  resource_group_name    = azurerm_resource_group.devops_rg.name
  version                = var.postgres_version
  administrator_login    = var.postgres_admin_user
  administrator_password = var.postgres_admin_password
  sku_name               = var.postgres_sku_name
  storage_mb             = 32768
  backup_retention_days  = 7
  zone                   = "1"
  lifecycle { enabled = var.deploy_webapp }
}

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
  lifecycle { enabled = var.deploy_webapp }
}

// Allow connections from other Azure services (0.0.0.0/0.0.0.0 = Azure internal traffic only)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  lifecycle { enabled = var.deploy_webapp }
}

// ── Spring Boot Web App ──────────────────────────────────────────────────────

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name
  service_plan_id     = azurerm_service_plan.webapp_plan.id
  lifecycle { enabled = var.deploy_webapp }

  site_config {
    application_stack {
      docker_image_name        = var.container_image
      docker_registry_url      = var.container_registry_url
      docker_registry_username = var.container_registry_username != "" ? var.container_registry_username : null
      docker_registry_password = var.container_registry_password != "" ? var.container_registry_password : null
    }
  }

  app_settings = {
    // Container port forwarding
    "WEBSITES_PORT" = tostring(var.container_port)

    // Spring Boot datasource — injected as environment variables,
    // picked up automatically via spring.datasource.* property binding
    "SPRING_DATASOURCE_URL"      = "jdbc:postgresql://${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${var.postgres_db_name}?sslmode=require"
    "SPRING_DATASOURCE_USERNAME" = var.postgres_admin_user
    "SPRING_DATASOURCE_PASSWORD" = var.postgres_admin_password

    // Additional Spring datasource properties
    "SPRING_DATASOURCE_DRIVER_CLASS_NAME" = "org.postgresql.Driver"
  }

  depends_on = [azurerm_postgresql_flexible_server_database.appdb]
}
