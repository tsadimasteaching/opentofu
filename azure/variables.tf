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