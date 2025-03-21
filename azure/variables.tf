// Define the variables that will be used by the Web VM, App VM, and SQL Server resources.
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