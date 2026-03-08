// Define the variables that will be used by the Web VM, App VM, and SQL Server resources.

// ── Scenario toggles ──────────────────────────────────────────────────────────

variable "deploy_vm" {
  description = "Set to true to deploy the Linux VM scenario (main.tf)."
  type        = bool
  default     = true
}

variable "deploy_webapp" {
  description = "Set to true to deploy the Spring Boot CaaS + PostgreSQL scenario (webapp.tf)."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created."
  type        = string
}

variable "vm_size" {
  description = "The size of the Virtual Machines."
  type        = string
}

variable "sub_id" {
  description = "The subscription ID for the Azure account."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key for VM access"
  type        = string
}

variable "email" {
  description = "Email address for the Azure account."
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the Virtual Network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "The name of the Subnet."
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix of the Subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_ip_name" {
  description = "The name of the Public IP address."
  type        = string
}

variable "nsg_name" {
  description = "The name of the Network Security Group."
  type        = string
}

variable "nic_name" {
  description = "The name of the Network Interface."
  type        = string
}

variable "vm_name" {
  description = "The name of the Virtual Machine."
  type        = string
}

variable "os_disk_name" {
  description = "The name of the OS disk."
  type        = string
}

// ── CaaS / App Service variables ─────────────────────────────────────────────

variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "app_service_plan_sku" {
  description = "The SKU of the App Service Plan (e.g. F1, B1, B2, P1v3)."
  type        = string
  default     = "B1"
}

variable "webapp_name" {
  description = "The globally unique name of the Linux Web App."
  type        = string
}

variable "container_image" {
  description = "Docker image to deploy, in the form image:tag (e.g. nginx:latest or ghcr.io/user/repo:main)."
  type        = string
}

variable "container_registry_url" {
  description = "URL of the container registry (e.g. https://index.docker.io for Docker Hub, https://ghcr.io for GHCR)."
  type        = string
  default     = "https://index.docker.io"
}

variable "container_registry_username" {
  description = "Username for the container registry. Leave empty for public images."
  type        = string
  default     = ""
}

variable "container_registry_password" {
  description = "Password or token for the container registry. Leave empty for public images."
  type        = string
  sensitive   = true
  default     = ""
}

variable "container_port" {
  description = "The port the container listens on (mapped via WEBSITES_PORT). Spring Boot default is 8080."
  type        = number
  default     = 8080
}

// ── PostgreSQL variables ──────────────────────────────────────────────────────

variable "postgres_server_name" {
  description = "The name of the PostgreSQL Flexible Server (must be globally unique in Azure)."
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "SKU of the PostgreSQL Flexible Server (e.g. B_Standard_B1ms, GP_Standard_D2s_v3)."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_db_name" {
  description = "The name of the application database to create on the server."
  type        = string
}

variable "postgres_admin_user" {
  description = "Administrator username for PostgreSQL."
  type        = string
}

variable "postgres_admin_password" {
  description = "Administrator password for PostgreSQL."
  type        = string
  sensitive   = true
}