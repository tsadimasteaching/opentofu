variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for the provider and resources."
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The GCP zone for the compute instance."
  type        = string
  default     = "europe-west4-b"
}

variable "machine_type" {
  description = "The machine type for the compute instance."
  type        = string
  default     = "e2-standard-2"
}

variable "instance_name" {
  description = "The name of the compute instance."
  type        = string
  default     = "my-vm"
}

variable "ssh_user" {
  description = "The Linux username used for SSH access and injected via instance metadata."
  type        = string
}

variable "credentials" {
  description = "Path to the GCP service account JSON key file."
  type        = string
}
