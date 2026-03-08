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
  project     = "hopeful-seat-418610"
  region      = "europe-west4-b"
}