terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"  # Use the latest stable version
    }
  }
}

provider "google" {
  project     = "hopeful-seat-418610"
  region      = "europe-west4-b"
}