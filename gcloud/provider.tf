terraform {
  required_version = "~> 1.11.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.22.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials)
}