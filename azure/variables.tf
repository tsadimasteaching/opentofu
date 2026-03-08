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